module ReleasesHelper
  def admin?
    true
  end

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
    link_to(column_heading, root_path(
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
    content_tag(:div, :class => 'view_release_limits') do
      'View: ' +
      pagination_link('20', params) << ' ' <<
      pagination_link('50', params) << ' ' <<
      pagination_link('100', params) << ' ' <<
      pagination_link('all', params)
    end
  end

  # Adds the "editable" class if the current user is logged in.
  def classes_for_release_row(is_admin, release)
    if is_admin
      "release_#{release.id} editable"
    else
      "release_#{release.id}"
    end
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

  def select_for_release_month
    select_tag('release_month',
      options_for_select([
        ['October 2010', releases_path(:start_date => '2010-10-01', :end_date => '2010-10-31')],
        ['September 2010', releases_path(:start_date => '2010-09-01', :end_date => '2010-09-30')]
      ])
    )
  end

  private

  # Creates an anchor tag to paginate the amount_to_paginate and sets the class to selected if it is the currently selected pagination amount.
  # This does not select the "all" option because it does not equal the total amount returned, but that's okay for now.
  def pagination_link(amount_to_paginate, params)
    content_tag :a,
                amount_to_paginate.to_s.capitalize,
                :href => releases_path(:p => amount_to_paginate, :start_date => params[:start_date], :end_date => params[:end_date]),
                :class => params[:p] == amount_to_paginate ? 'selected' : nil
  end
end
