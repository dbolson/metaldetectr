require 'spec_helper'

describe AmazonSearch do
  describe "searches for a US release date for a release" do
    before do
      @release = mock_model(Release, :name => 'Foo', :band => 'Bar')
      @result = mock('Amazon::Ecs::Response')
    end

    context "and finds it" do
      before do
        @result.stub(:get).with('itemattributes/artist').and_return('bar')
        @result.stub(:get).with('itemattributes/title').and_return('foo')
        @result.stub(:get).with('itemattributes/releasedate').and_return('02-03-2010')
        @results = mock('Amazon::Ecs::Response', :has_error? => false, :items => [@result])
      end

      context "in the music section" do
        it "should return the release date" do
          AmazonSearch.should_receive(:item_search_in_music).with(@release, :us).and_return(@results)
          AmazonSearch.find_us_release_date(@release).should == '02-03-2010'
        end
      end

      context "in the mp3 section" do
        it "should return the release date" do
          no_result = mock('Amazon::Ecs::Response')
          no_results = mock('Amazon::Ecs::Response', :has_error? => true, :items => [no_result])
          AmazonSearch.should_receive(:item_search_in_music).and_return(no_results)
          AmazonSearch.should_receive(:item_search_in_mp3downloads).with(@release, :us).and_return(@results)
          AmazonSearch.find_us_release_date(@release).should == '02-03-2010'
        end
      end
    end

    context "and doesn't find it" do
      it "should return nothing" do
        no_results = mock('Amazon::Ecs::Response', :has_error? => true)
        AmazonSearch.should_receive(:item_search_in_music).with(@release, :us).and_return(no_results)
        AmazonSearch.should_receive(:item_search_in_mp3downloads).with(@release, :us).and_return(no_results)
        AmazonSearch.find_us_release_date(@release).should be_nil
      end    
    end
  end

  describe "searches for a European release date for a release" do
    before do
      @release = mock_model(Release, :name => 'Foo', :band => 'Bar')
      @result = mock('Amazon::Ecs::Response')
    end

    context "and finds it" do
      before do
        @result.stub(:get).with('itemattributes/artist').and_return('bar')
        @result.stub(:get).with('itemattributes/title').and_return('foo')
        @result.stub(:get).with('itemattributes/releasedate').and_return('02-03-2010')
        @results = mock('Amazon::Ecs::Response', :has_error? => false, :items => [@result])
      end

      context "in the music section" do
        it "should return the release date" do
          AmazonSearch.should_receive(:item_search_in_music).with(@release, :uk).and_return(@results)
          AmazonSearch.find_euro_release_date(@release).should == '02-03-2010'
        end
      end

      context "in the mp3 section" do
        it "should return the release date" do
          no_result = mock('Amazon::Ecs::Response')
          no_results = mock('Amazon::Ecs::Response', :has_error? => true, :items => [no_result])
          AmazonSearch.should_receive(:item_search_in_music).and_return(no_results)
          AmazonSearch.should_receive(:item_search_in_mp3downloads).with(@release, :uk).and_return(@results)
          AmazonSearch.find_euro_release_date(@release).should == '02-03-2010'
        end
      end
    end

    context "and doesn't find it" do
      it "should return nothing" do
        no_results = mock('Amazon::Ecs::Response', :has_error? => true)
        [:uk, :de, :fr].each do |country|
          AmazonSearch.should_receive(:item_search_in_music).with(@release, country).and_return(no_results)
          AmazonSearch.should_receive(:item_search_in_mp3downloads).with(@release, country).and_return(no_results)
        end
        AmazonSearch.find_euro_release_date(@release).should be_nil
      end
    end
  end
end
