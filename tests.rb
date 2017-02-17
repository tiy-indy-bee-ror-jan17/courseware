# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'
require 'pry'

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

  # B-Test-1
  def test_a_reading_is_destroyed_when_its_lesson_is_destroyed
    lesson_test = Lesson.create(course_id: 99, parent_lesson_id: 99, name: "Test Reading destroyed", pre_class_assignment_id: 1, in_class_assignment_id: 1)

    reading_test = Reading.create(lesson_id: lesson_test.id, caption: "Testy test", order_number: 99 )

    lesson_test.destroy
    refute Reading.find_by(caption: "Testy test")
  end

  #B-Test-2
  def test_destroying_a_course_destroys_its_associated_lessons
    course_test = Course.create(name: "Destroying lessons like a BAWSS")

    lesson_test = Lesson.create(course_id: course_test.id, parent_lesson_id: 99, name: "Destroy this lesson!", pre_class_assignment_id: 1, in_class_assignment_id: 1)

    lesson_test2 = Lesson.create(course_id: course_test.id, parent_lesson_id: 99, name: "Destroy this lesson too!", pre_class_assignment_id: 1, in_class_assignment_id: 1)

    course_test.destroy
    refute Lesson.find_by(name: "Destroy this lesson!")
    refute Lesson.find_by(name: "Destroy this lesson too!")
  end

  #B-Test-3
  def test_that_a_course_with_instructors_cannot_be_deleted
    course_test = Course.create(name: "Destroying lessons like a BAWSS")
    instructor_test = CourseInstructor.create(course_id: course_test.id)

    refute course_test.destroy
  end

  #B-Test-4
  def test_that_a_lesson_is_associated_with_its_in_class_assignment
    lesson_test = Lesson.create()
    assign_test = 
  end



#End of Class
end
