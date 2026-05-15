require "test_helper"

class CspReportsControllerTest < ActionDispatch::IntegrationTest
  REPORT_HEADERS = { "CONTENT_TYPE" => "application/csp-report" }.freeze

  def post_report(payload)
    post "/csp-reports", params: payload.to_json, headers: REPORT_HEADERS
  end

  def capture_rails_log
    buffer = StringIO.new
    original = Rails.logger
    Rails.logger = ActiveSupport::Logger.new(buffer)
    begin
      yield
    ensure
      Rails.logger = original
    end
    buffer.string
  end

  test "logs a structured warning and returns 204" do
    report = {
      "csp-report" => {
        "document-uri"        => "https://example.com/events/123",
        "violated-directive"  => "script-src 'self'",
        "effective-directive" => "script-src",
        "blocked-uri"         => "inline",
        "source-file"         => "https://example.com/events/123",
        "line-number"         => 42,
      },
    }

    log = capture_rails_log do
      post_report(report)
    end

    assert_response :no_content
    assert_match "[CSP]", log
    assert_match "directive=script-src", log
    assert_match "blocked=inline", log
    assert_match "doc=https://example.com/events/123", log
    assert_match "source=https://example.com/events/123:42", log
  end

  test "drops reports caused by browser extensions" do
    report = {
      "csp-report" => {
        "violated-directive" => "script-src 'self'",
        "blocked-uri"        => "inline",
        "source-file"        => "chrome-extension://abcdef/contentscript.js",
        "line-number"        => 1,
      },
    }

    log = capture_rails_log do
      post_report(report)
    end

    assert_response :no_content
    assert_no_match(/\[CSP\]/, log)
  end

  test "swallows malformed JSON without raising" do
    post "/csp-reports", params: "{ not valid json", headers: REPORT_HEADERS
    assert_response :no_content
  end
end
