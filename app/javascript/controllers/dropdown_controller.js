import { Controller } from "@hotwired/stimulus"
import { Dropdown } from "bootstrap"

// Connects to data-controller="dropdown"
export default class extends Controller {
  connect() {
    try {
      this.dropdown = new Dropdown(this.element.querySelector('[data-bs-toggle="dropdown"]'))
      console.log("Dropdown controller connected successfully")
    } catch (error) {
      console.error("Error initializing dropdown:", error)
    }
  }

  disconnect() {
    if (this.dropdown) {
      try {
        this.dropdown.dispose()
      } catch (error) {
        console.error("Error disposing dropdown:", error)
      }
    }
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    
    if (this.dropdown) {
      try {
        this.dropdown.toggle()
      } catch (error) {
        console.error("Error toggling dropdown:", error)
      }
    }
  }
}
