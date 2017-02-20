class CourseInstructor < ActiveRecord::Base
  belongs_to :course
  belongs_to :instructor, class_name: "User"

  if :primary
    validates :primary, uniqueness: { scope: :course_id, message: "instructor can only exist once per course"}
  end

end
