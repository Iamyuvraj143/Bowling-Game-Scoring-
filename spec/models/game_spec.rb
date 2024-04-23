require 'rails_helper'

RSpec.describe Game, type: :model do
  describe "#start_new_game" do
    it "creates 10 frames for a new game" do
      game = Game.create
      expect(game.frames.count).to eq(10)
    end
  end

  describe "#input_pins" do
    let(:game) { Game.create }

    it "updates the knocked_pins and rolls_taken of the current frame" do
      frame = game.frames.first
      game.input_pins(5, frame.number)
      frame.reload
      expect(frame.knocked_pins).to eq(5)
      expect(frame.rolls_taken).to eq(1)
    end

    it "calculates the score for the current frame after input_pins" do
      frame = game.frames.first
      game.input_pins(3, frame.number)
      frame.reload
      expect(frame.score).to eq(3)
    end

    it "does not update frames if the frame number is invalid" do
      frame = game.frames.first
      game.input_pins(5, 11)
      frame.reload
      expect(frame.knocked_pins).to eq(0)
      expect(frame.rolls_taken).to eq(0)
    end
  end

  describe "#total_score" do
    let(:game) { Game.create }

    it "calculates the total score of the game" do
      10.times do |i|
        frame = game.frames.find_by(number: i + 1)
        frame.update_columns(status: "completed", score: i + 1)
      end
      expect(game.total_score).to eq(55)
    end
  end
end

RSpec.describe Frame, type: :model do
  describe "#calculate_score" do
    let(:game) { Game.create }

    it "updates the score for a strike frame" do
      frame = game.frames.first
      frame.update_columns(knocked_pins: 10, rolls_taken: 1)
      frame.calculate_score
      expect(frame.score).to eq(10)
      expect(frame.status).to eq("pending strike score")
    end

    it "updates the score for a spare frame" do
      frame = game.frames.first
      frame.update_columns(knocked_pins: 9, rolls_taken: 2)
      frame.calculate_score
      expect(frame.score).to eq(9)
      expect(frame.status).to eq("completed")
    end

    it "updates the score for a regular frame" do
      frame = game.frames.first
      frame.update_columns(knocked_pins: 4, rolls_taken: 2)
      frame.calculate_score
      expect(frame.score).to eq(4)
      expect(frame.status).to eq("completed")
    end
  end

  describe "#update_rolls_taken" do
    let(:game) { Game.create }

    it "updates the rolls_taken for the frame" do
      frame = game.frames.first
      frame.update_rolls_taken
      expect(frame.rolls_taken).to eq(1)
    end

    it "updates the status to completed if it's the 3rd roll of the 10th frame" do
      frame = game.frames.last
      frame.update_columns(number: 10, rolls_taken: 2)
      frame.update_rolls_taken
      expect(frame.status).to eq("completed")
    end
  end
end
