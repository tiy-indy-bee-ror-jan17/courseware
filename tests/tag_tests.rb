class TagTest < MiniTest::Test

  def test_create_a_new_tag
    user = User.create(first_name: 'first', last_name: 'last', email: 'email@email.com')
    tag = Tag.create
    tag2 = Tag.create(name: 'tag', taggable: user)
    refute tag.save
    assert tag.errors.full_messages.include?("Name can't be blank")
    assert tag.errors.full_messages.include?("Taggable can't be blank")
    assert tag2.persisted?
  end

  def test_a_lesson_can_be_tagged
    lesson = Lesson.create(name: 'lesson')
    tag = lesson.tags.create(name: 'lesson_tag')
    assert lesson.tags.count == 1
    assert lesson.tags.first == tag
  end

  def test_a_course_instructor_cannot_be_tagged
    cs = CourseInstructor.create
    cs_tag = cs.tags.create(name: 'cs_tag')
    assert cs.tags.count == 0
  end

  def test_a_tag_can_be_tagged
    lesson = Lesson.create(name: 'lesson')
    tag1 = Tag.create(name: 'tag1', taggable: lesson)
    tag2 = Tag.create(name: 'tag2', taggable: tag1)
    tag3 = Tag.create(name: 'tag3', taggable: tag2)

    assert tag1.tags.count == 1
    assert tag1.tags.first == tag2
    assert tag2.tags.count == 1
    assert tag2.tags.first == tag3
  end

  def test_a_tag_can_have_many_tags
    lesson = Lesson.create(name: 'lesson')
    tag4 = Tag.create(name: 'tag4', taggable: lesson)
    tag5 = Tag.create(name: 'tag5', taggable: tag4)
    tag6 = Tag.create(name: 'tag6', taggable: tag4)

    assert tag4.tags.count == 2
    assert tag4.tags.include?(tag5)
    assert tag4.tags.include?(tag6)
  end

end
