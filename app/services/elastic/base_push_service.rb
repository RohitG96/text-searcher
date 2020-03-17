# frozen_string_literal: true

module Elastic
  class BasePushService
    def initialize(query: {}, opts: {})
      @query = query || {}
      @opts = opts || {}
    end

    def fetch; end

    def batch_size
      opts[:batch_size] || 1000
    end

    def limit
      opts[:limit]
    end

    def index_name
      index_suffix.to_s
      end

    def index_suffix
      raise "#{__method__} Not implemented"
    end

    def source_model
      raise "#{__method__} Not implemented"
    end

    def source_query
        source_model
    end

    def associations
        []
    end
    
    def docs_for(batch, meta)
        association_jsons = associations.map {|resource| [resource, resource_for(resource, resource_ids_for(resource, batch))] }.to_h
        batch.map {|row|
            associations_data = associations.map {|resource| [resource, association_jsons[resource][row["#{resource}_id"]] || {}] }.to_h
            es_json_for(row, meta.merge(associations_data)).as_json
        }
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

    def es_json_for(row, meta={})
        pk = es_primary_key.to_sym
        out = row.merge(meta).symbolize_keys
  
        {
          index: {
            _id:  out[pk],
            data: out.reject {|_, v| v.nil? || v.is_a?(String) && v.blank? || v == "{}" }
          }
        }
    end
  end
end
