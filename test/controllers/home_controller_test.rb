require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  I18n.available_locales.each do |locale|
    define_method("test_should_get_index_#{locale}") do
      get root_url, params: { locale: locale }
      assert_response :success

      c = Content.for('instance-info', locale)
      assert_match c.content, @response.body
      assert_match c.title, @response.body
    end

    define_method("test_should_get_imprint_#{locale}") do
      get imprint_url, params: { locale: locale }
      assert_response :success
    end

    define_method("test_should_get_privacy_#{locale}") do
      get privacy_url, params: { locale: locale }
      assert_response :success
    end

    define_method("test_should_get_tos_#{locale}") do
      get tos_url, params: { locale: locale }
      assert_response :success
    end
  end
end
