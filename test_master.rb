require 'minitest/autorun'
require 'minitest/pride'
require './migration'
require './application'

ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)

require_relative 'tests/user_tests'
require_relative 'tests/assignment_tests'
require_relative 'tests/misc_tests'
require_relative 'tests/mypetocean_tests'
