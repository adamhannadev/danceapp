import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  connect() {
    try {
      // Access Bootstrap through the global window object
      if (window.bootstrap && window.bootstrap.Dropdown) {
        this.dropdown = new window.bootstrap.Dropdown(this.element.querySelector('[data-bs-toggle="dropdown"]'))
        console.log("Dropdown controller connected successfully")
      } else {
        console.warn("Bootstrap not available globally")
      }
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
