# Full Postgres DB daily backup 

require_relative '../config/environment'
require 'date'

dow = Date.today.wday
target_dir = '/Users/dmitri/folio/pgbackup/'
target_file = "#{target_dir}folio#{dow}.gz"

puts "This is osx_backup.rb on #{Socket.gethostname} #{Date.today}"

system("/usr/local/bin/pg_dump --no-acl -d folio -Z5 > #{target_file}")

puts "Finished writing to #{target_file}"
