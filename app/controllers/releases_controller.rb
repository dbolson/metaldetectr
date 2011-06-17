class ReleasesController < ApplicationController
  respond_to :html, :xml

  def index
    #lastfm = Lastfm.new(LASTFM_API_KEY, LASTFM_API_SECRET)
    #artists = lastfm.library.get_artists('dbolson11')
    #render :text => artists[0..10].inspect and return

    @releases = Release.find_with_params(params)
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
