require 'spec_helper'

describe SearchedAlbum do
  describe "::" do
    context "with no existing searched albums" do
      it "should save" do
        album_url = mock_model(AlbumUrl)
        lambda do
          SearchedAlbum.save_for_later(album_url)
        end.should change(SearchedAlbum, :count).by(1)
      end
    end

    context "with an existing searched album" do
      it "should not save" do
        album_url = mock_model(AlbumUrl)
        Factory(:searched_album, :album_url_id => album_url.id)
        lambda do
          SearchedAlbum.save_for_later(album_url)
        end.should_not change(SearchedAlbum, :count).by(1)
      end
    end
  end
end
