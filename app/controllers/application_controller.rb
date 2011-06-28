class ApplicationController < ActionController::Base
  protect_from_forgery

  # Require a user to be logged in and an administrator.
  def authenticate_admin!
    authenticate_user!
    unless current_user.admin?
      respond_to do |format|
        format.html { redirect_to(releases_path, :notice => 'You are not allowed access.') }
        format.xml  { :status => :forbidden }
      end
      redirect_to root_path
    end
  end
end
