require 'pry'
class MyPetOceanTest < Minitest::Test

  def setup
    @school = School.create!(name: 'school')
    @term = Term.create!(school_id: @school.id, name: 'term', starts_on: '1989-10-01', ends_on: '1999-12-31')
    @course = Course.create!(name: 'Catbutt & Other Specist Terms', course_code: '532', term_id: @term.id)
    @course_student = CourseStudent.create!(course_id: @course.id)
    @assignment = Assignment.create!(course_id: @course.id, name: 'Destroy C-138', percent_of_grade: '89')
    @pre_class_assignment = Assignment.create!(course_id: @course.id, name: 'Destroy C-139', percent_of_grade: '89')
    @pre_class_lesson = Lesson.create!(pre_class_assignment_id: @pre_class_assignment.id, name: 'Karl Jaspers')
    @lesson = Lesson.create!(name: 'Miguel Unamuno')
    @reading = Reading.create!(lesson_id: @lesson.id, order_number: '2334', url: 'https://www.youtube.com/watch?v=kytC4OOFeSs')
  end

  def test_uniqueness
    assert Course.create(name: 'Catbutt & Other Great Things to Call Your Dumbass Friends',
                         course_code: '532',
                         term_id: @term.id)
                 .invalid?
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
