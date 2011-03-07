require 'metal_detectr'

namespace :app do
  namespace :metal_archives do
    desc "Fetch the paginated result urls for a search from metal-archives.com"
    task :fetch_paginated_result_urls => :environment do
      MetalDetectr::MetalArchives.fetch_paginated_result_urls
    end

    #task :fetch_album_urls => [:environment, :fetch_paginated_result_urls] do
    desc "Fetch the album urls from a paginated search result url from metal-archives.com"
    task :fetch_album_urls => :environment do
      paginated_urls = MetalDetectr::MetalArchives.urls_to_search
      MetalDetectr::MetalArchives.fetch_album_urls(paginated_urls)
      MetalDetectr::MetalArchives.complete_album_urls_fetch_if_finished!
    end

    #task :fetch_album_urls => [:environment, :fetch_paginated_result_urls,:fetch_album_urls] do
    desc "Fetch the albums from metal-archives.com"
    task :fetch_albums => :environment do
      #album_urls = MetalDetectr::MetalArchives.albums_from_urls
      #MetalDetectr::MetalArchives.create_releases(album_urls)
      MetalDetectr::MetalArchives.albums_from_urls
      MetalDetectr::MetalArchives.complete_releases_from_urls_if_finished!
    end
  end
end
