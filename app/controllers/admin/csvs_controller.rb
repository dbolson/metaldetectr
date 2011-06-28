class Admin::CsvsController < ApplicationController
  before_filter :authenticate_admin!
  respond_to :html, :xml

  def index
  end

  def create
    CSVGenerator.save(params[:release][:csv].read)

    respond_to do |format|
      format.html {
        redirect_to root_path, :notice => 'Data uploaded.'
      }
    end
  end

  def show
    send_data(CSVGenerator.string_for_download, :type => 'text/csv; charset=utf-8; header-present', :filename => "metaldetectr_#{Date.today.to_s}.csv")
  end
end
