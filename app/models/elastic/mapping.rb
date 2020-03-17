# frozen_string_literal: true

module Elastic
  class Mapping
    def self.applicant
      {
        properties: {
          email: { type: 'text' },
          id: { type: 'long' },
          text: { type: 'text' },
          created_at: { type: 'text' },
          updated_at: { type: 'text' },
          t: {type: "long"}
        }
      }
    end
  end
end
