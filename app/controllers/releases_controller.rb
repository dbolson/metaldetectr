class ReleasesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  respond_to :html, :xml

  def index
    if current_user
      @releases = Release.find_with_params(params.merge(:conditions => 'lastfm_users.release_id = releases.id').merge(:include => :lastfm_users))
    else
      @releases = Release.find_with_params(params)
    end

    @release = Release.new
    respond_with(@releases)
  end

  def new
    @release = Release.new
    respond_with(@release)  
  end

  def create
    render :text => 'creating release' and return
  end

  def edit
    @release = Release.find(params[:id])
    respond_with(@release)  
  end

  def update
    render :text => 'updating release' and return
  end
end
