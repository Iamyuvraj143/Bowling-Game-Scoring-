class Game < ApplicationRecord
  has_many :frames
  after_create :start_new_game

  def start_new_game
    (1..10).each do |frame_number|
      frames.create(number: frame_number)
    end
  end

  def input_pins(knocked_pins, frame_number)
    current_frame = frames.find_by(number:frame_number, status:"active")  || frames.find_by(number:10)
    return unless current_frame
    if current_frame.ball_1_knocked_pins.nil?
      current_frame.ball_1_knocked_pins = knocked_pins
    elsif current_frame.ball_2_knocked_pins.nil?
      current_frame.ball_2_knocked_pins = knocked_pins
    else
      current_frame.ball_3_knocked_pins = knocked_pins
    end
    current_frame.knocked_pins = current_frame.knocked_pins + knocked_pins
    current_frame.update_rolls_taken
    current_frame.save!
    current_frame.calculate_score
  end


  def total_score
    frames.where(status:"completed").sum(:score)
  end
end
