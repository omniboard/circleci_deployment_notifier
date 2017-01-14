require "spec_helper"

describe CircleciDeploymentNotifier::Build do
  subject(:described_instance) { described_class.new(app_name: app_name) }
  let(:app_name) { "Application Name" }

  describe '#send_to_slack' do
    subject(:send_to_slack) { described_instance.send_to_slack(webhook_url: webhook_url) }
    let(:webhook_url) { "https://hooks.slack.com/services/WEBHOOK" }
    let!(:slack_request) { stub_request(:post, "https://hooks.slack.com/services/WEBHOOK") }

    context 'for a branch build' do
      before do
        ENV['CIRCLE_SHA1'] = "abc123"
        ENV['CIRCLE_BRANCH'] = "master"
        ENV['CIRCLE_USERNAME'] = "RobinDaugherty"
        ENV['CIRCLE_REPOSITORY_URL'] = "https://github.com/RobinDaugherty/circleci_deployment_notifier"
        ENV['CIRCLE_BUILD_NUM'] = "1100"
        ENV['CIRCLE_BUILD_URL'] = "https://circleci.com/gh/RobinDaugherty/circleci_deployment_notifier/1100"
      end
      after do
        ENV.delete 'CIRCLE_SHA1'
        ENV.delete 'CIRCLE_BRANCH'
        ENV.delete 'CIRCLE_USERNAME'
        ENV.delete 'CIRCLE_REPOSITORY_URL'
        ENV.delete 'CIRCLE_BUILD_NUM'
        ENV.delete 'CIRCLE_BUILD_URL'
      end

      #   .
      #      with(:body => ,
      #           :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
      #      to_return(:status => 200, :body => "", :headers => {})
      # }

      it 'sends a Slack webhook request' do
        send_to_slack
        expect(slack_request).to have_been_made
      end
      context 'the Slack request' do
        it 'has the correct body' do
          request_with_body = slack_request.with(
            body: {
              "payload" => "{\"username\":\"Application Name Deployments\","\
                "\"attachments\":["\
                "{\"fallback\":\"master deployed by RobinDaugherty\",\"color\":\"good\","\
                "\"text\":\"<https://github.com/RobinDaugherty/circleci_deployment_notifier/tree/abc123|master>\""\
                ",\"footer\":\"deployed by <https://github.com/RobinDaugherty|RobinDaugherty> "\
                "in <https://circleci.com/gh/RobinDaugherty/circleci_deployment_notifier/1100|build 1100>\","\
                "\"footer_icon\":\"https://github.com/RobinDaugherty.png\"}]}"
            }
          )
          send_to_slack
          expect(request_with_body).to have_been_made
        end
      end
    end

    context 'for a tag build' do
      before do
        ENV['CIRCLE_SHA1'] = "abc123"
        ENV['CIRCLE_TAG'] = "v1.0.0"
        ENV['CIRCLE_USERNAME'] = "RobinDaugherty"
        ENV['CIRCLE_REPOSITORY_URL'] = "https://github.com/RobinDaugherty/circleci_deployment_notifier"
        ENV['CIRCLE_BUILD_NUM'] = "1100"
        ENV['CIRCLE_BUILD_URL'] = "https://circleci.com/gh/RobinDaugherty/circleci_deployment_notifier/1100"
      end
      after do
        ENV.delete 'CIRCLECI'
        ENV.delete 'CIRCLE_SHA1'
        ENV.delete 'CIRCLE_TAG'
        ENV.delete 'CIRCLE_USERNAME'
        ENV.delete 'CIRCLE_REPOSITORY_URL'
        ENV.delete 'CIRCLE_BUILD_NUM'
        ENV.delete 'CIRCLE_BUILD_URL'
      end

      it 'sends a Slack webhook request' do
        send_to_slack
        expect(slack_request).to have_been_made
      end
      context 'the Slack request' do
        it 'has the correct body' do
          request_with_body = slack_request.with(
            body: {
              "payload" => "{\"username\":\"Application Name Deployments\","\
                "\"attachments\":[{\"fallback\":\"v1.0.0 deployed by RobinDaugherty\","\
                "\"color\":\"good\","\
                "\"text\":\"<https://github.com/RobinDaugherty/circleci_deployment_notifier/tree/v1.0.0|v1.0.0> "\
                "(<https://github.com/RobinDaugherty/circleci_deployment_notifier/releases/tag/v1.0.0|release notes>)\""\
                ",\"footer\":\"deployed by <https://github.com/RobinDaugherty|RobinDaugherty> in "\
                "<https://circleci.com/gh/RobinDaugherty/circleci_deployment_notifier/1100|build 1100>\","\
                "\"footer_icon\":\"https://github.com/RobinDaugherty.png\"}]}"
            }
          )
          send_to_slack
          expect(request_with_body).to have_been_made
        end
      end
    end
  end
end
