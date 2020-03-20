# frozen_string_literal: true

class ApplicantController < ApplicationController

    def fetch
        serv = ::ApplicantFetchService.new(params)
        if serv.fetch
            render json: serv.result, status: :ok
        else
            render json: {error:serv.errors}, status: :bad_request
        end    
    end

end
