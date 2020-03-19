class ApplicantFetchService
    def initialize(params)
        @query = params[:query]
        @type = params[:type] || "sql"
        @field = params[:field] || "text"
        @limit = params[:limit] || 10000
        @offset = params[:offset] || 0
    end

    attr_accessor :query, :type, :field, :limit, :offset, :result, :error

    def parser
        @parser ||=  "Expression::#{type.capitalize}Parser".constantize.new(query, field)
    end  
    
    def validate
        parser.valid?
    end

    def fetch
        begin
            validate && set_result
            true
        rescue StandardError => e
            @error = e.full_message
            byebug
            false    
        end
    end

    def set_result
        @result ||= decorate
    end

    def fetch_applicants
        Applicant.where(parser.dsl).offset(offset).limit(limit).to_a
    end

    def applicants
        @applicants ||= fetch_applicants
    end

    def decorate()
        hash = []
        applicants.each do |x|
            hash << x.as_json
        end
        {applicants: hash}
    end
end