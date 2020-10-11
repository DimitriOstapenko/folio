# Full Postgres DB daily backup 

require_relative '../config/environment'
require 'date'

dow = Date.today.wday
target_dir = '/home/folio/backup/'
target_file = "#{target_dir}folio#{dow}.gz"

puts "This is  backup.rb on #{Socket.gethostname} #{Date.today}"

system("/usr/bin/pg_dump --no-acl -d folio -Z5 > #{target_file}")

puts "Finished writing to #{target_file}"

