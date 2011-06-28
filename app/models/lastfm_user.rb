# coding: utf-8
class LastfmUser < ActiveRecord::Base
  belongs_to :release
  belongs_to :user

  validates :user, :presence => true, :associated => true

  # Finds the artists in the user's last.fm library, imports them if they are not already
  # in his list, and returns the new artists.
  def self.fetch_artists(user)
    lastfm = Lastfm.new(LASTFM_API_KEY, LASTFM_API_SECRET)
    artists = lastfm.library.get_artists(user.lastfm_username) # TODO: make asyncronous?

    artists.collect do |artist|
      lastfm_artist = self.find_or_initialize_by_name(artist['name'], :user => user)

      if lastfm_artist.new_record?
        band = URI.decode(lastfm_artist.name).strip # TODO: make this work (better?)
        if release = Release.find_by_band(band)
          lastfm_artist.release_id = release.id
          lastfm_artist.save
          lastfm_artist
        end
      end
    end.compact
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
