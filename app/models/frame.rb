class Frame < ApplicationRecord
  belongs_to :game

  validates :number, presence: true
  validates :knocked_pins, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }, allow_nil: true, if: :validate_knocked_pins?

  def validate_knocked_pins?
    (1..9).include?(number)
  end

  def calculate_score
    if strike?
      update_strike_score
    elsif spare?
      update_spare_score
    else
      update_regular_score
    end
    pending_spare_score
    pending_strike_score
  end

  def strike?
    knocked_pins == 10 && rolls_taken == 1
  end

  def spare?
    knocked_pins.to_i == 10 && rolls_taken == 2
  end

  def update_rolls_taken
    self.rolls_taken += 1
    self.status = "completed" if  self.rolls_taken == 3 && self.number ==10
  end

  private

  def update_strike_score
    if self.status == "active"
      self.score = 10
      self.status = "pending strike score"
      self.next_roll_pins = 2
      save!
    end
  end

  def update_spare_score
    if self.status == "active"
      self.score = 10
      self.status = "pending spare score"
      self.next_roll_pins = 1
      save!
    end
  end

  def update_regular_score
    if self.status == "active"
      self.score = knocked_pins.to_i
      if self.rolls_taken == 2
        self.status = "completed" unless self.strike? || self.spare?
      end
      save!
    end
  end

  def pending_strike_score 
   @last_frame = self.game.frames.find_by(status: "pending strike score")
    if @last_frame.present? && (@last_frame.number != self.number || @last_frame.number ==10 ) 
      if self.rolls_taken == 1
        last_frame_score = @last_frame.score + self.knocked_pins
      elsif self.rolls_taken == 2
        last_frame_score = @last_frame.score + self.knocked_pins - self.ball_1_knocked_pins
      end
          
      @last_frame.update_column(:score, last_frame_score)
      if @last_frame.next_roll_pins > 0
         @last_frame.update_column(:next_roll_pins, @last_frame.next_roll_pins-1)
         @last_frame.update_column(:status, "completed") if @last_frame.next_roll_pins == 0
      elsif
        @last_frame.update_column(:status, "completed")
      end
    end
  end

  def pending_spare_score
    @last_frame = self.game.frames.find_by(status: "pending spare score")
    if @last_frame.present? && self.rolls_taken == 1 && @last_frame.next_roll_pins == 1
      last_frame_score = @last_frame.score + self.knocked_pins
      @last_frame.update_column(:score, last_frame_score)
      @last_frame.update_column(:status, "completed")
      @last_frame.update_column(:next_roll_pins, 0)
    end
  end
end
