# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'
require 'minitest_activerecord_assertions'

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
  include MiniTest::ActiveRecordAssertions

  def test_truth
    assert true
  end










  def test_lessons_readings_association
    assert_association Lesson, :has_many, :readings
    assert_association Reading, :belongs_to, :lesson
  end

  def test_lessons_courses_association
    assert_association Course, :has_many, :lessons
    assert_association Lesson, :belongs_to, :course
  end

  def test_courses_instructors_association
    assert_association Course, :has_many, :instructors
    assert_association CourseInstructor, :belongs_to, :course
  end

  def test_lessons_in_class_assignments_association
    assert_association Lesson, :has_many, :in_class_assignments
    assert_association Assignment, :belongs_to, :lesson
  end

  # def test_course_readings_association
  #   assert_association Course,
  # end
end

# Person A
  # Associate schools with terms (both directions).
  # Associate terms with courses (both directions). If a term has any courses associated with it, the term should not be deletable.
  # Associate courses with course_students (both directions). If the course has any students associated with it, the course should not be deletable.
  # Associate assignments with courses (both directions). When a course is destroyed, its assignments should be automatically destroyed.
  # Associate lessons with their pre_class_assignments (both directions).
  # Set up a School to have many courses through the school's terms.
  # Validate that Lessons have names.
  # Validate that Readings must have an order_number, a lesson_id, and a url.
  # Validate that the Readings url must start with http:// or https://. Use a regular expression.
  # Validate that Courses have a course_code and a name.
  # Validate that the course_code is unique within a given term_id.
  # Validate that the course_code starts with three letters and ends with three numbers. Use a regular expression.
  # Associate course_instructors with instructors (who happen to be users)
  # Associate assignments with assignment_grades (both directions)
  # Set up a Course to have many instructors through the Course's course_instructors.
  # Validate that an Assignment's due_at field is not before the Assignment's active_at.
  # A Course's assignments should be ordered by due_at, then active_at.
#
# Person B
  # Set up a Course to have many readings through the Course's lessons.
  # Validate that Schools must have name.
  # Validate that Terms must have name, starts_on, ends_on, and school_id.
  # Validate that the User has a first_name, a last_name, and an email.
  # Validate that the User's email is unique.
  # Validate that the User's email has the appropriate form for an e-mail address. Use a regular expression.
  # Validate that the User's photo_url must start with http:// or https://. Use a regular expression.
  # Validate that Assignments have a course_id, name, and percent_of_grade.
  # Validate that the Assignment name is unique within a given course_id.
  # Associate CourseStudents with students (who happen to be users)
  # Associate CourseStudents with assignment_grades (both directions)
  # Set up a Course to have many students through the course's course_students.
  # Associate a Course with its ONE primary_instructor. This primary instructor is the one who is referenced by a course_instructor which has its primary flag set to true.
  # A Course's students should be ordered by last_name, then first_name.
#
# Together
# Associate Lessons with their child_lessons (and vice-versa). Sort the child_lessons by id.
