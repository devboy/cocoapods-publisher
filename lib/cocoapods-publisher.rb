require 'thor'
require 'spec_repository'
require 'cocoapods-core'

module Pod
  module Publisher
    class CLI < Thor

      desc "publish PODSPEC SPECREPOSITORY", "pushes PODSPEC to SPECREPOSITORY"
      def publish(podspec,repository)
        repo = SpecRepository.new(repository)
        repo.add_podspec Pod::Specification.from_file(podspec)
        repo.upload
        repo.wipe
      end

    end
  end
end