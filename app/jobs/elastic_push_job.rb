# frozen_string_literal: true

class ElasticPushJob < ApplicationJob
  queue_as :elastic

  def perform(task_id, index, data) # rubocop:disable Metrics/AbcSize
    out = HAPPY_SEARCH.bulk(index: index, body: data)
    errors = []
    success = out['items'].count do |val|
      errors << val['index']['error'] if val['index']['error'].present?
      val['index']['error'].blank?
    end
    puts("ELASTIC_SUCCESS #{task_id} #{index} #{success}")
    puts("ELASTIC_ERROR #{task_id} #{index} #{errors}") if errors.present?
  end
end
