import { Controller } from "@hotwired/stimulus"

// Toggles the data-bs-theme attribute on <html> between "dark" and "light".
// The icon target is swapped between bi-moon and bi-sun to reflect state.
//
// Usage:
//   %li.nav-item{ data: { controller: "dark-mode" } }
//     %a{ href: "#", data: { action: "click->dark-mode#toggle" } }
//       %i.bi.bi-moon{ data: { dark_mode_target: "icon" } }
export default class extends Controller {
  static targets = ["icon"]

  connect() {
    this.updateIcon()
  }

  toggle(event) {
    event.preventDefault()
    const html = document.documentElement
    const next = html.getAttribute("data-bs-theme") === "dark" ? "light" : "dark"
    html.setAttribute("data-bs-theme", next)
    this.updateIcon()
  }

  updateIcon() {
    const dark = document.documentElement.getAttribute("data-bs-theme") === "dark"
    this.iconTarget.classList.toggle("bi-moon", !dark)
    this.iconTarget.classList.toggle("bi-sun", dark)
  }
}
