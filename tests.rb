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

  def test_schools_can_have_terms
    school = School.create(name: "NSES")
    assert school.respond_to?(:terms)
  end



  def test_term_can_be_added_to_school
    school = School.create(name: "NSES")
    Term.create(name: "Fall",
                starts_on: "01-01-0001",
                ends_on: "01-02-0001",
                school_id: school.id)
    assert school.terms.count != 0
  end

  def test_terms_have_courses
    term = Term.create(name: "Fall",
                        starts_on: "01-01-0001",
                        ends_on: "01-02-0001",
                        school_id: 1)
    course = Course.create(name: "Math", term_id: term.id)
    assert course.term_id == term.id
    refute term.destroy
    assert term.errors.full_messages.include? "Cannot delete record because dependent courses exist"
  end

  def test_course_has_a_term
    term = Term.create(name: "Fall",
                       starts_on: "01-01-0001",
                       ends_on: "01-02-0001",
                       school_id: 1)
    assert term.save
    course = Course.create(name: "Math", term_id: term.id)
    assert course.save
    assert course.term.name == "Fall"
  end

  def test_courses_with_course_students_association
    user = User.create(first_name: "Test",
                      last_name: "User",
                      email: "user2@te2sting.com")
    course = Course.create(name: "Math")
    # p user
    # puts "\n"
    # p course
    # puts "\n"
    course_student = CourseStudent.create(course_id: course.id, student_id: user.id)
    # p course_student
    assert course_student.course_id == course.id
    refute course.destroy
    assert course.errors.full_messages.include? "Cannot delete record because dependent course students exist"
  end

  def test_assignments_with_courses_association
    course = Course.create(name: "Math")
    assignment = Assignment.create(course_id: course.id,
                                  name: "Test99",
                                  percent_of_grade: 0)
    # p assignment
    # assert assignment.save
    assignment2 = Assignment.create(course_id: course.id,
                                    name: "Test98",
                                    percent_of_grade: 0)
    # p assignment2
    # assert assignment2.save
    assert course.assignments.count == 2
    assert course.destroy
    assert course.assignments.count == 0
  end

  def test_school_has_many_courses_through_schools_term

  end

  def test_lessons_readings_association
    lesson = Lesson.create()
    reading = Reading.create(lesson_id: lesson.id)
    # p reading
    # p lesson
    assert_equal lesson.id, reading.lesson_id
  end
    # Set up a School to have many courses through the school's terms.


  def test_lessons_have_names

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
    # Validate that Lessons have names.

  def test_readings_have_order_number_lesson_id_url

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
    # Validate that Readings must have an order_number, a lesson_id,
    #  and a url.
    #

  def test_url_verification

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
    # Validate that the Readings url must start with http:// or
    # https://. Use a regular expression.
    #

  def test_courses_have_course_code_and_name
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
    # Validate that Courses have a course_code and a name.

  def test_course_code_uniq_within_term_id

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
    # Validate that the course_code is unique within a given term_id.

  def test_course_code_starts_with_three_letters_ends_with_three_numbers

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
# the child_lessons by id
