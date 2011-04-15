Factory.define :searched_release do |f|
  f.album_url { |a| a.association(:album_url) }
end
