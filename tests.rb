require 'minitest/autorun'
require 'minitest/pride'
require 'pry'

require './migration'
require './application'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)

class ApplicationTest < Minitest::Test

  def test_truth
    assert true
  end

  def affirm(expression, assocation)
    expression.class.to_s.include? assocation
  end

  def test_schools_can_have_terms
    school = School.create(name: "NSES")
    assert school.respond_to?(:terms)
  end

  def test_term_can_be_added_to_school
    school = School.create(name: "NSES")
    Term.create(name: "Fall",starts_on: "01-01-0001",ends_on: "01-02-0001",school_id: school.id)
    assert school.terms.count != 0
  end

  def test_terms_have_courses
    term = Term.create(name: "Fall",starts_on: "01-01-0001",ends_on: "01-02-0001",school_id: 1)
    course = Course.create(name: "Math", term_id: term.id)
    assert course.term_id == term.id
    refute term.destroy
    assert term.errors.full_messages.include? "Cannot delete record because dependent courses exist"
  end

  def test_course_has_a_term
    term = Term.create(name: "Fall",starts_on: "01-01-0001",ends_on: "01-02-0001",school_id: 1)
    assert term.save
    course = Course.create(name: "Math",term_id: term.id)
    assert course.save
    assert course.term.name == "Fall"
  end

  def test_courses_with_course_students_association
    user = User.create(first_name: "Test",last_name: "User",email: "user2@te2sting.com")
    course = Course.create(name: "Math")
    course_student = CourseStudent.create(course_id: course.id,student_id: user.id)
    assert course_student.course_id == course.id
    refute course.destroy
    assert course.errors.full_messages.include? "Cannot delete record because dependent course students exist"
  end

  def test_assignments_with_courses_association
    course = Course.create(name: "Math")
    assignment = Assignment.create(course_id:  course.id,name: "Test99",percent_of_grade: 0)
    assignment2 = Assignment.create(course_id: course.id,name: "Test98",percent_of_grade: 0)
    assert course.assignments.count == 2
    assert course.destroy
    assert course.assignments.count == 0
  end

  def test_school_has_many_courses_through_schools_term
  end

  def test_lessons_readings_association
    lesson = Lesson.create(name: "Test Me MoFo")
    reading = Reading.create(lesson_id: lesson.id)
    assert_equal lesson.id, reading.lesson_id
  end

  def test_lessons_have_names
  end

  def test_lessons_courses_association
    course = Course.create()
    lesson = Lesson.create(course_id: course.id,name: "Tesy MoFo")
    assert_equal course.id, lesson.course_id
  end

  def test_courses_instructors_association
    user = User.create(first_name: "Test",last_name: "User",email: "test@used.com",instructor: true)
    course = Course.create()
    course_instructor =
            CourseInstructor.create(course_id: course.id,instructor_id: user.id)
    refute course.destroy
    assert_equal course_instructor.course_id, course.id
  end

  def test_readings_have_order_number_lesson_id_url
  end

  def test_lessons_in_class_assignments_association
    course = Course.create()
    assignment = Assignment.create(name: "Test1",course_id: course.id,percent_of_grade: 100.00)
    lesson_assignment = Lesson.create(name: "That's the name of the game",in_class_assignment_id: assignment.id)
    assert lesson_assignment.in_class_assignments == assignment
  end

  def test_lessons_pre_class_assignments_association
    course = Course.create()
    assignments = Assignment.create(name: "Test2",course_id: course.id,percent_of_grade: 100.00)
    lesson_assignments = Lesson.create(name: "2 Infinity and Beyond!!!!!!!!!!!",pre_class_assignment_id: assignments.id)
    assert lesson_assignments.pre_class_assignments == assignments
  end

  def test_course_readings_association
    course = Course.create()
    lesson = Lesson.create(name: "",course_id: course.id)
    assert affirm(course.lessons,  'Lesson')
    assert affirm(lesson.readings, 'Reading')
    assert affirm(course.readings, 'Reading')
  end
  def test_url_verification
  end

  def test_school_has_name
    school = School.create(name: "")
    refute school.save
  end

  def test_terms_have_name_starts_on_ends_on_school_id
    term = Term.create(name: "",starts_on: "01-01-0001",ends_on: "01-02-0001",school_id: "")
    refute term.save
  end

  def test_courses_have_course_code_and_name
  end

  def test_user_has_name_and_email
    user = User.create(first_name: "", last_name: "", email: "")
    refute user.save
  end

  def test_user_email_unique
    user = User.create(first_name:  "Test",   last_name: "User",email: "test@user.com")
    assert user.save
    userB = User.create(first_name: "Testing",last_name: "User",email: "test@user.com")
    refute userB.save
  end

  def test_course_code_uniq_within_term_id

  end

  def test_user_email_proper_format
    user = User.create(first_name: "Test",last_name: "User",email: "a")
    refute user.save
  end

  def test_user_photo_url
      user = User.create(first_name: "Test",  last_name: "User", email: "test@users.com", photo_url: "htt://git.com")
      refute user.save
      user2 = User.create(first_name: "Testy",last_name: "Usery",email: "testy@usery.com",photo_url: "http://git.com")
      assert user2.save
  end

  def test_course_code_starts_with_three_letters_ends_with_three_numbers

  end

  def test_assignments_have_course_id_name_percent
    assignment = Assignment.create(course_id: "",name: "",percent_of_grade: 0)
    refute assignment.save
  end

  def test_assignment_name_unique_within_course
    course = Course.create()
    assignment = Assignment.create( course_id: course.id,name: "Test",percent_of_grade: 0)
    assignment2 = Assignment.create(course_id: course.id,name: "Test",percent_of_grade: 0)
    assert assignment.save
    refute assignment2.save
  end

  def test_coursestudents_students_association
    user = User.create(first_name: "Test",last_name: "User",email: "user@test.com")
    course_student = CourseStudent.create(student_id: user.id)
    assert affirm(course_student.student, 'User')
  end

  def test_coursestudents_assignment_grades_association
    user = User.create(first_name: "Test",last_name: "User",email: "user@testing.com")
    course_student = CourseStudent.create(student_id: user.id)
    assignment_grade = AssignmentGrade.create(course_student_id: course_student.id)
    assert affirm(assignment_grade.course_student,'CourseStudent')
  end

  def test_course_has_many_students_through_course_student
    course = Course.create()
    user1 = User.create(first_name: "Test",last_name: "User",email: "user1@test.com")
    course_student1 = CourseStudent.create(student_id: user1.id,course_id: course.id)
    user2 = User.create(first_name: "Test",last_name: "User",email: "user2@test.com")
    course_student2 = CourseStudent.create(student_id: user2.id,course_id: course.id)
    user3 = User.create(first_name: "Test",last_name: "User",email: "user3@test.com")
    course_student3 = CourseStudent.create(student_id: user3.id,course_id: course.id)

    assert affirm(course_student1.course, "Course")
    assert affirm(course_student2.course, "Course")
    assert affirm(course_student3.course, "Course")
  end

  def test_course_primary_instructor_association
    user = User.create(first_name: "Test",last_name: "User",email: "user6@test.com",instructor: true)
    course = Course.create()
    course_instructor = CourseInstructor.create(course_id: course.id,primary: true,instructor_id: user.id)
    assert course_instructor.primary == true && course_instructor.course_id == course.id
  end

  def test_sorting_last_and_first_names_by_student
    student1 = User.create(first_name:  "Michael",  last_name: "Stashevsky",email: "mike@stashevsky.com")
    student2 = User.create(first_name:  "Stephen",  last_name: "Stashevsky",email: "stephen@stashevsky.com")
    student3 = User.create(first_name:  "David",    last_name: "Stashevsky",email: "dave@stashevsky.com")
    student4 = User.create(first_name:  "Jennifer", last_name: "Stashevsky",email: "jen@stashevsky.com")
    student5 = User.create(first_name:  "Andrew",   last_name: "Evan",      email: "andrew@evan.com")
    student6 = User.create(first_name:  "Bonnie",   last_name: "Evan",      email: "bonnie@evan.com")
    student7 = User.create(first_name:  "Paul",     last_name: "Evan",      email: "paul@evan.com")
    student8 = User.create(first_name:  "Ben",      last_name: "Evan",      email: "ben@evan.com")
    student9 = User.create(first_name:  "Aimee",    last_name: "Evan",      email: "aimee@evan.com")
    student10 = User.create(first_name: "Sam",      last_name: "Evan",      email: "sam@evan.com")
    course  = Course.create(name: "Epic Mode",course_code: "qwe098")
    students_to_name = [student1,student2,student3,student4,student5,student6,student7,student8,student9,student10]
    course_students_names = Array.new
    students_to_name.each do |student_to_name|
      course_students_names << student_to_name
    end
    student_names = Array.new
    course_students_names.each do |course_student_name|
      student_name = Hash.new(last_name: "", first_name: "")
      CourseStudent.create(course_id: course.id, student_id: course_student_name.id)
      assert course_student_name.enrolled?(course)
      student_name[:last_name] = course_student_name.last_name
      student_name[:first_name] = course_student_name.first_name
      student_names << student_name
    end
    student_names.each do |student_name_puts|
      puts "#{student_name_puts[:last_name]}, #{student_name_puts[:first_name]}"
    end



  end
end
