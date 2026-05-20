import { Controller } from "@hotwired/stimulus"

// Dynamic add/remove for OfferContact rows in the offer form. Clones a
// <template> element on add, marks persisted rows for _destroy on remove,
// and updates a row's icon when its kind <select> changes.
//
// Usage in the form:
//   data-controller="offer-contacts"
//   data-offer-contacts-target="list"          (list container)
//   data-offer-contacts-target="template"      (<template> with sample row)
// Each row inside the list:
//   data-offer-contacts-target="row"
//   data-offer-contacts-target="icon"          (the icon element to update)
//   data-offer-contacts-target="destroyFlag"   (hidden _destroy field, persisted rows only)
//   the kind <select>: data-action="change->offer-contacts#updateIcon"
//   the remove button: data-action="click->offer-contacts#remove"
//   the add button:    data-action="click->offer-contacts#add"
const ICON_MAP = {
  phone:     "bi-telephone",
  sms:       "bi-chat-text",
  signal:    "bi-signal",
  whatsapp:  "bi-whatsapp",
  telegram:  "bi-telegram",
  instagram: "bi-instagram",
}

export default class extends Controller {
  static targets = ["list", "template"]

  add(event) {
    event.preventDefault()
    const stamp = new Date().getTime()
    const html = this.templateTarget.innerHTML.replaceAll("NEW_RECORD", stamp)
    this.listTarget.insertAdjacentHTML("beforeend", html)
  }

  remove(event) {
    event.preventDefault()
    const row = event.target.closest("[data-offer-contacts-target='row']")
    if (!row) return

    const destroyFlag = row.querySelector("[data-offer-contacts-target='destroyFlag']")
    if (destroyFlag) {
      destroyFlag.value = "1"
      row.style.display = "none"
    } else {
      row.remove()
    }
  }

  updateIcon(event) {
    const select = event.target
    const row = select.closest("[data-offer-contacts-target='row']")
    if (!row) return

    const icon = row.querySelector("[data-offer-contacts-target='icon']")
    if (!icon) return

    Object.values(ICON_MAP).forEach((cls) => icon.classList.remove(cls))
    const next = ICON_MAP[select.value]
    if (next) icon.classList.add(next)
  }
}
