require "circleci_deployment_notifier/build_info"
require "circleci_deployment_notifier/slack"

module CircleciDeploymentNotifier
  ##
  # The main object of this gem. Instantiated with the name of the application,
  # can then be used to send a notification.
  class Build
    ##
    # @param app_name [String] Name of the application that was deployed.
    def initialize(app_name:)
      self.app_name = app_name
    end

    ##
    # Sends a notification to Slack using the Slack Webhook URL.
    # @param webhook_url [String] Slack Webhook URL
    def send_to_slack(webhook_url:)
      Slack.new(webhook_url: webhook_url, app_name: app_name, build_info: build_info).send
    end

    private

    attr_accessor :app_name

    def build_info
      @build_info ||= BuildInfo.new
    end
  end
end
