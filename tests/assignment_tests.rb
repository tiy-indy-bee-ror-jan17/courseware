class AssignmentTest < MiniTest::Test

  def setup
    @course = Course.create(name: rand_a_z, course_code: rand_course_code)
  end

  def test_assignments_have_course_id_and_name_and_percent_of_grade
    assignment1 = Assignment.create(course_id: @course.id, name: 'Destroy C-137', percent_of_grade: '89', due_at: '2017-01-18 21:06:59.001', active_at: '2017-01-18 21:06:59.001')
    assignment2 = Assignment.create(due_at: '2017-01-18 21:06:59.001', active_at: '2017-01-18 21:06:59.001')

    assert assignment1.persisted?
    assert assignment2.errors.full_messages.include?("Course can't be blank")
    assert assignment2.errors.full_messages.include?("Name can't be blank")
    assert assignment2.errors.full_messages.include?("Percent of grade can't be blank")
  end

  def test_assignment_name_is_unique_within_given_course_id
    course1 = Course.create(name: 'course', course_code: rand_course_code)
    course2 = Course.create(name: 'Sharp Pointy Things & Other Reasons to Become a Gelatinous Cube', course_code: rand_course_code)
    assignment1 = Assignment.create(course_id: course1.id, name: 'Aztec Tomb', percent_of_grade: '76', due_at: '2017-01-18 21:06:59.001', active_at: '2017-01-18 21:06:59.001')
    assignment2 = Assignment.create(course_id: course1.id, name: 'Sword of Destiny', percent_of_grade: '81', due_at: '2017-01-18 21:06:59.001', active_at: '2017-01-18 21:06:59.001')
    assignment3 = Assignment.create(course_id: course1.id, name: 'Sword of Destiny', percent_of_grade: '66', due_at: '2017-01-18 21:06:59.001', active_at: '2017-01-18 21:06:59.001')
    assignment4 = Assignment.create(course_id: course2.id, name: 'Sword of Destiny', percent_of_grade: '99', due_at: '2017-01-18 21:06:59.001', active_at: '2017-01-18 21:06:59.001')

    assert assignment1.persisted?
    assert assignment2.persisted?
    assert assignment3.errors.full_messages.include?("Name has already been taken")
    assert assignment4.persisted?
  end

end
