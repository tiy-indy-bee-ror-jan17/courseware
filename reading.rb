class Reading < ActiveRecord::Base

  belongs_to :lesson

url_regx = /^(http|https):\/\/.*$/
# Validate that Readings must have an order_number, a lesson_id, and a url.
  validates   :order_number, presence: true
  validates   :lesson_id, presence: true
  validates   :url, presence: true,
                format: {with: /\A(http|https):\/\/.*\Z/}
  # validate    :url_ok
  #verify url starts with http or https
  #URL_Starts_with_https = \^(http|https):\/\/.*$\
  # First, lets try to get it to work w/o regex
  # def url_ok
  #   debug = false
  #   url_valid = /^(http|https):\/\/.*$/
  #   if url_valid.match(url)
  #     puts "URL Validated !! " if debug
  #   else
  #     puts "Invalid url #{url} missing http(s)" if debug
  #     errors.add(:field, 'error message')
  #   end
  # end
  default_scope { order('order_number') }

  scope :pre, -> { where("before_lesson = ?", true) }
  scope :post, -> { where("before_lesson != ?", true) }

  def clone
    dup
  end
end
