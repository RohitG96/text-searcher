# frozen_string_literal: true

module Elastic
  class BasePushService
    def initialize(query: {}, opts: {})
      @query = query || {}
      @opts = opts || {}
    end

    attr_reader :query, :opts

    def es_primary_key
      :id
    end

    def push
      out = source_query.where(query).limit(limit)
      raw_sql = out.select(select_columns).to_sql.squish
      conn = source_model.connection_pool.checkout
      db_conn = conn.raw_connection
      db_conn.send_query(raw_sql)
      db_conn.set_single_row_mode
      queue = []
      db_conn.get_result.stream_each do |row|
        queue << row
        next unless queue.size >= batch_size

        sync_batch(queue.pop(queue.size), {})
      end
      sync_batch(queue.pop(queue.size), {})
      source_model.connection_pool.checkin(conn)
    rescue StandardError => e
      ::Rollbar.error(e) if ::Rails.env.production?
      raise(e) if ::Rails.env.development?

      errors.add(:base, "Failed due to ERR:#{e.message}")
      false
    ensure
      source_model.connection_pool.checkin(source_model.connection)
    end

    def task_id
      @task_id ||= opts[:task_id] || SecureRandom.uuid
    end

    def sync_batch(batch, meta={})
      return true if batch.empty?
      ::ElasticPushJob.perform_now(task_id, index_name, docs_for(batch, meta))
      true
    end


    def batch_size
      opts[:batch_size] || 1000
    end

    def limit
      opts[:limit] || 10
    end

    def index_name
      index_suffix.to_s
    end

    def index_suffix
      "applicant"
    end

    def source_model
      # raise "#{__method__} Not implemented"
      Applicant
    end

    def source_query
      source_model
    end

    def docs_for(batch, meta)
      batch.map do |row|
        es_json_for(row, meta).as_json
      end
    end

    def pluck_columns
      column_mapping.keys.map(&:squish)
    end

    def target_columns
      column_mapping.values
    end

    def select_columns
      column_mapping.map { |k, v| Arel.sql("#{k.gsub("AS #{v}", '')} AS #{v}") }
    end

    def columns
      source_model.column_names
    end

    def column_mapping
      columns.zip(columns).to_h.merge('extract(epoch from updated_at) AS t' => 't').with_indifferent_access
    end

    def es_json_for(row, meta = {})
      pk = es_primary_key.to_sym
      out = row.merge(meta).symbolize_keys

      {
        index: {
          _id: out[pk],
          data: out.reject { |_, v| v.nil? || v.is_a?(String) && v.blank? || v == '{}' }
        }
      }
    end
  end
end
