# coding: utf-8
class LastfmArtist < ActiveRecord::Base
  def self.fetch_artists(user)
    lastfm = Lastfm.new(LASTFM_API_KEY, LASTFM_API_SECRET)
    artists = lastfm.library.get_artists(user.lastfm_username)

    artists.collect do |artist|
      lastfm_artist = self.find_or_create_by_name(artist['name'], :user_id => user.id)
      band = URI.decode(lastfm_artist.name).strip
      if release = Release.find_by_band(band)
        release.update_attribute(:last_fm, true)
      end
    end
  end
end

=begin
Lists are all fine and good, but what I'm looking for is something that will tell me only about the 2-3 dozens of bands that I care about.
Wading through humongous columns of names, 99% of which I've never heard of or don't care about, is pretty annoying to do regularly (Yep,
I'm lazy, big surprise).

EDIT: They have it! Well, almost. At New Releases there's an RSS feed with artists that either (a) you've listened to at some point or
(b) their algorithm recommends you. Not customisable, unfortunately, but still pretty good.
=end

=begin
sync
  find or create
  if band is in big list
    compare names without encoding
    tag in big list

  filter big list by tag
=end

=begin
    {
      "name"=>"Georg Friedrich Händel",
      "playcount"=>"115",
      "tagcount"=>"0",
      "mbid"=>"27870d47-bb98-42d1-bf2b-c7e972e6befc",
      "url"=>"http://www.last.fm/music/Georg+Friedrich+H%C3%A4ndel",
      "streamable"=>"1",
      "image"=>[
        {"size"=>"small",
          "content"=>"http://userserve-ak.last.fm/serve/34/55525281.jpg"}, {"size"=>"medium",
          "content"=>"http://userserve-ak.last.fm/serve/64/55525281.jpg"}, {"size"=>"large",
          "content"=>"http://userserve-ak.last.fm/serve/126/55525281.jpg"}, {"size"=>"extralarge",
          "content"=>"http://userserve-ak.last.fm/serve/252/55525281.jpg"}, {"size"=>"mega",
          "content"=>"http://userserve-ak.last.fm/serve/_/55525281/Georg+Friedrich+Hndel.jpg"
        }
      ]
    }
=end
#user.getTopArtists
#library.getArtists
