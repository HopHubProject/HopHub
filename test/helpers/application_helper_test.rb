require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  # ---------------------------------------------------------------------------
  # bootstrap_class_for
  # ---------------------------------------------------------------------------

  test "bootstrap_class_for maps flash types to alert classes" do
    assert_equal "alert-success", bootstrap_class_for(:success)
    assert_equal "alert-danger",  bootstrap_class_for(:error)
    assert_equal "alert-danger",  bootstrap_class_for(:recaptcha_error)
    assert_equal "alert-warning", bootstrap_class_for(:alert)
    assert_equal "alert-info",    bootstrap_class_for(:notice)
  end

  test "bootstrap_class_for accepts strings (Rails flash keys are often strings)" do
    assert_equal "alert-success", bootstrap_class_for("success")
  end

  test "bootstrap_class_for falls back to the raw key for unknown types" do
    assert_equal "weird",         bootstrap_class_for("weird")
    assert_equal "made_up",       bootstrap_class_for(:made_up)
  end

  # ---------------------------------------------------------------------------
  # icon_class_for_transport
  # ---------------------------------------------------------------------------

  test "icon_class_for_transport returns the matching bi-* class per transport" do
    {
      any:     "bi bi-asterisk",
      car:     "bi bi-car-front",
      train:   "bi bi-train-front",
      bus:     "bi bi-bus-front",
      bicycle: "bi bi-bicycle",
      foot:    "bi bi-person-walking",
    }.each do |sym, css|
      assert_equal css, icon_class_for_transport(sym), "for #{sym.inspect}"
      assert_equal css, icon_class_for_transport(sym.to_s), "for #{sym.to_s.inspect}"
    end
  end

  test "icon_class_for_transport falls back to bi-star for unknown transports" do
    assert_equal "bi bi-star", icon_class_for_transport(:plane)
    assert_equal "bi bi-star", icon_class_for_transport("rocket")
  end

  # ---------------------------------------------------------------------------
  # title
  # ---------------------------------------------------------------------------

  test "title joins @title array with pipes" do
    @title = ["HopHub", "Event X", "Edit"]
    assert_equal "HopHub | Event X | Edit", title
  end

  test "title with a single element returns just that element" do
    @title = ["HopHub"]
    assert_equal "HopHub", title
  end

  # ---------------------------------------------------------------------------
  # meta_description
  # ---------------------------------------------------------------------------

  test "meta_description returns @meta_description when set" do
    @meta_description = "Event X on HopHub."
    assert_equal "Event X on HopHub.", meta_description
  end

  test "meta_description falls back to the default i18n string when unset" do
    @meta_description = nil
    assert_equal I18n.t("meta.description.default"), meta_description
  end

  # ---------------------------------------------------------------------------
  # terms_and_conditions_prompt / _accepted
  # ---------------------------------------------------------------------------

  test "terms_and_conditions_prompt interpolates ToS and privacy links" do
    rendered = terms_and_conditions_prompt
    assert rendered.html_safe?, "expected the result to be html_safe"
    assert_match %r{<a [^>]*href="/tos[^"]*">}, rendered
    assert_match %r{<a [^>]*href="/privacy[^"]*">}, rendered
  end

  test "terms_and_conditions_accepted interpolates ToS and privacy links" do
    rendered = terms_and_conditions_accepted
    assert rendered.html_safe?
    assert_match %r{<a [^>]*href="/tos[^"]*">}, rendered
    assert_match %r{<a [^>]*href="/privacy[^"]*">}, rendered
  end
end
