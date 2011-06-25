require 'spec_helper'

describe User do
  describe "has a state" do
    it "starts as 'default'" do
      user = Factory(:user)
      user.should be_default
    end

    context "that changes to adminstrator" do
      it "changes" do
        user = Factory(:user)
        user.adminify
        user.should be_admin
      end
    end

    context "that changes from administrator" do
      it "changes" do
        user = Factory(:user, :state => 'admin')
        user.deadminify
        user.should be_default
      end
    end
  end

  describe "updating" do
    let(:user) { Factory(:user) }

    context "with a new email" do
      it "updates" do
        user.update_attributes(:email => 'new@email.com')
        user.reload.email.should == 'new@email.com'
      end
    end

    context "with a password" do
      it "updates" do
        encrypted_password = user.encrypted_password
        user.update_attributes(:password => 'newpass', :password_confirmation => 'newpass')
        user.reload.encrypted_password.should_not == encrypted_password
      end
    end

    context "with remember_me" do
      it "updates" do
        user.update_attributes(:remember_me => 1)
        user.reload.remember_me.should == 1
      end
    end

    context "with a lastfm_username" do
      it "updates" do
        user.update_attributes(:lastfm_username => 'foo')
        user.reload.lastfm_username.should == 'foo'
      end
    end
  end

  describe "#update_with_password" do
    let(:user) { Factory(:user) }

    context "without a new password" do
      it "updates" do
        params = { :email => 'foo@bar.com' }
        user.email.should_not == 'foo@bar.com'
        user.update_with_password(params).should be_true
        user.email.should == 'foo@bar.com'
      end
    end

    context "with a new password" do
      context "that is valid" do
        it "updates" do
          params = { :email => 'foo@bar.com', :password => 'newpass', :password_confirmation => 'newpass' }
          user.email.should_not == 'foo@bar.com'
          user.update_with_password(params)
          user.reload.email.should == 'foo@bar.com'
        end
      end

      context "that is invalid" do
        before do
          @params = { :email => 'foo', :password => 'newpass', :password_confirmation => 'badpass' }
        end

        it "sets errors" do
          user.update_with_password(@params)
          user.errors[:email].should_not be_nil
          user.errors[:password].should_not be_nil
        end

        it "is false" do
          user.update_with_password(@params).should be_false
          user.reload.email.should_not == 'foo@bar.com'
        end
      end

      context "with a set password and confirmation" do
        before do
          @params = { :password => 'newpass', :password_confirmation => 'newpass' }
        end

        it "clears out the password" do
          user.update_with_password(@params)
          user.password.should be_nil
        end

        it "clears out the password confirmation" do
          user.update_with_password(@params)
          user.password_confirmation.should be_nil
        end
      end
    end
  end

  describe "#synced_with_lastfm?" do
    context "with a lastfm username" do
      it "is true" do
        user = Factory(:user, :lastfm_username => 'foo')
        user.should be_synced_with_lastfm
      end
    end

    context "without a lastfm username" do
      it "is false" do
        user = Factory(:user)
        user.should_not be_synced_with_lastfm
      end
    end
  end
end
