require 'pry'

class MiscTest < Minitest::Test

  def test_a_school_must_have_a_name
    school = School.new(name: 'UNL')
    school2 = School.new
    assert school.save
    refute school2.save
  end

  def test_terms_must_have_name_and_starts_on_and_ends_on_and_school_id
    term = Term.create

  def test_a_lesson_has_readings
    lesson = Lesson.create(name: 'Soren Kierkegaard')
    reading = Reading.create(lesson_id: lesson.id, order_number: '654124', url: 'https://www.youtube.com/watch?v=D9JCwkx558o')
    assert lesson.readings.count == 1
  end

  def test_a_course_has_lessons
    course = Course.create(name: 'Existentialism & Anarchism', course_code: '236')
    lesson = Lesson.create(course_id: course.id, name: 'Nikolai Berdyaev')
    assert course.lessons.count == 1
  end

  def test_courses_have_course_instructors
    course = Course.create(name: 'The Geopolitical Entanglements of My Little Pony & Gematria', course_code: '4788')
    instructor = CourseInstructor.create(course_id: course.id)
    assert course.course_instructors.length == 1
  end

  def test_a_lesson_has_in_class_assignments
    course = Course.create(name: 'Oatmeal & Other Invertebrates', course_code: '6235')
    ica = Assignment.create(course_id: course.id, name: 'Go Cats', percent_of_grade: '89')
    lesson = Lesson.create(in_class_assignment_id: ica.id)
    refute lesson.in_class_assignment.nil?
  end

  def test_a_course_has_readings_through_lessons
    course = Course.create(name: 'Early Existentialists', course_code: '974')
    lesson = Lesson.create(course_id: course.id, name: 'Lev Shestov')
    reading = Reading.create(lesson_id: lesson.id, order_number: '1011', url: 'https://www.youtube.com/watch?v=sEBr6I6uGe0')
    assert course.readings.count == 1
  end

    assert term.errors.full_messages.include?("Name can't be blank")
    assert term.errors.full_messages.include?("Starts on can't be blank")
    assert term.errors.full_messages.include?("Ends on can't be blank")
    assert term.errors.full_messages.include?("School can't be blank")
  end

end
