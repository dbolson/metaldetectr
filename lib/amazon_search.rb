module MetalDetectr
  class AmazonSearch
    Amazon::Ecs.options = {
      :aWS_access_key_id => 'AKIAJCWVKJBETJQ24R3Q',
      :aWS_secret_key => '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'
    }

    # Searches amazon.com for the release to find the US release date.
    def self.find_us_release_date(release)
      self.search_response_groups_for_release_date(release)
    end

    # Searches various amazon.com local country sites for the release to find the European release date.
    # Priority of countries is United Kingdom, Germany, France.
    def self.find_euro_release_date(release)
      [:uk, :de, :fr].each do |country|
        results = self.search_response_groups_for_release_date(release, country)
        return results unless results.nil?
      end
      nil
    end

    private

    # Searches for release in Music and MP3Downloads response groups for the local country Amazon site.
    # If the artist and title match, return the release date.
    def self.search_response_groups_for_release_date(release, country=:us)
      search_results = self.item_search_in_music(release, country)
      if search_results.has_error?
        search_results = self.item_search_in_mp3downloads(release, country)
      end
      return nil if search_results.has_error?

      search_results.items.each do |item|
        if formatted_attribute(item.get('itemattributes/artist')) == formatted_attribute(release.band) &&
           formatted_attribute(item.get('itemattributes/title')) == formatted_attribute(release.name)
          return item.get('itemattributes/releasedate')
        end
      end
    end    

    # Strips out "The" if it exists, removes leading and trailing whitespace, and down cases, othewise it return ''.
    def self.formatted_attribute(attribute)
      attribute.present? ? attribute.gsub(/^the/i, '').strip.downcase : ''
    end

    # Searches for the release based on a keyword search in the Music category using the band and release names.
    # An optional country will search on that specifc amazon.com local site.
    def self.item_search_in_music(release, country=:us)
      params = { :search_index => 'Music', :response_group => 'Medium', :artist => release.band, :title => release.name }
      params.merge!(:country => country) if country.present?
      Amazon::Ecs.item_search("#{release.band}, #{release.name}", params)
    end

    # Searches for the release based on a keyword search in the MP3Downloads category using the band and release names.
    # An optional country will search on that specifc amazon.com local site.
    def self.item_search_in_mp3downloads(release, country=:us)
      params = { :search_index => 'MP3Downloads', :response_group => 'Medium', :title => release.name }
      params.merge!(:country => country) if country.present?
      Amazon::Ecs.item_search("#{release.band}, #{release.name}", params)
    end    
  end
end
