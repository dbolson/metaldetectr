require 'spec_helper'

describe ReleasesHelper do
  describe "#finished_collecting_metal_archives_releases?" do
    context "collected all releases" do
      it "says it's finished" do
        CompletedStep.stub!(:finished_collecting_metal_archives_releases?).and_return(true)
        helper.finished_collecting_metal_archives_releases?.should be_true
      end
    end

    context "not finished collecting all releases" do
      it "does not say it's finished" do
        CompletedStep.stub!(:finished_collecting_metal_archives_releases?).and_return(false)
        helper.finished_collecting_metal_archives_releases?.should be_false
      end
    end
  end

  describe "#reverse_sort_column_direction" do
    context "when set to descending order" do
      it "changes to ascending" do
        helper.reverse_sort_column_direction('desc').should == 'asc'
      end
    end
  end

  describe "#link_to_sort" do
    context "with an optional column name parameter" do
      it "creates a link" do
        column_name = 'name'
        params = { :p => 'all', :column_name => 'NAME' }
        helper.link_to_sort(column_name, params).should == content_tag(:a, 'NAME', :href => releases_path(:s => 'name', :d => 'desc', :p => 'all'))
      end
    end

    context "when showing all data" do
      it "creates a link" do
        column_name = 'name'
        params = { :p => 'all' }
        helper.link_to_sort(column_name, params).should == content_tag(:a, 'Name', :href => releases_path(:s => 'name', :d => 'desc', :p => 'all'))
      end
    end

    context "with pagination" do
      it "creates a link" do
        column_name = 'name'
        params = { :p => '10' }
        helper.link_to_sort(column_name, params).should == content_tag(:a, 'Name', :href => releases_path(:s => 'name', :d => 'desc', :p => '10'))
      end
    end

    context "in ascending order" do
      it "creates a link" do
        column_name = 'name'
        params = { :d => 'asc' }
        helper.link_to_sort(column_name, params).should == content_tag(:a, 'Name', :href => releases_path(:s => 'name', :d => 'desc'))
      end
    end

    context "in descending order" do
      it "creates a link" do
        column_name = 'name'
        params = { :d => 'desc' }
        helper.link_to_sort(column_name, params).should == content_tag(:a, 'Name', :href => releases_path(:s => 'name', :d => 'asc'))
      end
    end

    context "with a search term" do
      it "creates a link" do
        column_name = 'name'
        params = { :search => 'foo' }
        helper.link_to_sort(column_name, params).should == content_tag(:a, 'Name', :href => releases_path(:s => 'name', :d => 'desc', :search => 'foo'))
      end
    end

    context "with a start date" do
      it "creates a link" do
        column_name = 'name'
        params = { :d => 'desc', :start_date => '01-02-2010' }
        helper.link_to_sort(column_name, params).should == content_tag(:a, 'Name', :href => releases_path(:s => 'name', :d => 'asc', :start_date => '01-02-2010'))
      end
    end

    context "with an end date" do
      it "creates a link" do
        column_name = 'name'
        params = { :d => 'desc', :end_date => '01-02-2010' }
        helper.link_to_sort(column_name, params).should == content_tag(:a, 'Name', :href => releases_path(:s => 'name', :d => 'asc', :end_date => '01-02-2010'))
      end
    end
  end

  describe "#link_to_more" do
    context "showing a release with a url" do
      it "links to the url" do
        release = mock_model(Release, :url => '/foo.html')
        helper.link_to_more(release).should == content_tag(:a, :href => '/foo.html', :target => '_blank') { 'More' }
      end
    end

    context "showing a release without a url" do
      it "does not show a link to the url" do
        release = mock_model(Release, :url => nil)
        helper.link_to_more(release).should be_nil
      end
    end
  end

  describe "#pagination_toggle" do
    ['20', '50', '100', 'All'].each do |results|
      context "shows pagination link to view #{results} results" do
        it "shows a link to view #{results} results per page" do
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
  end

  describe "#classes_for_release_row" do
    context "with a signed-in user" do
      context "when the current user is an administrator" do
        it "prints the editable class" do
          release = mock_model(Release, :id => '20', :lastfm_user? => false)
          user = mock_model(User, :admin? => true).as_null_object
          helper.classes_for_release_row(release, user).should == 'release_20 editable'
        end
      end

      context "with a lastfm album" do
        it "prints the lastfm class" do
          release = mock_model(Release, :id => '20', :lastfm_user? => true)
          user = mock_model(User, :admin? => true).as_null_object
          helper.classes_for_release_row(release, user).should == 'release_20 editable lastfm'
        end
      end
    end

    context "without a signed-in user" do
      it "prints the default class" do
        release = mock_model(Release, :id => '20', :lastfm_user? => false)
        helper.classes_for_release_row(release).should == 'release_20'
      end
    end
  end

  describe "#release_field" do
    context "when the current user is an administrator" do
      it "prints the table cell" do
        params = { :class => 'my_class', :content => 'foo bar', :is_admin => true }
        helper.release_field(params).should == content_tag(:td, :class => 'my_class', :title => 'click to edit') { 'foo bar' }
      end
    end

    context "with a truncation length" do
      it "truncates the content" do
        params = { :class => 'my_class', :content => 'foo bar', :is_admin => false, :length => 5 }
        helper.release_field(params).should == content_tag(:td, :class => 'my_class', :title => 'foo bar') { 'fo...' }
      end
    end

    context "with no content" do
      it "does not have a title or content" do
        params = { :class => 'my_class', :is_admin => false }
        helper.release_field(params).should == content_tag(:td, :class => 'my_class') {}
      end
    end

    context "with content long enough to truncate" do
      it "prints the table cell with no title" do
        params = { :class => 'my_class', :content => 'foo bar 012345678901234567890123456789', :is_admin => false }
        helper.release_field(params).should == content_tag(:td, :class => 'my_class', :title => 'foo bar 012345678901234567890123456789') do
          'foo bar 012345678901234567890123...'
        end
      end
    end

    context "without content long enough to truncate" do
      it "prints the table cell with no title" do
        params = { :class => 'my_class', :content => 'foo bar', :is_admin => false }
        helper.release_field(params).should == content_tag(:td, :class => 'my_class') { 'foo bar' }
      end
    end
  end

  describe "#release_filter_select" do
    it "is wrapped in a div" do
      helper.release_filter_select(nil).should have_selector('div label#releases_filter_label')
    end

    it "has a label" do
      helper.release_filter_select(nil).should have_selector('label#releases_filter_label')
    end

    it "has 'upcoming' and 'all' options" do
      options = [['', 'Upcoming'], ['all', 'All']]
      helper.release_filter_select(nil).should have_selector('select#releases_filter') do |select|
        select.children.length.should == 2
        select.children.each_with_index do |child, index|
          child.attr('value').should == options[index][0]
          child.children[0].content.should == options[index][1]
        end
      end
    end

    context "with a filter" do
      it "selects the filter" do
        helper.release_filter_select(nil, 'all').should have_selector('select#releases_filter option[selected=selected][value=all]')
      end
    end

    context "with a user" do
      context "who is synced with lastfm" do
        it "has lastfm options" do
          helper.stub(:synced_with_lastfm?).and_return(true)

          options = [['', 'Upcoming'], ['all', 'All'], ['lastfm_upcoming', 'Upcoming Lastfm'], ['lastfm_all', 'All Lastfm']]
          helper.release_filter_select(mock_model(User)).should have_selector('select#releases_filter') do |select|
            select.children.length.should == 4
            select.children.each_with_index do |child, index|
              child.attr('value').should == options[index][0]
              child.children[0].content.should == options[index][1]
            end
          end
        end
      end
    end
  end
end
