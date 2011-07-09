class ReleasesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  respond_to :html, :xml

  def index
    # usability
    # http://vesess.com/blog/new-usability-enhancements-for-curdbee-filtering-sorting-and-batch-actions/
    # "#{Date::MONTHNAMES[date.month]} #{date.year}"

    @releases = Release.find_with_params(params, current_user)
    @release = Release.new
    respond_with(@releases)
  end
end

Release.class_eval do
  FIELDS_WITH_METHODS = {
    'band' => [:band, :first, :downcase],
    'name' => [:name, :first, :downcase],
    'us_date' => [:us_date, :month],
    'euro_date' => [:euro_date, :month],
    'format' => [:format],
    nil => [:us_date, :month]
  }

  def chain_methods(methods)
    methods.inject(nil) do |memo, acc|
      if memo.nil?
        if self.respond_to?(acc)
          self.send(acc)
        else
          memo
        end
      else
        memo.send(acc)
      end
    end
  end
end
