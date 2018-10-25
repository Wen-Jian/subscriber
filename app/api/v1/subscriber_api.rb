module Api::V1::SubscriberApi
    include API
    class ApiV1 < ApiBase
        resource :subscriber do
            get "/" do
                fetch_settings = FetchSetting.where revoke: false
                response = []
                fetch_settings.each do |f|
                    response << {
                        destination: f.destination,
                        start_date: f.start_date,
                        end_date: f.end_date
                    }
                end
                response
            end

            post "/" do
                params do
                    requires :destination, type: String
                    requires :start_date, type: String
                    requires :end_date, type: String
                end
                destination = params[:destination]
                start_date = params[:start_date]
                end_date = params[:end_date]
                fetch_settings = FetchSetting.where(revoke: false, destination: destination).first
                if fetch_settings.present?
                    fetch_settings.update_attributes(start_date: start_date, end_date: end_date)
                else
                    fetch_settings = FetchSetting.create!(
                        destination: destination,
                        start_date: start_date,
                        end_date: end_date,
                        revoke: false
                        )
                end
                {destination: fetch_settings.destination, start_date: start_date, end_date: end_date}
            end

            delete "/:destination" do
                setting = FetchSetting.find_by(destination: params[:destination], revoke: false)
                setting.update_attribute(:revoke, true)
            end
        end
    end
end