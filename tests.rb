# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'
require 'pry'

# Include both the migration and the app itself
require './migration'
require './application'
require_relative 'school'
require_relative 'term'
require_relative 'course'
require_relative 'course_student'
require_relative 'assignment'

#nancy insert, delete on merge, just for testing
ActiveRecord::Base.logger = Logger.new(STDOUT)

# Overwrite the development database connection with a test connection.
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

 #Gotta run migrations before we can run tests.  Down will fail the first time,
 #so we wrap it in a begin/rescue.
 begin ApplicationMigration.migrate(:down); rescue; end
 ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_school_has_terms
    school = School.new
    assert school.respond_to?(:terms)
  end

  def test_term_can_be_added
    school = School.create(name: "TEST")
    Term.create(name: "Fall Term", school_id: school.id)
    assert school.terms.count != 0
  end

  def test_term_has_courses
    term = Term.new
    assert term.respond_to?(:courses)
  end

  def test_course_can_be_added_to_term
    term = Term.create(name: "Fall Term")
    Course.create(name: "Coding 101", term_id: term.id)
    assert term.courses != 0
  end

  def test_term_cannot_be_deleted_with_courses
    term = Term.create(name: "Fall Term")
    Course.create(name: "Coding 101", term_id: term.id, course_code: "C101")
    refute term.destroy
    assert term.errors.full_messages.include? "Cannot delete record because dependent courses exist"
  end

  def test_course_has_students
    course = Course.create(name: "Class")
    CourseStudent.create(course_id: course.id)
    assert course.course_students != 0
  end

  def test_courses_cannot_be_deleted_with_students_in_them
    course = Course.create(name: "Test Class", course_code: "T200")
    CourseStudent.create(course_id: course.id)
    refute course.destroy
    assert course.errors.full_messages.include? "Cannot delete record because dependent course students exist"
  end

  def test_courses_has_assignments
    course = Course.create(name:"Test Class")
    Assignment.create(name: "SQL", course_id: course.id)
    assert course.assignments != 0
  end

  def test_assignment_deleted_with_courses
    course = Course.create(name: "Tested Class", course_code: "TC101")
    Assignment.create(name: "Bullshit", course_id: course.id)
    course.destroy
    refute Assignment.exists?(name: "Bullshit")
  end

  def test_lesson_can_have_pre_class_assignments
    hw = Assignment.create(name: "validation")
    lesson = Lesson.create(name: "Validating", pre_class_assignment_id: hw.id)
    assert lesson.pre_class_assignment != 0
  end

  def test_assignment_responds_to_lesson
    assign = Assignment.create(name: "validation")
    lesson = Lesson.create(name: "Ruby", pre_class_assignment_id: assign.id)
    assert_equal "Ruby", assign.lessons.first.name
  end

  def test_school_can_have_many_courses_through_terms
    tiy = School.create(name: "TIY")
    fall = Term.create(name: "Fall", starts_on: 20160901, ends_on: 20161231, school_id: tiy.id)
    winter = Term.create(name: "Winter", starts_on: 20160101, ends_on: 20160331, school_id: tiy.id)
    ruby = Course.create(name: "Course", term_id: fall.id, course_code: "CO")
    js = Course.create(name: "JavaScript", term_id: fall.id, course_code: "FEE")
    c = Course.create(name: "C", term_id: winter.id, course_code: "CEE")
    rails = Course.create(name: "Rails", term_id: winter.id, course_code: "BEE")
    assert tiy.terms.count > 1
    assert tiy.courses.count > 1
    assert_equal "TIY", rails.schools.first.name
  end

  def test_school_name_is_required
    school = School.new
    refute school.save
    assert school.errors.full_messages.include? "Name can't be blank"
  end

  def test_lessons_name_is_required
    lesson = Lesson.new
    refute lesson.save
    assert lesson.errors.full_messages.include? "Name can't be blank"
  end

  def test_reading_requires_stuff
    read = Reading.new
    refute read.save
    assert read.errors.full_messages.include? "Order number can't be blank"
  end

  def test_reading_url_starts_with_http
    read = Reading.new(url: "www.google.com")
    refute read.save
    assert read.errors.full_messages.include? "Url is invalid"
  end

  def test_course_requires_code_and_name
    course = Course.new
    refute course.save
    assert course.errors.full_messages.include? "Name can't be blank"
    assert course.errors.full_messages.include? "Course code can't be blank"

  end

  # def test_course_code_is_unique_in_term
  #   tiy = School.create(name: "TIY")
  #   fall = Term.create(name: "Fall", starts_on: 20160901, ends_on: 20161231, school_id: tiy.id)
  #   ruby = Course.create(name: "Course", term_id: fall.id, course_code: "F1")
  #   assert ruby.save
  #   js = Course.create(name: "JavaScript", term_id: fall.id, course_code: "F1")
  #   refute js.save
  #   assert
  #
  # end




  #Nancy's code

  def test_lesson_has_methods

  end
#-------------------------------------------------------------
# Explorer Player B Step 1 - Associate lessons with readings (both directions).
# When a lesson is destroyed, its readings should be automatically destroyed
# Note:  readings table has a course_id
#-------------------------------------------------------------

def test_lesson_has_table_column_methods
  new_lesson = Lesson.create(course_id: 101, name: "Psych 101", description: "Introduction to Psychology")
  assert  new_lesson.respond_to?("id?")
  refute  new_lesson.respond_to?("count")
