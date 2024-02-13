import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.scrollIntoView({ behavior: "smooth", block: "center" })
  }
}