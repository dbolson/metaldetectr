class LastfmUsersController < ApplicationController
  before_filter :authenticate_user!, :except => [ :index ]
  respond_to :html, :xml, :json

  def new
  end

  def create
    @lastfm_users = LastfmUser.fetch_artists(current_user)
    respond_with(@lastfm_users)
  end
end
