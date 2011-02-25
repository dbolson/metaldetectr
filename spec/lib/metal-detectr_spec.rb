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
end
