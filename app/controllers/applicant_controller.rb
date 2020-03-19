# frozen_string_literal: true

class TncsController < ApplicationController

    def fetch
        serv = ApplicantFetchService(params)
        if serv.fetch
            render json: serv.result, status: :ok
        else
            render json: {error:serv.errors}, status: :bad_request
        end    
    end

end
