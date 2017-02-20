require 'minitest/autorun'
require 'minitest/pride'
require './migration'
require './application'

# ActiveRecord::Base.logger = Logger.new(STDOUT)

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
require_relative 'tests/lesson_tests'
require_relative 'tests/course_tests'

def rand_a_z(len=rand(26))
  ('a'..'z').to_a.sample(len).join
end

def rand_course_code
  rand_a_z(3) + rand(100..999).to_s
end
