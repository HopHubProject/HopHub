import { Controller } from "@hotwired/stimulus"
import "altcha"

// Installs altcha v3 i18n strings that contain HTML (rendered by Rails as
// trusted i18n) and then patches the rendered <altcha-widget> labels in
// place, since altcha v3 escapes its label/verified text.
//
// The i18n strings are (re)installed on every connect so that switching the
// page locale via Turbo — which swaps the DOM without a full reload — updates
// the widget to the new locale's strings. The MutationObserver that reapplies
// the HTML substitution after altcha re-renders is installed once per page and
// always reads the latest strings, so a single observer serves every widget.
//
// Usage on the .altcha-widget wrapper:
//   data-controller="altcha-widget"
//   data-altcha-widget-label-value="<html ok'd label>"
//   data-altcha-widget-verified-value="<html ok'd verified label>"
let observerInstalled = false

export default class extends Controller {
  static values = {
    label:    String,
    verified: String,
  }

  connect() {
    window.customElements.whenDefined("altcha-widget").then(() => {
      const $altcha = window.globalThis.$altcha
      if (!$altcha) return

      $altcha.i18n.set("en", {
        ...($altcha.i18n.get("en") || {}),
        label:    this.labelValue,
        verified: this.verifiedValue,
      })

      const reapply = () => {
        const s = $altcha.i18n.get("en") || {}
        document.querySelectorAll("altcha-widget label").forEach((el) => {
          const t = el.textContent.trim()
          if (s.label && t === s.label.trim()) el.innerHTML = s.label
          else if (s.verified && t === s.verified.trim()) el.innerHTML = s.verified
        })
      }

      if (!observerInstalled) {
        observerInstalled = true
        new MutationObserver(reapply).observe(document.documentElement, {
          characterData: true, childList: true, subtree: true,
        })
      }
      reapply()
    })
  }
}
