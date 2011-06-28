module ReleasesHelper
  # True if all the releases are collected, false otherwise.
  def finished_collecting_metal_archives_releases?
    CompletedStep.finished_collecting_metal_archives_releases?
  end

  # Provides the opposite direction the column is currently set to.
  def reverse_sort_column_direction(direction)
    direction == 'desc' ? 'asc' : 'desc'
  end  

  # Creates a link to sort the data of the column name up or down, depending on what's in the params.
  def link_to_sort(column_name, params)
    column_heading = params[:column_name] || column_name.humanize
    link_to(column_heading, releases_path(
      :s => column_name,
      :d => reverse_sort_column_direction(params[:d]),
      :p => params[:p],
      :search => params[:search],
      :start_date => params[:start_date],
      :end_date => params[:end_date])
    )
  end

  # Links to the release's url if it exists.
  def link_to_more(release)
    if release.url.present?
      link_to 'More', release.url, :target => '_blank'
    end
  end

  # Creates links to paginate by 20, 50, 100, or all releases.
  def pagination_toggle(params)
    content_tag(:div,
      content_tag(:span, 'View:') << ' ' <<
      pagination_link('20', params) << ' ' <<
      pagination_link('50', params) << ' ' <<
      pagination_link('100', params) << ' ' <<
      pagination_link('all', params),
      :class => 'view_release_limits'
    )
  end

  # Adds the "editable" class if the current user is an admin.
  # Adds the "lastfm" class if the current user has the release in his lastfm list.
  def classes_for_release_row(release, user=nil)
    classes = "release_#{release.id}" 
    classes << ' editable' if user.try(:admin?)
    classes << ' lastfm' if user.try(:synced_with_lastfm?) && release.lastfm_user?(user)
    classes
  end

  # Creates a table cell with a class name, content, and title for either inline editing the field or viewing the content
  # if it's truncated.
  # Options hash includes:
  # class: the class name
  # content: the content to display
  # is_admin: true if the current user is an administrator, false otherwise
  # length (optional): the length of the string to truncate
  def release_field(options)
    class_name = options[:class]
    title = options[:content]
    truncate_length = options[:length] || 35

    if options[:is_admin]
      title = 'click to edit'
      content = options[:content]
    else
      content = truncate options[:content], :length => truncate_length
      title = nil if title && title.length < truncate_length
    end

    content_tag(:td, :class => class_name, :title => title) do
      content
    end
  end

  # Creates a select tag for the filter types to view the releases list.
  def release_filter_select(user, filter=nil)
    content_tag(:div) do
      select_tag(:releases_filter, options_for_select(options_for_release_filter_select(user), filter)) <<
      label_tag(:releases_filter, 'Filter:', :id => 'releases_filter_label')
    end
  end

  private

  # Creates an anchor tag to paginate the amount_to_paginate and sets the class to selected if it is the currently selected pagination amount.
  # This does not select the "all" option because it does not equal the total amount returned, but that's okay for now.
  def pagination_link(amount_to_paginate, params)
    ::Rails.logger.info "params: #{params.inspect}\n\n"
    content_tag(:a,
                amount_to_paginate.to_s.capitalize,
                :href => releases_path(:p => amount_to_paginate,
                                       :start_date => params[:start_date],
                                       :end_date => params[:end_date],
                                       :filter => params[:filter],
                                       :search => params[:search]
                                      ),
                :class => params[:p] == amount_to_paginate ? 'selected' : nil)
  end

  # Creates the options for the relese filter select.
  # Includes lastfm options if the user has them.
  def options_for_release_filter_select(user)
    options = [['Upcoming', ''], ['All', 'all']]
    if synced_with_lastfm?(user)
      options << ['Upcoming Lastfm', 'lastfm_upcoming'] << ['All Lastfm', 'lastfm_all']
    end
    options
  end
end
