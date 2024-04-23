class CreateFrames < ActiveRecord::Migration[6.0]
  def change
    create_table :frames do |t|
      t.integer :number
      t.integer :knocked_pins, default: 0
      t.integer :score, default: 0
      t.string :status, default: "active"
      t.references :game, foreign_key: true

      t.timestamps
    end
  end
end
