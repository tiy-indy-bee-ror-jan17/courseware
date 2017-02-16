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

    @course1 = Course.create(name: "course 1")
    @course2 = Course.create(name: "course 2")

    @course_instructor1 = CourseInstructor.create(course: @course1)
    @course_instructor2 = CourseInstructor.create(course: @course1)

    @lesson1 = Lesson.create(name: "lesson 1", course: @course1)
    @lesson2 = Lesson.create(name: "lesson 2", course: @course1)

    @reading1 = Reading.create(caption: "reading 1", lesson: @lesson1)
    @reading2 = Reading.create(caption: "reading 2", lesson: @lesson1)

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
    @school = School.create(name: "school")
    Term.create(name: "term1", school: @school)
    Term.create(name: "term2", school: @school)
    assert @school.terms.length == 2
    assert "term1" == @school.terms.first.name
  end

  def test_terms_have_courses
    @term = Term.create(name: "fall")
    Course.create(name: "science", term: @term)
    assert @term.courses.length == 1
    assert_equal "science", @term.courses.last.name
  end



end
