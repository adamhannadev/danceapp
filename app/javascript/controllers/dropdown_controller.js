import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  connect() {
    // Wait for Bootstrap to be available and initialize on next tick
    setTimeout(() => {
      this.initializeDropdown()
    }, 10)
  }

  initializeDropdown() {
    try {
      // Access Bootstrap through the global window object
      if (window.bootstrap && window.bootstrap.Dropdown) {
        const dropdownElement = this.element.querySelector('[data-bs-toggle="dropdown"]')
        if (dropdownElement) {
          this.dropdown = new window.bootstrap.Dropdown(dropdownElement)
          console.log("Dropdown controller connected successfully")
        } else {
          console.warn("Dropdown toggle element not found")
        }
      } else {
        console.warn("Bootstrap not available globally, retrying...")
        // Retry after a short delay
        setTimeout(() => {
          this.initializeDropdown()
        }, 100)
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
    } else {
      // Fallback: try to initialize and then toggle
      this.initializeDropdown()
      setTimeout(() => {
        if (this.dropdown) {
          this.dropdown.toggle()
        }
      }, 50)
    }
  }
}
