require 'spec_helper'

describe ApplicationHelper do
  context "shows a flash message" do
    context "with a notice" do
      it "should show the message" do
        flash[:notice] = 'this is a notice'
        flash_messages.should == content_tag(:div, :id => 'notice') { 'this is a notice' }
      end
    end

    context "with an alert" do
      it "should show the message" do
        flash[:alert] = 'this is an alert'
        flash_messages.should == content_tag(:div, :id => 'alert') { 'this is an alert' }
      end
    end

    context "with no message" do
      it "should not show a message" do
        flash_messages.should be_nil
      end
    end

    context "with a notice and an alert" do
      it "should show the alert message" do
        flash[:notice] = 'this is a notice'
        flash[:alert] = 'this is an alert'
        flash_messages.should == content_tag(:div, :id => 'alert') { 'this is an alert' }
      end
    end
  end
end
