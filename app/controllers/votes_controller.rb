class VotesController < ApplicationController
  before_action :require_user!

  def create
    command_bus.call(vote_command)
    redirect_back fallback_location: events_path, notice: "Vote recorded."
  rescue ActiveModel::ValidationError => error
    redirect_back fallback_location: events_path, alert: error.model.errors.full_messages.to_sentence
  rescue ActiveRecord::RecordNotFound
    redirect_to events_path, alert: "Event not found."
  end

  private

  def vote_command
    attributes = { event_id: params[:event_id].to_s, user_id: current_user_id }
    case vote_params[:direction]
    when "up" then Catalog::UpvoteEvent.new(attributes)
    when "down" then Catalog::DownvoteEvent.new(attributes)
    else
      raise ActiveModel::ValidationError, direction_error
    end
  end

  def vote_params
    params.fetch(:vote, ActionController::Parameters.new).permit(:direction)
  end

  def direction_error
    command = Catalog::UpvoteEvent.new
    command.errors.add(:direction, "must be like or dislike")
    command
  end
end
