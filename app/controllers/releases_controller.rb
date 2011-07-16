class ReleasesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  respond_to :html, :xml

  def index
    # usability
    # http://vesess.com/blog/new-usability-enhancements-for-curdbee-filtering-sorting-and-batch-actions/

    @releases = Release.find_with_params(params, current_user)
    respond_with(@releases)
  end
end
