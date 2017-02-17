# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

# Include both the migration and the app itself
require './migration'
require './application'

# Overwrite the development database connection with a test
# connection.
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

# Gotta run migrations before we can run tests.  Down will fail
# the first time, so we wrap it in a begin/rescue.
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def test_truth
    assert true
  end

  def affirm(expression, assocation)
    expression.class.to_s.include? assocation
  end






































































  def test_lessons_readings_association
    lesson = Lesson.create()
    reading = Reading.create(lesson_id: lesson.id)
    # p reading
    # p lesson
    assert_equal lesson.id, reading.lesson_id
  end

  def test_lessons_courses_association
    course = Course.create()
    lesson = Lesson.create(course_id: course.id)
    # test1 = course
    # test2 = lesson
    # p test1
    # p test2
    assert_equal course.id, lesson.course_id
  end

  def test_courses_instructors_association
    course = Course.create()
    course_instructor = CourseInstructor.create(course_id: course.id)
    # p course
    # p course_instructor
    # puts "\n"
    assert_equal course_instructor.course_id, course.id
  end

  def test_lessons_in_class_assignments_association
    assignment = Assignment.new(
                          name: "test",
                          course_id: 1,
                          percent_of_grade: 100.00
                          )
    lesson_assignment = Lesson.create(in_class_assignment_id: assignment.id)
    # p lesson_assignment
    # p assignment
    assert lesson_assignment.in_class_assignments == assignment.id
  end

  def test_lessons_pre_class_assignments_association
    assignments = Assignment.new(
                          name: "test",
                          course_id: 1,
                          percent_of_grade: 100.00
                          )
    lesson_assignments = Lesson.create(pre_class_assignment_id: assignments.id)
    # p lesson_assignments
    # p assignments
    assert lesson_assignments.pre_class_assignments == assignments.id
  end

  def test_course_readings_association
    course = Course.create()
    lesson = Lesson.create(course_id: course.id)
    # reading = Reading.create(lesson_id: lesson.id)

    assert affirm(course.lessons, 'Lesson')
    assert affirm(lesson.readings, 'Reading')
    assert affirm(course.readings, 'Reading')
  end

  def test_school_has_name
    school = School.new(name: "")
    refute school.save
    # p school.errors.full_messages
    # assert school.errors.full_messages.include?("Name can't be blank"), school.errors.full_messages
  end

  def test_terms_have_name_starts_on_ends_on_school_id
    term = Term.new(name: "", starts_on: "01-01-0001", ends_on: "01-02-0001", school_id: "")
    refute term.save
    # p term.errors.full_messages
    # assert term.errors.full_messages.include?("Name can't be blank"), term.errors.full_messages
    # assert term.errors.full_messages.include?("Starts on can't be blank"), term.errors.full_messages
    # assert term.errors.full_messages.include?("Ends on can't be blank"), term.errors.full_messages
    # assert term.errors.full_messages.include?("School id can't be blank"), term.errors.full_messages
  end

  def test_user_has_name_and_email
    user = User.new(first_name: "", last_name: "", email: "")
    refute user.save
    # p user.errors.full_messages
    # assert user.errors.full_messages.include?("First name can't be blank"), user.errors.full_messages
    # assert user.errors.full_messages.include?("Last name can't be blank"), user.errors.full_messages
    # assert user.errors.full_messages.include?("Email can't be blank"), user.errors.full_messages
  end

  def test_user_email_unique
    user = User.create(first_name: "Test", last_name: "User", email: "test@user.com")
    # p user.errors.full_messages
    assert user.save
    userB = User.create(first_name: "Testing", last_name: "User", email: "test@user.com")
    refute userB.save
    # p userB.errors.full_messages
    # assert userB.errors.full_messages.include?("Email has already been taken"), userB.errors.full_messages
  end

  def test_user_email_proper_format
    user = User.new(first_name: "", last_name: "", email: "a")
    refute user.save
    # p user
  end

  def test_user_photo_url
      # user = User.new(first_name: "", last_name: "", email: "a", photo_url: "htt://git.com")
      # refute user.save
  end

  def test_assignments_have_course_id_name_percent
    assignment = Assignment.new(course_id: "",
                                name: "",
                                percent_of_grade: 0)
    refute assignment.save
    # p assignment.errors.full_messages
    # assert assignment.errors.full_messages.include?("Course id can't be blank"), assignment.errors.full_messages
    # assert assignment.errors.full_messages.include?("Name can't be blank"), assignment.errors.full_messages
    # assert assignment.errors.full_messages.include?("Percent of grade can't be blank"), assignment.errors.full_messages
  end

  def test_assignment_name_unique_within_course
    # Validate that the Assignment name is unique within a given
    # course_id.
    course = Course.create()
    assignment = Assignment.new(course_id: course.id,
                                name: "Test",
                                percent_of_grade: 0)
    assignment2 = Assignment.new(course_id: course.id,
                                name: "Test",
                                percent_of_grade: 0)
    assert assignment.save
    refute assignment2.save
  end

  # def test_coursestudents_students_association
  #   assert_association CourseStudent, :belongs_to, :student
  #   assert_association User, :has_many, :course_students
  # end

  # def test_coursestudents_assignment_grades_association
  #   assert_association CourseStudent, :has_many, :assignment_grades
  #   assert_association AssignmentGrade, :belongs_to, :course_student
  # end

  # def test_course_has_many_students_through_course_student
  #   # Set up a Course to have many students through the course's
  #   # course_students.
  # end

  # def test_course_primary_instructor_association
  #   # Associate a Course with its ONE primary_instructor. This
  #   # primary instructor is the one who  is referenced by a
  #   # course_instructor which has its primary flag set to true.
  # end

  # def test_course_students_ordered_last_first_name
  #   # A Course's students should be ordered by last_name, then
  #   # first_name.
  # end

end
#
# Together
# Associate Lessons with their child_lessons (and vice-versa). Sort
# the child_lessons by id.
