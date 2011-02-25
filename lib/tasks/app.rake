namespace :app do
  namespace :metal_archives do
    desc "Fetch the paginated result urls for a search from metal-archives.com"
    task :fetch_paginated_result_urls => :environment do
    end

    desc "Fetch the album urls from a paginated search result url from metal-archives.com"
    task :fetch_album_urls => [:environment, :fetch_paginated_result_urls] do
    end

    desc "Fetch the albums from the paginated search urls from metal-archives.com"
    task :fetch_albums => [:environment, :fetch_album_urls] do
    end
  end
end
