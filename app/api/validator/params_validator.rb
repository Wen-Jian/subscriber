module Api::Validator::ParamsValidator
    class ParamsValidator
        def initializer(params)
            @params = params
        end
        def valid
            @params.each do |key, val|
                if val.blank?
                    raise "#{key} can not be blank"
                end
            end
        end
    end
end