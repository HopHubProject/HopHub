require "test_helper"

class EntryTest < ActiveSupport::TestCase
  test "should create entry" do
    a = entries(:owt1).attributes
    entry = Entry.new(a)
    assert entry.save

    assert entry.id.present?
    assert entry.token.present?
  end

  test "controller should increment seats_added_total" do
    event = events(:one)
    entry = entries(:owt1)

    assert_difference("event.seats_added_total", 5) do
      Entry.create!(entry.attributes.merge(event_id: event.id, seats: 5))
      assert event.reload
    end
  end
end
