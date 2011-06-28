require 'spec_helper'
require 'rake'

describe "app rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('../../lib/tasks/app')
    Rake::Task.define_task(:environment)
  end

  describe "rake app:metal_archives:fetch_paginated_result_urls" do
    before do
      @task_name = 'app:metal_archives:fetch_paginated_result_urls'
    end

    it "should have 'environment' as a prerequisite" do
      @rake[@task_name].prerequisites.should include('environment')
    end

    it "should fetch the paginated result urls" do
      MetalArchives.should_receive(:fetch_paginated_result_urls)
      @rake[@task_name].invoke
    end
  end

  describe "rake app:metal_archives:fetch_album_urls" do
    before do
      @task_name = 'app:metal_archives:fetch_album_urls'
    end

    it "should have 'environment' as a prerequisite" do
      @rake[@task_name].prerequisites.should include('environment')
    end

    it "should have 'fetch_paginated_result_urls' as a prerequisite" do
      #@rake[@task_name].prerequisites.should include('fetch_paginated_result_urls')
    end

    it "should find the urls to search" do
      MetalArchives.should_receive(:urls_to_search)
      MetalArchives.stub(:fetch_album_urls)
      MetalArchives.stub(:complete_album_urls_fetch_if_finished!)
      @rake[@task_name].invoke
    end

    it "should fetch the album urls" do
      MetalArchives.stub(:urls_to_search)
      MetalArchives.should_receive(:fetch_album_urls)
      MetalArchives.stub(:complete_album_urls_fetch_if_finished!)
      @rake[@task_name].invoke
    end

    it "should try to mark the album url search step as complete" do
      MetalArchives.stub(:urls_to_search)
      MetalArchives.stub(:fetch_album_urls)
      MetalArchives.should_receive(:complete_album_urls_fetch_if_finished!)
      @rake[@task_name].invoke
    end
  end

  describe "rake app:metal_archives:fetch_albums" do
    before do
      @task_name = 'app:metal_archives:fetch_albums'
    end

    it "should have 'environment' as a prerequisite" do
      @rake[@task_name].prerequisites.should include('environment')
    end

    it "should find the albums from their urls" do
      MetalArchives.should_receive(:releases_from_urls)
      MetalArchives.stub(:complete_releases_from_urls_if_finished!)
      @rake[@task_name].invoke
    end

    it "should try to mark the releases from urls step as complete" do
      MetalArchives.stub(:releases_from_urls)
      MetalArchives.should_receive(:complete_releases_from_urls_if_finished!)
      @rake[@task_name].invoke
    end
  end
end
