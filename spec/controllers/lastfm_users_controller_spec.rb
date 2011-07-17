require 'spec_helper'

describe LastfmUsersController do
  context "#new" do
    context "with a user" do
      before do
        user = mock_model(User).as_null_object
        request.env['warden'] = mock(Warden, :authenticate => user, :authenticate! => user)
        sign_in user
      end

      it "is successful" do
        get :new
        response.should be_success
      end

      it "renders the new template" do
        get :new
        response.should render_template('lastfm_users/new')
      end
    end

    context "without a user" do
      it "redirects" do
        get :new
        response.should be_redirect
      end
    end
  end

  context "#create" do
    context "with a user" do
      before do
        user = mock_model(User).as_null_object
        request.env['warden'] = mock(Warden, :authenticate => user, :authenticate! => user)
        sign_in user
      end

      #it "is successful" do
      #  lastfm_user = mock_model(LastfmUser)
      #  LastfmUser.stub(:fetch_artists).and_return([lastfm_user])
      #  post :create
      #  response.should be_redirect
      #end

      it "assigns lastfm_users" do
        lastfm_user = mock_model(LastfmUser)
        LastfmUser.should_receive(:fetch_artists).and_return([lastfm_user])
        post :create
        assigns[:lastfm_users].should == [lastfm_user]
      end

      #it "renders the new template"
    end

    context "without a user" do
      it "redirects" do
        post :create
        response.should be_redirect
      end
    end
  end
end
