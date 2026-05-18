require "test_helper"

class CleanupTest < ActionDispatch::IntegrationTest
  test "should remove outdated events" do
    event = events(:one)
    event.end_date = DateTime.now-2.days
    event.save(validate: false)

    ApplicationController.helpers.cleanup

    assert_nil Event.find_by(id: event.id)
  end

  test "should remove outdated offers" do
    offer = offers(:owt1)
    offer.date = DateTime.now-4.hours
    offer.save(validate: false)

    ApplicationController.helpers.cleanup

    assert_nil Offer.find_by(id: offer.id)
  end

  test "should remove unconfirmed events" do
    event = events(:one)
    event.created_at = DateTime.now-1.days
    event.confirmed_at = nil
    event.save

    ApplicationController.helpers.cleanup

    assert_nil Event.find_by(id: event.id)
  end

  test "should remove unconfirmed offers" do
    offer = offers(:owt1)
    offer.created_at = DateTime.now-1.days
    offer.confirmed_at = nil
    offer.save

    ApplicationController.helpers.cleanup

    assert_nil Offer.find_by(id: offer.id)
  end
end
