class CspReportsController < ActionController::API
  # Receives Content-Security-Policy violation reports from the browser
  # (wired up via `policy.report_uri "/csp-reports"` in the CSP initializer)
  # and writes a structured line to the Rails log. No DB writes, no auth —
  # the endpoint is intentionally cheap and idempotent.
  #
  # Reports come in as `application/csp-report` JSON with the shape:
  #   { "csp-report": { "document-uri": ..., "violated-directive": ..., ... } }
  # Rails won't auto-parse that content type, so we read the raw body.
  #
  # Browser extensions injecting their own scripts into pages are by far the
  # noisiest source of false-positive reports. We drop anything whose
  # source-file looks like an extension URL before logging.

  EXTENSION_SCHEMES = %w[
    chrome-extension
    moz-extension
    safari-extension
    safari-web-extension
    ms-browser-extension
  ].freeze

  def create
    report = parse_report
    return head :no_content if report.blank?
    return head :no_content if extension_noise?(report)

    Rails.logger.warn(
      "[CSP] directive=#{report['effective-directive'] || report['violated-directive']} " \
      "blocked=#{report['blocked-uri']} " \
      "doc=#{report['document-uri']} " \
      "source=#{report['source-file']}:#{report['line-number']}"
    )
    head :no_content
  end

  private

  def parse_report
    JSON.parse(request.raw_post)["csp-report"]
  rescue JSON::ParserError
    nil
  end

  def extension_noise?(report)
    source = report["source-file"].to_s
    EXTENSION_SCHEMES.any? { |scheme| source.start_with?("#{scheme}://") }
  end
end
