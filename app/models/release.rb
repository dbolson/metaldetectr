class Release < ActiveRecord::Base
  has_many :lastfm_users

  # Finds the releases with a name, band, or label similar to the search term.
  scope :search, lambda { |search_term| {
    :conditions => ['name LIKE ? OR band LIKE ? OR label LIKE ?', "%#{search_term}%", "%#{search_term}%", "%#{search_term}%"]
  }}

  class << self
    # Finds the releases from the generic search term and with the sorting parameters.
    # params[:search] = search term to check all fields for
    # params[:s] = sorted name
    # params[:d] = sorted direction
    # params[:p] = pagination page
    def find_with_params(params)
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
    def find_sorted(params)
      params[:s] ||= 'us_date'
      params[:d] ||= 'desc'
      params[:p] = self.all.count if params[:p].try(:downcase) == 'all'
      params[:conditions] ||= {}
      self.paginate(
        :page => params[:page],
        :order => "#{params[:s]} #{params[:d]}",
        :per_page => params[:p],
        :conditions => params[:conditions],
        :include => params[:include]
      )
    end  
  end

  # True if the release is in the user's lastfm list,
  # false otherwise.
  def lastfm_user?(user=nil)
    lastfm_users.any? { |lastfm| lastfm.user_id == user.try(:id) }
  end

  def formatted_date(field)
    self.send(field).strftime('%b %d, %Y') if self.send(field).present?
  end
end
