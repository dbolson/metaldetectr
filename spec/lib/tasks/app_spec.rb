require 'spec_helper'
require 'rake'

describe "app rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('../../lib/tasks/app')
    Rake::Task.define_task(:environment)
  end

  context "rake app:metal_archives:fetch_paginated_result_urls" do
    before do
      @task_name = "app:metal_archives:fetch_paginated_result_urls"
    end

    it "should have 'environment' as a prerequisite" do
      @rake[@task_name].prerequisites.should include('environment')
    end

    it "should fetch the paginated result urls" do
      MetalDetectr::MetalArchives.should_receive(:fetch_paginated_result_urls)
      @rake[@task_name].invoke
    end
  end

  context "rake app:metal_archives:fetch_album_urls" do
    before do
      @task_name = "app:metal_archives:fetch_album_urls"
    end

    it "should have 'environment' as a prerequisite" do
      @rake[@task_name].prerequisites.should include('environment')
    end

    it "should have 'fetch_paginated_result_urls' as a prerequisite" do
      #@rake[@task_name].prerequisites.should include('fetch_paginated_result_urls')
    end

    it "should find the urls to search" do
      MetalDetectr::MetalArchives.should_receive(:urls_to_search)
      MetalDetectr::MetalArchives.stub(:fetch_album_urls)
      MetalDetectr::MetalArchives.stub(:complete_album_urls_fetch_if_finished!)
      @rake[@task_name].invoke
    end

    it "should fetch the album urls" do
      MetalDetectr::MetalArchives.stub(:urls_to_search)
      MetalDetectr::MetalArchives.should_receive(:fetch_album_urls)
      MetalDetectr::MetalArchives.stub(:complete_album_urls_fetch_if_finished!)
      @rake[@task_name].invoke
    end

    it "should try to mark the album url search step as complete" do
      MetalDetectr::MetalArchives.stub(:urls_to_search)
      MetalDetectr::MetalArchives.stub(:fetch_album_urls)
      MetalDetectr::MetalArchives.should_receive(:complete_album_urls_fetch_if_finished!)
      @rake[@task_name].invoke
    end
  end
end
