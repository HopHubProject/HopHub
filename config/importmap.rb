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
# preload: false because controllers are lazy-loaded (see controllers/index.js)
pin_all_from "app/javascript/controllers", under: "controllers", preload: false

# All vendor/javascript/*.js files were downloaded from cdn.jsdelivr.net.
# Versions are tracked via `# @<version>` comments below; `bin/importmap outdated`
# reads them. To upgrade a pin, re-curl from a new jsdelivr URL and update the
# version comment here. See README ("Updating vendored JS") for the exact URLs.
#
# Not pinned: es-module-shims@2.8.1 — loaded as a plain <script> from
# cdn.jsdelivr.net in app/views/layouts/application.html.haml with an SRI
# hash. Kept on the CDN because the local Sprockets pipeline truncates this
# specific file in dev mode; the CDN URL is SRI-pinned so the byte content
# is still verified by the browser.

# popper + bootstrap are loaded eagerly from application.js because the global
# navbar (dropdowns, collapse) needs them on every page.
pin "popper", preload: true                                # @popperjs/core@2.11.8
pin "bootstrap", preload: true                             # @5.3.8

# The remaining libs are imported by individual Stimulus controllers and are
# only fetched on pages that mount those controllers. preload: false prevents
# importmap-rails from emitting a modulepreload link for them on every page.
pin "tempus-dominus",         preload: false               # @eonasdan/tempus-dominus@6.10.4
pin "tempus-dominus-bi-one",  preload: false               # @eonasdan/tempus-dominus@6.10.4 (plugins/bi-one)
pin "altcha",                 preload: false               # @3.0.9
pin "confetti",               preload: false               # canvas-confetti@1.9.4
pin "geonames",               preload: false               # local (app/javascript/geonames.js)
