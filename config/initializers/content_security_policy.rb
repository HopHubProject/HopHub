# Be sure to restart your server when you modify this file.
#
# This policy ships in report-only mode for now: browsers will log violations
# to the console (and to a report-uri/report-to if one is configured) but will
# NOT block anything. After one prod deploy cycle confirms no real-world
# violations, flip `content_security_policy_report_only` to false to enforce.
#
# Notes on the directives:
#   script-src 'self' + per-request nonce  — locks down XSS. The nonce is
#     auto-applied by Rails to inline tags emitted by javascript_importmap_tags
#     because script-src is listed in `content_security_policy_nonce_directives`.
#   style-src 'self' 'unsafe-inline'       — required because Popper, Bootstrap
#     (dropdowns, collapse transitions), Tempus-Dominus, and our flash fade-out
#     write to element.style.* / style="..." attributes. None of these libraries
#     read CSP nonces, so 'unsafe-inline' is the only practical option for
#     style. This is the standard Rails + importmap + Bootstrap posture.
#   frame-ancestors 'none'                 — defends against clickjacking.

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src     :self
    policy.font_src        :self
    policy.img_src         :self, :data, :https
    policy.object_src      :none
    policy.script_src      :self
    policy.style_src       :self, :unsafe_inline
    policy.connect_src     :self
    policy.base_uri        :self
    policy.form_action     :self
    policy.frame_ancestors :none

    # Violations are POSTed to CspReportsController, which logs them to the
    # Rails log. Without this directive the browser warns that report-only
    # mode "cannot report violations" and the policy effectively just sits
    # in the developer's own DevTools console.
    policy.report_uri "/csp-reports"

    # Plausible analytics: the script is served from PLAUSIBLE_SRC and reports
    # back to the same host. Both fetches need to be allowed when configured.
    if ENV["PLAUSIBLE_SRC"].present?
      begin
        uri = URI.parse(ENV["PLAUSIBLE_SRC"])
        if uri.scheme.present? && uri.host.present?
          host = "#{uri.scheme}://#{uri.host}"
          policy.script_src  :self, host
          policy.connect_src :self, host
        end
      rescue URI::InvalidURIError
        # PLAUSIBLE_SRC is malformed; skip rather than crash boot.
      end
    end
  end

  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]

  config.content_security_policy_report_only = true
end
