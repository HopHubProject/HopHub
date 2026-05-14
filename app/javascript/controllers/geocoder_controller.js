import { Controller } from "@hotwired/stimulus"
import { resolveZipCode } from "geonames"

// Wires a location (zip code) input, a country select, and two hidden
// latitude/longitude inputs together. Typing in the zip field triggers an
// AJAX postal-code lookup at the configured URL; changing the country resets
// the geocoded values so the user re-enters the zip.
//
// Usage on a form:
//   data-controller="geocoder"
//   data-geocoder-url-value="<%= postal_code_search_path %>"
// On the inputs:
//   data-geocoder-target="location"  data-action="input->geocoder#resolve"
//   data-geocoder-target="country"   data-action="input->geocoder#clear"
//   data-geocoder-target="latitude"
//   data-geocoder-target="longitude"
export default class extends Controller {
  static targets = ["location", "latitude", "longitude", "country"]
  static values = { url: String }

  resolve() {
    resolveZipCode(this.locationTarget.value, this.elements, { url: this.urlValue })
  }

  clear() {
    this.latitudeTarget.value = ""
    this.longitudeTarget.value = ""
    this.locationTarget.value = ""
  }

  get elements() {
    return {
      locationInput:  this.locationTarget,
      latitudeInput:  this.latitudeTarget,
      longitudeInput: this.longitudeTarget,
      countryInput:   this.countryTarget,
    }
  }
}
