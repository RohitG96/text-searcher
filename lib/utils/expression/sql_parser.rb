module Expression
    class SqlParser < BaseParser
        def or_parser(val1, val2)
            "(#{val1} OR #{val2})"
          end
        
          def and_parser(val1, val2)
            "(#{val1} AND #{val2})"
          end
        
          def content_parser(val)
            "content ILIKE '%#{val}%'"
          end

    end
end