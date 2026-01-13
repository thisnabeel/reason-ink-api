class CreatePhrases < ActiveRecord::Migration[8.1]
  def change
    create_table :phrases do |t|
      t.references :concept, null: false, foreign_key: true
      t.text :body

      t.timestamps
    end
  end
end
