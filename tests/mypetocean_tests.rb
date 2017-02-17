require 'pry'
class MyPetOceanTest < Minitest::Test

  def setup
    @school = School.create!
    @term = Term.create!(school_id: @school.id)
    @course = Course.create!(term_id: @term.id)
    @course_student = CourseStudent.create!(course_id: @course.id)
    @assignment = Assignment.create!(course_id: @course.id, name: 'Destroy C-138', percent_of_grade: '89')
    @pre_class_assignment = Assignment.create!(course_id: @course.id, name: 'Destroy C-139', percent_of_grade: '89')
    @pre_class_lesson = Lesson.create!(pre_class_assignment_id: @pre_class_assignment.id, name: 'Karl Jaspers')
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
    assert affirm('@pre_class_assignment.pre_class_lessons')
    assert affirm('@pre_class_lesson.pre_class_assignment', 'Assignment')
  end

  def affirm(expression, as_class='')
    association = expression.split('.')[1] # pull the word after the period (.)
    association = association[0...-1] if association[-1] == 's' # drop the final 's'
    association = association.gsub(/_/, ' ').titlecase.gsub(/ /, '') # convert from snake case to camel case
    association = as_class if as_class # optional argument for cases where the association name does not match the class
    eval(expression).class.to_s.include? association # evaluate the original expression and check if it responds to the association
  end

end
