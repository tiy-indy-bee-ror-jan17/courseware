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

  def setup
    @school = School.create(name: "Starfleet Academy")
    @term = Term.create(name: "Fall Term", starts_on: "2004-05-26", ends_on: Date.today, school_id: 1, school: @school)
    @term_two = Term.create(name: "Spring Term", starts_on: "1988-05-10", ends_on: Date.today, school_id: 1, school: @school)
    @course = Course.create(name: "Advanced Subspace Geometry", term: @term, course_code: "ncc1701")
    @course_two = Course.create(name: "Basic Warp Design", term: @term, course_code: "ncc74210")
    @course_student = CourseStudent.create(course: @course)
    @course_student_two = CourseStudent.create(course: @course)
    @assignment = Assignment.create(course: @course)
    @assignment_two = Assignment.create(course: @course)
    @lesson = Lesson.create(name: "First Lesson", pre_class_assignment: @assignment)
    @lesson_two = Lesson.create(name: "Second Lesson", pre_class_assignment: @assignment)
  end

  def test_truth
    assert true
  end

  def test_school_has_many_terms
    assert_equal 2, @school.terms.length
  end

  def test_term_belongs_to_school
    assert @term.school == @school
  end

  def test_term_has_many_courses
    assert_equal 2, @term.courses.length
  end

  def test_course_belongs_to_term
    assert @course.term == @term
  end

  def test_cant_delete_term_with_courses
    refute @term.destroy
    assert @term.errors.full_messages.include?("Cannot delete record because dependent courses exist")
    assert Term.exists?(name: "Fall Term")
  end

  def test_courses_have_many_course_students
    assert_equal 2, @course.course_students.length
  end

  def test_course_student_belongs_to_course
    assert @course_student.course == @course
  end

  def test_cant_delete_course_with_students
    refute @course.destroy
    assert @course.errors.full_messages.include?("Cannot delete record because dependent course students exist")
    assert Course.exists?(name: "Advanced Subspace Geometry")
  end

  def test_courses_have_many_assignments
    assert_equal 2, @course.assignments.length
  end

  def test_assignment_belongs_to_course
    assert @assignment.course == @course
  end

  def test_assignments_are_deleted_with_course
    Assignment.create(name: "Intermix Chamber", course: @course_two)
    @course_two.destroy
    refute Assignment.exists?(name: "Intermix Chamber")
  end

  def test_lesson_belongs_to_assignment
    assert @lesson.pre_class_assignment == @assignment
  end

  def test_assignment_has_many_lessons
    assert_equal 2, @assignment.lessons.length
  end

  def test_school_has_many_courses_through_terms
    assert_equal 2, @school.courses.length
  end

  def test_lesson_has_a_name
    lesson = Lesson.new
    refute lesson.save
    assert lesson.errors.full_messages.include?("Name can't be blank")
  end

  def test_readings_has_an_order_number
    reading = Reading.new
    refute reading.save
    assert reading.errors.full_messages.include?("Order number can't be blank")
  end

  def test_reading_has_a_lesson_id
    reading = Reading.new
    refute reading.save
    assert reading.errors.full_messages.include?("Lesson can't be blank")
  end

  def test_reading_has_a_url
    reading = Reading.new
    refute reading.save
    assert reading.errors.full_messages.include?("Url can't be blank")
  end

  def test_reading_has_url_in_specific_format
    reading = Reading.new(url: "www.resistanceisfutile.com")
    refute reading.save
    assert reading.errors.full_messages.include?("Url is invalid")
    reading_two = Reading.new(order_number: 1, lesson_id: 1, url: "http://borg.com")
    assert reading_two.save
    reading_three = Reading.new(order_number: 1, lesson_id: 1, url: "https://borg.com")
    assert reading_three.save
  end

  def test_course_has_a_name
    course = Course.new
    refute course.save
    assert course.errors.full_messages.include?("Name can't be blank")
  end

  def test_course_code_is_unique_per_term
    course = Course.new(name: "Communications", course_code: "ncc1371", term: @term)
    assert course.save
    course_two = Course.new(name: "Exochemistry", course_code: "ncc1371", term: @term)
    refute course_two.save
    assert course_two.errors.full_messages.include?("Course code has already been taken")
  end

  def test_course_code_is_in_specific_format
    course = Course.new(name: "Interspecies Protocol", course_code: "borg", term: @term)
    refute course.save
    course.errors.full_messages.include?("Course code is invalid")
  end

  def test_course_instructor_belongs_to_instructor
    user = User.create
    course_instructor = CourseInstructor.create(instructor: user)
    assert course_instructor.instructor == user
  end

  def test_assignment_has_many_assignment_grades
    assignment = Assignment.create
    assigntment_grade = AssignmentGrade.create(assignment: assignment)
    assignment_grade_two = AssignmentGrade.create(assignment: assignment)
    assert_equal 2, assignment.assignment_grades.length
  end

  def test_assignment_grade_belongs_to_assignment
    assignment = Assignment.create
    assignment_grade = AssignmentGrade.create(assignment: assignment)
    assert assignment_grade.assignment == assignment
  end

  def test_course_has_many_instructors_through_course_instructors
    course = Course.create(name: "Klingon Physiology", course_code: "ncc150")
    course_instructor = CourseInstructor.create(course: course)
    course_instructor2 = CourseInstructor.create(course: course)
    assert_equal 2, course.course_instructors.length

  # B-Test-1
  def test_a_reading_is_destroyed_when_its_lesson_is_destroyed
    lesson_test = Lesson.create(course_id: 99, parent_lesson_id: 99, name: "Test Reading destroyed", pre_class_assignment_id: 1, in_class_assignment_id: 1)

    reading_test = Reading.create(lesson_id: lesson_test.id, caption: "Testy test", order_number: 99 )

    lesson_test.destroy
    refute Reading.find_by(caption: "Testy test")
  end

  #B-Test-2
  def test_destroying_a_course_destroys_its_associated_lessons
    course_test = Course.create(name: "Destroying lessons like a BAWSS", course_code: "ncc74656")

    lesson_test = Lesson.create(course_id: course_test.id, parent_lesson_id: 99, name: "Destroy this lesson!")

    lesson_test2 = Lesson.create(course_id: course_test.id, parent_lesson_id: 99, name: "Destroy this lesson too!")

    course_test.destroy
    refute Lesson.find_by(name: "Destroy this lesson!")
    refute Lesson.find_by(name: "Destroy this lesson too!")
  end

  #B-Test-3
  def test_that_a_course_with_instructors_cannot_be_deleted
    course_test = Course.create(name: "Destroying lessons like a BAWSS", course_code: "ncc1764")
    instructor_test = CourseInstructor.create(course_id: course_test.id)

    refute course_test.destroy
  end

  #B-Test-4
  def test_that_a_lesson_is_associated_with_its_in_class_assignment
    assign_test = Assignment.create(name: "Assignment Test")
    lesson_test = Lesson.create(in_class_assignment_id: assign_test.id)

    assert lesson_test.in_class_assignment_id == assign_test.id
  end

  #B-Test-5
  def test_a_course_has_many_readings_through_lessons
    course_many_readings_test = Course.create(name: "Advanced Lesson Destroying", course_code: "ncc2000")
    lesson_test = Lesson.create(course_id: course_many_readings_test.id, name: "Lesson Destroying Best Practices")
    lesson_test2 = Lesson.create(course_id: course_many_readings_test.id, name: "Lesson Destroying: Safety")
    reading_test1 = Reading.create(lesson_id: lesson_test.id, caption: "Lesson Destroying: Industry Methods and Standards", url: "http://destroythelesson.com", order_number: 1)
    reading_test2 = Reading.create(lesson_id: lesson_test.id, caption: "How to destroy Lessons Safely", url: "http://destroythelesson.com", order_number: 1)
    reading_test3 = Reading.create(lesson_id: lesson_test2.id, caption: "What to do after you've destroyed a lesson",url: "http://destroythelesson.com", order_number: 1)

    assert course_many_readings_test.readings.count > 2
  end

  #B-Test-6
  def test_validate_a_school_has_a_name
    new_school = School.create()
    assert new_school.name == nil
    assert new_school.errors.messages
    refute new_school.save
  end

  #The following tests come from a single deliverable.
  #B-Test-7
  #Date (used later) requires YYYY-MM-DD format
  def test_validate_terms_must_have_a_name
    terms_have_names = Term.new()
    assert terms_have_names.name == nil
    assert terms_have_names.errors.messages
    refute terms_have_names.save
  end

  def test_validate_terms_must_have_starts_on
    terms_have_starts_on = Term.new(name: "Winter")
    assert terms_have_starts_on.starts_on == nil
    assert terms_have_starts_on.errors.messages
    refute terms_have_starts_on.save
  end

  def test_validate_terms_must_have_ends_on
    terms_have_ends_on = Term.new(name: "Spring", starts_on: "2017-02-16")
    assert terms_have_ends_on.ends_on == nil
    assert terms_have_ends_on.errors.messages
    refute terms_have_ends_on.save
  end

  def test_validate_terms_must_have_a_school_id
    terms_have_school_id = Term.new(name: "Summer", starts_on: Date.today, ends_on: "2017-04-29")
    assert terms_have_school_id.school_id == nil
    assert terms_have_school_id.errors.messages
    refute terms_have_school_id.save
  end

  #B-Test-8
  #The following tests come from a single deliverable
  def test_that_a_user_has_a_first_name
    user_first_name = User.new()
    assert user_first_name.first_name == nil
    assert user_first_name.errors.messages
    refute user_first_name.save
  end

  def test_that_a_user_has_a_last_name
    user_last_name = User.new(first_name: "Bobby")
    assert user_last_name.last_name == nil
    assert user_last_name.errors.messages
    refute user_last_name.save
  end

  def test_that_a_user_has_an_email
    user_email = User.new(first_name: "Bobby", last_name: "Tables")
    assert user_email.email == ""
    assert user_email.errors.messages
    refute user_email.save
  end

  #B-Test-9
  def test_that_a_users_email_is_unique
    unique_email = User.new(first_name: "Bobby", last_name: "Tables", email: "dropallthetables@dropitlikeitshot.com")
    assert unique_email.save
    unique_email1 = User.new(first_name: "Fred", last_name: "Dunston", email: "dropallthetables@dropitlikeitshot.com")
    assert unique_email1.errors.messages
    refute unique_email1.save
  end

end
