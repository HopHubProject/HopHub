require "test_helper"

class ContentTest < ActiveSupport::TestCase
  test "fallback" do
    assert_equal contents(:tos_en).content, Content.for('tos', 'en')
    assert_equal contents(:tos_en).content, Content.for('tos', 'xx')
    assert_equal contents(:tos_de).content, Content.for('tos', 'de')
  end
end
