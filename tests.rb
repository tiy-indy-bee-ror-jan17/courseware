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
    school = School.create(name: "NSE54S")
    assert school.respond_to?(:terms)
  end

  def test_term_can_be_added_to_school
    school = School.create(name: "NSES")
    Term.create(name: "Fall",starts_on: "01-01-0001",ends_on: "01-02-0001",school_id: school.id)
    assert school.terms.count != 0
  end

  def test_terms_have_courses
    school = School.create(name: "NSES34")
    term = Term.create(name: "Fall", starts_on: "01-01-0001", ends_on: "01-02-0001", school_id: school.id)
    course = Course.create(name: "Math", term_id: term.id, course_code: "AAA1311")
    assert course.term_id == term.id
    refute term.destroy
    assert term.errors.full_messages.include? "Cannot delete record because dependent courses exist"
  end

  def test_course_has_a_term
    school = School.create(name: "NSESs")
    term = Term.create(name: "Fall",starts_on: "01-01-0001",ends_on: "01-02-0001",school_id: school.id)
    assert term.save
    course = Course.create(name: "Math", term_id: term.id, course_code: "AAA1211")
    assert course.save
    assert course.term.name == "Fall"
  end

  def test_courses_with_course_students_association
    user = User.create(first_name: "Test", last_name: "User", email: "user2@te2sting.com")
    course = Course.create(name: "Math", course_code: "AAA1011")
    course_student = CourseStudent.create(course_id: course.id, student_id: user.id)
    assert course_student.course_id == course.id
    refute course.destroy
    assert course.errors.full_messages.include? "Cannot delete record because dependent course students exist"
  end

  def test_assignments_with_courses_association
    course = Course.create(name: "Science", course_code: "AAA17575757575757rew511")
    assignment = Assignment.create(course_id: course.id, name: "Test99876543", percent_of_grade: 0)
    assignment2 = Assignment.create(course_id: course.id, name: "Test87798", percent_of_grade: 0)
    assert course.assignments.count == 2
    assert course.destroy
    assert course.assignments.count == 0
  end

  def test_school_has_many_courses_through_schools_term
    school = School.create(name: "NSES")
    term = Term.create(name: "Fall", starts_on: "01-01-0001", ends_on: "01-02-0001", school_id: school.id)
    course_1 = Course.create(name: "Language", course_code: "AAA1151", term_id: term.id)
    course_2 = Course.create(name: "English", course_code: "BBB1181", term_id: term.id)
    assert school.courses.count == 2
  end

  def test_lessons_have_names
    lesson = Lesson.create(name: "Math Lesson")
    assert lesson.valid?
  end

  def test_readings_have_order_number_lesson_id_url
    lesson = Lesson.create(name:"Doctor Who Lesson 2")
    reading = Reading.create(order_number: 1, lesson_id: lesson.id, url: "http://espn.com")
    assert reading.save
  end

  def test_url_verification
    lesson = Lesson.create(name:"Doctor Who Lesson")
    reading = Reading.create(order_number: 1, lesson_id: lesson.id, url: "htp://espn.com")
    refute reading.save
  end

  def test_courses_have_course_code_and_name
    course = Course.create(name: "Math", course_code: "AAA10000011")
    assert course.save
  end

  def test_course_code_uniq_within_term_id
    school = School.create(name: "NSES")
    term1 = Term.create(name: "Fall", starts_on: "01-01-0001", ends_on: "01-02-0001", school_id: school.id)
    course1 = Course.create(name: "Math", course_code: "AAA111000")
    assert course1.save
    course2 = Course.create(name: "English", course_code: "AAA111000")
    refute course2.save
  end

  def test_course_code_regex
    course = Course.create(name: "Math", course_code: "AAA15511")
    assert course.save
  end

  def test_course_instructos_are_users
    magic_mike = User.create(first_name: "Mike", last_name: "Staaaaaaaahchefski", email: "moneymike@craigslist.org", instructor: true)
    course_instructors = CourseInstructor.create(instructor_id: magic_mike.id)
    assert magic_mike.id == course_instructors.instructor_id
  end

  def test_assigntments_have_assignment_grades
    assignment = Assignment.create(name: "HW76767867676", course_id: 1, percent_of_grade: 5)
    assignment_grades = AssignmentGrade.create(assignment_id: assignment.id)
    assignment_grades2 = AssignmentGrade.create(assignment_id: assignment.id)
    assert assignment.assignment_grades.count == 2
  end

  def test_assignment_grades_belong_to_an_assignment
    assignment = Assignment.create(name: "HW5", course_id: 1, percent_of_grade: 5)
    assignment_grades = AssignmentGrade.create(assignment_id: assignment.id)
    assert assignment_grades.assignment_id == assignment.id
  end

  def test_course_has_many_instructors_through_course_instructors
    course = Course.create(name: "Math", course_code: "AAA153232511")
    magic_ike = User.create(first_name: "Ike", last_name: "Staaaaaaaahchefski", email: "moneyike@yahooligan.org", instructor: true)
    course.instructors << magic_ike
    assert course.instructors.count == 1
    assert course.instructors.first == magic_ike
    assert course.course_instructors.length == 1
    assert magic_ike.courses.length == 1
  end

  def test_assignment_cant_be_due_before_active
    course = Course.create(name: "Doctor Who", course_code: "Life042")
    assignment1 = Assignment.create(name: "HW3333335", course_id: course.id, percent_of_grade: 5, active_at: "13-12-2012", due_at: "12-12-2012")
    refute assignment1.save
  end

  def test_lessons_readings_association
    lesson = Lesson.create(name: "Test Me MoFo")
    reading = Reading.create(order_number: 1, lesson_id: lesson.id, url: "http://test.com")
    assert_equal lesson.id, reading.lesson_id
  end

  def test_lessons_courses_association
    course = Course.create(name: "Math", course_code: "AAA111344")
    lesson = Lesson.create(course_id: course.id, name: "Tesy MoFo")
    assert_equal course.id, lesson.course_id
  end

  def test_courses_instructors_association
    user = User.create(first_name: "Test", last_name: "User", email: "test@used.com", instructor: true)
    course = Course.create(name: "Math", course_code: "AAA1544311")
    course_instructor = CourseInstructor.create(course_id: course.id, instructor_id: user.id)
    refute course.destroy
    assert_equal course_instructor.course_id, course.id
  end

  def test_lessons_in_class_assignments_association
    course = Course.create(name: "Math", course_code: "AAA0890111")
    assignment = Assignment.create( name: "Test1", course_id: course.id, percent_of_grade: 100.00)
    lesson_assignment = Lesson.create(in_class_assignment_id: assignment.id)
    assert lesson_assignment.in_class_assignments == assignment
  end

  def test_lessons_pre_class_assignments_association
    course = Course.create(name: "Math", course_code: "AAA15349811")
    assignments = Assignment.create(name: "Test2", course_id: course.id, percent_of_grade: 100.00)
    lesson_assignments = Lesson.create(name: "2 Infinity and Beyond!!!!!!!!!!!",pre_class_assignment_id: assignments.id)
    assert lesson_assignments.pre_class_assignments == assignments
  end

  def test_course_readings_association
    course = Course.create(name: "CyberMen", course_code:"Error404")
    lesson = Lesson.create(name: "Delete",course_id: course.id)
    assert affirm(course.lessons,  'Lesson')
    assert affirm(lesson.readings, 'Reading')
    assert affirm(course.readings, 'Reading')
  end

  def test_school_has_name
    school = School.create(name: "")
    refute school.save
  end

  def test_terms_have_name_starts_on_ends_on_school_id
    term = Term.create(name: "",starts_on: "01-01-0001",ends_on: "01-02-0001",school_id: "")
    refute term.save
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
    course = Course.create(name: "Daleks", course_code: "EXTERMINATE")
    refute course.save
    course2 = Course.create(name: "Doctor Who", course_code: "TARDIS042")
    assert course2.save
  end

  def test_assignments_have_course_id_name_percent
    assignment = Assignment.create(course_id: "",name: "",percent_of_grade: 0)
    refute assignment.save
  end

  def test_assignment_name_unique_within_course
    course = Course.create(name: "Math", course_code: "AAA109099011")
    assignment = Assignment.create(course_id: course.id, name: "Test", percent_of_grade: 0)
    assignment2 = Assignment.create(course_id: course.id, name: "Test", percent_of_grade: 0)
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
    course = Course.create(name: "Math", course_code: "AAA111")
    user1 = User.create(first_name: "Test", last_name: "User", email: "user1@test.com")
    course_student1 = CourseStudent.create(student_id: user1.id, course_id: course.id)
    user2 = User.create(first_name: "Test", last_name: "User", email: "user2@test.com")
    course_student2 = CourseStudent.create(student_id: user2.id, course_id: course.id)
    user3 = User.create(first_name: "Test", last_name: "User", email: "user3@test.com")
    course_student3 = CourseStudent.create(student_id: user3.id, course_id: course.id)
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
    student_objects = [
      ["Michael", "Stashevsky","mike@stashevsky.com"],
      ["Stephen", "Stashevsky","stephen@stashevsky.com"],
      ["David",   "Stashevsky","dave@stashevsky.com"],
      ["Jennifer","Stashevsky","jen@stashevsky.com"],
      ["Andrew",  "Evan",      "andrew@evan.com"],
      ["Bonnie",  "Evan",      "bonnie@evan.com"],
      ["Paul",    "Evan",      "paul@evan.com"],
      ["Ben",     "Evan",      "ben@evan.com"],
      ["Aimee",   "Evan",      "aimee@evan.com"],
      ["Sam",     "Evan",      "sam@evan.com"]
    ]
    students_to_name = Array.new
    student_objects.each do |student_name|
      student_name_array = User.create!(title: "", first_name: student_name[0], middle_name: "", last_name: student_name[1], email:student_name[2])
      students_to_name << student_name_array
    end
    epic_course  = Course.create(name: "Epic Mode",course_code: "qweyyyy5555098")
    course_students_names = Array.new
    students_to_name.each do |student_to_name|
      course_students_names << student_to_name
    end
    student_names = Array.new
    course_students_names.each do |course_student_name|
      student_name = Hash.new(last_name: "", first_name: "")
      CourseStudent.create(course_id: epic_course.id, student_id: course_student_name.id)
      student_name[:last_name] = course_student_name.last_name
      student_name[:first_name] = course_student_name.first_name
      student_names << student_name
    end
    assert epic_course.students.first.full_name == " Aimee Evan"
  end
end
