class LessonTest < Minitest::Test

  def setup
    @course = Course.create
    @lesson = Lesson.new(name: 'lesson', course_id: @course.id)
  end

  def test_a_lesson_has_readings
    reading = Reading.create(lesson_id: @lesson.id)
    assert @lesson.readings.count == 1
  end

  def test_readings_are_destroyed_when_their_lesson_is_destroyed
    reading = Reading.create(lesson_id: @lesson.id)
    @lesson.destroy
    assert @lesson.destroy
    assert_equal 0, Lesson.where(id: @lesson.id).count
    refute Reading.find_by(lesson_id: @lesson.id)
  end

  def test_lessons_are_destroyed_when_their_course_is_destroyed
    @course.destroy
    assert @course.destroy
    refute Lesson.find_by(course_id: @course.id)
  end

  def test_a_lesson_has_in_class_assignments_and_in_class_assignments_are_linked_to_lessons
    ica = Assignment.create(course_id: @course.id, name: 'Go Cats', percent_of_grade: '89')
    ic_lesson = Lesson.create(in_class_assignment_id: ica.id)
    assert ic_lesson.respond_to?(:in_class_assignment)
    assert_equal 1, ica.lessons.count
  end

  def test_lessons_have_child_lessons
    
  end

end
