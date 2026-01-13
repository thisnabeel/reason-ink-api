class CreateExamples < ActiveRecord::Migration[8.1]
  def change
    create_table :examples do |t|
      t.string :title
      t.text :body
      t.references :concept, null: false, foreign_key: true

      t.timestamps
    end
  end
end
