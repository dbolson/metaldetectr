require 'spec_helper'

describe Release do
  it "has many lastfm_users" do
    release = Factory(:release)
    lastfm_user = Factory(:lastfm_user, :release => release)
    lastfm_user_2 = Factory(:lastfm_user, :release => release)
    release.lastfm_users.should == [lastfm_user, lastfm_user_2]
  end

  describe "#search" do
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

  describe "::find_with_params" do
    before do
      @release1 = Factory(:release, :name => 'foo', :band => 'foo', :us_date => Time.zone.now.beginning_of_month)
      @release2 = Factory(:release, :name => 'crum', :band => 'crum', :us_date => Time.zone.now.beginning_of_month)
      @release3 = Factory(:release, :name => 'fooing and baring', :band => 'foo and the bars', :us_date => Time.zone.now.beginning_of_month + (24 * 60 * 60))
    end

    it "should search" do
      params = { :search => 'foo' }
      Release.find_with_params(params).should == [@release1, @release3]
    end

    context "with field sort" do
      it "should search and sort" do
        params = { :search => 'foo', :s => 'us_date' }
        Release.find_with_params(params).should == [@release1, @release3]
      end

      context "with a sort direction" do
        it "should search and sort in the direction" do
          params = { :search => 'foo', :s => 'us_date', :d => 'desc' }
          Release.find_with_params(params).should == [@release3, @release1]
        end
      end
    end

    context "with a filter" do
      context "of all" do
        it "does not filter" do
          Release.find_with_params({ :filter => 'all' }).should == [@release1, @release2, @release3]
        end
      end

      context "that's blank" do
        it "filters by the beginning of the month" do
          old_release = Factory(:release, :us_date => 2.months.ago)
          Release.find_with_params({}).should == [@release1, @release2, @release3]
        end
      end

      context "for lastfm releases" do
        before do
          @user = Factory(:user, :lastfm_username => 'blah')
          @old_lastfm_release = Factory(:release, :name => 'Not Slayer', :us_date => 2.months.ago)
          @lastfm_release = Factory(:release, :name => 'foo', :us_date => Time.zone.now.beginning_of_month + 1)
          Factory(:lastfm_user, :user => @user, :release => @old_lastfm_release)
          Factory(:lastfm_user, :user => @user, :release => @lastfm_release)
        end

        context "when upcoming" do
          it "filters lastfm releases by the beginning of the month" do
            Release.find_with_params({ :filter => 'lastfm_upcoming' }, @user).should == [ @lastfm_release ]
          end

          context "with no user" do
            it "sorts upcoming releases" do
              Release.find_with_params({ :filter => 'lastfm_upcoming' }).should == [ @release1, @release2, @lastfm_release, @release3 ]
            end
          end
        end

        context "when all" do
          it "filters all lastfm releases" do
            Release.find_with_params({ :filter => 'lastfm_all' }, @user).should == [ @old_lastfm_release, @lastfm_release ]
          end

          context "with no user" do
            it "sorts upcoming releases" do
              Release.find_with_params({ :filter => 'lastfm_upcoming' }).should == [ @release1, @release2, @lastfm_release, @release3 ]
            end
          end
        end

        context "for all" do
          it "filters by lastfm releases for the current user" do
            Factory(:lastfm_user, :user => @user, :release => @old_lastfm_release)
            Factory(:lastfm_user, :user => @user, :release => @lastfm_release)
            Release.find_with_params({ :filter => 'lastfm_all' }, @user).should == [ @old_lastfm_release, @lastfm_release ]
          end
        end
      end
    end
  end  

  describe "::paginate_sorted" do
    context "with no column" do
      it "should sort by release date" do
        release1 = Factory(:release, :name => 'Zebras', :us_date => 'January 3rd')
        release2 = Factory(:release, :name => 'Albacas', :us_date => 'January 4th')
        release3 = Factory(:release, :name => 'Camels', :us_date => 'January 2nd')
        Release.paginate_sorted({}).should == [release3, release1, release2]
      end
    end

    context "with no direction" do
      it "should sort in descending order" do
        release1 = Factory(:release, :name => 'Zebras')
        release2 = Factory(:release, :name => 'Albacas')
        release3 = Factory(:release, :name => 'Camels')
        params = { :s => 'name' }
        Release.paginate_sorted(params).should == [release2, release3, release1]
      end
    end

    context "with a given sort order" do
      it "lists the releases in that order" do
        release1 = Factory(:release, :name => 'Zebras')
        release2 = Factory(:release, :name => 'Albacas')
        release3 = Factory(:release, :name => 'Camels')
        params = { :s => 'name', :d => 'asc' }
        Release.paginate_sorted(params).should == [release2, release3, release1]
      end
    end
  end

  describe "::default_sort" do
    context "with a sort" do
      it "is the sort" do
        Release.default_sort('foo').should == 'foo'
      end
    end

    context "with no sort" do
      it "is 'us_date'" do
        Release.default_sort(nil).should == 'us_date'
      end
    end
  end

  describe "::comparison_operator" do
    context "with no direction" do
      it "is greater than" do
        Release.comparison_operator(nil).to_s.should == '>'
      end
    end

    context "with an ascending direction" do
      it "is greater than" do
        Release.comparison_operator('asc').to_s.should == '>'
      end
    end

    context "with a descending direction" do
      it "is less than" do
        Release.comparison_operator('desc').to_s.should == '<'
      end
    end
  end

  describe "::values_compared?" do
    context "with no current value" do
      it "is false" do
        Release.values_compared?(nil, 'foo', 'asc').should be_false
      end
    end

    context "with no comparison value" do
      it "is false" do
        Release.values_compared?('foo', nil, 'asc').should be_false
      end
    end

    context "with both current and comparison values" do
      context "and ascending order" do
        context "and the current value > than the comparison value" do
          it "is true" do
            Release.values_compared?('foo', 'bar', 'asc').should be_true
          end
        end

        context "and the current value < than the comparison value" do
          it "is false" do
            Release.values_compared?('bar', 'foo', 'asc').should be_false
          end
        end

        context "and the current value == than the comparison value" do
          it "is false" do
            Release.values_compared?('foo', 'foo', 'asc').should be_false
          end
        end
      end

      context "and descending order" do
        context "and the current value > than the comparison value" do
          it "is false" do
            Release.values_compared?('foo', 'bar', 'desc').should be_false
          end
        end

        context "and the current value < than the comparison value" do
          it "is true" do
            Release.values_compared?('bar', 'foo', 'desc').should be_true
          end
        end

        context "and the current value == than the comparison value" do
          it "is false" do
            Release.values_compared?('foo', 'foo', 'desc').should be_false
          end
        end
      end
    end
  end

  describe "#lastfm_user?" do
    context "without a user" do
      it "is false" do
        release = Factory(:release)
        release.lastfm_user?(nil).should be_false
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

  describe "#formatted_date" do
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
