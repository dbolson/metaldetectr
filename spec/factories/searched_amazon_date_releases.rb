Factory.define :searched_amazon_date_release do |f|
  f.release { |a| a.association(:release) }
end
