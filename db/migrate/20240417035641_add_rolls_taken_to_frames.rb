class AddRollsTakenToFrames < ActiveRecord::Migration[6.0]
  def change
    add_column :frames, :rolls_taken, :integer, default: 0
    add_column :frames, :next_roll_pins, :integer, default: 0
    add_column :frames, :ball_1_knocked_pins, :integer
    add_column :frames, :ball_2_knocked_pins, :integer
    add_column :frames, :ball_3_knocked_pins, :integer
  end
end
