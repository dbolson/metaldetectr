require 'spec_helper'

describe LastfmUser do
  describe "associations" do
    context "to a user" do
      it "requires a user" do
        lastfm_user = Factory.build(:lastfm_user, :user => nil)
        lastfm_user.should_not be_valid
        lastfm_user.errors[:user].should_not be_nil
      end

      it "belongs to a user" do
        user = Factory(:user)
        lastfm_user = Factory(:lastfm_user, :user => user)
        lastfm_user.user.should == user
      end
    end

    context "to a release" do
      it "does not require a release" do
        lastfm_user = Factory.build(:lastfm_user, :release => nil)
        lastfm_user.should be_valid
      end

      it "belongs to a release" do
        release = Factory(:release)
        lastfm_user = Factory(:lastfm_user, :release => release)
        lastfm_user.release.should == release
      end
    end
  end

  describe "#fetch_artists" do
    it "connects to last.fm" do
      library = mock('library', :get_artists => [])
      lastfm = mock('Lastfm', :library => library)
      user = mock_model(User, :lastfm_username => 'foo')
      Lastfm.should_receive(:new).and_return(lastfm)
      LastfmUser.fetch_artists(user)
    end

    context "with found artists" do
      context "that are new" do
        it "saves them" do
          release = Factory(:release, :band => 'bar')
          release = Factory(:release, :band => 'baz')
          artist_1 = mock_model(LastfmUser, :name => 'bar')
          artist_2 = mock_model(LastfmUser, :name => 'baz')

          library = mock('library', :get_artists => [{ 'name' => 'bar' }, { 'name' => 'baz' }])
          lastfm = mock('Lastfm', :library => library)
          user = mock_model(User, :lastfm_username => 'foo')

          Lastfm.stub(:new).and_return(lastfm)
          lambda do
            LastfmUser.fetch_artists(user)
          end.should change(LastfmUser, :count).by(2)
        end
      end

      context "that already exist" do
        it "skips them" do
          release = Factory(:release, :band => 'baz')
          existing = Factory(:lastfm_user, :name => 'bar')
          artist_1 = mock_model(LastfmUser, :name => 'bar')
          artist_2 = mock_model(LastfmUser, :name => 'baz')

          library = mock('library', :get_artists => [{ 'name' => 'bar' }, { 'name' => 'baz' }])
          lastfm = mock('Lastfm', :library => library)
          user = mock_model(User, :lastfm_username => 'foo')

          Lastfm.stub(:new).and_return(lastfm)
          lambda do
            LastfmUser.fetch_artists(user)
          end.should change(LastfmUser, :count).by(1)
        end
      end
    end
  end
end
