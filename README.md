# Legacy Associations and Validations

## Description

Take an existing legacy codebase with no associations or validations and add them.

## Objectives

After completing this assignment, you should...

* Become more comfortable working with code which you did not write
* Become more comfortable adding functionality to an existing codebase
* Understand how two developers can work on the same codebase
* Be able to branch your code
* Be able to handle merge conflicts
* Be able to write associations
* Be able to write validations
* Be able to add tests to verify associations and validations

## Deliverables

* **A GitHub organization.**  Your team should create a new organization in GitHub for this assignment.
* **A pull request to this repository.**  Fork this repository to your organization, do the work, then create a pull request.
* **A modified README.**
* **A test suite.**  This test suite must be written using TDD.

This means that BEFORE adding any of these validations or associations you must:

* Write a new test.
* Run your tests and see that ONLY the new one fails (but make sure that it DOES fail).
* Write code to make the test pass.
* Run your tests and see that all tests pass.
* (Repeat those last two as necessary.)

Use the homework submission form on the course website to state when you are done.

## Normal Mode

Your assignment is to take the existing code in this folder and add associations and validations to it.  You will be working with a partner, but you will be branching your code, splitting the tasks amongst the two of you, and working on them separately.  Once you have finished your separate tasks, then you will merge your branches together and deal with any merge conflicts that arise.

If you would like, you can merge your branches more than once.

The tasks will be divided as follows.  "Associate" means to place `has_many`, `belongs_to`, `has_and_belongs_to_many`, etc in the appropriate classes.  "Validate" means to use `validates` in the appropriate classes with the appropriate parameters.

Person A:

* Associate `schools` with `terms` (both directions).
use the has_many/belongs_to relationship

* Associate `terms` with `courses` (both directions).  If a term has any courses associated with it, the term should not be deletable.
has_many/belongs_to relationship, but also make sure a dependent, restrict with error prevents terms from deleting if it contains courses. Test by destroying and refuting the destruction.  

* Associate `courses` with `course_students` (both directions).  If the course has any students associated with it, the course should not be deletable.
has_many/belongs_to relationship, same kind of restrict as terms and courses here. Test by destroying and refuting the destruction.

* Associate `assignments` with `courses` (both directions).  When a course is destroyed, its assignments should be automatically destroyed.
has_many/belongs_to relationship, destroy dependency as well.

* Associate `lessons` with their `pre_class_assignments` (both directions). Foreign key assignment that specifically tells ruby the association to make.


* Set up a School to have many `courses` through the school's `terms`.
almost literal, just use a has_many relationship to show that "through: terms" you can show the school where to find courses.

* Validate that Lessons have `names`.
presence: true is validated under the Lessons class.

* Validate that Readings must have an `order_number`, a `lesson_id`, and a `url`.
use presence: true and call out the necessary fields

* Validate that the Readings `url` must start with `http://` or `https://`.  Use a regular expression.
validate the format of the url object. basically used rubular to find the regular expression for http and made sure the string started with that.

* Validate that Courses have a `course_code` and a `name`.
again, just validating presence and testing for circumstances where they do and do not have required fields.

* Validate that the `course_code` is unique within a given `term_id`.
validate the uniqueness and test options with and without unique term_id's

* Validate that the `course_code` starts with three letters and ends with three numbers.  Use a regular expression.
rubular made this easy. still not 100% on how to account for case sensitivity. I'll have to check that out later.


Person B:

* Associate `lessons` with `readings` (both directions).  When a lesson is destroyed, its readings should be automatically destroyed.
  > `has_many` and `belongs_to` for basic association. `readings` has the foreign key, so `lesson` uses `has_many` and gets `dependent :destroy` to make this work.

* Associate `lessons` with `courses` (both directions).  When a course is destroyed, its lessons should be automatically destroyed.
  > Same thing as above. `lessons` has the foreign key in this case, so courses uses `has_many`.

* Associate `courses` with `course_instructors` (both directions).  If the course has any instructors associated with it, the course should not be deletable.
  > Associations function the same as previous. `dependent :restrict_with_error` prevents destroying `courses` with `course_instructors`

