module Api::V1::SubscriberApi
    include API
    class ApiV1 < ApiBase
        resource :test do
            get "test" do
                ["ok"]
            end
        end
    end
end