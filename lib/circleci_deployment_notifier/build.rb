require "circleci_deployment_notifier/build_info"
require "circleci_deployment_notifier/slack"

module CircleciDeploymentNotifier
  class Build
    def initialize(app_name:)
      self.app_name = app_name
    end

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
