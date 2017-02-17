# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'
require 'minitest_activerecord_assertions'

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
  include MiniTest::ActiveRecordAssertions

  def test_truth
    assert true
  end



  def test_schools_can_have_terms
    school = School.create(name: "NSES")
    assert school.respond_to?(:terms)
  end

  def test_term_can_be_added_to_school
    school = School.create(name: "NSES")
    Term.create(name: "Fall", school_id: school.id)
    assert school.terms.count != 0
  end

  def test_terms_have_courses
    term = Term.create(name: "Fall")
    course = Course.create(name: "Math", term_id: term.id)
    assert course.term_id == term.id
    refute term.destroy
    assert term.errors.full_messages.include? "Cannot delete record because dependent courses exist"
  end

  def test_course_has_a_term
    term = Term.create(name: "Fall")
    course = Course.create(name: "Math", term_id: term.id)
    assert course.term.name == "Fall"
  end

  def test_courses_with_course_students_association
    user = User.create
    course = Course.create(name: "Math")
    course_student = CourseStudent.create(course_id: course.id)
    assert course_student.course_id == course.id
    refute course.destroy
    assert course.errors.full_messages.include? "Cannot delete record because dependent course students exist"
  end

  def test_assignements_with_courses_association
    course = Course.create(name: "Math")
    assignment = Assignment.create(course_id: course.id)
    assignment2 = Assignment.create(course_id: course.id)
    assert course.assignments.count == 2
    assert course.destroy
    assert course.assignments.count == 0
  end

  def test_school_has_many_courses_through_schools_term

  end
    # Set up a School to have many courses through the school's terms.

  def test_lessons_have_names

  end
    # Validate that Lessons have names.

  def test_readings_have_order_number_lesson_id_url

  end
    # Validate that Readings must have an order_number, a lesson_id,
    #  and a url.
    #

  def test_url_verification

  end
    # Validate that the Readings url must start with http:// or
    # https://. Use a regular expression.
    #

  def test_courses_have_course_code_and_name

  end
    # Validate that Courses have a course_code and a name.

  def test_course_code_uniq_within_term_id

  end
    # Validate that the course_code is unique within a given term_id.

  def test_course_code_starts_with_three_letters_ends_with_three_numbers

  end
    # Validate that the course_code starts with three letters and ends
    # with three numbers. Use a regular expression.
    #
    # Associate course_instructors with instructors (who happen to be
    # users)
    #
    # Associate assignments with assignment_grades (both directions)
    # Set up a Course to have many instructors through the Course's
    # course_instructors.
    #
    # Validate that an Assignment's due_at field is not before the
    # Assignment's active_at.
    #
    # A Course's assignments should be ordered by due_at, then
    # active_at.
  #
  # Together
  # Associate Lessons with their child_lessons (and vice-versa). Sort
  # the child_lessons by id.






#///////////////////////////////////////////////////////////
  # def test_lessons_readings_association
  #   assert_association Lesson, :has_many, :readings
  #   assert_association Reading, :belongs_to, :lesson
  # end
  #
  # def test_lessons_courses_association
  #   assert_association Course, :has_many, :lessons
  #   assert_association Lesson, :belongs_to, :course
  # end
  #
  # def test_courses_instructors_association
  #   assert_association Course, :has_many, :instructors
  #   assert_association CourseInstructor, :belongs_to, :course
  # end
  #
  # def test_lessons_in_class_assignments_association
  #   assert_association Lesson, :has_many, :in_class_assignments
  #   assert_association Assignment, :belongs_to, :lesson
  # end
  #
  # def test_course_readings_association
  #   assert_association Course, :has_and_belongs_to_many, :readings
  #   assert_association Reading, :has_and_belongs_to_many, :courses
  # end
  #
  # def test_school_has_name
  #   # Validate that Schools must have name.
  # end
  #
  # def test_terms_have_name_starts_on_ends_on_school_id
  #   # Validate that Terms must have name, starts_on, ends_on, and
  #   # school_id.
  # end
  #
  # def test_user_has_name_and_email
  #   # Validate that the User has a first_name, a last_name, and an
  #   # email.
  # end
  #
  # def test_user_email_unique
  #   # Validate that the User's email is unique.
  # end
  #
  # def test_user_email_proper_format
  #   # Validate that the User's email has the appropriate form for
  #   # an e-mail address. Use a regular expression.
  # end
  #
  # def test_user_photo_url
  #   # Validate that the User's photo_url must start with http://
  #   # or https://. Use a regular expression.
  # end
  #
  # def test_assignments_have_course_id_name_percent
  #   # Validate that Assignments have a course_id, name, and
  #   # percent_of_grade.
  # end
  #
  # def test_assignment_name_unique_within_course
  #   # Validate that the Assignment name is unique within a given
  #   # course_id.
  # end
  #
  # def test_coursestudents_students_association
  #   assert_association CourseStudent, :belongs_to, :student
  #   assert_association User, :has_many, :course_students
  # end
  #
  # def test_coursestudents_assignment_grades_association
  #   assert_association CourseStudent, :has_many, :assignment_grades
  #   assert_association AssignmentGrade, :belongs_to, :course_student
  # end
  #
  # def test_course_has_many_students_through_course_student
  #   # Set up a Course to have many students through the course's
  #   # course_students.
  # end
  #
  # def test_course_primary_instructor_association
  #   # Associate a Course with its ONE primary_instructor. This
  #   # primary instructor is the one who  is referenced by a
  #   # course_instructor which has its primary flag set to true.
  # end
  #
  # def test_course_students_ordered_last_first_name
  #   # A Course's students should be ordered by last_name, then
  #   # first_name.
  # end

end
#///////////////////////////////////////////////////////////////////////////
# Person A
  # Associate schools with terms (both directions).
  # Associate terms with courses (both directions). If a term has any
  # courses associated with it, the term should not be deletable.
  #
  # Associate courses with course_students (both directions). If the
  # course has any students associated with it, the course should not
  # be deletable.
  #
  # Associate assignments with courses (both directions). When a
  # course is destroyed, its assignments should be automatically
  # destroyed.
  #
  # Associate lessons with their pre_class_assignments (both
  # directions)
  #
  # Set up a School to have many courses through the school's terms.
  # Validate that Lessons have names.
  # Validate that Readings must have an order_number, a lesson_id,
  #  and a url.
  #
  # Validate that the Readings url must start with http:// or
  # https://. Use a regular expression.
  #
  # Validate that Courses have a course_code and a name.
  # Validate that the course_code is unique within a given term_id.
  # Validate that the course_code starts with three letters and ends
  # with three numbers. Use a regular expression.
  #
  # Associate course_instructors with instructors (who happen to be
  # users)
  #
  # Associate assignments with assignment_grades (both directions)
  # Set up a Course to have many instructors through the Course's
  # course_instructors.
  #
  # Validate that an Assignment's due_at field is not before the
  # Assignment's active_at.
  #
  # A Course's assignments should be ordered by due_at, then
  # active_at.
#
# Together
# Associate Lessons with their child_lessons (and vice-versa). Sort
# the child_lessons by id
