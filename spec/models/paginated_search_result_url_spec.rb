require 'spec_helper'

describe PaginatedSearchResultUrl do
  describe "validates a url" do
    it "should exist" do
      result = PaginatedSearchResultUrl.new
      result.should_not be_valid
      result.errors[:url].should_not be_nil
    end

    it "should be unique" do
      existing_url = Factory(:paginated_search_result_url)
      result = PaginatedSearchResultUrl.new(:url => existing_url.url)
      result.should_not be_valid
      result.errors[:url].should_not be_nil
    end
  end

  describe "#page_number" do
    it "should find the page number" do
      url = Factory.build(:paginated_search_result_url, :url => '/advanced.php?release_year=2011&p=1&p=32')
      url.page_number.should == 32
    end

    context "but doesn't find it" do
      it "should be -1" do
        url = Factory.build(:paginated_search_result_url, :url => '/advanced.php?release_year=2011')
        url.page_number.should == -1
      end
    end
  end
end
