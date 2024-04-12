# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "popper", to: 'popper.js', preload: true

pin "bootstrap", to: "https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js", preload: true
pin "tempus-dominus", to: "https://cdn.jsdelivr.net/npm/@eonasdan/tempus-dominus@6.9.6/dist/js/tempus-dominus.min.js"
pin "tempus-dominus-bi-one", to: "https://cdn.jsdelivr.net/npm/@eonasdan/tempus-dominus@6.9.6/dist/plugins/bi-one.js"
pin "altcha", to: "https://cdn.jsdelivr.net/npm/altcha@0.2.3/+esm"
pin "confetti", to: "https://cdn.jsdelivr.net/npm/canvas-confetti@1.9.2/dist/confetti.browser.min.js"
pin "maptilersdk", to: "https://cdn.jsdelivr.net/npm/@maptiler/sdk@1.2.1/dist/maptiler-sdk.umd.js"
pin "maptilersdk-maptiler-geocoder", to: "https://cdn.maptiler.com/maptiler-geocoding-control/v1.2.0/maptilersdk.umd.js"
pin "maptiler"
