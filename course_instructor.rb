class CourseInstructor < ActiveRecord::Base

  belongs_to :course
  belongs_to :instructor, class_name: 'User',
                          foreign_key: 'instructor_id'

  has_many :tags, as: :taggable

end
