require 'spec_helper'

describe PaginatedSearchResultUrl do
  context "validates a url" do
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
end
