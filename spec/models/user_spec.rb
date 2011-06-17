require 'spec_helper'

describe User do
  context "has a state" do
    it "should start as 'default'" do
      user = Factory(:user)
      user.should be_default
    end

    context "that changes to adminstrator" do
      it "should change" do
        user = Factory(:user)
        user.adminify
        user.should be_admin
      end
    end

    context "that changes from administrator" do
      it "should change" do
        user = Factory(:user, :state => 'admin')
        user.deadminify
        user.should be_default
      end
    end
  end
end
