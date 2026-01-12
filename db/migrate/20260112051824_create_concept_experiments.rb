class CreateConceptExperiments < ActiveRecord::Migration[8.1]
  def change
    create_table :concept_experiments do |t|
      t.references :concept, null: false, foreign_key: true
      t.references :experiment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
