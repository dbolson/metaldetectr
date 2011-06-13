class FindAlbumsJob
  # Scrapes metal-archives.com for releases until all albums are searched.
  # It next finds all the releases on Amazon's US site and European sites to update the release dates if it can.
  # When all the albums have been searched, delete the obsolete data and send an email about the completion.
  def perform
    ::MetalDetectr::MetalArchives.generate_releases
  end

  # Sends an email that says the data for the month is gathered.
  def send_complete_notification
    ReleaseMailer.finished_gathering_releases.deliver
  end
end

# rake watchr &
# spork &

# rake jobs:work
# bundle exec clockwork lib/clock.rb

#generate list from metal archives
#generate dates from amazon
#show list
#user
#  provides last.fm credentials
#  get list of favorite/recommended bands
#  filter to only show those bands' releases

#last.fm
#Your API Key is 02eabadbf626b4e166ff7505bb78cac8
#Your secret is a9562ce4bbfcef5935152c5063deb668

=begin
Lists are all fine and good, but what I'm looking for is something that will tell me only about the 2-3 dozens of bands that I care about.
Wading through humongous columns of names, 99% of which I've never heard of or don't care about, is pretty annoying to do regularly (Yep,
I'm lazy, big surprise).

EDIT: They have it! Well, almost. At New Releases there's an RSS feed with artists that either (a) you've listened to at some point or
(b) their algorithm recommends you. Not customisable, unfortunately, but still pretty good.
=end

    #api_key = '02eabadbf626b4e166ff7505bb78cac8'
    #api_secret = 'a9562ce4bbfcef5935152c5063deb668'
    #lastfm = Lastfm.new(api_key, api_secret)
    #token = lastfm.auth.get_token
    ##lastfm.session = lastfm.auth.get_session(token)
    #artists = lastfm.library.get_artists('dbolson11')
=begin
find all the lastfm bands
save name
each band not checked
  check if there is a release
    (compare lowercase strings without accents)
    if so, flag release
  flag band as checked

viewing list
  filter by lastfm bands

searching ma
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

    #render :text => artists[10].inspect and return
    #user.getTopArtists
    #library.getArtists
