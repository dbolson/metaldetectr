require 'spec_helper'

describe Release do
  it "has many lastfm_users" do
    release = Factory(:release)
    lastfm_user = Factory(:lastfm_user, :release => release)
    lastfm_user_2 = Factory(:lastfm_user, :release => release)
    release.lastfm_users.should == [lastfm_user, lastfm_user_2]
  end

  describe "#lastfm_user?" do
    context "without a user" do
      it "is false" do
        release = Factory(:release)
        release.lastfm_user?.should be_false
      end
    end

    context "with a user" do
      context "who has a lastfm release" do
        it "is true" do
          release = Factory(:release)
          user = Factory(:user)
          last_fm_user = Factory(:lastfm_user, :user => user, :release => release)
          release.lastfm_user?(user).should be_true
        end
      end

      context "who does not have a lastfm release" do
        it "is false" do
          release = Factory(:release)
          user = Factory(:user)
          release.lastfm_user?(user).should be_false
        end
      end
    end
  end

  context "finds all releases from generic search term" do
    ['name', 'band'].each do |field|
      context "when term is the #{field}" do
        it "should find the releases" do
          release1 = Factory(:release, field.to_sym => 'Foo1')
          release2 = Factory(:release, field.to_sym => 'bar')
          release3 = Factory(:release, field.to_sym => 'foo and the bars')
          Release.search('foo').should == [release1, release3]
        end
      end
    end
  end

  context "::find_with_params" do
    ['name', 'band'].each do |field|
      before do
        Release.delete_all
        @release1 = Factory(:release, field.to_sym => 'Foo1', :us_date => 'January 31st')
        @release2 = Factory(:release, field.to_sym => 'bar', :us_date => 'January 31st')
        @release3 = Factory(:release, field.to_sym => 'foo and the bars', :us_date => 'February 3rd')
      end

      it "should filter by #{field}" do
        params = { :search => 'foo' }
        Release.find_with_params(params).should == [@release1, @release3]
      end

      context "with field sort" do
        it "should filter by #{field} and sort" do
          params = { :search => 'foo', :s => 'us_date' }
          Release.find_with_params(params).should == [@release1, @release3]
        end
      end

      context "with field sort" do
        it "should filter by #{field} and sort" do
          params = { :search => 'foo', :s => 'us_date', :d => 'desc' }
          Release.find_with_params(params).should == [@release3, @release1]
        end
      end
    end
  end  

  context "::find_sorted" do
    context "with no column" do
      it "should sort by release date" do
        release1 = Factory(:release, :name => 'Zebras', :us_date => 'January 3rd')
        release2 = Factory(:release, :name => 'Albacas', :us_date => 'January 4th')
        release3 = Factory(:release, :name => 'Camels', :us_date => 'January 2nd')
        Release.find_sorted({}).should == [release3, release1, release2]
      end
    end

    context "with no direction" do
      it "should sort in descending order" do
        release1 = Factory(:release, :name => 'Zebras')
        release2 = Factory(:release, :name => 'Albacas')
        release3 = Factory(:release, :name => 'Camels')
        params = { :s => 'name' }
        Release.find_sorted(params).should == [release2, release3, release1]
      end
    end

    context "with a given sort order" do
      it "lists the releases in that order" do
        release1 = Factory(:release, :name => 'Zebras')
        release2 = Factory(:release, :name => 'Albacas')
        release3 = Factory(:release, :name => 'Camels')
        params = { :s => 'name', :d => 'asc' }
        Release.find_sorted(params).should == [release2, release3, release1]
      end
    end
  end

  context "#formatted_date" do
    context "with the us_date field" do
      it "should show the release date in a specific format" do
        release = Factory(:release, :us_date => 'Jan 02, 2010')
        release.formatted_date(:us_date).should == 'Jan 02, 2010'
      end

      context "with no release date" do
        it "should be nil" do
          release = Factory(:release, :us_date => nil)
          release.formatted_date(:us_date).should be_nil
        end
      end
    end

    context "with the euro_date field" do
      it "should show the release date in a specific format" do
        release = Factory(:release, :euro_date => 'Jan 03, 2010')
        release.formatted_date(:euro_date).should == 'Jan 03, 2010'
      end

      context "with no release date" do
        it "should be nil" do
          release = Factory(:release, :euro_date => nil)
          release.formatted_date(:euro_date).should be_nil
        end
      end
    end
  end
end
