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
    @user = User.new()
    @school = School.create(name: "school")

    @term1 = Term.create(name: "fall", school: @school)
    @term2 = Term.create(name: "spring", school: @school)

    @course1 = Course.create(name: "course 1", term: @term1)
    @course2 = Course.create(name: "course 2", term: @term1)

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

  def test_truth
    assert true
  end


  def test_lessons_has_reading
    assert_equal 2, @lesson1.readings.length
    assert_equal "lesson 1", @reading1.lesson.name
  end

  def test_lessons_has_courses
    assert_equal 2, @course1.lessons.length
    assert_equal "course 1", @lesson1.course.name
  end

  def test_courseinstructor_has_courses
    assert_equal 2, @course1.course_instructors.length
    assert_equal "course 1", @course_instructor1.course.name
  end

  def test_school_has_terms
    assert_equal 2, @school.terms.length
    assert_equal "fall", @school.terms.first.name
  end

  def test_terms_have_courses
    assert_equal 2, @term1.courses.length
    assert_equal "course 1", @term1.courses.last.name
  end

  def test_courses_have_course_students
    assert_equal 2, @course1.course_students.length
  end

  def test_that_course_has_assignments
    assert_equal 2, @course1.assignments.length
    assert_equal "assignment 1", @course1.assignments.first.name
  end

  def test_lesson_has_in_class_assignments
    assert_equal "lesson 1", @assignment1.lessons.first.name
    assert_equal "assignment 1", @lesson1.in_class_assignment.name
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
    u = Reading.new(caption: "reading 1", lesson: @lesson1, order_number: 1, url: "http://")
    r = Reading.new(caption: "reading 1", lesson: @lesson1, order_number: 1, url: "https://")
    l = Reading.new(caption: "reading 1", lesson: @lesson1, order_number: 1, url: "anything else")
    assert u.save
    assert r.save
    #refute l.save

  end

end
