module Api::V1::SubscriberApi
    include API
    class ApiV1 < ApiBase
        get "test" do
            ["ok"]
        end
    end
end