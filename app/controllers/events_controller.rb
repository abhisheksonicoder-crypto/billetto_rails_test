class EventsController < ApplicationController
  PAGE_SIZE = 24

  def index
    page = params[:page].to_i
    page = 1 if page < 1
    scope = Event.includes(:vote_tally).order(:starts_at, :id)
    @events = scope.offset((page - 1) * PAGE_SIZE).limit(PAGE_SIZE)
    @next_page = page + 1 if scope.offset(page * PAGE_SIZE).exists?
    @previous_page = page - 1 if page > 1
    @votes_by_event_id = votes_for(@events)
  end

  def show
    @event = Event.includes(:vote_tally).find(params[:id])
    @vote = current_user_id.present? && EventVote.find_by(event_id: @event.id, user_id: current_user_id)
  end

  private

  def votes_for(events)
    return {} if current_user_id.blank?

    EventVote.where(user_id: current_user_id, event_id: events.map(&:id)).index_by(&:event_id)
  end
end
