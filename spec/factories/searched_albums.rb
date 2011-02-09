Factory.define :searched_album do |f|
  f.album_link { |a| a.association(:album_link) }
end