* Associate `lessons` with their `in_class_assignments` (both directions).
  >This was tricky since `in_class_assignments` are actually `assignments`, but are called as `in_class_assignments` in `lesson`.

  >in `lesson` the id is already under `in_class_assignment_id` so `belongs_to :in_class_assignment,  class_name: "Assignment"` works, we just have to tell it where that id points (since it's not in a table called `in_class_assignments`).

  > On the other hand, for `assignment`, `has_many :lessons_in, class_name: "Lesson", foreign_key: "in_class_assignment_id"` works because we had to tell it both the table name and where to find the foreign key.

* Set up a Course to have many `readings` through the Course's `lessons`.
  > used `has_many :readings, through: :lessons` and vice versa. this just tells active record that we want to link through two existing links.

* Validate that Schools must have `name`.
  > `validates :name, presence: true`. Pretty self explanatory.

* Validate that Terms must have `name`, `starts_on`, `ends_on`, and `school_id`.
  > pretty much identical to above. just with four seperate validation statements.

* Validate that the User has a `first_name`, a `last_name`, and an `email`.
  > also the same as above.

* Validate that the User's `email` is unique.
  >Used `validates :email, presence: true, uniqueness: true`.

* Validate that the User's `email` has the appropriate form for an e-mail address.  Use a regular expression.
  > full command used was: `validates :email, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+/i, message: "is bad juju"}`

  > regex checks that the email starts with allowed characters, has and '@' symbol, then has allowed characters, a '.' then more allowed characters, which optional more '.' dividers.

* Validate that the User's `photo_url` must start with `http://` or `https://`.  Use a regular expression.
  > this needed `allow_blank` so the validation didn't require the field to be filled: `validates :photo_url, allow_blank: true, format: {with: /\Ahttps?:\/\/\S+/i, message: "is bad potato"}`

  > the regex just checks that it starts with 'http', an optional 's', then '://', then some number of non-space characters.

* Validate that Assignments have a `course_id`, `name`, and `percent_of_grade`.
  >same as other presence validations

* Validate that the Assignment `name` is unique within a given `course_id`.
  > used `validates :name, presence: true, uniqueness: {scope: :course, message: "can't be duplicates in the same course!!"}`

Don't forget to write tests for each of these before coding them!


## Hard Mode

After merging, add the following validations and associations, then merge again:

Person A:

* Associate `course_instructors` with `instructors` (who happen to be users)
* Associate `assignments` with `assignment_grades` (both directions)
* Set up a Course to have many `instructors` through the Course's `course_instructors`.
* Validate that an Assignment's `due_at` field is not before the Assignment's `active_at`.

Person B:

* Associate CourseStudents with `students` (who happen to be users)
  >students are just users, so `belongs_to :student, class_name: "User"` tells it that when student is called, look in the `User` class/table (and by default `:student_id` is where it looks for the link id).

  >likewise, `User` needs to know where to find it's id in `course_students` so we use `has_many :course_students, foreign_key: "student_id"`.

* Associate CourseStudents with `assignment_grades` (both directions)
  >basic assignment using `has_many` and `belongs_to`

* Set up a Course to have many `students` through the course's `course_students`.
  >similar to other `through` statements, used `has_many :courses, through: :course_students` and `has_many :students, through: :course_students`. `course_students` takes care of the foreign key weirdness with students/users.

* Associate a Course with its ONE `primary_instructor`.  This primary instructor is the one who is referenced by a course_instructor which has its `primary` flag set to `true`.
  > This was interesting. I used:

  >`if :primary`

  >    `validates :primary, uniqueness: { scope: :course_id, message: "instructor can only exist once per course"}`

  >  `end`

  > I don't know if this is the best way, but I worried if I didn't wrap the `validates` in a conditional that it would only allow one non-primary instructor (i.e. unique) per course.

Again, don't forget to write tests!

## Nightmare Mode

Although you've set up associations between these records, there's no telling what order the associated records will come back in.  For instance, when you call `course.assignments`, they may or may not be sorted by the due date.

After merging hard mode, modify the associations to do the following, then merge again:

Person A:

* A Course's `assignments` should be ordered by `due_at`, then `active_at`.

Person B:

* A Course's `students` should be ordered by `last_name`, then `first_name`.
  > this was already done via `default_scope`. I just had to test it.

Then, together:

* Associate Lessons with their `child_lessons` (and vice-versa).  Sort the `child_lessons` by `id`.
  > Active Record automatically looks under the calling key with an added `_id` for `belongs_to`, So we just had to tell it to look in `lesson`. Not sure if some form of `.self` would work here.

  > `belongs_to :parent_lesson, class_name: "Lesson"`

  > for the `has_many` side, it already knows what table to look in (`lessons`), so we just need to tell Active Record that the foreign key is not in `lesson_id`.
  
  > `has_many :lessons, foreign_key: "parent_lesson_id"`

(And, of course, tests tests tests).
