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

  def setup
    @school = School.create(name: "Starfleet Academy")
    @term = Term.create(name: "Fall Term", school: @school)
    @term_two = Term.create(name: "Spring Term", school: @school)
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
    assingment = Assignment.create(name: "Intermix Chamber", course: @course_two)
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

end
