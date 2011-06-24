module ApplicationHelper
  # Shows the flash messages if they exist.
  def flash_messages
    if flash[:alert].present?
      content_tag(:div, :id => 'alert') { flash[:alert] }
    elsif flash[:notice].present?
      content_tag(:div, :id => 'notice') { flash[:notice] }
    end
  end
end
