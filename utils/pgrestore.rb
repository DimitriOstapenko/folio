#!/home/oms/.rvm/rubies/ruby-2.6.4/bin/ruby
# restore is run on the same day as backup, but later
# use this script on a backup server, run as postgres, or whoever the owner of db is
# 
# N.B! dropdb will fail if db is accessed by other client(s) - stop apache before running! (root cron)
#
#This script is different on debian and OSX. Version below is for OSX
# OSX: /usr/local/bin/createdb 
# deb: /usr/bin/createdb

require_relative '../config/environment'
require 'date'

dow = Date.today.wday.to_s
target = '/Users/dmitri/folio/pgbackup/folio'+dow+'.gz'
puts "This is restore.rb on #{Socket.gethostname} #{Date.today}"

puts "Dropping db 'folio'"
system("/usr/local/bin/dropdb --if-exists folio -e")
puts "Creating db 'folio'"
system("/usr/local/bin/createdb folio")
puts "Restoring DB folio - full restore from latest backup #{target}"
system("/bin/cat #{target} | /usr/bin/gunzip | /usr/local/bin/psql folio")
puts "done."

