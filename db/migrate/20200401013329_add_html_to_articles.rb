class AddHtmlToArticles < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :html, :text
  end
end
