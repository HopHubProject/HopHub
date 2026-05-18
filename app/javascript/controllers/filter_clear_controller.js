import { Controller } from "@hotwired/stimulus"

// Resets every target field's value, then re-submits the closest form via
// Turbo. Used by the offers-filter "Clear" button to drop all filter state
// and refetch the unfiltered list.
//
// Usage on the button:
//   data-controller="filter-clear"
//   data-action="click->filter-clear#clear"
// On each input to be cleared:
//   data-filter-clear-target="field"
export default class extends Controller {
  static targets = ["field"]

  clear(event) {
    event.preventDefault()
    this.fieldTargets.forEach((f) => { f.value = "" })
    const form = this.element.closest("form")
    if (form) window.Turbo.navigator.submitForm(form)
  }
}
