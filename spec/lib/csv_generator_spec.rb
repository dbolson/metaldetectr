require 'spec_helper'
require 'csv_generator'

describe MetalDetectr::CSVGenerator do
  context "saving" do
    context "with new releases" do
      it "should save the releases" do
        lambda do
          MetalDetectr::CSVGenerator.save(csv_string)
        end.should change(Release, :count).by(2)
      end
    end

    context "with existing releases" do
      it "should not save the releases" do
        Factory(:release, :band => 'Nocturnal Blood', :name => 'The Morbid Celebration', :us_date => Date.new(2010, 10, 26), :euro_date => Date.new(2010, 10, 27), :format => 'Full-length', :url => 'release.php?id=280771')
        csv = "Band,Release,Date,Format,URL\nNocturnal Blood,The Morbid Celebration,\"Oct 26, 2010\",Full-length,release.php?id=280771\nNocturnal Blood - imported,The Morbid Celebration,\"Oct 27, 2010\",Full-length,release.php?id=280771"
        lambda do
          MetalDetectr::CSVGenerator.save(csv)
        end.should change(Release, :count).by(1)
      end
    end
  end

  context "creating string for download" do
    context "with existing releases" do
      it "should generate a csv string" do
        Factory(:release, :band => 'Nocturnal Blood', :name => 'The Morbid Celebration', :us_date => Date.new(2010, 10, 26), :euro_date => Date.new(2010, 10, 27), :format => 'Full-length', :url => 'release.php?id=280771')
        Factory(:release, :band => 'Nocturnal Blood 2', :name => 'The Morbid Celebration 2', :us_date => Date.new(2010, 10, 27), :format => 'Full-length', :url => 'release.php?id=280772')
        MetalDetectr::CSVGenerator.string_for_download.should == csv_string
      end
    end
  end
end

# CSV string with headings and release data.
def csv_string
  "Band,Release,US date,Euro date,Format,URL\nNocturnal Blood,The Morbid Celebration,\"Oct 26, 2010\",\"Oct 27, 2010\",Full-length,release.php?id=280771\nNocturnal Blood 2,The Morbid Celebration 2,\"Oct 27, 2010\",,Full-length,release.php?id=280772\n"
end
