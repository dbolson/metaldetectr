class CreatePaginatedSearchResultUrls < ActiveRecord::Migration
  def self.up
    create_table :paginated_search_result_urls do |t|
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :paginated_search_result_urls
  end
end
