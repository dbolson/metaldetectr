require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'
require 'find_albums_job'

every(1.minutes, 'album.fetch') { Delayed::Job.enqueue FindAlbumsJob.new.perform }
