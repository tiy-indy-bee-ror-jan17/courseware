class School < ActiveRecord::Base

  validates :name, presence: true

  default_scope { order('name') }

  has_many :terms
  has_many :courses, through: :terms

end
