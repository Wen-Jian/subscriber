module Api::Validator::ParamsValidator
    class ParamsValidator
        def initialize(params)
            @params = params
        end
        def valid
            @params.each do |key, val|
                if val.blank?
                    raise "#{key} can not be blank"
                elsif key =~ /.*_date/
                    @params[key] = Date.today.strftime("%Y/%m/%d") if Date.parse(val) < Date.today
                end
            end
            @params
        end
    end
end