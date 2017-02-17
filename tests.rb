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
    @user = User.create(first_name: "never", last_name: "nude", email: "email@email.com" )
    @school = School.create(name: "school")

    @term1 = Term.create(name: "fall", school: @school, starts_on: 5, ends_on: 12)
    @term2 = Term.create(name: "spring", school: @school, starts_on: 2, ends_on: 10)

    @course1 = Course.create(name: "course 1", term: @term1, course_code: "Phil")
    @course2 = Course.create(name: "course 2", term: @term1, course_code: "Dave")

    @course_instructor1 = CourseInstructor.create(course: @course1)
    @course_instructor2 = CourseInstructor.create(course: @course1)

    @course_student1 = CourseStudent.create(course: @course1)
    @course_student2 = CourseStudent.create(course: @course1)

    @assignment1 = Assignment.create(name: "assignment 1", course: @course1)
    @assignment2 = Assignment.create(name: "assignment 2", course: @course1)

    @lesson1 = Lesson.create(name: "lesson 1", course: @course1, in_class_assignment: @assignment1)
    @lesson2 = Lesson.create(name: "lesson 2", course: @course1)

    @reading1 = Reading.create(caption: "reading 1", lesson: @lesson1, order_number: 1, url: "http://google.com")
    @reading2 = Reading.create(caption: "reading 2", lesson: @lesson1, order_number: 2, url: "http://google.com")
  end

  def test_truth_and_like______everything_else_too
    assert true
    lessons_has_reading
    lessons_has_courses
    courseinstructor_has_courses
    school_has_terms
    terms_have_courses
    courses_have_course_students
    that_course_has_assignments
    lesson_has_in_class_assignments
    course_has_many_readings_through_lessons
    validate_school_has_name
    validate_terms_have_name_startson_endon_and_schoolid
    validate_user_has_firstname_lastname_email
    email_unique
    that_lessons_have_names
    that_readings_must_have_ordernumber_lessonid_and_url
    readings_urls_start_with_hypertext_transfer_protocol
    courses_have_coursecodes_and_names
    course_code_unique
  end

  def lessons_has_reading
    assert_equal 2, @lesson1.readings.length
    assert_equal "lesson 1", @reading1.lesson.name
  end

  def lessons_has_courses
    assert_equal 2, @course1.lessons.length
    assert_equal "course 1", @lesson1.course.name
  end

  def courseinstructor_has_courses
    assert_equal 2, @course1.course_instructors.length
    assert_equal "course 1", @course_instructor1.course.name
  end

  def school_has_terms
    assert_equal 2, @school.terms.length
    assert_equal "fall", @school.terms.first.name
  end

  def terms_have_courses
    assert_equal 2, @term1.courses.length
    assert_equal "course 1", @term1.courses.last.name
  end

  def courses_have_course_students
    assert_equal 2, @course1.course_students.length
  end

  def that_course_has_assignments
    assert_equal 2, @course1.assignments.length
    assert_equal "assignment 1", @course1.assignments.first.name
  end

  def lesson_has_in_class_assignments
    assert_equal "lesson 1", @assignment1.lessons_in.first.name
    assert_equal "assignment 1", @lesson1.in_class_assignment.name
  end

  def course_has_many_readings_through_lessons
    assert_equal 2, @course1.readings.length
    assert_equal 1, @reading1.courses.length
  end

  def validate_school_has_name
    school = School.new
    refute school.save
    assert school.errors.full_messages.include?("Name can't be blank")
  end

  def validate_terms_have_name_startson_endon_and_schoolid
    term = Term.new
    refute term.save
    assert term.errors.full_messages.include?("Name can't be blank")
    assert term.errors.full_messages.include?("Starts on can't be blank")
    assert term.errors.full_messages.include?("Ends on can't be blank")
    assert term.errors.full_messages.include?("School can't be blank")
  end

  def validate_user_has_firstname_lastname_email
    user = User.new
    refute user.save
    assert user.errors.full_messages.include?("First name can't be blank")
    assert user.errors.full_messages.include?("Last name can't be blank")
    assert user.errors.full_messages.include?("Email can't be blank")
  end

  def email_unique
    unique_user = User.create(first_name: "anakin", last_name: "skywalker", email: "darklord@theforce.com")
    assert unique_user.valid?, unique_user.errors.full_messages
    user = User.create(first_name: "crash", last_name: "dummy", email: unique_user.email)
    refute user.save
    assert user.errors.full_messages.include?("Email has already been taken")
  end

  def email_appropriate_form

  end

  def that_lessons_have_names
    l = Lesson.new
    refute l.save
    assert l.errors.full_messages.include?("Name can't be blank")
  end

  def that_readings_must_have_ordernumber_lessonid_and_url
    r = Reading.new
    refute r.save
    assert r.errors.full_messages.include?("Order number can't be blank")
    assert r.errors.full_messages.include?("Lesson can't be blank")
    assert r.errors.full_messages.include?("Url can't be blank")
  end


  def readings_urls_start_with_hypertext_transfer_protocol
    u = Reading.new(caption: "reading 1", lesson: @lesson1, order_number: 1, url: "https://google.com")
    r = Reading.new(caption: "reading 1", lesson: @lesson1, order_number: 1, url: "http://google.com")
    l = Reading.new(caption: "reading 1", lesson: @lesson1, order_number: 1, url: "anything else")
    s = Reading.new
    assert u.save
    assert r.save
    refute l.save
    refute s.save
  end

  def courses_have_coursecodes_and_names
    c = Course.new
    r = @course1
    refute c.save
    assert r.save
  end

  def course_code_unique
    psy101 = Course.new(name: "course 1", term: @term1, course_code: "psy101")
    not_og = Course.new(name: "this won't work", term: @term1, course_code: psy101.course_code)
    assert psy101.save
    refute not_og.save
  end


  def validate_photo_url_starts_with_http

  end

  def validate_assignments_have_courseid_name_percentofgrade

  end

  def validate_assignment_name_unique_within_courseid

  end

end
