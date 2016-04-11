module Requests
  module JsonHelpers
    def json_response_body
      JSON.parse(response.body)
    end
  end
end
