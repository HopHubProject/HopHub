require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "should not create event without name" do
    a = events(:one).attributes
    a[:name] = ""

    event = Event.new(a)
    assert_not event.save
  end

  test "should not create event without end date" do
    a = events(:one).attributes
    a[:end_date] = ""

    event = Event.new(a)
    assert_not event.save
  end

  test "should not create event with end date in the past" do
    a = events(:one).attributes
    a[:end_date] = DateTime.now-1.hour

    event = Event.new(a)
    assert_not event.save
  end

  test "should create event" do
    a = events(:one).attributes

    event = Event.new(a)
    assert event.save

    assert event.admin_token.present?
  end
end
