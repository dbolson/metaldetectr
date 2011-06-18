require 'spec_helper'

describe ReleasesHelper do
  context "collected all releases" do
    it "should say it's finished" do
      CompletedStep.stub!(:finished_collecting_metal_archives_releases?).and_return(true)
      finished_collecting_metal_archives_releases?.should be_true
    end
  end

  context "not finished collecting all releases" do
    it "should not say it's finished" do
      CompletedStep.stub!(:finished_collecting_metal_archives_releases?).and_return(false)
      finished_collecting_metal_archives_releases?.should be_false
    end
  end

  context "sorts a column" do
    context "that is set to descending order" do
      it "should change to ascending" do
        reverse_sort_column_direction('desc').should == 'asc'
      end
    end
  end

  context "creates a link to sort data" do
    context "with an optional column name parameter" do
      it "should create a link" do
        column_name = 'name'
        params = { :p => 'all', :column_name => 'NAME' }
        link_to_sort(column_name, params).should == content_tag(:a, 'NAME', :href => releases_path(:s => 'name', :d => 'desc', :p => 'all'))
      end
    end

    context "when showing all data" do
      it "should create a link" do
        column_name = 'name'
        params = { :p => 'all' }
        link_to_sort(column_name, params).should == content_tag(:a, 'Name', :href => releases_path(:s => 'name', :d => 'desc', :p => 'all'))
      end
    end

    context "with pagination" do
      it "should create a link" do
        column_name = 'name'
        params = { :p => '10' }
        link_to_sort(column_name, params).should == content_tag(:a, 'Name', :href => releases_path(:s => 'name', :d => 'desc', :p => '10'))
      end
    end

    context "in ascending order" do
      it "should create a link" do
        column_name = 'name'
        params = { :d => 'asc' }
        link_to_sort(column_name, params).should == content_tag(:a, 'Name', :href => releases_path(:s => 'name', :d => 'desc'))
      end
    end

    context "in descending order" do
      it "should create a link" do
        column_name = 'name'
        params = { :d => 'desc' }
        link_to_sort(column_name, params).should == content_tag(:a, 'Name', :href => releases_path(:s => 'name', :d => 'asc'))
      end
    end

    context "with a search term" do
      it "should create a link" do
        column_name = 'name'
        params = { :search => 'foo' }
        link_to_sort(column_name, params).should == content_tag(:a, 'Name', :href => releases_path(:s => 'name', :d => 'desc', :search => 'foo'))
      end
    end

    context "with a start date" do
      it "should create a link" do
        column_name = 'name'
        params = { :d => 'desc', :start_date => '01-02-2010' }
        link_to_sort(column_name, params).should == content_tag(:a, 'Name', :href => releases_path(:s => 'name', :d => 'asc', :start_date => '01-02-2010'))
      end
    end

    context "with an end date" do
      it "should create a link" do
        column_name = 'name'
        params = { :d => 'desc', :end_date => '01-02-2010' }
        link_to_sort(column_name, params).should == content_tag(:a, 'Name', :href => releases_path(:s => 'name', :d => 'asc', :end_date => '01-02-2010'))
      end
    end
  end

  context "showing a release with a url" do
    it "should link to the url" do
      release = mock_model(Release, :url => '/foo.html')
      link_to_more(release).should == content_tag(:a, :href => '/foo.html', :target => '_blank') { 'More' }
    end
  end

  context "showing a release without a url" do
    it "should not show a link to the url" do
      release = mock_model(Release, :url => nil)
      link_to_more(release).should be_nil
    end
  end

  ['20', '50', '100', 'All'].each do |results|
    context "shows pagination link to view #{results} results" do
      it "should show a link to view #{results} results per page" do
        params = { :p => results }
        pagination_toggle(params).should == content_tag(:div, :class => 'view_release_limits') do
          content_tag(:span, 'View:') << ' ' <<
          content_tag(:a, :href => '/releases?p=20', :class => results == '20' ? 'selected' : nil) { '20' } << ' ' <<
          content_tag(:a, :href => '/releases?p=50', :class => results == '50' ? 'selected' : nil) { '50' } << ' ' <<
          content_tag(:a, :href => '/releases?p=100', :class => results == '100' ? 'selected' : nil) { '100' } << ' ' <<
          content_tag(:a, :href => '/releases?p=all', :class => results == 'all' ? 'selected' : nil) { 'All' }
        end
      end
    end
  end

  context "prints the classes for the releases table rows" do
    context "when the current user is an administrator" do
      it "should print the editable class" do
        release = mock_model(Release, :id => '20')
        classes_for_release_row(true, release).should == 'release_20 editable'
      end
    end

    it "should print the default class" do
      release = mock_model(Release, :id => '20')
      classes_for_release_row(false, release).should == 'release_20'
    end
  end

  context "prints a table cell for a release" do
    context "when the current user is an administrator" do
      it "should print the table cell" do
        params = { :class => 'my_class', :content => 'foo bar', :is_admin => true }
        release_field(params).should == content_tag(:td, :class => 'my_class', :title => 'click to edit') { 'foo bar' }
      end
    end

    context "with a truncation length" do
      it "should truncate the content" do
        params = { :class => 'my_class', :content => 'foo bar', :is_admin => false, :length => 5 }
        release_field(params).should == content_tag(:td, :class => 'my_class', :title => 'foo bar') { 'fo...' }
      end
    end

    context "with no content" do
      it "should not have a title or content" do
        params = { :class => 'my_class', :is_admin => false }
        release_field(params).should == content_tag(:td, :class => 'my_class') {}
      end
    end

    context "with content long enough to truncate" do
      it "should print the table cell with no title" do
        params = { :class => 'my_class', :content => 'foo bar 012345678901234567890123456789', :is_admin => false }
        release_field(params).should == content_tag(:td, :class => 'my_class', :title => 'foo bar 012345678901234567890123456789') do
          'foo bar 012345678901234567890123...'
        end
      end
    end

    context "without content long enough to truncate" do
      it "should print the table cell with no title" do
        params = { :class => 'my_class', :content => 'foo bar', :is_admin => false }
        release_field(params).should == content_tag(:td, :class => 'my_class') { 'foo bar' }
      end
    end
  end
end
