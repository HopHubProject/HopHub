require "test_helper"

class ContentTest < ActiveSupport::TestCase
  test "fallback" do
    assert_equal contents(:en).content, Content.for('name', 'en')
    assert_equal contents(:en).content, Content.for('name', 'xx')
    assert_equal contents(:de).content, Content.for('name', 'de')
  end
end
