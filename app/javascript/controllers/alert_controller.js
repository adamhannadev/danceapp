import { Controller } from "@hotwired/stimulus"

// Auto-dismissing Alert Controller
// Connects to data-controller="alert"
// 
// Usage:
//   <div data-controller="alert" data-alert-timeout-value="5000">
//     Alert content
//   </div>
//
// Features:
// - Auto-dismiss after specified timeout (default: 5000ms)
// - Pause timer on hover, resume on mouse leave
// - Manual dismiss with close button
// - Smooth fade-out animation
// - Visual progress bar
export default class extends Controller {
  static values = { 
    timeout: { type: Number, default: 3000 } // Default 5 seconds
  }

  connect() {
    // Ensure the alert is visible and has the Bootstrap show class
    this.element.classList.add('show')
    
    // Start the auto-dismiss timer
    this.startTimer()
  }

  disconnect() {
    // Clear timer if element is removed
    this.clearTimer()
  }

  startTimer() {
    // Clear any existing timer
    this.clearTimer()
    
    // Set new timer for auto-dismiss
    this.timer = setTimeout(() => {
      this.dismiss()
    }, this.timeoutValue)
  }

  dismiss() {
    // Clear the timer
    this.clearTimer()
    
    // Add fade out animation
    this.element.classList.add('fade-out')
    
    // Remove element after animation completes
    setTimeout(() => {
      if (this.element && this.element.parentNode) {
        this.element.remove()
      }
    }, 300) // Match CSS transition duration
  }

  // Manual dismiss (when user clicks X)
  close(event) {
    event.preventDefault()
    this.dismiss()
  }

  // Pause timer on hover
  pauseTimer() {
    this.clearTimer()
  }

  // Resume timer when hover ends
  resumeTimer() {
    this.startTimer()
  }

  clearTimer() {
    if (this.timer) {
      clearTimeout(this.timer)
      this.timer = null
    }
  }
}