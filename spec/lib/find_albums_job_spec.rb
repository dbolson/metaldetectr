require 'spec_helper'
require 'metal_detectr'
require 'find_albums_job'

describe FindAlbumsJob do
  describe "#perform" do
    it "should generate the releases" do
      MetalDetectr::MetalArchives.should_receive(:generate_releases)
      FindAlbumsJob.new.perform
    end
  end
end
