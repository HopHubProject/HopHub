import { Controller } from "@hotwired/stimulus"
import "confetti"

// Fades the flash container out after a delay and removes it from the DOM.
// If the flash contains a success alert (the controller's element has a child
// with .alert-success), fires a one-off confetti burst on connect.
//
// Usage on the .flash wrapper:
//   data-controller="flash"
//   data-flash-fade-after-value="3000"
export default class extends Controller {
  static values = { fadeAfter: { type: Number, default: 3000 } }

  connect() {
    if (this.element.querySelector(".alert-success") && typeof window.confetti === "function") {
      window.confetti()
    }
    this.timeout = setTimeout(() => this.fadeOut(), this.fadeAfterValue)
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
    if (this.fadeInterval) clearInterval(this.fadeInterval)
  }

  fadeOut() {
    let opacity = 1
    this.fadeInterval = setInterval(() => {
      opacity -= 0.2
      this.element.style.opacity = opacity
      if (opacity <= 0) {
        clearInterval(this.fadeInterval)
        this.fadeInterval = null
        this.element.remove()
      }
    }, 200)
  }
}
