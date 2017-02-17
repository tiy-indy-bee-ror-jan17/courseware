# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'
require 'pry'

# Include both the migration and the app itself
require './migration'
require './application'

# Overwrite the development database connection with a test connection.
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def test_truth
    assert true
  end

  # B-Test-1
  def test_a_reading_is_destroyed_when_its_lesson_is_destroyed
    lesson_test = Lesson.create(course_id: 99, parent_lesson_id: 99, name: "Test Reading destroyed", pre_class_assignment_id: 1, in_class_assignment_id: 1)

    reading_test = Reading.create(lesson_id: lesson_test.id, caption: "Testy test", order_number: 99 )

    lesson_test.destroy
    refute Reading.find_by(caption: "Testy test")
  end

  #B-Test-2
  def test_destroying_a_course_destroys_its_associated_lessons
    course_test = Course.create(name: "Destroying lessons like a BAWSS")

    lesson_test = Lesson.create(course_id: course_test.id, parent_lesson_id: 99, name: "Destroy this lesson!")

    lesson_test2 = Lesson.create(course_id: course_test.id, parent_lesson_id: 99, name: "Destroy this lesson too!")

    course_test.destroy
    refute Lesson.find_by(name: "Destroy this lesson!")
    refute Lesson.find_by(name: "Destroy this lesson too!")
  end

  #B-Test-3
  def test_that_a_course_with_instructors_cannot_be_deleted
    course_test = Course.create(name: "Destroying lessons like a BAWSS")
    instructor_test = CourseInstructor.create(course_id: course_test.id)

    refute course_test.destroy
  end

  #B-Test-4
  def test_that_a_lesson_is_associated_with_its_in_class_assignment
    assign_test = Assignment.create(name: "Assignment Test")
    lesson_test = Lesson.create(in_class_assignment_id: assign_test.id)

    assert lesson_test.in_class_assignment_id == assign_test.id
  end

  #B-Test-5
  def test_a_course_has_many_readings_through_lessons
    course_many_readings_test = Course.create(name: "Advanced Lesson Destroying")
    lesson_test = Lesson.create(course_id: course_many_readings_test.id, name: "Lesson Destroying Best Practices")
    lesson_test2 = Lesson.create(course_id: course_many_readings_test.id, name: "Lesson Destroying: Safety")
    reading_test1 = Reading.create(lesson_id: lesson_test.id, caption: "Lesson Destroying: Industry Methods and Standards")
    reading_test2 = Reading.create(lesson_id: lesson_test.id, caption: "How to destroy Lessons Safely")
    reading_test3 = Reading.create(lesson_id: lesson_test2.id, caption: "What to do after you've destroyed a lesson")

    assert course_many_readings_test.readings.count > 2
  end

  #B-Test-6
  def test_validate_a_school_has_a_name
    new_school = School.create()
    assert new_school.name == nil
    assert new_school.errors.messages
    refute new_school.save
  end

  #The following tests come from a single deliverable.
  #B-Test-7
  #Date (used later) requires YYYY-MM-DD format
  def test_validate_terms_must_have_a_name
    terms_have_names = Term.new()
    assert terms_have_names.name == nil
    assert terms_have_names.errors.messages
    refute terms_have_names.save
  end

  def test_validate_terms_must_have_starts_on
    terms_have_starts_on = Term.new(name: "Winter")
    assert terms_have_starts_on.starts_on == nil
    assert terms_have_starts_on.errors.messages
    refute terms_have_starts_on.save
  end

  def test_validate_terms_must_have_ends_on
    terms_have_ends_on = Term.new(name: "Spring", starts_on: "2017-02-16")
    assert terms_have_ends_on.ends_on == nil
    assert terms_have_ends_on.errors.messages
    refute terms_have_ends_on.save
  end

  def test_validate_terms_must_have_a_school_id
    terms_have_school_id = Term.new(name: "Summer", starts_on: Date.today, ends_on: "2017-04-29")
    assert terms_have_school_id.school_id == nil
    assert terms_have_school_id.errors.messages
    refute terms_have_school_id.save
  end

  #B-Test-8
  #The following tests come from a single deliverable
  def test_that_a_user_has_a_first_name
    user_first_name = User.new()
    assert user_first_name.first_name == nil
    assert user_first_name.errors.messages
    refute user_first_name.save
  end

  def test_that_a_user_has_a_last_name
    user_last_name = User.new(first_name: "Bobby")
    assert user_last_name.last_name == nil
    assert user_last_name.errors.messages
    refute user_last_name.save
  end

  def test_that_a_user_has_an_email
    user_email = User.new(first_name: "Bobby", last_name: "Tables")
    assert user_email.email == ""
    assert user_email.errors.messages
    refute user_email.save
  end

  #B-Test-9
  def test_that_a_users_email_is_unique
    unique_email = User.new(first_name: "Bobby", last_name: "Tables", email: "dropallthetables@dropitlikeitshot.com")
    assert unique_email.save
    unique_email1 = User.new(first_name: "Fred", last_name: "Dunston", email: "dropallthetables@dropitlikeitshot.com")
    assert unique_email1.errors.messages
    refute unique_email1.save
  end


#End of Class
end
