require 'rspec'
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'git'
require 'fakefs'
require 'cocoapods-core'

describe Pod::Publisher::SpecRepository, :fakefs => true do

  def cleanup
    FileUtils.rm_rf @local_path if File.directory? @local_path
  end

  before :each do
    @repo_url = 'https://github.com/CocoaPods/Specs.git'
    @local_path = File.join(File.expand_path('~'), '.pod-publish', 'https_github_com_cocoapods_specs_git')
    @repo = Pod::Publisher::SpecRepository.new(@repo_url)
    cleanup
  end

  after :all do
    cleanup
  end

  it 'should be initialized with a repository url' do
    @repo.url.should == @repo_url
  end

  it 'should point to a local directory' do
    @repo.local_path.should end_with(@local_path)
  end

  it 'should clone the repository into local path on download' do
    allow(Git).to receive(:clone).and_return(nil)
    @repo.download
    expect(Git).to have_received(:clone).with(@repo_url, '', :path => @local_path)
  end

  it 'should delete the local path on wipe' do
    FileUtils.mkdir_p(@local_path)
    @repo.wipe
    File.directory?(@local_path).should be_false
  end

  it 'should push the repository on upload' do
    git = double('git')
    allow(Git).to receive(:clone).and_return(git)
    allow(git).to receive(:push)
    @repo.upload
    git.should have_received :push
  end

  describe '#add_podspec' do

    before :each do
      File.open("Test.podspec", 'w') {|f| f.write(<<-file
      Pod::Spec.new do |s|
        s.name         = "Test"
        s.version      = "1.0.0"
        s.summary      = "Test"
        s.homepage     = "http://test.com"
        s.license      = 'MIT'
        s.author       = { "a" => "a.b@gmail.com" }
        s.source       = { :git => "https://github.com/test/test.git", :tag => "\#{s.version}" }
        s.platform     = :ios
        s.source_files = 'Test/*.{h,m}'
        s.requires_arc =  true
      end
      file
      ) }
      git = double('git')
      allow(Git).to receive(:clone).and_return(git)
      allow(git).to receive(:commit_all)
      allow(git).to receive(:add)
      FileUtils.mkdir_p(File.join(@local_path,'.git'))
    end

    it 'should add a spec file to the repository' do
      @repo.add_podspec(Pod::Specification.from_file('Test.podspec'))
      File.exist?(File.join(@local_path, 'Test', '1.0.0', 'Test.podspec')).should be_true
    end

    it 'should commit the spec file' do
      @repo.add_podspec(Pod::Specification.from_file('Test.podspec'))
      File.exist?(File.join(@local_path, 'Test', '1.0.0', 'Test.podspec')).should be_true
    end

  end

end