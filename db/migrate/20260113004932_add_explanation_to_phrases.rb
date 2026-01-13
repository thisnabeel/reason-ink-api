class AddExplanationToPhrases < ActiveRecord::Migration[8.1]
  def change
    add_column :phrases, :explanation, :text
  end
end
