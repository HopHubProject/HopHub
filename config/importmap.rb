# Pin npm packages by running ./bin/importmap

# Emit Subresource Integrity (SRI) hashes alongside each pin in the rendered
# importmap. Sprockets computes the hash from the actual served bytes; the
# browser refuses to execute a script whose hash doesn't match, so a tampered
# vendored file (or a hijacked asset CDN) will be rejected by the client.
# Combined with the `# @<version>` comments below, this is the enforcement
# layer for the vendored deps.
enable_integrity!

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# All vendor/javascript/*.js files were downloaded from cdn.jsdelivr.net.
# Versions are tracked via `# @<version>` comments below; `bin/importmap outdated`
# reads them. To upgrade a pin, re-curl from a new jsdelivr URL and update the
# version comment here. See README ("Updating vendored JS") for the exact URLs.
#
# Not pinned but also vendored: es-module-shims@1.8.3 — loaded as a plain <script>
# in app/views/layouts/application.html.haml from vendor/javascript/es-module-shims.js.

pin "popper", preload: true                # @popperjs/core@2.11.8
pin "bootstrap", preload: true             # @5.3.8
pin "tempus-dominus"                       # @eonasdan/tempus-dominus@6.10.4
pin "tempus-dominus-bi-one"                # @eonasdan/tempus-dominus@6.10.4 (plugins/bi-one)
pin "altcha"                               # @3.0.9
pin "confetti"                             # canvas-confetti@1.9.4
pin "geonames"                             # local (app/javascript/geonames.js)
