import { Controller } from "@hotwired/stimulus"
import "tempus-dominus"
import "tempus-dominus-bi-one"

// Wraps a text input in a Tempus Dominus date/time picker. Loaded via
// data-controller="timepicker" on the input element. Optional values:
//   data-timepicker-locale-value="de"
//   data-timepicker-max-date-value="2026-05-21T00:00:00Z"   (any Date-parseable string)
//   data-timepicker-date-only-value="true"                  (hide the clock)
//   data-timepicker-format-value="dd/MM/yyyy HH:mm"         (Luxon-style format)
let pluginExtended = false

export default class extends Controller {
  static values = {
    locale:   { type: String, default: "en" },
    maxDate:  { type: String, default: "" },
    dateOnly: { type: Boolean, default: false },
    format:   { type: String, default: "dd/MM/yyyy HH:mm" },
  }

  connect() {
    if (!pluginExtended) {
      window.tempusDominus.extend(window.tempusDominus.plugins.bi_one.load)
      pluginExtended = true
    }

    const options = {
      restrictions: { minDate: new Date() },
      localization: {
        locale: this.localeValue,
        format: this.formatValue,
        startOfTheWeek: 1,
      },
    }

    if (this.maxDateValue) {
      options.restrictions.maxDate = new Date(this.maxDateValue)
    }
    if (this.dateOnlyValue) {
      options.display = { components: { date: true, clock: false } }
    }

    this.picker = new window.tempusDominus.TempusDominus(this.element, options)
  }

  disconnect() {
    this.picker?.dispose?.()
    this.picker = null
  }
}
