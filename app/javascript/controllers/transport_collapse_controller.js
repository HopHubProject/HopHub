import { Controller } from "@hotwired/stimulus"

// Shows/hides a Bootstrap collapse panel based on the value of a select.
// On the entries form, this reveals car-specific inputs (seats, driver) when
// transport is "car".
//
// Usage:
//   data-controller="transport-collapse"
//   data-transport-collapse-match-value="car"
// Targets:
//   data-transport-collapse-target="select"  data-action="change->transport-collapse#sync"
//   data-transport-collapse-target="panel"
export default class extends Controller {
  static targets = ["select", "panel"]
  static values = { match: { type: String, default: "car" } }

  connect() {
    this.collapse = new window.bootstrap.Collapse(this.panelTarget, { toggle: false })
    this.sync()
  }

  disconnect() {
    this.collapse?.dispose?.()
    this.collapse = null
  }

  sync() {
    if (this.selectTarget.value === this.matchValue) {
      this.collapse.show()
    } else {
      this.collapse.hide()
    }
  }
}
