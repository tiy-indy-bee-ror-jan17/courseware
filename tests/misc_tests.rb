require 'pry'

class ApplicationTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_a_lesson_has_readings
    lesson = Lesson.create
    reading = Reading.create(lesson_id: lesson.id)
    assert lesson.readings.count == 1
  end

  def test_readings_are_destroyed_when_their_lesson_is_destroyed
    lesson = Lesson.create
    reading = Reading.create(lesson_id: lesson.id)
    lesson.destroy
    assert lesson.destroy
    assert_equal 0, Lesson.where(id: lesson.id).count
    refute Reading.find_by(lesson_id: lesson.id)
  end

  def test_a_course_has_lessons_and_lessons_belong_to_a_course
    course = Course.create
    lesson = Lesson.create(course_id: course.id)
    assert course.lessons.count == 1
    assert lesson.course
  end

  def test_courses_have_course_instructors
    course = Course.create
    instructor = CourseInstructor.create(course_id: course.id)
    assert course.course_instructors.length == 1
  end

  def test_a_lesson_has_in_class_assignments
    course = Course.create
    ica = Assignment.create(course_id: course.id, name: 'Go Cats', percent_of_grade: '89')
    lesson = Lesson.create(in_class_assignment_id: ica.id)
    refute lesson.in_class_assignment.nil?
  end

  def test_a_course_has_readings_through_lessons
    course = Course.create
    lesson = Lesson.create(course_id: course.id)
    reading = Reading.create(lesson_id: lesson.id)
    assert course.readings.count == 1
  end

  def test_a_school_must_have_a_name
    school = School.new(name: 'UNL')
    assert school.save
  end

  def test_terms_must_have_name_and_starts_on_and_ends_on_and_school_id
    school = School.create
    term1 = Term.new
    term2 = Term.new(name: 'Phrasing')
    term3 = Term.new(name: 'Mawp', starts_on: '2016-01-01')
    term4 = Term.new(name: 'Rampage', starts_on: '2017-01-01', ends_on: '2017-01-10')
    term5 = Term.new(name: 'Ugly Duckling', starts_on: '2017-01-01', ends_on: '2017-01-05', school_id: school.id)

    refute term1.save
    refute term2.save
    refute term3.save
    refute term4.save
    assert term5.save
  end

  def test_a_course_has_many_students_through_course_students
    course = Course.create
    student = User.create(first_name: 'Basil', last_name: 'Rathbone', email: 'posh@britain.com')
    cs = CourseStudent.create(course_id: course.id, student_id: student.id)

    assert_equal 1, course.students.length
  end

  def test_a_course_has_one_primary_instructor
    
    #primary_instructor will be a foreign key
  end

end
