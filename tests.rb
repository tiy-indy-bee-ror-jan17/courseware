# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'
require "pry"

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

  def test_truth
    assert true
  end

  def test_lessons_has_readings
    lesson = Lesson.create
    new_reading = Reading.create
    lesson.readings << new_reading
    lesson.destroy
    refute Reading.find_by(id: new_reading.id)
  end

  def test_course_has_lessons
    course = Course.create
    new_lesson = Lesson.create
    course.lessons << new_lesson
    course.destroy
    refute Lesson.find_by(id: new_lesson.id)
  end

  def test_courses_has_course_instructors
    course = Course.create
    new_instructor = CourseInstructor.create(course_id: course.id)
    refute course.course_instructors.count == 0
    # course = Course.create
    # new_instructor = CourseInstructor.create
    # course = Course.create
    # course.course_instructors << new_instructor
    # refute course.course_instructors.count == 0

  end

  def test_course_instructors_is_deleted_when_course_is_deleted
    course = Course.create
    new_instructor = CourseInstructor.create
    course.course_instructors << new_instructor
    course.destroy
    assert course.course_instructors.exists? == true


  end

  def test_lessons_to_in_class_assignments

  end

  def test_lessons_to_preclass_assignments

  end

end
