require 'net/http'
require 'net/https'
require 'json'

module CircleciDeploymentNotifier
  ##
  # Sends deployment notification to New Relic.
  # Builds the message using a BuildInfo object.
  class NewRelic
    ##
    # @param new_relic_api_key [String] New Relic API Key
    # @param new_relic_app_id [String] New Relic Application ID
    # @param build_info [BuildInfo]
    def initialize(new_relic_api_key:, new_relic_app_id:, build_info:)
      self.new_relic_api_key = new_relic_api_key
      self.new_relic_app_id = new_relic_app_id
      self.build_info = build_info
    end

    ##
    # Sends the deployment notification to New Relic.
    # @return [Boolean] Whether the request was successful.
    def send
      http_response.code == 201
    end

    private

    attr_accessor :new_relic_api_key
    attr_accessor :new_relic_app_id
    attr_accessor :build_info

    def uri
      URI("https://api.newrelic.com/v2/applications/#{new_relic_app_id}/deployments.json")
    end

    def http_connection
      Net::HTTP.new(uri.host, uri.port).tap do |http|
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end
    end

    def http_request
      Net::HTTP::Post.new(uri).tap do |req|
        req.add_field "X-Api-Key", new_relic_api_key
        req.add_field "Content-Type", "application/json"
        req.body = JSON.dump body_data
      end
    end

    def body_data
      {
        deployment: {
          revision: build_info.tag_name || build_info.branch_name,
          user: build_info.builder_username,
          description: build_info.tag_release_notes_url || build_info.commit_browse_url,
        }
      }
    end

    def http_response
      @http_response ||= http_connection.request http_request
    end
  end
end
