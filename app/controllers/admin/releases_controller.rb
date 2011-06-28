class Admin::ReleasesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :xml

  def new
    @release = Release.new
    respond_with(@release)
  end

  def create
    @release = Release.new(params[:release])

    if @release.save
      respond_to do |format|
        format.html { redirect_to(releases_path, :notice => 'Created release.') }
        format.xml  { render :xml => @release, :status => :created, :location => @release }
      end
    else
      render 'new'
    end
  end

  def edit
    @release = Release.find(params[:id])
    respond_with(@release)
  end

  def update
    @release = Release.find(params[:id])

    if @release.update_attributes(params[:release])
      respond_to do |format|
        format.html { redirect_to(releases_path, :notice => 'Updated release.') }
        format.xml  { render :xml => @release, :status => :created, :location => @release }
      end
    else
      respond_to do |format|
        format.html { render 'edit' }
      end
    end
  end

  def destroy
    @release = Release.find(params[:id])
    @release.destroy

    respond_to do |format|
      format.html { redirect_to(releases_path, :notice => 'Deleted release.') }
      format.xml  { head :ok }
    end
  end
end
