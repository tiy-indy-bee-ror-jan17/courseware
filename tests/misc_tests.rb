class ApplicationTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_a_lesson_has_readings
    lesson = Lesson.create
    reading = Reading.create(lesson_id: lesson.id)
    assert lesson.readings.count == 1
  end

  def test_a_course_has_lessons
    course = Course.create
    lesson = Lesson.create(course_id: course.id)
    assert course.lessons.count == 1
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
    refute school.name.length == 0
  end

  def test_a_course_has_many_student_through_course_students
  end

  def test_a_course_has_one_primary_instructor
  end

end
