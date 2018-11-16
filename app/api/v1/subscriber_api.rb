module Api::V1::SubscriberApi
    include API
    include Api::Validator::ParamsValidator
    class ApiV1 < ApiBase
        resource :subscriber do
            get "/" do
                fetch_settings = FetchSetting.where revoke: false
                response = []
                fetch_settings.each do |f|
                    response << {
                        destination: f.destination,
                        start_date: f.start_date,
                        end_date: f.end_date,
                        flight_type: f.flight_type,
                        notify_price: f.notify_price
                    }
                end
                response
            end

            params do
                requires :destination, type: String
                requires :start_date, type: String
                requires :end_date, type: String
                requires :notified_price, type: Integer
                optional :flight_type, type: Integer
            end
            post "/" do
                begin
                    validator = Api::Validator::ParamsValidator::ParamsValidator.new(params)
                    params = validator.valid
                    destination = params[:destination]
                    start_date = params[:start_date]
                    end_date = params[:end_date]
                    notified_price = params[:notified_price]
                    flight_type = params[:flight_type]
                    fetch_settings = FetchSetting.where(revoke: false, destination: destination).first
                    if fetch_settings.present?
                        fetch_settings.update_attributes(start_date: start_date, end_date: end_date, notify_price: notified_price)
                    else
                        fetch_settings = FetchSetting.create!(
                            destination: destination,
                            start_date: start_date,
                            end_date: end_date,
                            notify_price: notified_price,
                            flight_type: flight_type,
                            revoke: false
                            )
                    end
                    {destination: fetch_settings.destination, start_date: start_date, end_date: end_date, notified_price: notified_price}
                rescue => exception
                    if exception.message =~ /.*can not be blank/
                        exception
                    else
                        raise exception
                    end
                end
            end

            delete "/:destination" do
                setting = FetchSetting.find_by(destination: params[:destination], revoke: false)
                setting.update_attribute(:revoke, true)
            end
        end
    end
end