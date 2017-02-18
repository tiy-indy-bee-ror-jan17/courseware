class School < ActiveRecord::Base

  has_many :terms

  default_scope { order('name') }

  validates :name, presence: true


end
