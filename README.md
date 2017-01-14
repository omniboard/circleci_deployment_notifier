
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/b76abb83eb5449499cbe3740c147715e)](https://www.codacy.com/app/robindaugherty/circleci_deployment_notifier?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=RobinDaugherty/circleci_deployment_notifier&amp;utm_campaign=Badge_Grade)
[![Codacy Coverage](https://api.codacy.com/project/badge/Coverage/b76abb83eb5449499cbe3740c147715e)](https://www.codacy.com/app/robindaugherty/circleci_deployment_notifier?utm_source=github.com&utm_medium=referral&utm_content=RobinDaugherty/circleci_deployment_notifier&utm_campaign=Badge_Coverage)

# CircleCI Deployment Notifier

Sends deployment notifications based on deployments that occur on CircleCI.

Assumptions:

- Using CircleCI.
- Using Github.
- Using Slack for notifications.

You can also:

- Deploy releases that are tagged using Github Releases.

## Installation

Requires Ruby 2.0.0 or higher.

```sh
gem install circleci_deployment_notifier
```

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/RobinDaugherty/circleci_deployment_notifier.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
