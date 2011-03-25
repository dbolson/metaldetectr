require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

every(5.minutes, 'album.fetch') { Delayed::Job.enqueue FindAlbumsJob.new }
