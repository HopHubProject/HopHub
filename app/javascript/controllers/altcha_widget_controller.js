import { Controller } from "@hotwired/stimulus"
import "altcha"

// Installs altcha v3 i18n strings that contain HTML (rendered by Rails as
// trusted i18n) and then patches the rendered <altcha-widget> labels in
// place, since altcha v3 escapes its label/verified text. A single
// MutationObserver per page reapplies the substitution whenever altcha
// re-renders. Multiple widgets on a page share the same observer.
//
// Usage on the .altcha-widget wrapper:
//   data-controller="altcha-widget"
//   data-altcha-widget-label-value="<html ok'd label>"
//   data-altcha-widget-verified-value="<html ok'd verified label>"
let labelsInstalled = false

export default class extends Controller {
  static values = {
    label:    String,
    verified: String,
  }

  connect() {
    if (labelsInstalled) return
    labelsInstalled = true

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

      new MutationObserver(reapply).observe(document.documentElement, {
        characterData: true, childList: true, subtree: true,
      })
      reapply()
    })
  }
}
