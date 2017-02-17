class UserTest < MiniTest::Test

  def test_user_must_have_first_name_and_last_name_and_email
    user1 = User.new(first_name: 'Alex', last_name: 'Woofsley', email: 'alex@pawtmail.com')
    user2 = User.new(first_name: 'Sammy', email: 'sammy@meow.com')
    user3 = User.new(last_name: 'Book', email: 'shepherd@book.com')
    user4 = User.new(first_name: 'Admiral', last_name: 'Crunch')

    assert user1.valid?
    refute user2.valid?
    refute user3.valid?
    refute user4.valid?
  end

  def test_user_email_is_unique
    user1 = User.create(first_name: 'Archduke', last_name: 'Chocula', email: 'choc@choco.com')
    user2 = User.create(first_name: 'Turanga', last_name: 'Fry', email: 'apt1i@leela.com')
    user3 = User.create(first_name: 'Count', last_name: 'Chocula', email: 'choc@choco.com')

    assert user2.valid?
    refute user3.valid?
  end


  def test_user_email_is_valid  # Use regular expression
    user1 = User.create(first_name: 'White', last_name: 'Mage', email: 'healbot@heals.com')
    user2 = User.create(first_name: 'Red', last_name: 'Mage', email: 'refreshmeplz')

    assert user1.valid?
    refute user2.valid?
  end

  def test_user_photo_url_begins_correctly
    user1 = User.create(first_name: 'Gob', last_name: 'Bluth', email: 'illusions@magictricks.com', photo_url: 'https://gothiccastle.com')
    user2 = User.create(first_name: 'Lucille', last_name: 'Bluth', email: 'thirsty@vodka.com', photo_url: 'http://motherboyxxx.com')
    user3 = User.create(first_name: 'Gene', last_name: 'Parmesan', email: 'ahhhhh@itsgene.com', photo_url: 'idiotwithballoons.com')

    assert user1.valid?
    assert user2.valid?
    refute user3.valid?
  end

  def test_a_course_student_is_associated_with_students
    student = User.create(first_name: 'Rick', last_name: 'Sanchez', email: 'rick@earthc137.com')
    cs = CourseStudent.create(student_id: student.id)

    refute cs.student_id.nil?
  end

  def test_course_student_is_associated_with_assignment_grades
    cs = CourseStudent.create
    grade = AssignmentGrade.create(course_student_id: cs.id)

    refute grade.course_student.nil?
  end


end
