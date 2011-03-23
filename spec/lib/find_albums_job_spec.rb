require 'spec_helper'
require 'metal_detectr'
require 'find_albums_job'

describe FindAlbumsJob do
  describe "#perform" do
    it "should fetch the paginated result urls" do
      MetalDetectr::MetalArchives.should_receive(:fetch_paginated_result_urls)
      FindAlbumsJob.new.perform
    end

    it "should get the paginated urls to search over" do
      MetalDetectr::MetalArchives.stub(:fetch_paginated_result_urls).and_yield
      MetalDetectr::MetalArchives.should_receive(:urls_to_search)
      MetalDetectr::MetalArchives.stub(:fetch_album_urls)
      FindAlbumsJob.new.perform
    end

    it "should fetch the album urls" do
      MetalDetectr::MetalArchives.stub(:fetch_paginated_result_urls).and_yield
      MetalDetectr::MetalArchives.stub(:urls_to_search)
      MetalDetectr::MetalArchives.should_receive(:fetch_album_urls)
      FindAlbumsJob.new.perform
    end

    context "when fetching album urls times out" do
      it "should not yield" do
        MetalDetectr::MetalArchives.stub(:fetch_paginated_result_urls).and_yield
        MetalDetectr::MetalArchives.stub(:urls_to_search)
        MetalDetectr::MetalArchives.stub(:fetch_album_urls)
        MetalDetectr::MetalArchives.should_not_receive(:complete_album_urls_fetch_if_finished!)
        FindAlbumsJob.new.perform
      end
    end

    it "should check the step to complete the album urls" do
      MetalDetectr::MetalArchives.stub(:fetch_paginated_result_urls).and_yield
      MetalDetectr::MetalArchives.stub(:urls_to_search)
      MetalDetectr::MetalArchives.stub(:fetch_album_urls).and_yield
      MetalDetectr::MetalArchives.should_receive(:complete_album_urls_fetch_if_finished!)
      FindAlbumsJob.new.perform
    end

    context "when saving releases from urls times out" do
      it "should not yield" do
        MetalDetectr::MetalArchives.stub(:fetch_paginated_result_urls).and_yield
        MetalDetectr::MetalArchives.stub(:urls_to_search)
        MetalDetectr::MetalArchives.stub(:fetch_album_urls).and_yield
        MetalDetectr::MetalArchives.stub(:complete_album_urls_fetch_if_finished!)
        MetalDetectr::MetalArchives.should_receive(:releases_from_urls)
        MetalDetectr::MetalArchives.should_not_receive(:complete_releases_from_urls_if_finished!)
        FindAlbumsJob.new.perform
      end
    end

    it "should save the releases from the album urls" do
      MetalDetectr::MetalArchives.stub(:fetch_paginated_result_urls).and_yield
      MetalDetectr::MetalArchives.stub(:urls_to_search)
      MetalDetectr::MetalArchives.stub(:fetch_album_urls).and_yield
      MetalDetectr::MetalArchives.stub(:complete_album_urls_fetch_if_finished!)
      MetalDetectr::MetalArchives.should_receive(:releases_from_urls).and_yield
      MetalDetectr::MetalArchives.should_receive(:complete_releases_from_urls_if_finished!)
      FindAlbumsJob.new.perform
    end
  end
end
