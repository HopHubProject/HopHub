require "test_helper"

class CleanupTest < ActionDispatch::IntegrationTest
  test "should remove outdated events" do
    event = events(:one)
    event.end_date = DateTime.now-2.days
    event.save(validate: false)

    ApplicationController.helpers.cleanup

    assert_nil Event.find_by(id: event.id)
  end

  test "should remove outdated entries" do
    entry = entries(:rwt1)
    entry.date = DateTime.now-4.hours
    entry.save(validate: false)

    ApplicationController.helpers.cleanup

    assert_nil Entry.find_by(id: entry.id)
  end

  test "should remove unconfirmed events" do
    event = events(:one)
    event.created_at = DateTime.now-1.days
    event.confirmed_at = nil
    event.save

    ApplicationController.helpers.cleanup

    assert_nil Event.find_by(id: event.id)
  end

  test "should remove unconfirmed entries" do
    entry = entries(:rwt1)
    entry.created_at = DateTime.now-1.days
    entry.confirmed_at = nil
    entry.save

    ApplicationController.helpers.cleanup

    assert_nil Entry.find_by(id: entry.id)
  end
end
