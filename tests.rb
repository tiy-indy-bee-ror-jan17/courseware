# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'
require 'pry'

# Include both the migration and the app itself
require './migration'
require './application'

ActiveRecord::Base.logger = Logger.new(STDOUT)

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
    @school = School.create
    @term = Term.create(school_id: @school.id)
    @course = Course.create(term_id: @term.id)
    @course_student = CourseStudent.create(course_id: @course.id)
    @assignment = Assignment.create(course_id: @course.id)
    @pre_class_assignment = Assignment.create
    @lesson = Lesson.create(pre_class_assignment_id: @pre_class_assignment.id)
  end

  def test_associations
    assert affirm('@school.terms')
    assert affirm('@term.school')
    assert affirm('@term.courses')
    assert affirm('@school.courses')
    assert affirm('@course.course_students')
    assert affirm('@course_student.course')
    assert affirm('@course.assignments')
    assert affirm('@assignment.course')
    assert affirm('@pre_class_assignment.lessons')
    assert affirm('@lesson.pre_class_assignment', 'Assignment')
  end

  def affirm(expression, as_class='')
    association = expression.split('.')[1] # pull the word after the period (.)
    association = association[0...-1] if association[-1] == 's' # drop the final 's'
    association = association.gsub(/_/, ' ').titlecase.gsub(/ /, '') # convert from snake case to camel case
    association = as_class if as_class
    eval(expression).class.to_s.include? association # evaluate the original expression and check if it responds to the association
  end

end
