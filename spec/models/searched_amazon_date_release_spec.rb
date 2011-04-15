require 'spec_helper'

describe SearchedAmazonDateRelease do
  describe "#save_for_later" do
    context "with no existing searched releases" do
      it "should save" do
        release = mock_model(Release)
        lambda do
          SearchedAmazonDateRelease.save_for_later(release)
        end.should change(SearchedAmazonDateRelease, :count).by(1)
      end
    end

    context "with an existing searched album" do
      it "should not save" do
        release = mock_model(Release)
        Factory(:searched_amazon_date_release, :release_id => release.id)
        lambda do
          SearchedAmazonDateRelease.save_for_later(release)
        end.should_not change(SearchedAmazonDateRelease, :count).by(1)
      end
    end
  end
end
