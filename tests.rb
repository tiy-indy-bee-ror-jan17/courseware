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

  def test_truth
    assert true
  end

  def test_a_lesson_has_readings
    lesson = Lesson.create
    reading = Reading.create(lesson_id: lesson.id)
    assert lesson.readings.count == 1
  end

  def test_a_course_has_lessons
    course = Course.create
    lesson = Lesson.create(course_id: course.id)
    assert course.lessons.count == 1
  end

  def test_courses_have_course_instructors
    course = Course.create
    instructor = CourseInstructor.create(course_id: course.id)
    assert course.course_instructors.length == 1
  end

  def test_a_lesson_has_in_class_assignments
    ica = Assignment.create
    lesson = Lesson.create(in_class_assignment_id: ica.id)
    refute lesson.in_class_assignment.nil?
  end

  def test_a_course_has_readings_through_lessons
    course = Course.create
    lesson = Lesson.create(course_id: course.id)
    reading = Reading.create(lesson_id: lesson.id)
    assert course.readings.count == 1
  end

  def test_a_school_must_have_a_name
    school = School.new(name: 'UNL')
    refute school.name.length == 0
  end

end
