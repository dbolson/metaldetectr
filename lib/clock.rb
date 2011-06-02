require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

every(10.minutes, 'album.fetch') { Delayed::Job.enqueue FindAlbumsJob.new }
