class GamesController < ApplicationController
  before_action :set_game, only: [:show, :update]

  def create
    @game = Game.create!
    render json: @game, status: :created
  end

  def update
    knocked_pins = params[:pins_knocked_down].to_i
    frame_number = params[:frame_number].to_i

    @game.input_pins(knocked_pins, frame_number)
    render json: {
      id: @game.id,
      total_score: @game.total_score,
      frames: @game.frames.order(number: :DESC).map do |frame|
        {
          number: frame.number,
          knocked_pins: frame.knocked_pins,
          rolls_taken: frame.rolls_taken,
          status: frame.status,
          score: frame.score,
          ball_1: frame.ball_1_knocked_pins,
          ball_2: frame.ball_2_knocked_pins,
          ball_3: frame.ball_3_knocked_pins
        }
      end
    }, status: :ok
  end

  def show
    game_details = {
      id: @game.id,
      total_score: @game.total_score,
      frames: @game.frames.order(number: :DESC).where(status: "completed").map do |frame|
        {
          number: frame.number,
          knocked_pins: frame.knocked_pins,
          rolls_taken: frame.rolls_taken,
          status: frame.status,
          score: frame.score,
          ball_1: frame.ball_1_knocked_pins,
          ball_2: frame.ball_2_knocked_pins,
          ball_3: frame.ball_3_knocked_pins
        }
      end
    }
    render json: game_details, status: :ok
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end
end
