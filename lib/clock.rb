require '/../config/boot'
require '/../config/environment'

every(5.minutes, 'album.fetch') { Delayed::Job.enqueue FindAlbumsJob.new }
