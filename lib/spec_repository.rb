require 'cocoapods-core'
require 'git'

module Pod
  module Publisher
    class SpecRepository

      attr_reader :url, :local_path

      def initialize(url)
        @url = url
        @local_path = find_local_path url
      end

      def download
        wipe
        FileUtils.mkdir_p(@local_path)
        Git.clone(@url, '', :path => @local_path)
      end

      def upload
        repo.push
      end

      def wipe
        FileUtils.rm_rf @local_path if File.directory? @local_path
      end

      def add_podspec(podspec)
        repo
        target_file = File.join(@local_path, podspec.name, podspec.version.to_s, "#{podspec.name}.podspec")
        FileUtils.mkdir_p(File.dirname(target_file))
        FileUtils.cp podspec.defined_in_file, target_file
        repo.add(target_file)
        repo.commit_all("Adding #{podspec.name} #{podspec.version}")
      end

      private

      def repo
        @repo ||= download
      end

      def find_local_path(url)
        File.join(File.expand_path('~'), '.pod-publish', url.gsub(/[^a-zA-Z]/,"_").gsub(/_{2,}/,'_').downcase)
      end

    end
  end
end