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


# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_school_has_many_terms
    school = School.create(name: "Test School")
    term = Term.create(name: "Fall Term", school: school)
    term2 = Term.create(name: "Spring Term", school: school)
    assert_equal 2, school.terms.length
  end

  def test_term_belongs_to_school
    school = School.first
    term = Term.create(name: "Fall Term", school: school)
    assert term.school == School.first
  end

  def test_term_has_many_courses
    term = Term.create(name: "Fall Term")
    course = Course.create(name: "First Course", term: term, course_code: "abc123")
    course2 = Course.create(name: "Second Course", term: term, course_code: "abc124")
    assert_equal 2, term.courses.length
  end

  def test_course_belongs_to_term
    term = Term.create(name: "Winter Term")
    course = Course.create(name: "Third Course", term: term, course_code: "abc125")
    assert course.term == Term.find_by(name: "Winter Term")
  end

  def test_cant_delete_term_with_courses
    term = Term.create(name: "Summer Term")
    course = Course.create(name: "Fourth Course", term: term, course_code: "abc126")
    refute term.destroy
    assert term.errors.full_messages.include?("Cannot delete record because dependent courses exist")
    assert Term.exists?(name: "Summer Term")
  end

  def test_courses_have_many_course_students
    course = Course.create(name: "Fifth Course", course_code: "abc122")
    course_student = CourseStudent.create(course: course)
    course_student2 = CourseStudent.create(course: course)
    assert_equal 2, course.course_students.length
  end

  def test_course_student_belongs_to_course
    course = Course.first
    course_student = CourseStudent.create(course: course)
    assert course_student.course == course
  end

  def test_cant_delete_course_with_students
    course = Course.create(name: "Sixth Course", course_code: "abc127")
    course_student = CourseStudent.create(course: course)
    refute course.destroy
    assert course.errors.full_messages.include?("Cannot delete record because dependent course students exist")
    assert Course.exists?(name: "Sixth Course")
  end

  def test_courses_have_many_assignments
    course = Course.create(name: "Seventh Course", course_code: "abc128")
    assignment = Assignment.create(course: course)
    assignment2 = Assignment.create(course: course)
    assert_equal 2, course.assignments.length
  end

  def test_assignment_belongs_to_course
    course = Course.create(name: "Eight Course", course_code: "abc129")
    assignment = Assignment.create(course: course)
    assert assignment.course == course
  end

  def test_assignments_are_deleted_with_course
    course = Course.create(name: "Ninth Course", course_code: "abc130")
    assingment = Assignment.create(name: "ninth_course_assignment", course: course)
    course.destroy
    refute Assignment.exists?(name: "ninth_course_assignment")
  end

  def test_lesson_belongs_to_assignment
    assignment = Assignment.create
    lesson = Lesson.create(name: "First Lesson", pre_class_assignment: assignment)
    assert lesson.pre_class_assignment == assignment
  end

  def test_assignment_has_many_lessons
    assignment = Assignment.create
    lesson = Lesson.create(name: "Second Lesson", pre_class_assignment: assignment)
    lesson2 = Lesson.create(name: "Third Lesson", pre_class_assignment: assignment)
    assert_equal 2, assignment.lessons.length
  end

  def test_school_has_many_courses_through_terms
    school = School.create
    term = Term.create(school: school)
    course = Course.create(name: "Tenth Course", term: term, course_code: "abc131")
    course2 = Course.create(name: "Eleventh Course", term: term, course_code: "abc132")
    assert_equal 2, school.courses.length
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
    reading = Reading.new(url: "www.cats.com")
    refute reading.save
    assert reading.errors.full_messages.include?("Url is invalid")
    reading2 = Reading.new(order_number: 1, lesson_id: 1, url: "http://cats.com")
    assert reading2.save
    reading3 = Reading.new(order_number: 1, lesson_id: 1, url: "https://cats.com")
    assert reading3.save
  end

  def test_course_has_a_name
    course = Course.new
    refute course.save
    assert course.errors.full_messages.include?("Name can't be blank")
  end

  def test_course_code_is_unique_per_term
    term = Term.create
    course = Course.new(name: "Course Borg", course_code: "abc133", term: term)
    assert course.save
    course2 = Course.new(name: "Course 8472", course_code: "abc133", term: term)
    refute course2.save
    assert course2.errors.full_messages.include?("Course code has already been taken")
  end

  def test_course_code_is_in_specific_format
    term = Term.new
    course = Course.new(name: "Course Delta Quadrant", course_code: 13, term: term)
    refute course.save
    course.errors.full_messages.include?("Course code is invalid")
  end

end
