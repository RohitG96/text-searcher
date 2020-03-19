module Expression
    class SqlParser < BaseParser
        def or_parser(val1, val2)
            {
                bool:{
                    should: [
                        val1, val2
                    ]
                }
            }
          end
        
          def and_parser(val1, val2)
            {
                bool:{
                    must: [
                        val1, val2
                    ]
                }
            }
          end
        
          def content_parser(val)
            {
                match:{
                   "#{}": val
                }
             }
          end

    end
end