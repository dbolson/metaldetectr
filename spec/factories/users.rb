Factory.define :user do |f|
  f.sequence(:email) { |s| "steve#{s}@test.com" }
  f.password 'foobar'
end
