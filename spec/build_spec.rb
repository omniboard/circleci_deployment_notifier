require "spec_helper"

RSpec.describe CircleciDeploymentNotifier::Build do
  subject(:described_instance) { described_class.new(app_name: app_name) }
  let(:app_name) { "Application Name" }

  after do
    ENV.delete 'CIRCLE_SHA1'
    ENV.delete 'CIRCLE_BRANCH'
    ENV.delete 'CIRCLE_TAG'
    ENV.delete 'CIRCLE_USERNAME'
    ENV.delete 'CIRCLE_REPOSITORY_URL'
    ENV.delete 'CIRCLE_BUILD_NUM'
    ENV.delete 'CIRCLE_BUILD_URL'
  end

  def prepare_for_build
    ENV['CIRCLE_SHA1'] = "abc123"
    ENV['CIRCLE_USERNAME'] = "RobinDaugherty"
    ENV['CIRCLE_REPOSITORY_URL'] = "https://github.com/RobinDaugherty/circleci_deployment_notifier"
    ENV['CIRCLE_BUILD_NUM'] = "1100"
    ENV['CIRCLE_BUILD_URL'] = "https://circleci.com/gh/RobinDaugherty/circleci_deployment_notifier/1100"
  end

  def prepare_for_branch_build
    prepare_for_build
    ENV['CIRCLE_BRANCH'] = "master"
  end

  def prepare_for_tag_build
    prepare_for_build
    ENV['CIRCLE_TAG'] = "v1.0.0"
  end

  describe '#send_to_slack' do
    subject(:send_to_slack) { described_instance.send_to_slack(webhook_url: webhook_url) }
    let(:webhook_url) { "https://hooks.slack.com/services/WEBHOOK" }
    let!(:slack_request) { stub_request(:post, "https://hooks.slack.com/services/WEBHOOK") }

    context 'for a branch build' do
      before do
        prepare_for_branch_build
      end

      it 'sends a Slack webhook request' do
        send_to_slack
        expect(slack_request).to have_been_made
      end
      context 'the Slack request' do
        it 'has the correct body' do
          request_with_body = slack_request.with(
            body: {
              "payload" => <<-JSON.gsub("\n", ''),
{
"username":"Application Name Deployments",
"attachments":
[
{
"fallback":"master deployed by RobinDaugherty","color":"good",
"text":"<https://github.com/RobinDaugherty/circleci_deployment_notifier/tree/abc123|master>",
"footer":"deployed by <https://github.com/RobinDaugherty|RobinDaugherty>
 in <https://circleci.com/gh/RobinDaugherty/circleci_deployment_notifier/1100|build 1100>",
"footer_icon":"https://github.com/RobinDaugherty.png"
}
]
}
              JSON
            },
          )
          send_to_slack
          expect(request_with_body).to have_been_made
        end
      end
    end

    context 'for a tag build' do
      before do
        prepare_for_tag_build
      end

      it 'sends a Slack webhook request' do
        send_to_slack
        expect(slack_request).to have_been_made
      end
      context 'the Slack request' do
        it 'has the correct body' do
          request_with_body = slack_request.with(
            body: {
              "payload" => <<-JSON.gsub("\n", ''),
{
"username":"Application Name Deployments",
"attachments":[
{
"fallback":"v1.0.0 deployed by RobinDaugherty",
"color":"good",
"text":"<https://github.com/RobinDaugherty/circleci_deployment_notifier/tree/v1.0.0|v1.0.0>
 (<https://github.com/RobinDaugherty/circleci_deployment_notifier/releases/tag/v1.0.0|release notes>)",
"footer":"deployed by <https://github.com/RobinDaugherty|RobinDaugherty>
 in
 <https://circleci.com/gh/RobinDaugherty/circleci_deployment_notifier/1100|build 1100>",
"footer_icon":"https://github.com/RobinDaugherty.png"}
]
}
              JSON
            }
          )
          send_to_slack
          expect(request_with_body).to have_been_made
        end
      end
    end
  end

  describe '#send_to_new_relic' do
    subject(:send_to_new_relic) {
      described_instance.send_to_new_relic(
        new_relic_api_key: new_relic_api_key,
        new_relic_app_id: new_relic_app_id,
      )
    }
    let(:new_relic_api_key) { "abcdefg" }
    let(:new_relic_app_id) { "12345" }
    let!(:new_relic_request) {
      stub_request(:post, "https://api.newrelic.com/v2/applications/12345/deployments.json")
    }

    context 'for a branch build' do
      before do
        prepare_for_branch_build
      end

      it 'sends a New Relic deployment request' do
        send_to_new_relic
        expect(new_relic_request).to have_been_made
      end
      context 'the New Relic request' do
        it 'has the correct body' do
          request_with_body = new_relic_request.with(
            body: <<-JSON.gsub("\n", ''),
{
"deployment":
{
"revision":"master","user":"RobinDaugherty",
"description":"https://github.com/RobinDaugherty/circleci_deployment_notifier/tree/abc123"
}
}
            JSON
          )
          send_to_new_relic
          expect(request_with_body).to have_been_made
        end
      end
    end

    context 'for a tag build' do
      before do
        prepare_for_tag_build
      end

      it 'sends a New Relic deployment request' do
        send_to_new_relic
        expect(new_relic_request).to have_been_made
      end
      context 'the New Relic request' do
        it 'has the correct body' do
          request_with_body = new_relic_request.with(
            body: <<-JSON.gsub("\n", ''),
{
"deployment":
{
"revision":"v1.0.0","user":"RobinDaugherty",
"description":"https://github.com/RobinDaugherty/circleci_deployment_notifier/releases/tag/v1.0.0"
}
}
            JSON
          )
          send_to_new_relic
          expect(request_with_body).to have_been_made
        end
      end
    end
  end
end
