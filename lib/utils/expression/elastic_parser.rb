# frozen_string_literal: false

module Expression
  class ElasticParser < BaseParser
    def or_parser(val1, val2)
      {
        bool: {
          should: [
            val1, val2
          ]
        }
      }.with_indifferent_access
      end

    def and_parser(val1, val2)
      {
        bool: {
          must: [
            val1, val2
          ]
        }
      }.with_indifferent_access
      end

    def content_parser(val)
      {
        match: {
          "#{field_name}": val
        }
      }.with_indifferent_access
      end
  end
end
