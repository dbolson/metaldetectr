class ReleasesController < ApplicationController
  respond_to :html, :xml

  def index
    #current_user = User.first
    #LastfmArtist.fetch_artists(current_user)

    #@releases = Release.find_with_params(params)
    @releases = Release.paginate(:page => 1, :per_page => 10, :conditions => { :last_fm => true })

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
