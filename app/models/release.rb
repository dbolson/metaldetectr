class Release < ActiveRecord::Base
  # Finds the releases with a name, band, or label similar to the search term.
  scope :search, lambda { |search_term| {
    :conditions => ['name LIKE ? OR band LIKE ? OR label LIKE ?', "%#{search_term}%", "%#{search_term}%", "%#{search_term}%"]
  }}

  # Finds the releases from the generic search term and with the sorting parameters.
  # params[:search] = search term to check all fields for
  # params[:s] = sorted name
  # params[:d] = sorted direction
  # params[:p] = pagination page
  def self.find_with_params(params)
    if params[:search].present?
      releases = Release.search(params[:search]).find_sorted(params)
    else
      releases = Release.find_sorted(params)
    end
    releases
  end

  # Finds the releases sorted by the given column in the given direction.
  # params[:s] = sorted name
  # params[:d] = sorted direction
  # params[:p] = pagination page
  def self.find_sorted(params)
    params[:s] ||= 'us_date'
    params[:d] ||= 'desc'
    params[:p] = self.all.count if params[:p].try(:downcase) == 'all'
    self.paginate(:page => params[:page], :order => "#{params[:s]} #{params[:d]}", :per_page => params[:p])
  end  

  def formatted_date(field)
    self.send(field).strftime('%b %d, %Y') if self.send(field).present?
  end
end
