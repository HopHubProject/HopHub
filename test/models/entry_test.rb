require "test_helper"

class EntryTest < ActiveSupport::TestCase
  test "should create entry" do
    a = entries(:rwt1).attributes
    entry = Entry.new(a)
    assert entry.save

    assert entry.id.present?
    assert entry.token.present?
  end
end
