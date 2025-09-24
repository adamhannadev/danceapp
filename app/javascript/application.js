// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Import Bootstrap for Rails 8 best practices
import "bootstrap"
// Initialize other Bootstrap components if needed
document.addEventListener('turbo:load', () => {
  // Bootstrap is now loaded via importmap, so it should be available
  // Initialize tooltips if any exist
  const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
  if (tooltipTriggerList.length > 0) {
    tooltipTriggerList.map(function (tooltipTriggerEl) {
      return new bootstrap.Tooltip(tooltipTriggerEl);
    });
  }

  // Initialize popovers if any exist  
  const popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
  if (popoverTriggerList.length > 0) {
    popoverTriggerList.map(function (popoverTriggerEl) {
      return new bootstrap.Popover(popoverTriggerEl);
    });
  }
});

// Clean up Bootstrap components before caching (for Turbo)
document.addEventListener("turbo:before-cache", () => {
    // Dispose of tooltips
    document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(tooltip => {
      const bsTooltip = bootstrap.Tooltip.getInstance(tooltip);
      if (bsTooltip) bsTooltip.dispose();
    });

    // Dispose of popovers
    document.querySelectorAll('[data-bs-toggle="popover"]').forEach(popover => {
      const bsPopover = bootstrap.Popover.getInstance(popover);
      if (bsPopover) bsPopover.dispose();
    });
});

import "trix"
import "@rails/actiontext"
