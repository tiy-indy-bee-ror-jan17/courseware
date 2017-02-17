class School < ActiveRecord::Base
  has_many   :terms
  has_many   :courses
  default_scope { order('name') }
end
