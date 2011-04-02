require 'spec_helper'
require 'metal_detectr'

describe MetalDetectr do
  describe "fetching paginated result urls" do
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

  describe "finding paginated urls to search" do
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

  describe "fetching album urls" do
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
        @url_1 = mock_model(PaginatedSearchResultUrl, :url => '/advanced.php?release_year=2011&p=1', :page_number => 1)
        @url_2 = mock_model(PaginatedSearchResultUrl, :url => '/advanced.php?release_year=2011&p=2', :page_number => 2)
        @url_3 = mock_model(PaginatedSearchResultUrl, :url => '/advanced.php?release_year=2011&p=3', :page_number => 3)
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

  describe "checking if all album urls are fetched" do
    before do
      @agent = stub('MetalArchives::Agent')
      MetalArchives::Agent.stub(:new).and_return(@agent)
      @agent.stub(:total_albums).and_return(10)
    end

    context "finished fetching all album urls" do
      context "but hasn't marked this step as complete" do
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

  describe "fetching releases from urls" do
    before do
      CompletedStep.stub(:finished_fetching_album_urls?).and_return(true)
      @agent = stub('MetalArchives::Agent')
      MetalArchives::Agent.stub(:new).and_return(@agent)
    end

    context "having already searched all the albums" do
      it "should not search anymore" do
        CompletedStep.should_receive(:finished_fetching_album_urls?).and_return(false)
        MetalDetectr::MetalArchives.releases_from_urls
      end
    end

    context "having not searched any albums" do
      it "should start searching from the first album" do
        album_url_1 = mock_model(AlbumUrl).as_null_object
        album_url_2 = mock_model(AlbumUrl).as_null_object
        album_url_3 = mock_model(AlbumUrl).as_null_object
        AlbumUrl.stub(:all).and_return([album_url_1, album_url_2, album_url_3])
        @agent.should_receive(:album_from_url).exactly(3).times.and_return({ :an => 'album' })

        MetalDetectr::MetalArchives.releases_from_urls
      end
    end

    context "having searched some albums" do
      it "should start searching from the last album not searched" do
        album_url_1 = mock_model(AlbumUrl).as_null_object
        album_url_2 = mock_model(AlbumUrl).as_null_object
        album_url_3 = mock_model(AlbumUrl).as_null_object
        SearchedAlbum.stub(:last).and_return(album_url_2)
        AlbumUrl.stub(:where).and_return([album_url_2, album_url_3])
        @agent.should_receive(:album_from_url).exactly(2).times.and_return({ :an => 'album' })

        MetalDetectr::MetalArchives.releases_from_urls
      end
    end

    context "when the site times out" do
      before do
        @album_url_1 = mock_model(AlbumUrl, :url => '/foo')
        @album_url_2 = mock_model(AlbumUrl)
      end

      it "should stop searching" do
        AlbumUrl.should_receive(:all).and_return([@album_url_1, @album_url_2])
        @agent.should_receive(:album_from_url).once.and_return(nil)
        MetalDetectr::MetalArchives.releases_from_urls
      end

      it "should save the url to search later" do
        MetalDetectr::MetalArchives.stub(:albums_to_search).and_return([@album_url_1, @album_url_2])
        @agent.stub(:album_from_url).once.and_return(nil)
        SearchedAlbum.should_receive(:find_or_create_by_album_url_id).with(@album_url_1.id)
        MetalDetectr::MetalArchives.releases_from_urls
      end
    end

    context "when an already-existing album is found" do
      it "should not create another album" do
        release = Factory(:release, :format => 'Full-length', :label => 'Foo Records', :us_date => Date.parse('01-02-1982'), :url => '/foo')
        album_url = mock_model(AlbumUrl).as_null_object
        album_from_site = {
          :album => release.name,
          :band => release.band,
          :release_type => release.format,
          :label => release.label,
          :release_date => release.us_date,
          :url => release.url
        }
        @agent.should_receive(:album_from_url).and_return(album_from_site)
        MetalDetectr::MetalArchives.stub(:albums_to_search).and_return([album_url])

        lambda do
          MetalDetectr::MetalArchives.releases_from_urls
        end.should change(Release, :count).by(0)
      end
    end

    it "should create an album" do
      album_url_1 = Factory(:album_url)
      album_from_site = {
        :album => 'New Album',
        :band => 'The Band',
        :release_type => 'Full-length',
        :label => 'Foo Bar Records',
        :release_date => "January 20th, #{Time.now.year}",
        :url => '/foo?1'
      }
      @agent.should_receive(:album_from_url).and_return(album_from_site)

      MetalDetectr::MetalArchives.releases_from_urls

      Release.should have(1).record
      release = Release.first
      release.name.should == album_from_site[:album]
      release.band.should == album_from_site[:band]
      release.format.should == album_from_site[:release_type]
      release.label.should == album_from_site[:label]
      release.url.should == album_from_site[:url]
      release.us_date.should == Date.parse(album_from_site[:release_date])
    end

    context "finished fetching all releases" do
      context "but hasn't marked this step as complete" do
        it "should mark this step as complete" do
          step = mock_model(CompletedStep, :step => 2)
          CompletedStep.stub(:finished_fetching_releases?).and_return(false)
          AlbumUrl.stub(:last).and_return(mock_model(AlbumUrl).as_null_object)
          Release.stub(:exists?).and_return(true)
          CompletedStep.should_receive(:find_or_create_by_step).and_return(step)
          MetalDetectr::MetalArchives.complete_releases_from_urls_if_finished!
        end
      end

      context "and already marked this step as complete" do
        it "should not mark this step as complete" do
          CompletedStep.stub(:finished_fetching_releases?).and_return(true)
          CompletedStep.should_not_receive(:find_or_create_by_step)
          MetalDetectr::MetalArchives.complete_releases_from_urls_if_finished!
        end
      end
    end

    context "has not finished fetching all releases" do
      it "should not mark this step as complete" do
        CompletedStep.stub(:finished_fetching_releases?).and_return(false)
        AlbumUrl.stub(:last).and_return(mock_model(AlbumUrl).as_null_object)
        Release.stub(:exists?).and_return(false)
        CompletedStep.should_not_receive(:find_or_create_by_step)
        MetalDetectr::MetalArchives.complete_releases_from_urls_if_finished!
      end
    end
  end

  describe "updates the release dates" do
    it "should update the US release date for the releases" do
      release_1 = Factory(:release, :us_date => '01/02/2010')
      release_2 = Factory(:release, :us_date => '01/02/2010')

      MetalDetectr::AmazonSearch.stub(:find_euro_release_date)
      MetalDetectr::AmazonSearch.should_receive(:find_us_release_date).with(release_1).and_return('02/02/2010')
      MetalDetectr::AmazonSearch.should_receive(:find_us_release_date).with(release_2).and_return('02/03/2010')
      MetalDetectr::MetalArchives.update_release_dates
      release_1.reload
      release_2.reload

      release_1.us_date.should == Date.parse('02/02/2010')
      release_2.us_date.should == Date.parse('02/03/2010')
    end

    it "should update the European release date for the releases" do
      release_1 = Factory(:release, :euro_date => '01/02/2010')
      release_2 = Factory(:release, :euro_date => '01/02/2010')

      MetalDetectr::AmazonSearch.stub(:find_us_release_date)
      MetalDetectr::AmazonSearch.should_receive(:find_euro_release_date).with(release_1).and_return('02/02/2010')
      MetalDetectr::AmazonSearch.should_receive(:find_euro_release_date).with(release_2).and_return('02/03/2010')
      MetalDetectr::MetalArchives.update_release_dates
      release_1.reload
      release_2.reload

      release_1.euro_date.should == Date.parse('02/02/2010')
      release_2.euro_date.should == Date.parse('02/03/2010')
    end
  end
end
