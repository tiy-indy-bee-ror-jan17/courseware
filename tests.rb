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
    user = User.create(first_name: "Test",
                       last_name: "User",
                       email: "test@used.com",
                       instructor: true)
    course = Course.create()
    course_instructor = CourseInstructor.create(course_id: course.id, instructor_id: user.id)
    # p course
    # p course_instructor
    # puts "\n"
    refute course.destroy
    assert_equal course_instructor.course_id, course.id
  end

  def test_lessons_in_class_assignments_association
    course = Course.create()
    assignment = Assignment.create(
                          name: "Test1",
                          course_id: course.id,
                          percent_of_grade: 100.00
                          )
    lesson_assignment = Lesson.create(
                          in_class_assignment_id: assignment.id
                        )
    # puts "In Class Assignment\n"
    # p lesson_assignment
    # puts "\n"
    # p assignment
    # puts "\n"
    # puts "================================================="
    # puts "\n"
    # assert_equal assignment.id, lesson_assignment
                    # .in_class_assignment_id
    assert lesson_assignment.in_class_assignments == assignment
  end

  def test_lessons_pre_class_assignments_association
    course = Course.create()
    assignments = Assignment.create(
                          name: "Test2",
                          course_id: course.id,
                          percent_of_grade: 100.00
                          )
    lesson_assignments = Lesson.create(
                            pre_class_assignment_id: assignments.id
                          )
    # puts "Pre Class Assignment\n"
    # puts "\n"
    # p lesson_assignments
    # puts "\n"
    # p assignments
    # puts "\n"
    # puts "=============================================="
    # puts "\n"
    # assert_equal assignments.id,
                    # lesson_assignments.pre_class_assignment_id
    assert lesson_assignments.pre_class_assignments == assignments
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
    school = School.create(name: "")
    refute school.save
    # p school.errors.full_messages
    # assert school.errors.full_messages
                # .include?("Name can't be blank"),
                # school.errors.full_messages
  end

  def test_terms_have_name_starts_on_ends_on_school_id
    term = Term.create(name: "",
                       starts_on: "01-01-0001",
                       ends_on: "01-02-0001",
                       school_id: "")
    refute term.save
    # p term.errors.full_messages
    # assert term.errors.full_messages
              # .include?("Name can't be blank"),
              #   term.errors.full_messages
    # assert term.errors.full_messages
              # .include?("Starts on can't be blank"),
              #   term.errors.full_messages
    # assert term.errors.full_messages
              # .include?("Ends on can't be blank"),
              #   term.errors.full_messages
    # assert term.errors.full_messages
              # .include?("School id can't be blank"),
              #   term.errors.full_messages
  end

  def test_user_has_name_and_email
    user = User.create(first_name: "", last_name: "", email: "")
    refute user.save
    # p user.errors.full_messages
    # assert user.errors.full_messages
              # .include?("First name can't be blank"),
              #   user.errors.full_messages
    # assert user.errors.full_messages
              # .include?("Last name can't be blank"),
              #   user.errors.full_messages
    # assert user.errors.full_messages
              # .include?("Email can't be blank"),
              #   user.errors.full_messages
  end

  def test_user_email_unique
    user = User.create(first_name: "Test",
                       last_name: "User",
                       email: "test@user.com")
    # p user.errors.full_messages
    assert user.save
    userB = User.create(first_name: "Testing",
                        last_name: "User",
                        email: "test@user.com")
    refute userB.save
    # p userB.errors.full_messages
    # assert userB.errors.full_messages
                # .include?("Email has already been taken"),
                #   userB.errors.full_messages
  end

  def test_user_email_proper_format
    user = User.create(first_name: "Test",
                       last_name: "User",
                       email: "a")
    refute user.save
    # p user
  end

  def test_user_photo_url
      user = User.create(first_name: "Test",
                         last_name: "User",
                         email: "test@users.com",
                         photo_url: "htt://git.com")
      refute user.save
  end

  def test_assignments_have_course_id_name_percent
    assignment = Assignment.create(course_id: "",
                                name: "",
                                percent_of_grade: 0)
    refute assignment.save
    # p assignment.errors.full_messages
    # assert assignment.errors.full_messages
              # .include?("Course id can't be blank"),
                # assignment.errors.full_messages
    # assert assignment.errors.full_messages
              # .include?("Name can't be blank"),
              #   assignment.errors.full_messages
    # assert assignment.errors.full_messages
              # .include?("Percent of grade can't be blank"),
              #   assignment.errors.full_messages
  end

  def test_assignment_name_unique_within_course
    course = Course.create()
    assignment = Assignment.create(course_id: course.id,
                                name: "Test",
                                percent_of_grade: 0)
    assignment2 = Assignment.create(course_id: course.id,
                                name: "Test",
                                percent_of_grade: 0)
    assert assignment.save
    refute assignment2.save
  end

  def test_coursestudents_students_association
    user = User.create(first_name: "Test",
                       last_name: "User",
                       email: "user@test.com")
    course_student = CourseStudent.create(student_id: user.id)

    assert affirm(course_student.student, 'User')
  end

  def test_coursestudents_assignment_grades_association
    user = User.create(first_name: "Test",
                      last_name: "User",
                      email: "user@testing.com")
    course_student = CourseStudent.create(student_id: user.id)
    assignment_grade = AssignmentGrade.create(
                        course_student_id: course_student.id)
    # puts "\n"
    # p user
    # puts "\n"
    # p course_student
    # puts "\n"
    # p assignment_grade
    # puts "======================================================"
    assert affirm(assignment_grade.course_student, 'CourseStudent')
  end

  def test_course_has_many_students_through_course_student
    course = Course.create()
    user1 = User.create(first_name: "Test",
                      last_name: "User",
                      email: "user1@test.com")
    course_student1 = CourseStudent.create(
                      student_id: user1.id,
                      course_id: course.id)
    user2 = User.create(first_name: "Test",
                      last_name: "User",
                      email: "user2@test.com")
    course_student2 = CourseStudent.create(
                      student_id: user2.id,
                      course_id: course.id)
    user3 = User.create(first_name: "Test",
                      last_name: "User",
                      email: "user3@test.com")
    course_student3 = CourseStudent.create(
                      student_id: user3.id,
                      course_id: course.id)

    assert affirm(course_student1.course, "Course")
    assert affirm(course_student2.course, "Course")
    assert affirm(course_student3.course, "Course")
  end

  def test_course_primary_instructor_association
    user = User.create(first_name: "Test",
                       last_name: "User",
                       email: "user6@test.com",
                       instructor: true)
    course = Course.create()
    course_instructor = CourseInstructor.create(
                                          course_id: course.id,
                                          primary: true,
                                          instructor_id: user.id
                                        )
    assert course_instructor.primary == true &&
           course_instructor.course_id == course.id
  end

  # def test_course_students_ordered_last_first_name
  #   # A Course's students should be ordered by last_name, then
  #   # first_name.
  # end

end
#
# Together
# Associate Lessons with their child_lessons (and vice-versa). Sort
# the child_lessons by id.
