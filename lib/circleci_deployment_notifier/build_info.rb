module CircleciDeploymentNotifier
  ##
  # Gets build information from the environment.
  # Expects and currently only works with builds of Github repositories.
  class BuildInfo
    def commit_hash
      ENV['CIRCLE_SHA1']
    end

    def commit_browse_url
      "#{repository_url}/tree/#{commit_hash}"
    end

    def branch_name
      ENV['CIRCLE_BRANCH']
    end

    def tag_name
      ENV['CIRCLE_TAG']
    end

    def tag_url
      return unless tag_name
      "#{repository_url}/tree/#{tag_name}"
    end

    def tag_release_notes_url
      return unless tag_name
      "#{repository_url}/releases/tag/#{tag_name}"
    end

    def tag?
      tag_name
    end

    def builder_username
      ENV['CIRCLE_USERNAME']
    end

    def builder_icon
      return unless builder_username
      "https://github.com/#{builder_username}.png"
    end

    def builder_url
      return unless builder_username
      "https://github.com/#{builder_username}"
    end

    def repository_url
      ENV['CIRCLE_REPOSITORY_URL']
    end

    def build_identifier
      ENV['CIRCLE_BUILD_NUM']
    end

    def build_url
      ENV['CIRCLE_BUILD_URL']
    end
  end
end
