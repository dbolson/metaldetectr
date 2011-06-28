class CSVGenerator
  # Parses the uploaded csv file and saves each new release.
  # The order of the fields is: band, name, release dates, url.
  def self.save(data)
    csv = CSV.parse(data)
    csv.slice(1..csv.length).each do |row|
      Release.find_or_create_by_band_and_name(
        :band => row[0],
        :name => row[1],
        :us_date => row[2],
        :euro_date => row[3],
        :format => row[4],
        #:label => row[5],
        :url => row[5]
      )
    end
  end

  # Generates a csv string for downloading.
  def self.string_for_download
    releases = Release.all
    csv_string = CSV.generate do |csv|
      csv << ['Band', 'Release', 'US date', 'Euro date', 'Format', 'URL']
      releases.each { |release| csv << [ release.band, release.name, release.formatted_date(:us_date), release.formatted_date(:euro_date), release.format, release.url ]}
    end
    csv_string
  end
end
