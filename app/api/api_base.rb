module API
    class ApiBase < Grape::API
        mount Api::V1::SubscriberApi::ApiV1
    end
    
end