Factory.define :album_link do |f|
  f.sequence(:page) { |n| n }
  f.sequence(:url) { |n| "http://metal-archives.com/release.php?id=#{n}" }
end
