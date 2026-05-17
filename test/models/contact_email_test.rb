require "test_helper"

class ContactEmailTest < ActiveSupport::TestCase
  def build(name: "Daniel", from: "daniel@example.com", text: "Hi there.")
    m = ContactEmail.new
    m.name = name
    m.from = from
    m.text = text
    m
  end

  test "valid with minimal attributes" do
    assert build.valid?
  end

  test "requires name, from, and text" do
    [:name, :from, :text].each do |attr|
      m = build
      m.public_send("#{attr}=", nil)
      assert_not m.valid?, "expected invalid when #{attr} is nil"
      assert m.errors.added?(attr, :blank), "expected :blank on #{attr}, got #{m.errors[attr].inspect}"
    end
  end

  test "rejects malformed email" do
    ["not-an-email", "missing@tld", "@example.com", "spaces here@example.com"].each do |bad|
      m = build(from: bad)
      assert_not m.valid?, "expected #{bad.inspect} to be rejected"
      assert_not_empty m.errors[:from]
    end
  end

  test "rejects name over 100 chars" do
    m = build(name: "x" * 101)
    assert_not m.valid?
    assert_not_empty m.errors[:name]
  end

  test "rejects text over 1000 chars" do
    m = build(text: "x" * 1001)
    assert_not m.valid?
    assert_not_empty m.errors[:text]
  end

  test "ActiveModel form integration responds correctly" do
    m = ContactEmail.new
    assert_nil m.to_key
    assert_equal m, m.to_model
    assert_not m.persisted?
  end
end
