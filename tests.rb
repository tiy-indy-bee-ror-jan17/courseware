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
    school = School.create
    assert school.respond_to?(:terms)
  end

  def test_school_has_a_term
    school = School.create(name: "asdf")
    assert school.save
    term = Term.create(
      name: 'Q1-2017',
      starts_on: '2017-02-01',
      ends_on:   '2017-04-20',
      school_id: 1
    )
    assert term.save
    school.terms << term
    assert school.terms.count > 0
  end

  def test_term_responds_to_school_method
    term = Term.create
    assert term.respond_to?(:school)
  end

  def test_term_has_a_course_method
    term = Term.create(name: "Fall",
                       starts_on: "01-01-0001",
                       ends_on: "01-01-0001",
                       school_id: 1)
    assert term.save
    course = Course.create(
                          course_code: 'abc123',
                          name: "blah"#,
                          # term_id: term.id
                          )
    term.courses << course
    assert term.courses.count > 0
  end

  def test_term_cannot_be_deleted_if_courses
    term = Term.create(
      name: 'Summer 42',
      starts_on: '2001-01-01',
      ends_on:   '2001-03-30',
      school_id:  11
    )
    assert term.save
    course = Course.create(
      course_code: 'abc129',
      name: 'Ruby on Rails'
    )
    assert course.save
    term.courses << course
    assert term.courses.count > 0 #verify it has courses
    assert term.save   #triple verify term still in db
    term.destroy  #should fail, since still have courses
    assert term.save   #verify term NOT destroyed
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
      course_code: 'abc133',
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
      url:  "https://www.google.com"
      )
    refute reading.errors.any?
  end

  def test_school_course_through_terms
    school = School.create(name: "asdf")
    refute school.errors.any?
    assert school.save
    term1  = Term.create(
      name: 'Q1-2017',
      starts_on: '2017-01-01',
      ends_on:   '2017-04-30',
      school_id: 1
    )
    assert term1.save
    course = Course.create(
      course_code: 'abc143',
      name: "Ruby"
      )
    assert course.save
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
    course = Course.create(
      name: "1st course",
      course_code: 'abc153')
    assert course.save
    new_instructor = CourseInstructor.create(course_id: course.id)
    assert new_instructor.save
    course.course_instructors << new_instructor
    refute course.course_instructors.count == 0
    course = Course.create(
      name: "2nd course",
      course_code: 'abc163')
    assert course.save
    new_instructor = CourseInstructor.create
    assert new_instructor.save
    course.course_instructors << new_instructor
    assert course.course_instructors.count > 0
  end

  def test_course_instructors_is_not_deleted_when_course_is_deleted
    term = Term.create(
      name: 'Q1-1601',
      starts_on: '1601-05-01',
      ends_on:   '1601-08-30',
      school_id: 4
      )
      assert term.save
    course = Course.new(
      name: "1st course",
      course_code: 'abc173')
    term.courses << course
    new_instructor = CourseInstructor.create
    course.course_instructors << new_instructor
    course.destroy      #should fail
    assert course.save  #verify course still there
  end

  def test_lessons_to_in_class_assignments
    new_assignment = Assignment.create(course_id: 1, name: "asdf", percent_of_grade: 0.1)
    new_lesson = Lesson.create(
      name: 'Rails 101',
      in_class_assignment_id: new_assignment.id)
    assert new_lesson.respond_to?(:in_class_assignment)
  end

  def test_in_class_assignments_to_lessons
    new_assignment = Assignment.create(course_id: 1, name: "asdf", percent_of_grade: 0.1)
    new_lesson = Lesson.create(name: "asdfa", in_class_assignment_id: new_assignment.id)
    assert new_lesson.in_class_assignment_id == new_assignment.id
  end

  def test_there_are_many_readings_through_a_lesson
    new_course = Course.create(course_code: "asdf345654", name: "asdf")
    assert new_course.save
    new_lesson = Lesson.create(name: "asdfa", course_id: new_course.id)
    assert new_lesson.save
    new_reading = Reading.create(lesson_id:  new_lesson.id, order_number: 1, url: "http://www.git.com")
    assert new_reading.save
    # new_course.lessons << new_lesson
    # p new_course.lessons.class
    # puts "\n\n"
    # p new_lesson.readings.class
    # puts "\n\n"
    # p new_course.readings.class
    # puts "\n\n"
    # p new_reading.class
    # new_lesson.readings << new_reading
    # puts "\n"
    # p new_course.readings.first
    assert new_course.readings.first == new_reading, new_course.readings.inspect
  end

  def test_in_class_assignments_to_lessons
    new_assignment = Assignment.create(course_id: 1, name: "qwert12345", percent_of_grade: 100.00)
    new_lesson = Lesson.create(
      name: "asdfa",
      in_class_assignment_id:
      new_assignment.id)
    assert new_lesson.in_class_assignment == new_assignment
  end

  def test_preclass_assignments_to_lessons
    new_assignment = Assignment.create(course_id: 1, name: "poiuyt5432", percent_of_grade: 100.00)
    new_lesson = Lesson.create(
      name: "asdfa",
      pre_class_assignment_id: new_assignment.id)
    assert new_lesson.pre_class_assignment == new_assignment
  end

  def test_validate_Lessons_have_names
    refute Lesson.create.valid?
    lesson = Lesson.create(
      name: 'easy')
    assert lesson.save
  end

  def test_readings_url_requires_http_or_https
    refute Reading.create(
      order_number: 123,
      lesson_id:  3,
      url:  "htps://www.invalid_url.com"
    ).valid?
    assert Reading.create(
      order_number: 123,
      lesson_id:  3,
      url:  "https://www.valid_url.com"
    ).valid?
  end

  # Validate that Courses requires both course_code and a name.
  def test_course_requires_both_course_code_and_name
    course = Course.create(
      course_code: 'a1'
    )
    refute course.save
    course = Course.create(
      name: 'Python 201'
    )
    refute course.save
    course = Course.create(
      course_code: 'abc183',
      name: 'Python 201'
    )
    assert course.save
  end

  # Validate that the course_code is unique within a given term_id.
  def test_coursecode_uniq_within_given_termid
    term = Term.create(
      name: 'Q1-1601',
      starts_on: '1601-05-01',
      ends_on:   '1601-08-30',
      school_id: 4
      )
    assert term.save
    course = Course.create(
      course_code: 'abc193',
      name: 'Python 201'
    )
    assert course.save
    term.courses << course
    assert term.courses.count == 1
    course = Course.new(
      course_code: 'abc193',
      name: 'Python 201'
    )
    term.courses << course
    refute term.courses.count == 2
    course = Course.new(
      course_code: 'wgc324',
      name: 'Python 401'
    )
    term.courses << course
    assert term.courses.count == 2
  end

# Validate course_code starts with three letters
# and ends with three numbers. Use a regular expression.
  def test_coursecode_starts_3letters_ends_3numbers
    term = Term.create(
      name: 'Q1-1601',
      starts_on: '1601-05-01',
      ends_on:   '1601-08-30',
      school_id: 4
      )
    assert term.save
    course = Course.new(
      course_code: 'ab123',
      name: 'Python 301'
    )
    refute course.save
    course = Course.new(
      course_code: 'abz423',
      name: 'Python 301'
    )
    assert course.save
  end

end
