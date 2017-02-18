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

  def test_school_has_a_term_method
    school = School.new
    assert school.respond_to?(:terms)
  end

  def test_school_has_a_term
    school = School.create(name: "asdf")
    term = Term.new
    school.terms << term
    assert school.terms.count > 0
  end

  def test_term_responds_to_school_method
    term = Term.new
    assert term.respond_to?(:school)
  end

  def test_course_has_a_term_method
    course = Course.new
    assert course.respond_to?(:term)
  end

  def test_term_cannot_be_deleted_if_courses
    term = Term.new
    course = Course.new
    term.courses << course
    term.save
    term.delete
    assert term.errors,true
  end

  def test_course_responds_to_coursestudents
    course = Course.new
    assert course.respond_to?(:course_students)
  end

  def test_coursestudent_has_a_course_method
    course_student = CourseStudent.new
    assert course_student.respond_to?(:course)
  end

  def test_cannot_delete_course_if_coursestudents
    course = Course.create(
      course_code: 42,
      name: "Ruby on Rails"
      )
    coursestudent = CourseStudent.new
    course.course_students << coursestudent
    assert course.course_students.count > 0
    refute course.destroy
  end

  def test_assignment_has_a_course_method
    assignment = Assignment.new
    assert assignment.respond_to?(:course)
  end

  def test_course_has_an_assignment_method
    course = Course.new
    assert course.respond_to?(:assignments)
  end

  # When a course is destroyed, its assignments should be automatically destroyed.
  def test_course_destroyed_means_assignments_destroyed
    course = Course.create
    assignment = Assignment.new(course_id: 1, name: "asdf", percent_of_grade: 0.1)
    course.assignments << assignment
    course.destroy
    assert course.assignments.count == 0
  end

  def test_lesson_respondsto_preclassassignt
    lesson = Lesson.new
    assert lesson.respond_to?(:pre_class_assignment)
  end

  def test_lesson_respondsto_inclassassignt
    lesson = Lesson.new
    assert lesson.respond_to?(:in_class_assignment)
  end

  def test_assignment_responds_to_lesson
    a = Assignment.new(course_id: 1, name: "asdf", percent_of_grade: 0.1)
    assert a.respond_to?(:lessons)
  end

  def test_lessons_require_name
    lesson = Lesson.create
    assert lesson.errors.any?
  end

  def test_readings_require_order_number
    reading = Reading.create
    assert reading.errors.any?
  end

  def test_readings_require_lesson_id
    reading = Reading.create
    assert reading.errors.any?
  end

  def test_readings_require_url
    reading = Reading.new
    assert reading.errors
  end

  def test_readings_OK_when_params_exist
    reading = Reading.create(
      order_number: 42,
      lesson_id: 43,
      url:  "www.google.com"
      )
    refute reading.errors.any?
  end

  def test_school_course_through_terms
    school = School.create(name: "asdf")
    refute school.errors.any?
    term1  = Term.create
    course = Course.create(
      course_code: 101,
      name: "Ruby"
      )
    refute course.errors.any?
    school.terms << term1
    term1.courses << course
    assert school.courses.count >= 1
  end

  def test_when_lessons_is_destroyed_so_is_readings
    lesson = Lesson.create
    new_reading = Reading.create
    lesson.readings << new_reading
    lesson.destroy
    refute Reading.find_by(id: new_reading.id)
  end

  def test_when_course_is_destroyed_so_is_lessons
    course = Course.create
    new_lesson = Lesson.create
    course.lessons << new_lesson
    course.destroy
    refute Lesson.find_by(id: new_lesson.id)
  end

  def test_courses_has_course_instructors
    course = Course.create(name: "1st course", course_code: "asdf")
    new_instructor = CourseInstructor.create(course_id: course.id)
    refute course.course_instructors.count == 0
    course = Course.create(name: "2nd course", course_code: "zzzz")
    new_instructor = CourseInstructor.create
    course = Course.create(name: "3rd course", course_code: "xxxx")
    course.course_instructors << new_instructor
    refute course.course_instructors.count == 0

  end

  def test_course_instructors_is_not_deleted_when_course_is_deleted
    course = Course.create(name: "1st course", course_code: "asdf")
    new_instructor = CourseInstructor.create
    course.course_instructors << new_instructor
    course.destroy
    assert course.course_instructors.exists? == true
  end

  def test_lessons_to_in_class_assignments
    new_assignment = Assignment.create(course_id: 1, name: "asdf", percent_of_grade: 0.1)
    new_lesson = Lesson.create(in_class_assignment_id: new_assignment.id)
    assert new_lesson.respond_to?(:in_class_assignment)
  end

  def test_in_class_assignments_to_lessons
    new_assignment = Assignment.create(course_id: 1, name: "asdf", percent_of_grade: 0.1)
    new_lesson = Lesson.create(name: "asdfa", in_class_assignment_id: new_assignment.id)
    assert new_lesson.in_class_assignment_id == new_assignment.id
  end

  def test_there_are_many_readings_through_a_lesson
  new_course = Course.create(course_code: "123", name: "asdf")
  new_lesson = Lesson.create(name: "asdfa", course_id: new_course.id)
  new_reading = Reading.create(lesson_id:  new_lesson.id, order_number: 1, url: "as")
  new_course.lessons << new_lesson
  # assert new_course.save

  # p new_course.lessons.class
  # puts "\n\n"
  # p new_lesson.readings.class
  # puts "\n\n"
  # p new_course.readings.class
  # puts "\n\n"
  new_lesson.readings << new_reading
  assert new_course.readings.first == new_reading, new_course.readings.inspect

  end

end
