# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

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

  def setup
    @school = School.create(name: "school")
    Term.create(name: "term1", school_id: 1)
    Term.create(name: "term2", school_id: 1)
  end

  def test_truth
    assert true
  end

  def test_school_has_terms
    @school = School.create(name: "school")
    Term.create(name: "term1", school_id: 1)
    Term.create(name: "term2", school_id: 1)
    assert school.terms.length == 2
    assert "term1" == school.terms.first.name
  end

  def test_terms_have_course
    Course.create()
  end



end
