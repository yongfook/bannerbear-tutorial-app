class AddUrlToArticles < ActiveRecord::Migration[6.0]
  def change
  	add_column :articles, :url, :string
  end
end
