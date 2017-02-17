class Reading < ActiveRecord::Base

  belongs_to :lesson
  has_many :courses, through: :lesson
  default_scope { order('order_number') }

  scope :pre, -> { where("before_lesson = ?", true) }
  scope :post, -> { where("before_lesson != ?", true) }

  validates :order_number, presence: true
  validates :lesson_id, presence: true
  validates :url, presence: true
  validates :url, format: {with: /\Ahttps?:\/\/\S+/i}
  def clone
    dup
  end


#   def url_checker
#     url.start_with?("http://") || url.start_with?("https://")
#   end
# end

# def url_validator(url)
#
# url_regex = Regexp.new("((https?|ftp|file):((//)|(\\\\))+[\w\d:\#@%/;$()~_?\+-=\\\\.&]*)")
#
#     if url =~ url_regex then
#         puts "%s is valid" % url
#     else
#         puts "%s not valid" % url
#     end
end
