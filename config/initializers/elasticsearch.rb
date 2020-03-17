# frozen_string_literal: true

HAPPY_SEARCH = Elasticsearch::Client.new(url: 'http://localhost:9200', port: 9200, transport_options: { request: { timeout: 1000 } })

def delete_index(index_suffix)
  return true unless HAPPY_SEARCH.indices.exists?(index: index_suffix.to_s)

  out = HAPPY_SEARCH.indices.delete(index: index_suffix.to_s)
  return true if out['errors'].blank?

  Rails.logger.error("Failed to delete elastic index for #{index_suffix} #{out}")
  false
rescue StandardError => e
  raise(e) if ::Rails.env.development?

  Rails.logger.error("Failed to delete elastic index for #{index_suffix} #{e.message}")
  false
end

def create_index(index_suffix)
  return true if HAPPY_SEARCH.indices.exists?(index: index_suffix.to_s)

  out = HAPPY_SEARCH.indices.create(index: index_suffix.to_s, body: { mappings: ::Elastic::Mapping.method(index_suffix).call })
  return true if out['errors'].blank?

  Rails.logger.error("Failed to create elastic index for #{index_suffix} #{out}")
  false
rescue StandardError => e
  raise(e) if ::Rails.env.development?

  Rails.logger.error("Failed to create elastic index for #{index_suffix} #{e.message}")
  false
end
