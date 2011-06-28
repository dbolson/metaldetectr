require 'spec_helper'

describe ApplicationHelper do
  context "shows a flash message" do
    context "with a notice" do
      it "should show the message" do
        flash[:notice] = 'this is a notice'
        helper.flash_messages.should == content_tag(:div, :id => 'notice') { 'this is a notice' }
      end
    end

    context "with an alert" do
      it "should show the message" do
        flash[:alert] = 'this is an alert'
        helper.flash_messages.should == content_tag(:div, :id => 'alert') { 'this is an alert' }
      end
    end

    context "with no message" do
      it "should not show a message" do
        helper.flash_messages.should be_nil
      end
    end

    context "with a notice and an alert" do
      it "should show the alert message" do
        flash[:notice] = 'this is a notice'
        flash[:alert] = 'this is an alert'
        helper.flash_messages.should == content_tag(:div, :id => 'alert') { 'this is an alert' }
      end
    end
  end

  describe "#synced_with_lastfm?" do
    context "with a user" do
      context "who is synced with lastfm" do
        it "is true" do
          helper.should be_synced_with_lastfm(mock_model(User, :synced_with_lastfm? => true))
        end
      end

      context "who is not synced with lastfm" do
        it "is false" do
          helper.should_not be_synced_with_lastfm(mock_model(User, :synced_with_lastfm? => false))
        end
      end
    end

    context "without a user" do
      it "is false" do
        helper.should_not be_synced_with_lastfm
      end
    end
  end

  describe "#admin?" do
    context "when there is no current user" do
      it "should be false" do
        helper.admin?(nil).should be_false
      end
    end

    context "when the current user is not an administrator" do
      it "should be false" do
        user = mock_model(User, :admin? => false)
        helper.admin?(user).should be_false
      end
    end

    context "when the current user is an administrator" do
      it "should be true" do
        user = mock_model(User, :admin? => true)
        helper.admin?(user).should be_true
      end
    end
  end  
end
