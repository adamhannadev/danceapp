// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as bootstrap from "bootstrap"

// Make Bootstrap available globally
window.bootstrap = bootstrap

// Initialize Bootstrap components on page load
document.addEventListener('turbo:load', () => {
  // Initialize Bootstrap dropdowns
  const dropdownElementList = document.querySelectorAll('.dropdown-toggle');
  const dropdownList = [...dropdownElementList].map(dropdownToggleEl => new bootstrap.Dropdown(dropdownToggleEl));

  // Initialize Bootstrap collapses
  const collapseElementList = document.querySelectorAll('.collapse');
  const collapseList = [...collapseElementList].map(collapseEl => new bootstrap.Collapse(collapseEl, {
    toggle: false
  }));
});

// Clean up Bootstrap components before caching
document.addEventListener("turbo:before-cache", () => {
  // Dispose of dropdowns
  document.querySelectorAll('[data-bs-toggle="dropdown"]').forEach(dropdown => {
    const bsDropdown = bootstrap.Dropdown.getInstance(dropdown)
    if (bsDropdown) bsDropdown.dispose()
  })
  
  // Dispose of collapses
  document.querySelectorAll('[data-bs-toggle="collapse"]').forEach(collapse => {
    const bsCollapse = bootstrap.Collapse.getInstance(collapse)
    if (bsCollapse) bsCollapse.dispose()
  })
  
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
