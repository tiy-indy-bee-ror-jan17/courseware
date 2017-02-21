require 'pry'
class CourseTest < Minitest::Test

  def setup
    @course ||= Course.create(name: 'course', course_code: rand_course_code)
    @lesson = Lesson.create(course_id: @course.id, name: 'lesson')
  end

  def test_a_course_has_lessons_and_lessons_belong_to_a_course
    assert @course.lessons.count == 1
    assert @lesson.course
  end

  def test_courses_have_course_instructors
    instructor = CourseInstructor.create(course_id: @course.id)
    assert @course.course_instructors.length == 1
  end

  def test_course_cannot_be_deleted_when_it_has_course_instructor
    course = Course.create(name: 'course', course_code: rand_course_code)
    instructor = CourseInstructor.create(course_id: course.id)
    course.destroy
    refute course.destroy
    assert_equal 1, course.course_instructors.count
  end

  def test_a_course_has_readings_through_lessons
    reading = Reading.create(lesson_id: @lesson.id, order_number: '1', url: 'http://url.com')
    assert @course.readings.count == 1
  end

  def test_a_course_has_many_students_through_course_students
    student = User.create(first_name: 'Basil', last_name: 'Rathbone', email: 'posh@britain.com')
    cs = CourseStudent.create(course_id: @course.id, student_id: student.id)

    assert_equal 1, @course.students.length
    assert @course.students.first == student
  end

  def test_a_course_has_one_primary_instructor
    user = User.create(first_name: 'Sammy', last_name: 'Meow', email: 'sammy@meow.com')
    instructor = CourseInstructor.create(instructor_id: user.id, course_id: @course.id, primary: true)
    assert @course.primary_instructor == instructor    # instructor instance == instructor instance
  end

end
