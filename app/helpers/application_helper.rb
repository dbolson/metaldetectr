module ApplicationHelper
  # Shows the flash messages if they exist.
  def flash_messages
    if flash[:alert].present?
      content_tag(:div, :id => 'alert') { flash[:alert] }
    elsif flash[:notice].present?
      content_tag(:div, :id => 'notice') { flash[:notice] }
    end
  end

  # True if the user is logged in and synced to lastfm, false otherwise.
  def synced_with_lastfm?(user=nil)
    user.try(:synced_with_lastfm?)
  end

  # True if the user is an administrator.
  def admin?(user)
    user.try(:admin?)
  end  
end
