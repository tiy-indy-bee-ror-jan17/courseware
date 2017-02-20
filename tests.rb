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



require 'pry'
# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test


  def setup
    @user = User.find_or_create_by(first_name: "never", last_name: "nude", email: "email@email.com", photo_url: "http://nevernudephotos" )
    @student1 = User.find_or_create_by(first_name: "astudent", last_name: "a", email: "one@student.com", photo_url: "https://maybe")
    @student2 = User.find_or_create_by(first_name: "bstudent", last_name: "b", email: "two@student.com" )
    @student3 = User.find_or_create_by(first_name: "zeb", last_name: "a", email: "three@student.com")
    @instructor1 = User.find_or_create_by(first_name: "instructor", last_name: "one", email: "one@instructor.com")
    @instructor2 = User.find_or_create_by(first_name: "instructor", last_name: "two", email: "two@instructor.com")
    @instructor3 = User.find_or_create_by(first_name: "instructor3", last_name: "three", email: "three@instructor.com")

    @school = School.find_or_create_by(name: "school")

    @term1 = Term.find_or_create_by(name: "fall", school: @school, starts_on: 5, ends_on: 12)
    @term2 = Term.find_or_create_by(name: "spring", school: @school, starts_on: 2, ends_on: 10)

    @course1 = Course.find_or_create_by(name: "course 1", term: @term1, course_code: "phi101")
    @course2 = Course.find_or_create_by(name: "course 2", term: @term1, course_code: "dav101")

    @course_instructor1 = CourseInstructor.find_or_create_by(course: @course1, instructor_id: @instructor1.id, primary: true)
    @course_instructor2 = CourseInstructor.find_or_create_by(course: @course1, instructor_id: @instructor2.id)

    @course_student1 = CourseStudent.find_or_create_by(course: @course1, student: @student1)
    @course_student2 = CourseStudent.find_or_create_by(course: @course1, student: @student2)
    @course_student3 = CourseStudent.find_or_create_by(course: @course1, student: @student3)

    @assignment1 = Assignment.find_or_create_by(name: "assignment 1", course: @course1, percent_of_grade: 0.72)
    @assignment2 = Assignment.find_or_create_by(name: "assignment 2", course: @course1, percent_of_grade: 0.86)
    @assignment3 = Assignment.find_or_create_by(name: "assignment 3", course: @course2, percent_of_grade: 0.25)

    @lesson1 = Lesson.find_or_create_by(name: "lesson 1", course: @course1, in_class_assignment: @assignment1)
    @lesson2 = Lesson.find_or_create_by(name: "lesson 2", course: @course1, parent_lesson: @lesson1)
    @lesson3 = Lesson.find_or_create_by(name: "lesson 3", course: @course1, parent_lesson: @lesson1)

    @reading1 = Reading.find_or_create_by(caption: "reading 1", lesson: @lesson1, order_number: 1, url: "http://google.com")
    @reading2 = Reading.find_or_create_by(caption: "reading 2", lesson: @lesson1, order_number: 2, url: "http://google.com")

    @assignment_grade1 = AssignmentGrade.find_or_create_by(course_student: @course_student1, final_grade: 0.92)
  end


  def test_lessons_has_reading
    assert @lesson1.readings.length > 1
    assert_equal "lesson 1", @reading1.lesson.name
  end

  def test_lesson_destoyed_destroys_reading
    lesson = Lesson.create(name: "testlesson", course: @course1)
    reading = Reading.create(caption: "testreading", lesson: lesson, order_number: 6, url: "http://test.reading")
    assert Reading.exists?(id: reading)
    assert Lesson.exists?(id: lesson)
    lesson.destroy
    refute Reading.exists?(id: reading)
    refute Lesson.exists?(id: lesson)
  end

  def test_lessons_has_courses
    assert @course1.lessons.length > 1
    assert_equal "course 1", @lesson1.course.name
  end

  def test_course_destroyed_destroys_lesson
    course = Course.create(name: "coursetest", term: @term1, course_code: "phi401")
    lesson = Lesson.create(name: "testlesson", course: course)
    assert Course.exists?(id: course)
    assert Lesson.exists?(id: lesson)
    course.destroy
    refute Course.exists?(id: course)
    refute Lesson.exists?(id: lesson)
  end

  def test_courseinstructor_has_courses
    assert @course1.course_instructors.length > 1, @course1.course_instructors.length
    assert_equal "course 1", @course_instructor1.course.name
  end

  def test_course_cant_be_destroyed_if_course_instructor_exists
    course = Course.create(name: "coursetest", term: @term1, course_code: "phi401")
    assert Course.exists?(id: course)
    course.destroy
    refute Course.exists?(id: course)
    @course1.destroy
    assert Course.exists?(id: @course1)
  end

  def test_school_has_terms
    assert @school.terms.length > 1
    assert_equal "fall", @school.terms.first.name
  end

  def test_terms_have_courses
    assert @term1.courses.length > 1
    assert_equal "course 1", @term1.courses.last.name
  end

  def test_courses_have_course_students
    assert @course1.course_students.length > 1, @course1.course_students.length
  end

  def test_that_course_has_assignments
    assert @course1.assignments.length > 1
  end

  def lesson_has_in_class_assignments
    assert_equal "lesson 1", @assignment1.lessons_in.first.name
    assert_equal "assignment 1", @lesson1.in_class_assignment.name
  end

  def test_course_has_many_readings_through_lessons
    assert @course1.readings.length > 1
    assert @reading1.courses.length > 0

  end

  def test_validate_school_has_name
    school = School.new
    refute school.save
    assert school.errors.full_messages.include?("Name can't be blank")
  end

  def test_validate_terms_have_name_startson_endon_and_schoolid
    term = Term.new
    refute term.save
    assert term.errors.full_messages.include?("Name can't be blank")
    assert term.errors.full_messages.include?("Starts on can't be blank")
    assert term.errors.full_messages.include?("Ends on can't be blank")
    assert term.errors.full_messages.include?("School can't be blank")
  end

  def test_validate_user_has_firstname_lastname_email
    user = User.new
    refute user.save
    assert user.errors.full_messages.include?("First name can't be blank")
    assert user.errors.full_messages.include?("Last name can't be blank")
    assert user.errors.full_messages.include?("Email can't be blank")
  end

  def test_email_unique
    assert @user.valid?
    unique_user = User.create(first_name: "luke", last_name: "skywalker", email: "jedi@theforce.com")
    assert unique_user.valid?, unique_user.errors.full_messages
    user = User.create(first_name: "crash", last_name: "dummy", email: unique_user.email)
    refute user.save
    assert user.errors.full_messages.include?("Email has already been taken")
  end

  def test_email_appropriate_form
    user1 = User.create(first_name: "ben", last_name: "1", email: "bademail")
    user2 = User.create(first_name: "kendrick", last_name: "2", email: "another bad email @stupidmail.com")
    assert user1.errors.full_messages.include?("Email is bad juju")
    assert user2.errors.full_messages.include?("Email is bad juju")
    assert @user.valid?
    refute user1.valid?
    refute user2.valid?
  end

  def test_that_lessons_have_names
    l = Lesson.new
    refute l.save
    assert l.errors.full_messages.include?("Name can't be blank")
  end

  def test_that_readings_must_have_ordernumber_lessonid_and_url
    r = Reading.new
    refute r.save
    assert r.errors.full_messages.include?("Order number can't be blank")
    assert r.errors.full_messages.include?("Lesson can't be blank")
    assert r.errors.full_messages.include?("Url can't be blank")
  end


  def test_readings_urls_start_with_hypertext_transfer_protocol
    u = Reading.new(caption: "reading 1", lesson: @lesson1, order_number: 1, url: "https://google.com")
    r = Reading.new(caption: "reading 1", lesson: @lesson1, order_number: 1, url: "http://google.com")
    l = Reading.new(caption: "reading 1", lesson: @lesson1, order_number: 1, url: "anything else")
    s = Reading.new
    assert u.save
    assert r.save
    refute l.save
    refute s.save
  end

  def test_courses_have_coursecodes_and_names
    c = Course.new
    r = @course1
    refute c.save
    assert r.save
  end

  def test_course_code_unique
    psy101 = Course.new(name: "course 1", term: @term1, course_code: "psy101")
    not_og = Course.new(name: "this won't work", term: @term1, course_code: psy101.course_code)
    assert psy101.save
    refute not_og.save
  end

  def test_validate_photo_url_starts_with_http
    user1 = User.create(first_name: "dave", last_name: "nevernude", email: "dave@nevernude.com", photo_url: "https:nevernudephotos")
    assert user1.errors.full_messages.include?("Photo url is bad potato")
    refute user1.save
    assert @user.valid?, user1.errors.full_messages
    assert @student1.valid?, user1.errors.full_messages

  end

  def test_validate_assignments_have_courseid_name_percentofgrade
    assignment = Assignment.new
    refute assignment.save
    assert assignment.errors.full_messages.include?("Name can't be blank")
    assert assignment.errors.full_messages.include?("Course can't be blank")
    assert assignment.errors.full_messages.include?("Percent of grade can't be blank")
  end

  def test_validate_assignment_name_unique_within_courseid
    assert @assignment1.valid?, @assignment1.errors.full_messages
    assert @assignment2.valid?
    assert @assignment3.valid?
    assignmentdup = Assignment.create(name: "assignment 1", course: @course1, percent_of_grade: 0.16)
    refute assignmentdup.valid?
    assignment_1again = Assignment.create(name: "assignment 1", course: @course2, percent_of_grade: 0.34)
    assert assignment_1again.valid?, assignment_1again.errors.full_messages
    assignment_1again.destroy
  end


  def test_course_code_is_unique_within_given_term_id
    assert @course1.valid?
    assert @course2.valid?
    c_id = Course.create(name: "course 1", term: @term1, course_code: "phi101")
    refute c_id.valid?
    c_id2 = Course.create(name: "course 1", term: @term1, course_code: "pho101")
    assert c_id2.valid?
    c_id2.destroy

  end

  def test_that_terms_with_courses_are_not_deletable
    assert @term1.valid?
    @term1.destroy
    refute @term1.destroy
  end

  def test_that_courses_with_students_are_not_deletable
    assert @course1.valid?
    @course1.destroy
    refute @course1.destroy
  end

    #Adventure tests

  def test_associate_coursestudents_with_users
    refute_equal 0, @student1.course_students.count
    assert_equal "a", @course_student1.student.last_name
  end

  def test_associate_coursestudents_with_assignment_grades
    refute_equal 0, @course_student1.assignment_grades.count
    assert @assignment_grade1.respond_to?("course_student")
  end

  def test_courses_have_many_students_through_course_students
    refute_equal 0, @student1.courses.count
    refute_equal 0, @course1.students.count
  end

  def test_associate_course_with_one_primary_instructor

    course_instructor_a = CourseInstructor.create(course: @course1, instructor_id: @instructor3, primary: true)
    assert @course_instructor2.valid?
    assert course_instructor_a.errors.full_messages.include?("Primary instructor can only exist once per course")
    refute course_instructor_a.valid?
  end

  #EPIC MODE

  def test_students_ordered_by_lastname_then_firstname
    assert_equal "astudent", @course1.students.first.first_name
    assert_equal "zeb", @course1.students.second.first_name
    assert_equal "bstudent", @course1.students.third.first_name
  end

  def test_childlessons_sorted_by_id
    refute_equal 0, @lesson1.lessons.count
    assert_equal @lesson1, @lesson2.parent_lesson
    assert_equal 2, @lesson1.lessons.first.id
    assert_equal 3, @lesson1.lessons.second.id
  end

end
