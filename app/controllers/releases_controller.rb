class ReleasesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  respond_to :html, :xml

  def index
    #@releases = Release.find_with_params(params.merge(:conditions => 'lastfm_users.release_id = releases.id').merge(:include => :lastfm_users))
    @releases = Release.find_with_params(params)

    #@releases = Release.includes(:lastfm_users).where('lastfm_users.release_id = releases.id')
    #@releases = Release.paginate(
    #  :per_page => 200,
    #  :page => 1,
    #  :include => :lastfm_users,
    #  :conditions => 'lastfm_users.release_id = releases.id'
    #)

    #@releases = Release.paginate(:page => 1, :per_page => 10, :conditions => { :last_fm => true })
    #@releases = Release.all
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