end

def test_lesson_has_many_readings
  # if lesson doesn't have a "has_many :readings" you'll get an error on the assert
  # below - NoMethodError: undefined method `reading' for #<Lesson:0x007fa1fe3ae308>    assert Lesson.respond_to?("count")
  new_lesson = Lesson.create(course_id: 101, name: "Psych 101", description: "Introduction to Psychology")
  new_reading1 = Reading.create(order_number: 1, lesson_id: new_lesson.id, caption: "Freud Theory", url: "http://www.iep.utm.edu/freud/" )
  assert new_lesson.readings.count > 0
end

def test_reading_belongs_to_lesson
  # if reading doesn't have a "belongs_to lesson" you receive NoMethodError:
  # undefined method `lesson' for #<Reading:0x007ff374c9f198>
  new_lesson = Lesson.create(course_id: 101, name: "Psych 101", description: "Introduction to Psychology")
  new_reading1 = Reading.create( lesson_id: new_lesson.id, caption: "Freud Theory", url: "http://www.iep.utm.edu/freud/" )
  assert new_reading1.lesson
end

def test_delete_lesson_deletes_associated_readings
  new_lesson = Lesson.create(course_id: 101, name: "Psych 101", description: "Introduction to Psychology")
  Reading.create( lesson_id: new_lesson.id, caption: "Freud Theory", url: "http://www.iep.utm.edu/freud/" )
  assert Lesson.find(new_lesson.id)
  new_lesson.destroy
  assert new_lesson.readings.count == 0
  refute Lesson.find_by id: new_lesson.id
end #end test_lesson

#-------------------------------------------------------------
# Explorer Player B Step 2 - Associate lessons with courses (both directions).
# When a course is destroyed, its lessons should be automatically destroyed
# Note:  lessons table has a course_id
#-------------------------------------------------------------
  def test_course_has_table_columns
    new_course = Course.create( name: "Course.1" )
    assert new_course.respond_to?("id?")
    assert new_course.respond_to?("term_id")
  end

  def test_course_has_many_lessons
    new_course = Course.create( name: "Course1", course_code: "COO100" )
    Lesson.create(course_id: new_course.id, name: "Lesson 1")
    Lesson.create(course_id: new_course.id, name: "Lesson 2")
    assert new_course.lessons.count > 1
  end

  def test_lesson_belongs_to_course
    # Fails with message NoMethodError: undefined method `course
    # if this is missing:
    new_course2 = Course.create( name: "Course1" )
    Lesson.create(course_id: new_course2.id, name: "Lesson 1")
    assert new_course2.lessons
  end

  def test_delete_lesson_deletes_associated_courses
    new_course = Course.create( name: "Course1", course_code: "COO100" )
    Lesson.create(course_id: new_course.id, name: "Lesson 1")
    assert Course.find(new_course.id)
    new_course.destroy
    refute Course.exists?(id: new_course.id)
    refute Lesson.exists?(name: "Lesson 1")

  end
#-------------------------------------------------------------
# Explorer Player B Step 3:  Associate courses with course_instructors
# (both directions).
# If the course has any instructors associated with it, the course should
# not be deletable.
# Note:  course_instructors table has a course_id
#-------------------------------------------------------------
def test_course_instructors_has_table_columns
  new_course_instructor = CourseInstructor.create( course_id: 1, instructor_id: 1 )
  assert new_course_instructor.respond_to?("id?")
  assert new_course_instructor.respond_to?("course_id")
end

def test_courses_has_many_course_instructors
  # no instructor table?
  new_course = Course.create(name: "Course", course_code: "COO101")
  CourseInstructor.create( course_id: new_course.id, instructor_id: 500 )
  CourseInstructor.create( course_id: new_course.id, instructor_id: 600 )
  assert new_course.course_instructors.count > 1
end

def test_course_instructor_belongs_to_course
  new_course = Course.create( name: "Course77", course_code: "COO770" )
  new_course_instructor = CourseInstructor.create( course_id: new_course.id, instructor_id: 800 )
  assert new_course_instructor.course
end

def test_cant_delete_course_if_instructor_has_course
  new_course = Course.create( name: "Course88", course_code: "COO808" )
  CourseInstructor.create(course_id: new_course.id, instructor_id: 99)
  assert Course.find(new_course.id)
  new_course.destroy
  assert Course.find(new_course.id)
end

#-------------------------------------------------------------
# Explorer Player B Step 4 - Associate lessons with their in_class_assignments
# (both directions)
# Note:  lessons table has an in_class_assignments_id
#        and a pre_class_assignment_id.  Both are foreign key relationships
#        with a non-standard name
#
# Web Example:
# belongs_to :author, class_name: "Patron",
#                        foreign_key: "patron_id"
#
#
#
#-------------------------------------------------------------

def test_lessons_foreign_key_in_class_assignment
  new_assignment = Assignment.create( name: "Assignment with In Class")
  new_lesson = Lesson.create(in_class_assignment_id:  new_assignment.id )
  assert new_lesson.in_class_assignment

  # for a lesson, should be able to get the assignment represented by
  #     in_class_assignment_id
  # for an assignment, should be able to find for what all lessons
  #        have it as an in_class_assignment_id
  #
end

# def test_in_class_assignment_id_exists_in_assignment
#     new_lesson = Lesson.create
#
#
# end



end # end ApplicationTest < Minitest::Test
