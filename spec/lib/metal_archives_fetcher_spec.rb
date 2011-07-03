require 'spec_helper'

describe MetalArchivesFetcher do
  describe "::generating_releases" do
    context "when finished fetching releases" do
      before do
        CompletedStep.stub(:finished_fetching_releases?).and_return(true)
      end

      context "when finished updating releases from amazon" do
        before do
          CompletedStep.stub(:finished_updating_releases_from_amazon?).and_return(true)
        end

        it "resets the Metal Archives data already fetched" do
          CompletedStep.should_receive(:destroy_all)
          SearchedAmazonDateRelease.should_receive(:destroy_all)
          MetalArchivesFetcher.generate_releases
        end
      end

      context "when still updating releases from amazon" do
        before do
          CompletedStep.stub(:finished_updating_releases_from_amazon?).and_return(false)
        end

        context "with no searched releases" do
          it "finds all the releases" do
            SearchedAmazonDateRelease.stub(:last).and_return(nil)
            Release.should_receive(:all).and_return([])
            MetalArchivesFetcher.generate_releases
          end
        end

        context "with some searched releases" do
          it "finds the first release not searched" do
            SearchedAmazonDateRelease.stub(:last).and_return(mock_model(SearchedAmazonDateRelease, :release_id => '20'))
            Release.should_receive(:where).with('id >= 20').and_return([])
            MetalArchivesFetcher.generate_releases
          end
        end

        it "updates the release dates from amazon" do
          release = mock_model(Release)
          MetalArchivesFetcher.stub(:release_dates_to_search_from_amazon).and_return([release])
          MetalArchivesFetcher.stub(:complete_release_dates_update_if_finished!)
          AmazonSearch.should_receive(:find_us_date)
          AmazonSearch.should_receive(:find_euro_date)
          release.should_receive(:update_attributes)
          MetalArchivesFetcher.generate_releases
        end

        context "and times out" do
          it "saves the searched release to check later" do
            release = mock_model(Release)
            MetalArchivesFetcher.stub(:release_dates_to_search_from_amazon).and_return([release])
            AmazonSearch.stub(:find_us_date).and_raise(Exception)
            SearchedAmazonDateRelease.should_receive(:save_for_later).with(release)
            MetalArchivesFetcher.generate_releases
          end
        end
      end
    end

    context "when still fetching releases" do
      before do
        CompletedStep.stub(:finished_fetching_releases?).and_return(false)
        @agent = stub('MetalArchives::Agent')
        MetalArchives::Agent.stub(:new).and_return(@agent)
      end

      context "while searching the paginated albums" do
        context "with no band" do
          it "does nothing" do
            albums = [[ "<span>no band</span>" ]]
            @agent.should_receive(:paginated_albums).and_return([albums])
            MetalArchivesFetcher.generate_releases
          end
        end

        context "with a found band" do
          context "that already exists" do
            it "does not save it" do
              existing_release = mock_model(Release, :name => 'Chaotic World', :band => 'Anonymous Hate')
              albums = [[
                "<a href=\"http://www.metal-archives.com/bands/Anonymous_Hate/3540310799\" title=\"Anonymous Hate (BR)\">Anonymous Hate</a>",
                "<a href=\"http://www.metal-archives.com/albums/Anonymous_Hate/Chaotic_World/302588\">Chaotic World</a>",
                "Full-length",
                "April 2011 <!-- 2011-04-00 -->"
              ]]
              @agent.should_receive(:paginated_albums).and_return([albums])
              @agent.stub(:album_name).with(albums[0])
              @agent.stub(:band_name).with(albums[0])
              @agent.stub(:release_type).with(albums[0])
              @agent.stub(:album_url).with(albums[0])
              @agent.stub(:country).with(albums[0])
              @agent.stub(:release_date).with(albums[0])
              lambda do
                Release.should_receive(:find_or_create_by_name_and_band).and_return(existing_release)
              end.should_not change(Release, :count).by(1)
              MetalArchivesFetcher.generate_releases
            end
          end

          it "creates a release" do
            albums = [[
              "<a href=\"http://www.metal-archives.com/bands/Anonymous_Hate/3540310799\" title=\"Anonymous Hate (BR)\">Anonymous Hate</a>",
              "<a href=\"http://www.metal-archives.com/albums/Anonymous_Hate/Chaotic_World/302588\">Chaotic World</a>",
              "Full-length",
              "April 2011 <!-- 2011-04-00 -->"
            ]]
            @agent.should_receive(:paginated_albums).and_return([albums])
            @agent.should_receive(:album_name).with(albums[0])
            @agent.should_receive(:band_name).with(albums[0])
            @agent.should_receive(:release_type).with(albums[0])
            @agent.should_receive(:album_url).with(albums[0])
            @agent.should_receive(:country).with(albums[0])
            @agent.should_receive(:release_date).with(albums[0])
            Release.should_receive(:find_or_create_by_name_and_band)
            MetalArchivesFetcher.generate_releases
          end
        end

        it "sets the releases collected step to complete" do
          @agent.stub(:paginated_albums).and_return([])
          CompletedStep.should_receive(:find_or_create_by_step).with(CompletedStep::ReleasesCollected)
          MetalArchivesFetcher.generate_releases
        end
      end
    end
  end
end
