class Release < ActiveRecord::Base
  FIELDS_WITH_METHODS = {
    'band' => [:band, :first, :downcase],
    'name' => [:name, :first, :downcase],
    'us_date' => [:us_date, :month],
    'euro_date' => [:euro_date, :month],
    'format' => [:format],
    nil => [:us_date, :month]
  }

  has_many :lastfm_users

  # Finds the releases with a name or band similar to the search term.
  scope :search, lambda { |search_term| {
    :conditions => [ 'name LIKE ? OR band LIKE ?', "%#{search_term}%", "%#{search_term}%" ]
  }}

  # Finds the releases from the generic search term and with the sorting parameters.
  # params[:search] = search term to check all fields for
  # params[:s] = sorted name
  # params[:d] = sorted direction
  # params[:p] = pagination page
  def self.find_with_params(params, user=nil)
    params.merge!(options_for_filter(params[:filter], user))

    if params[:search].present?
      releases = Release.search(params[:search]).paginate_sorted(params)
    else
      releases = Release.paginate_sorted(params)
    end
    releases
  end

  # Finds the releases sorted by the given column in the given direction.
  # params[:s] = sorted name
  # params[:d] = sorted direction
  # params[:p] = pagination page
  def self.paginate_sorted(params)
    params[:s] = default_sort(params[:s])
    params[:d] ||= 'asc'
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

  # Sets the sort order to what's passed or us_date.
  def self.default_sort(sort)
    sort || 'us_date'
  end

  # Sets the comparison operator to be greater than if the direction is nil or ascending,
  # or less than if the direction is descending.
  def self.comparison_operator(direction)
    (direction.nil? || direction == 'asc') ? :> : :<
  end

  # True if both value and comparison exist and
  # if the direction is ascending:
  #   true if value > comparison, false otherwise
  # if the direction is descending:
  #   true if value < comparison, false otherwise
  def self.values_compared?(value, comparison, direction)
    value &&
    comparison &&
    value.send(
      Release.comparison_operator(direction),
      comparison
    )
  end

  # Takes an array of symbols and calls them on the release instance if it
  # responds to them.
  # Example: release.chain_methods([:us_date, :month]) => release.us_date.month
  def chain_methods(methods)
    methods.inject(nil) do |memo, acc|
      target = memo ? memo : self
      target.respond_to?(acc) ? target.send(acc) : memo
    end
  end

  # True if the release is in the user's lastfm list, false otherwise.
  def lastfm_user?(user)
    lastfm_users.any? { |lastfm| lastfm.user_id == user.try(:id) }
  end

  # If the field exists, format it as a date.
  def formatted_date(field)
    self.send(field).strftime('%b %d, %Y') if self.send(field).present?
  end

  private

  # Sets additional query options based on the filter.
  def self.options_for_filter(filter, user)
    options = {}
    if filter == 'all'
      # no additional filters
    elsif filter == 'lastfm_upcoming' && user.try(:synced_with_lastfm?)
      options[:conditions] = [
        'releases.us_date >= ? AND lastfm_users.user_id = ?',
        Time.zone.now.beginning_of_month,
        user.id
      ]
    elsif filter == 'lastfm_all' && user.try(:synced_with_lastfm?)
      options[:conditions] = [ 'lastfm_users.user_id = ?', user.id ]
    else # default
      options[:conditions] = [ 'releases.us_date >= ?', Time.zone.now.beginning_of_month ]
    end
    options[:include] = :lastfm_users # always include lastfm_users
    options
  end
end
