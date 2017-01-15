require 'slack-notifier'

module CircleciDeploymentNotifier
  ##
  # Sends notifications to Slack.
  # Builds the message using a BuildInfo object.
  class Slack
    ##
    # @param webhook_url [String] Slack Webhook URL
    # @param app_name [String] Name of the application that was deployed.
    # @param build_info [BuildInfo]
    def initialize(webhook_url:, app_name:, build_info:)
      self.webhook_url = webhook_url
      self.app_name = app_name
      self.build_info = build_info
    end

    # Sends the message to Slack.
    def send
      slack_notifier.post message
    end

    private

    attr_accessor :webhook_url
    attr_accessor :app_name
    attr_accessor :build_info

    def message
      {
        username: username,
        attachments: [
          {
            fallback: fallback_text,
            color: "good",
            text: text,
            footer: footer_text,
            footer_icon: footer_icon,
          },
        ],
      }
    end

    def username
      "#{app_name} Deployments"
    end

    def fallback_text
      "#{build_info.tag_name || build_info.branch_name} deployed"\
        "#{build_info.builder_username ? " by #{build_info.builder_username}" : ""}"
    end

    def text
      if build_info.tag_name
        "<#{build_info.tag_url}|#{build_info.tag_name}>" \
          " (<#{build_info.tag_release_notes_url}|release notes>)"
      elsif build_info.branch_name
        "<#{build_info.commit_browse_url}|#{build_info.branch_name}>"
      end
    end

    def footer_text
      return unless build_info.builder_url
      "deployed by <#{build_info.builder_url}|#{build_info.builder_username}>" \
        " in <#{build_info.build_url}|build #{build_info.build_identifier}>"
    end

    def footer_icon
      build_info.builder_icon
    end

    def slack_notifier
      @slack_notifier ||= ::Slack::Notifier.new(webhook_url)
    end
  end
end
