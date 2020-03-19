# frozen_string_literal: true

class Applicant < ApplicationRecord
  searchkick batch_size: 200
end
