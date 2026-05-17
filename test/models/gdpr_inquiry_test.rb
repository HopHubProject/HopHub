require "test_helper"

class GdprInquiryTest < ActiveSupport::TestCase
  def build(email)
    m = GdprInquiry.new
    m.email = email
    m
  end

  test "valid with a well-formed email" do
    assert build("x@example.com").valid?
  end

  test "requires email" do
    m = GdprInquiry.new
    assert_not m.valid?
    assert m.errors.added?(:email, :blank)
  end

  test "requires email when blank string" do
    m = build("")
    assert_not m.valid?
    assert m.errors.added?(:email, :blank)
  end

  test "rejects malformed emails" do
    ["not-an-email", "missing@tld", "@example.com", "user@.com"].each do |bad|
      m = build(bad)
      assert_not m.valid?, "expected #{bad.inspect} to be rejected"
      assert_not_empty m.errors[:email]
    end
  end

  test "ActiveModel form integration responds correctly" do
    m = GdprInquiry.new
    assert_nil m.to_key
    assert_equal m, m.to_model
    assert_not m.persisted?
  end
end
