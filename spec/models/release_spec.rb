require 'spec_helper'

describe Release do
  describe "::create_from" do
    it "should save the release" do
      album = {
        :album => 'Foo',
        :band => 'Bar',
        :release_type => 'Full-length',
        :label => 'Foo Bar Records',
        :url => '/foo',
        :release_date => '1/2/2001',
      }
      lambda do
        Release.create_from(album)
      end.should change(Release, :count).by(1)
    end

    context "with a release with the same name" do
      it "should save the release" do
        Factory(:release, :name => 'Foo')
        album = {
          :album => 'Foo',
          :band => 'Bar',
          :release_type => 'Full-length',
          :label => 'Foo Bar Records',
          :url => '/foo',
          :release_date => '1/2/2001',
        }
        lambda do
          Release.create_from(album)
        end.should change(Release, :count).by(1)
      end
    end

    context "with a release with the same band" do
      it "should save the release" do
        Factory(:release, :band => 'Bar')
        album = {
          :album => 'Foo',
          :band => 'Bar',
          :release_type => 'Full-length',
          :label => 'Foo Bar Records',
          :url => '/foo',
          :release_date => '1/2/2001',
        }
        lambda do
          Release.create_from(album)
        end.should change(Release, :count).by(1)
      end
    end

    context "with a release with the same url" do
      it "should save the release" do
        Factory(:release, :url => '/foo')
        album = {
          :album => 'Foo',
          :band => 'Bar',
          :release_type => 'Full-length',
          :label => 'Foo Bar Records',
          :url => '/foo',
          :release_date => '1/2/2001',
        }
        lambda do
          Release.create_from(album)
        end.should change(Release, :count).by(1)
      end
    end

    context "with a release with the same name, band, and url" do
      it "should not save the release" do
        Factory(:release, :name => 'Foo', :band => 'Bar', :url => '/foo')
        album = {
          :album => 'Foo',
          :band => 'Bar',
          :release_type => 'Full-length',
          :label => 'Foo Bar Records',
          :url => '/foo',
          :release_date => '1/2/2001',
        }
        lambda do
          Release.create_from(album)
        end.should_not change(Release, :count).by(1)
      end
    end
  end
end
