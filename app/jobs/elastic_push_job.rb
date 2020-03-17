# frozen_string_literal: true

class ElasticPushJob < ApplicationJob
  queue_as :elastic

  def perform(task_id, index, data) # rubocop:disable Metrics/AbcSize
    out = HAPPY_SEARCH.bulk(index: index, body: data)
    verified_ids = data.map do |rec|
      rec['index']['_id'] if rec['index']['data']['verified']
    end .compact
    errors = []
    resource = index.sub(/#{es_env}\_/, '')
    success = out['items'].count do |val|
      errors << val['index']['error'] if val['index']['error'].present?
      val['index']['error'].blank?
    end
    if errors.present?
      Rails.logger.error("ELASTIC_ERROR #{task_id} #{index} #{errors}")
    end
  end

  def core_resources
    %w[products partners lenders]
  end
end
