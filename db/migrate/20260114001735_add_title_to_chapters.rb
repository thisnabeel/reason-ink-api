class AddTitleToChapters < ActiveRecord::Migration[8.1]
  def change
    add_column :chapters, :title, :string
  end
end
