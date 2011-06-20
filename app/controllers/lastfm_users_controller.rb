class LastfmUsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  respond_to :html, :xml, :json

  def new
    @user = current_user
    respond_with(@user)
  end

  def create
    @lastfm_users = LastfmUser.fetch_artists(current_user)
    @user = current_user
    @lastfm_users_count = LastfmUser.where(:user_id => current_user.id).count

    #respond_with(@lastfm_users_count)
    #render 'new'

    #if @lastfm_users
    #  respond_to do |format|
    #    format.html { redirect_to(releases_path, :notice => 'Created release.') }
    #    format.xml  { render :xml => @lastfm_users, :status => :created, :location => @lastfm_users }
    #  end
    #else
    #  render 'new'
    #end
  end
end
=begin
lastfm page

text field for username
has delete button too
"sync" button
spinner when syncing
success message when finished

main page

pagination
filter for 20, 50, 100, all
filter for lastfm list, all list
=end
