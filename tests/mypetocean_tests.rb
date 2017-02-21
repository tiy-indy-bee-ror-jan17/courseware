require 'pry'
class MyPetOceanTest < Minitest::Test

  def setup
    @school = School.find_or_create_by!(name: 'school')
    @term = Term.find_or_create_by!(school_id: @school.id, name: 'term', starts_on: '1989-10-01', ends_on: '1999-12-31')
    @course = Course.find_or_create_by!(name: 'Catbutt & Other Specist Terms', course_code: rand_course_code, term_id: @term.id)
    @course_student = CourseStudent.find_or_create_by!(course_id: @course.id)
    @assignment = Assignment.find_or_create_by!(course_id: @course.id, name: 'Destroy C-138', percent_of_grade: '89', due_at: '2017-03-18 21:06:59.001', active_at: '2017-01-19 20:04:59.001')
    @pre_class_assignment = Assignment.find_or_create_by!(course_id: @course.id, name: 'Destroy C-139', percent_of_grade: '89', due_at: '2017-07-18 21:06:59.001', active_at: '2016-12-18 21:06:59.001')
    @pre_class_lesson = Lesson.find_or_create_by!(pre_class_assignment_id: @pre_class_assignment.id, name: 'Karl Jaspers')
    @lesson = Lesson.find_or_create_by!(name: 'Miguel de Unamuno')
    @reading = Reading.find_or_create_by!(lesson_id: @lesson.id, order_number: '2334', url: 'https://www.youtube.com/watch?v=kytC4OOFeSs')
    @instructor = User.find_or_create_by!(last_name: 'Archer', first_name: 'Sterling', email: 'phrasing5@dangerzone.com')
    @course_instructor = CourseInstructor.find_or_create_by(instructor_id: @instructor.id)
    @assignment = Assignment.find_or_create_by!(course_id: @course.id, name: 'Find the Kitten and Eat It with Copious Cheddar', percent_of_grade: '100', due_at: '2017-12-18 21:06:59.001', active_at: '2017-02-18 21:06:59.001')
    @assignment_grade = AssignmentGrade.find_or_create_by!(assignment_id: @assignment.id)
  end

  def test_assignment_ordering
    correct_order = Assignment.all.sort_by{ |a| [-a.due_at.to_i, -a.active_at.to_i] }
    assert Assignment.all == correct_order
  end

  def test_uniqueness
    assert Course.create(
                         name: 'Catbutt & Other Great Things to Call Your Dumbass Friends',
                         course_code: '532',
                         term_id: @term.id
                        ).invalid?
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
    assert affirm('@pre_class_assignment.pre_class_lessons', 'Lesson')
    assert affirm('@pre_class_lesson.pre_class_assignment', 'Assignment')
    assert affirm('@instructor.course_instructors')
    assert affirm('@course_instructor.instructor', 'User')
    assert affirm('@assignment_grade.assignment')
    assert affirm('@assignment.assignment_grades')
    assert affirm('@course.instructors', 'User')
  end

  def affirm(expression, as_class='')
    association = expression.split('.')[1] # pull the word following the period (.)
    association = association[0...-1] if association[-1] == 's' # drop any final 's'
    association = association.gsub(/_/, ' ').titlecase.gsub(/ /, '') # convert snake case to camel case
    association = as_class if !as_class.empty? # optional arg for cases where association name does not match class
    eval(expression).class.to_s.include? association # evaluate the original expression and check if it responds to the association
  end

end
