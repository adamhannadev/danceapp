import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { instructorId: Number }
  static targets = ["saveButton", "clearButton", "pendingCount"]

  connect() {
    this.pendingSlots = []
    this.hasUnsavedChanges = false
    
    // Wait for FullCalendar to be loaded from CDN
    if (typeof FullCalendar !== 'undefined') {
      this.initializeCalendar()
    } else {
      // Retry after a short delay if FullCalendar isn't loaded yet
      setTimeout(() => this.initializeCalendar(), 100)
    }
  }

  initializeCalendar() {
    // Find the calendar container (the div with height 600px inside the card)
    const calendarEl = this.element.querySelector('.card-body > div[style*="height: 600px"]')
    
    this.calendar = new FullCalendar.Calendar(calendarEl, {
      initialView: 'timeGridWeek',
      headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: 'dayGridMonth,timeGridWeek,timeGridDay'
      },
      slotMinTime: '08:00:00',
      slotMaxTime: '22:00:00',
      allDaySlot: false,
      editable: true,
      selectable: true,
      selectMirror: true,
      dayMaxEvents: true,
      weekends: true,
      selectOverlap: false,
      eventOverlap: false,
      events: `/users/${this.instructorIdValue}/availabilities.json`,
      eventDrop: info => this.updateAvailability(info),
      eventResize: info => this.updateAvailability(info),
      select: info => this.createPendingSlot(info),
      eventClick: info => this.handleEventClick(info),
      eventMouseEnter: info => this.showTooltip(info),
      eventMouseLeave: info => this.hideTooltip(info)
    })
    this.calendar.render()
    this.updateUI()
  }

  createPendingSlot(info) {
    // Create a pending slot (not saved yet)
    const pendingSlot = {
      id: 'pending_' + Date.now(),
      title: 'New Slot (Pending)',
      start: info.startStr,
      end: info.endStr,
      backgroundColor: '#ffc107',
      borderColor: '#ff9800',
      textColor: '#000',
      pending: true
    }
    
    this.pendingSlots.push(pendingSlot)
    this.calendar.addEvent(pendingSlot)
    this.hasUnsavedChanges = true
    this.updateUI()
    
    // Clear the selection
    this.calendar.unselect()
  }

  handleEventClick(info) {
    // Single click - show info, double click - delete
    if (this.clickTimeout) {
      // This is a double click
      clearTimeout(this.clickTimeout)
      this.clickTimeout = null
      this.deleteAvailability(info)
    } else {
      // This is a single click - wait to see if double click follows
      this.clickTimeout = setTimeout(() => {
        this.clickTimeout = null
        this.showEventInfo(info)
      }, 250)
    }
  }

  showEventInfo(info) {
    if (info.event.extendedProps.pending) {
      alert(`Pending slot: ${info.event.startStr} to ${info.event.endStr}\nDouble-click to remove`)
    } else {
      alert(`Availability: ${info.event.title}\n${info.event.startStr} to ${info.event.endStr}\nDouble-click to delete`)
    }
  }

  showTooltip(info) {
    if (info.event.extendedProps.pending) {
      info.el.title = 'Pending - not saved yet. Double-click to remove.'
    } else {
      info.el.title = 'Double-click to delete this availability'
    }
  }

  hideTooltip(info) {
    info.el.title = ''
  }

  updateAvailability(info) {
    if (info.event.extendedProps.pending) {
      // Don't update pending slots
      return
    }
    
    fetch(`/users/${this.instructorIdValue}/availabilities/${info.event.id}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        instructor_availability: {
          start_time: info.event.start.toISOString(),
          end_time: info.event.end.toISOString()
        }
      })
    }).then(response => {
      if (!response.ok) {
        // Revert the change if update failed
        info.revert()
        alert('Failed to update availability')
      }
    })
  }

  deleteAvailability(info) {
    if (info.event.extendedProps.pending) {
      // Remove from pending slots
      this.pendingSlots = this.pendingSlots.filter(slot => slot.id !== info.event.id)
      info.event.remove()
      this.hasUnsavedChanges = this.pendingSlots.length > 0
      this.updateUI()
      return
    }

    if (confirm('Delete this availability slot?')) {
      fetch(`/users/${this.instructorIdValue}/availabilities/${info.event.id}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      }).then(response => {
        if (response.ok) {
          info.event.remove()
        } else {
          alert('Failed to delete availability')
        }
      })
    }
  }

  saveAllSlots() {
    if (this.pendingSlots.length === 0) {
      alert('No pending slots to save')
      return
    }

    this.saveButtonTarget.disabled = true
    this.saveButtonTarget.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Saving...'

    const promises = this.pendingSlots.map(slot => 
      fetch(`/users/${this.instructorIdValue}/availabilities`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          instructor_availability: {
            start_time: slot.start,
            end_time: slot.end
          }
        })
      }).then(response => response.json())
    )

    Promise.all(promises).then(results => {
      // Remove all pending events
      this.calendar.getEvents().forEach(event => {
        if (event.extendedProps.pending) {
          event.remove()
        }
      })

      // Add the saved events with proper IDs
      results.forEach(result => {
        if (result.id) {
          this.calendar.addEvent(result)
        }
      })

      this.pendingSlots = []
      this.hasUnsavedChanges = false
      this.updateUI()
      alert(`Successfully saved ${results.length} availability slots!`)
    }).catch(error => {
      console.error('Error saving slots:', error)
      alert('Error saving some slots. Please try again.')
    }).finally(() => {
      this.saveButtonTarget.disabled = false
      this.saveButtonTarget.innerHTML = '<i class="fas fa-save me-1"></i>Save All Slots'
    })
  }

  clearPendingSlots() {
    if (this.pendingSlots.length === 0) {
      alert('No pending slots to clear')
      return
    }

    if (confirm(`Clear ${this.pendingSlots.length} pending slots?`)) {
      // Remove all pending events from calendar
      this.calendar.getEvents().forEach(event => {
        if (event.extendedProps.pending) {
          event.remove()
        }
      })

      this.pendingSlots = []
      this.hasUnsavedChanges = false
      this.updateUI()
    }
  }

  updateUI() {
    if (this.hasSaveButtonTarget) {
      this.saveButtonTarget.disabled = this.pendingSlots.length === 0
    }
    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.disabled = this.pendingSlots.length === 0
    }
    if (this.hasPendingCountTarget) {
      this.pendingCountTarget.textContent = this.pendingSlots.length
      this.pendingCountTarget.style.display = this.pendingSlots.length > 0 ? 'inline' : 'none'
    }
  }
}
