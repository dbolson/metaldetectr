require 'spec_helper'

describe SearchedRelease do
  describe "#save_for_later" do
    context "with no existing searched albums" do
      it "should save" do
        album_url = mock_model(AlbumUrl)
        lambda do
          SearchedRelease.save_for_later(album_url)
        end.should change(SearchedRelease, :count).by(1)
      end
    end

    context "with an existing searched album" do
      it "should not save" do
        album_url = mock_model(AlbumUrl)
        Factory(:searched_release, :album_url_id => album_url.id)
        lambda do
          SearchedRelease.save_for_later(album_url)
        end.should_not change(SearchedRelease, :count).by(1)
      end
    end
  end
end
