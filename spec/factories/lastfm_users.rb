Factory.define :lastfm_user do |f|
  f.association :release
  f.association :user
  f.sequence(:name) {|n| "band_#{n}" }
end
