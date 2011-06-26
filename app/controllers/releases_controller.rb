class ReleasesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  respond_to :html, :xml

  def index
    # usability
    # http://vesess.com/blog/new-usability-enhancements-for-curdbee-filtering-sorting-and-batch-actions/

    #if current_user
    #  @releases = Release.find_with_params(params.merge(:conditions => 'lastfm_users.release_id = releases.id').merge(:include => :lastfm_users))
    #else
    #  @releases = Release.find_with_params(params)
    #end

    if params[:filter] == 'all'
    elsif params[:filter] == 'lastfm_upcoming'
      params[:conditions] = [ 'us_date >= ? AND lastfm_users.release_id = releases.id', Time.now.beginning_of_month ]
      params[:include] = :lastfm_users
    elsif params[:filter] == 'lastfm_all'
      params[:conditions] = 'lastfm_users.release_id = releases.id'
      params[:include] = :lastfm_users
    else # default
      params[:conditions] = [ 'us_date >= ?', Time.now.beginning_of_month ]
    end

    ::Rails.logger.info "\n\nparams: #{params.inspect}\n\n"
    @releases = Release.find_with_params(params)

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
