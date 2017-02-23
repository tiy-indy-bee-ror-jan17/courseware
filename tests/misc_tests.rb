require 'pry'

class MiscTest < Minitest::Test

  def test_a_school_must_have_a_name
    school = School.new(name: 'UNL')
    school2 = School.new
    assert school.save
    refute school2.save
  end

  def test_terms_must_have_name_and_starts_on_and_ends_on_and_school_id
    term1 = Term.create(name: 'term', starts_on: '2000-01-01', ends_on: '2014-02-02', school_id: 'id')
    term2 = Term.create

    assert term1.save
    assert term2.errors.full_messages.include?("Name can't be blank")
    assert term2.errors.full_messages.include?("Starts on can't be blank")
    assert term2.errors.full_messages.include?("Ends on can't be blank")
    assert term2.errors.full_messages.include?("School can't be blank")
  end

end
