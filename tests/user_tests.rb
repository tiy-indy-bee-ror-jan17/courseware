class UserTest < MiniTest::Test

  def test_user_must_have_first_name_and_last_name_and_email
    user = User.create
    assert user.errors.full_messages.include?("First name can't be blank")
    assert user.errors.full_messages.include?("Last name can't be blank")
    assert user.errors.full_messages.include?("Email can't be blank")
  end

  def test_user_email_is_unique
    user1 = User.create(first_name: 'Archduke', last_name: 'Chocula', email: 'choc@choco.com')
    user2 = User.create(first_name: 'Turanga', last_name: 'Fry', email: 'apt1i@leela.com')
    user3 = User.create(first_name: 'Count', last_name: 'Chocula', email: 'choc@choco.com')

    assert user1.valid?
    assert user2.valid?
    assert user3.errors.full_messages.include?('Email has already been taken')
  end


  def test_user_email_is_valid  # Use regular expression
    user1 = User.create(first_name: 'White', last_name: 'Mage', email: 'healbot@heals.com')
    user2 = User.create(first_name: 'Red', last_name: 'Mage', email: 'refreshmeplz')

    assert user1.valid?
    assert user2.errors.full_messages.include?('Email is invalid')
  end

  def test_user_photo_url_begins_correctly
    user1 = User.create(first_name: 'Gob', last_name: 'Bluth', email: 'illusions@magictricks.com', photo_url: 'https://gothiccastle.com')
    user2 = User.create(first_name: 'Lucille', last_name: 'Bluth', email: 'thirsty@vodka.com', photo_url: 'http://motherboyxxx.com')
    user3 = User.create(first_name: 'Gene', last_name: 'Parmesan', email: 'ahhhhh@itsgene.com', photo_url: 'idiotwithballoons.com')

    assert user1.valid?
    assert user2.valid?
    assert user3.errors.full_messages.include?('Photo url is invalid')
  end

  def test_a_course_student_is_associated_with_students
    student = User.create(first_name: 'Rick', last_name: 'Sanchez', email: 'rick@earthc137.com')
    cs = CourseStudent.create(student_id: student.id)
    assert cs.student == student
  end

  def test_course_student_is_associated_with_assignment_grades
    cs = CourseStudent.create
    grade = AssignmentGrade.create(course_student_id: cs.id)

    assert grade.course_student == cs
  end

  def test_students_are_ordered_by_last_name_first_name
    student1 = User.create(first_name: 'Sterling', last_name: 'Archer', email: 'sarcher@isis.com')
    student2 = User.create(first_name: 'Mallory', last_name: 'Archer', email: 'marcher@isis.com')
    student3 = User.create(first_name: 'Algernop', last_name: 'Krieger', email: 'drkrieger@isis.com')
    student4 = User.create(first_name: 'Cheryl', last_name: 'Tunt', email: 'neckbones@isis.com')

    course = Course.create(name: 'course', course_code: 'cod123')

    cs1 = CourseStudent.create(student_id: student1.id, course_id: course.id)
    cs2 = CourseStudent.create(student_id: student2.id, course_id: course.id)
    cs3 = CourseStudent.create(student_id: student3.id, course_id: course.id)
    cs4 = CourseStudent.create(student_id: student4.id, course_id: course.id)

    assert course.students[0] == student2
    assert course.students[1] == student1
    assert course.students[2] == student3
    assert course.students[3] == student4
  end

end
