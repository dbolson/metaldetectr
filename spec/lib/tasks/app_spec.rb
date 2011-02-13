require 'spec_helper'
require 'rake'

describe "app rake tasks" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('../../lib/tasks/app')
    Rake::Task.define_task(:environment)
  end

  context "rake app:get_paginated_result_links" do
    before do
      @task_name = "app:get_paginated_result_links"
    end

    it "should have 'environment' as a prerequisite" do
      @rake[@task_name].prerequisites.should include('environment')
    end

    it "" do
    end
  end

  #describe "rake app:options:refresh" do
  #  before do
  #    @task_name = "app:options:refresh"
  #    YAML.stub!(:load_file).and_return([])
  #  end
  #  it "should have 'environment' as a prereq" do
  #    @rake[@task_name].prerequisites.should include("environment")
  #  end  
  #end
end

=begin
  require 'mechanize'
  require 'metal-archives'

  agent = MetalArchives::Agent.new
  links = []

  agent.paginated_result_links.each do |search_result|
    link = agent.album_links_from_url(search_result)
    if link.nil?
      puts "\nThrew an exception so exit"
      break
    else
      print '.'
      links << link
    end
  end
  links.flatten!
  puts "DONE: #{links.size}"

  if links.size >= 1
    puts "album information for the first result: #{agent.album_from_url(links.first).inspect}"
    puts "album information for the first result: #{agent.album_from_url(links.last).inspect}"
  end
=end
