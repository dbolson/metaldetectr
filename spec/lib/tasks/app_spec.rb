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
  end

  context "rake app:metal_archives:fetch_album_urls" do
    before do
      @task_name = "app:metal_archives:fetch_album_urls"
    end

    it "should have 'environment' as a prerequisite" do
      @rake[@task_name].prerequisites.should include('environment')
    end

    it "should have 'fetch_paginated_result_urls' as a prerequisite" do
      @rake[@task_name].prerequisites.should include('fetch_paginated_result_urls')
    end
  end
end
