// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as bootstrap from "bootstrap"

// Make Bootstrap available globally
window.bootstrap = bootstrap

// Initialize Bootstrap components on page load
document.addEventListener("turbo:load", () => {
  console.log("Turbo:load - initializing Bootstrap components")
  
  // Initialize tooltips
  const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
  const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))

  // Initialize popovers
  const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]')
  const popoverList = [...popoverTriggerList].map(popoverTriggerEl => new bootstrap.Popover(popoverTriggerEl))
})

// Clean up Bootstrap components before caching
document.addEventListener("turbo:before-cache", () => {
  // Dispose of tooltips
  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(tooltip => {
    const bsTooltip = bootstrap.Tooltip.getInstance(tooltip)
    if (bsTooltip) bsTooltip.dispose()
  })

  // Dispose of popovers
  document.querySelectorAll('[data-bs-toggle="popover"]').forEach(popover => {
    const bsPopover = bootstrap.Popover.getInstance(popover)
    if (bsPopover) bsPopover.dispose()
  })
})
