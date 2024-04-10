require "test_helper"

class ContentTest < ActiveSupport::TestCase
  test "fallback" do
    assert_equal contents(:tos_en).content, Content.for('tos', 'en').content
    assert_equal contents(:tos_en).content, Content.for('tos', 'xx').content
    assert_equal contents(:tos_de).content, Content.for('tos', 'de').content
  end
end
