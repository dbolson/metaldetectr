class ReleasesController < ApplicationController
  before_filter :authenticate_user!, :except => [ :index ]
  respond_to :html, :xml

  def index
    @releases = Release.find_with_params(params, current_user)
    respond_with(@releases)
  end
end
