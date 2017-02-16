# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

# Include both the migration and the app itself
require './migration'
require './application'

# Overwrite the development database connection with a test connection.
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def setup
    @user = User.new()
    @lesson1 = Lesson.create(name: "lesson 1")
    @reading1 = Reading.create(caption: "reading 1", lesson_id: 1)
    @reading2 = Reading.create(caption: "reading 2", lesson_id: 1)
  end

  def test_truth
    assert true
  end

  def test_lessons_associate_reading
    assert_equal 2, lesson1.readings.length
    assert_equal "lesson 1", reading1.lesson.name
  end

  def test_lessons_associate_courses
    
  end



end
