require "test_helper"

class GeonamesHelperTest < ActionView::TestCase
  include GeonamesHelper

  test "get_countries short-circuits in the test environment and returns a fixed list" do
    # In test env the helper avoids hitting secure.geonames.org and instead
    # returns a small fixture-shaped list, so controllers can render forms
    # offline. We just assert the shape and contents here.
    result = get_countries("en")

    assert_kind_of Array, result
    assert result.size >= 4, "expected at least four pinned countries"

    result.each do |country|
      assert_kind_of Array, country
      assert_equal 2, country.size, "expected [name, code] pair, got #{country.inspect}"
    end

    codes = result.map(&:last)
    assert_includes codes, "DE"
    assert_includes codes, "US"
    assert_includes codes, "FR"
    assert_includes codes, "GB"
  end

  test "get_countries returns the same list regardless of the requested locale in test env" do
    assert_equal get_countries("en"), get_countries("de")
    assert_equal get_countries("en"), get_countries("es")
  end

  test "geonames_username falls back to a sentinel when the env var is unset" do
    original = ENV["GEONAMES_USERNAME"]
    ENV.delete("GEONAMES_USERNAME")
    assert_equal "invalid_username", geonames_username
  ensure
    ENV["GEONAMES_USERNAME"] = original
  end

  test "geonames_username reads from the environment when set" do
    original = ENV["GEONAMES_USERNAME"]
    ENV["GEONAMES_USERNAME"] = "test-user"
    assert_equal "test-user", geonames_username
  ensure
    ENV["GEONAMES_USERNAME"] = original
  end
end
