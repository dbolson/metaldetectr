require 'spec_helper'
require 'metal-detectr'

describe MetalDetectr do
  context "fetching paginated result urls" do
    before do
      @agent = stub('MetalArchives::Agent')
      MetalArchives::Agent.stub(:new).and_return(@agent)
    end

    context "with existing urls" do
      it "should not search for more" do
        PaginatedSearchResultUrl.stub(:count).and_return(1)
        MetalDetectr::MetalArchives.fetch_paginated_result_urls
        PaginatedSearchResultUrl.all.should be_empty
      end
    end

    context "with no existing urls" do
      it "should search for the urls" do
        urls = ['/advanced.php?release_year=2011&p=1', '/advanced.php?release_year=2011&p=2']
        PaginatedSearchResultUrl.stub(:count).and_return(0)
        @agent.stub(:paginated_result_urls).and_return(urls)
        MetalDetectr::MetalArchives.fetch_paginated_result_urls
        results = PaginatedSearchResultUrl.all
        results.size.should == 2
        results.first.url.should == urls.first
        results.last.url.should == urls.last
      end
    end
  end

  context "finding paginated urls to search" do
    before do
      @url_1 = mock_model(PaginatedSearchResultUrl, :page => 1)
      @url_2 = mock_model(PaginatedSearchResultUrl, :page => 2)
      @url_3 = mock_model(PaginatedSearchResultUrl, :page => 3)
      PaginatedSearchResultUrl.stub(:all).and_return([@url_1, @url_2, @url_3])
    end

    context "with no existing urls" do
      it "should find all the urls" do
        AlbumUrl.stub(:last).and_return(nil)
        MetalDetectr::MetalArchives.urls_to_search.should == [@url_1, @url_2, @url_3]
      end
    end

    context "with some existing urls" do
      it "should find the urls starting from the last one" do
        AlbumUrl.stub(:last).and_return(mock_model(AlbumUrl, :page => 1))
        MetalDetectr::MetalArchives.urls_to_search.should == [@url_2, @url_3]
      end
    end

    context "with only existing urls" do
      it "should be empty" do
        AlbumUrl.stub(:last).and_return(mock_model(AlbumUrl, :page => 3))
        MetalDetectr::MetalArchives.urls_to_search.should == []
      end
    end
  end

  context "fetching album urls" do
    context "when all urls have been collected" do
      it "should be nil" do
        CompletedStep.stub(:find_by_step).and_return(mock_model(CompletedStep))
        MetalDetectr::MetalArchives.fetch_album_urls([]).should be_nil
      end
    end

    context "when searching" do
      before do
        @agent = stub('MetalArchives::Agent')
        MetalArchives::Agent.stub(:new).and_return(@agent)
        @url_1 = mock_model(PaginatedSearchResultUrl, :url => '/advanced.php?release_year=2011&p=1')
        @url_2 = mock_model(PaginatedSearchResultUrl, :url => '/advanced.php?release_year=2011&p=2')
        @url_3 = mock_model(PaginatedSearchResultUrl, :url => '/advanced.php?release_year=2011&p=3')
        CompletedStep.stub(:find_by_step).and_return(nil)
      end

      context "when the search quits without finishing" do
        it "should find some album urls" do
          @agent.should_receive(:album_urls).and_return(['release.php?id=000001', 'release.php?id=000002'])
          @agent.should_receive(:album_urls).and_return(['release.php?id=000003', 'release.php?id=000004'])
          @agent.should_receive(:album_urls).and_return(nil)
          MetalDetectr::MetalArchives.fetch_album_urls([@url_1, @url_2, @url_3])
          results = AlbumUrl.all
          results.size.should == 4
        end
      end

      context "when a found url already exists" do
        it "should not save the url again" do
          @agent.should_receive(:album_urls).and_return(['release.php?id=000001', 'release.php?id=000002'])
          @agent.should_receive(:album_urls).and_return(['release.php?id=000003', 'release.php?id=000004'])
          @agent.should_receive(:album_urls).and_return(['release.php?id=000003', 'release.php?id=000005'])
          MetalDetectr::MetalArchives.fetch_album_urls([@url_1, @url_2, @url_2])
          results = AlbumUrl.all
          results.size.should == 5
        end
      end

      it "should find the album urls" do
        @agent.should_receive(:album_urls).and_return(['release.php?id=000001', 'release.php?id=000002'])
        @agent.should_receive(:album_urls).and_return(['release.php?id=000003', 'release.php?id=000004'])
        @agent.should_receive(:album_urls).and_return(['release.php?id=000005', 'release.php?id=000006'])
        MetalDetectr::MetalArchives.fetch_album_urls([@url_1, @url_2, @url_3])
        results = AlbumUrl.all
        results.size.should == 6
      end
    end
  end

  context "checking if all album urls are fetched" do
    before do
      @agent = stub('MetalArchives::Agent')
      MetalArchives::Agent.stub(:new).and_return(@agent)
      @agent.stub(:total_albums).and_return(10)
    end

    context "finished fetching all album urls" do
      context "but haven't marked this step as complete" do
        it "should mark this step as complete" do
          step = mock_model(CompletedStep, :step => 1)
          AlbumUrl.stub(:count).and_return(10)
          CompletedStep.stub(:find_by_step).and_return(nil)
          CompletedStep.should_receive(:find_or_create_by_step).and_return(step)
          MetalDetectr::MetalArchives.complete_album_urls_fetch_if_finished!
        end
      end

      context "and already marked this step as complete" do
        it "should not mark this step as complete" do
          step = mock_model(CompletedStep, :step => 1)
          CompletedStep.stub(:find_by_step).and_return(step)
          CompletedStep.should_not_receive(:find_or_create_by_step)
          MetalDetectr::MetalArchives.complete_album_urls_fetch_if_finished!
        end
      end
    end

    context "not finished fetching all album urls" do
      it "should not mark this step as complete" do
        AlbumUrl.stub(:count).and_return(5)
        CompletedStep.should_not_receive(:find_or_create_by_step)
        MetalDetectr::MetalArchives.complete_album_urls_fetch_if_finished!
      end
    end
  end
end
