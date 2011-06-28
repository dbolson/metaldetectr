#require 'metal_archives'

namespace :app do
  namespace :metal_archives do
    desc "Fetch the paginated result urls for a search from metal-archives.com"
    task :fetch_paginated_result_urls => :environment do
      MetalArchives.fetch_paginated_result_urls
    end

    #task :fetch_album_urls => [:environment, :fetch_paginated_result_urls] do
    desc "Fetch the album urls from a paginated search result url from metal-archives.com"
    task :fetch_album_urls => :environment do
      paginated_urls = MetalArchives.urls_to_search
      MetalArchives.fetch_album_urls(paginated_urls)
      MetalArchives.complete_album_urls_fetch_if_finished!
    end

    #task :fetch_album_urls => [:environment, :fetch_paginated_result_urls,:fetch_album_urls] do
    desc "Fetch the albums from metal-archives.com"
    task :fetch_albums => :environment do
      MetalArchives.releases_from_urls
      MetalArchives.complete_releases_from_urls_if_finished!
    end
  end
end
