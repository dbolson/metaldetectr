class CreateSearchedAmazonDateReleases < ActiveRecord::Migration
  def self.up
    create_table :searched_amazon_date_releases do |t|
      t.references :release

      t.timestamps
    end
  end

  def self.down
    drop_table :searched_amazon_date_releases
  end
end
