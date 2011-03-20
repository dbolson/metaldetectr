Factory.define :searched_album do |f|
  f.album_url { |a| a.association(:album_url) }
end
