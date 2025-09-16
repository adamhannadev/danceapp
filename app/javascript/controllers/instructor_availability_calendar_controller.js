import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { instructorId: Number }
  static targets = ["saveButton", "clearButton", "pendingCount"]

  connect() {
    console.log('Instructor availability calendar controller connected')
    this.pendingSlots = []
    this.pendingUpdates = [] // Track moved/resized slots that need saving
    this.hasUnsavedChanges = false
    
    // Wait for FullCalendar to be loaded from CDN
    if (typeof FullCalendar !== 'undefined') {
      console.log('FullCalendar found, initializing calendar')
      this.initializeCalendar()
    } else {
      console.log('FullCalendar not found, retrying...')
      // Retry after a short delay if FullCalendar isn't loaded yet
      setTimeout(() => this.initializeCalendar(), 100)
    }
  }

  initializeCalendar() {
    console.log('initializeCalendar called')
    // Find the calendar container (the div with height 600px inside the card)
    const calendarEl = this.element.querySelector('.card-body > div[style*="height: 600px"]')
    console.log('Calendar element found:', calendarEl)
    
    if (!calendarEl) {
      console.error('Calendar container not found!')
      return
    }
    
    console.log('Creating FullCalendar with instructor ID:', this.instructorIdValue)
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
      eventDrop: info => {
        console.log('Event dropped!', info.event.id)
        this.updateAvailability(info)
      },
      eventResize: info => {
        console.log('Event resized!', info.event.id)
        this.updateAvailability(info)
      },
      select: info => this.createPendingSlot(info),
      eventClick: info => this.handleEventClick(info),
      eventMouseEnter: info => this.showTooltip(info),
      eventMouseLeave: info => this.hideTooltip(info)
    })
    console.log('Calendar created, rendering...')
    this.calendar.render()
    console.log('Calendar rendered, calling updateUI...')
    this.updateUI()
    console.log('initializeCalendar completed')
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
      alert(`New slot: ${info.event.startStr} to ${info.event.endStr}\nNot saved yet - double-click to remove`)
    } else if (info.event.extendedProps.hasUpdates) {
      alert(`Modified slot: ${info.event.startStr} to ${info.event.endStr}\nChanges not saved yet - double-click to delete`)
    } else {
      alert(`Availability: ${info.event.title}\n${info.event.startStr} to ${info.event.endStr}\nDouble-click to delete`)
    }
  }

  showTooltip(info) {
    if (info.event.extendedProps.pending) {
      info.el.title = 'New slot - not saved yet. Double-click to remove.'
    } else if (info.event.extendedProps.hasUpdates) {
      info.el.title = 'Modified slot - changes not saved yet. Double-click to delete.'
    } else {
      info.el.title = 'Saved availability slot. Double-click to delete.'
    }
  }

  hideTooltip(info) {
    info.el.title = ''
  }

  updateAvailability(info) {
    console.log('updateAvailability called:', {
      eventId: info.event.id,
      isPending: info.event.extendedProps.pending,
      hasUpdates: info.event.extendedProps.hasUpdates,
      startTime: info.event.start.toISOString(),
      endTime: info.event.end.toISOString()
    })
    
    if (info.event.extendedProps.pending) {
      // Update the pending slot data
      const pendingSlot = this.pendingSlots.find(slot => slot.id === info.event.id)
      if (pendingSlot) {
        pendingSlot.start = info.event.startStr
        pendingSlot.end = info.event.endStr
        console.log('Updated pending slot:', pendingSlot)
      }
      return
    }
    
    // Check if this event is already in pending updates
    const existingUpdateIndex = this.pendingUpdates.findIndex(update => update.id === info.event.id)
    
    if (existingUpdateIndex >= 0) {
      // Update existing pending update
      this.pendingUpdates[existingUpdateIndex] = {
        id: info.event.id,
        start_time: info.event.start.toISOString(),
        end_time: info.event.end.toISOString(),
        event: info.event
      }
      console.log('Updated existing pending update:', this.pendingUpdates[existingUpdateIndex])
    } else {
      // Add new pending update
      const newUpdate = {
        id: info.event.id,
        start_time: info.event.start.toISOString(),
        end_time: info.event.end.toISOString(),
        event: info.event
      }
      this.pendingUpdates.push(newUpdate)
      console.log('Added new pending update:', newUpdate)
    }
    
    // Mark the event as having pending changes
    console.log('Setting event properties...')
    info.event.setExtendedProp('hasUpdates', true)
    info.event.setProp('backgroundColor', '#17a2b8') // Info color for updated events
    info.event.setProp('borderColor', '#138496')
    console.log('Event properties set. Total pending updates:', this.pendingUpdates.length)
    
    this.hasUnsavedChanges = true
    this.updateUI()
    
    console.log('Queued availability update:', {
      id: info.event.id,
      start: info.event.start.toISOString(),
      end: info.event.end.toISOString(),
      totalPendingUpdates: this.pendingUpdates.length
    })
  }

  deleteAvailability(info) {
    if (info.event.extendedProps.pending) {
      // Remove from pending slots
      this.pendingSlots = this.pendingSlots.filter(slot => slot.id !== info.event.id)
      info.event.remove()
      this.hasUnsavedChanges = this.pendingSlots.length > 0 || this.pendingUpdates.length > 0
      this.updateUI()
      return
    }

    // If this event has pending updates, remove them
    if (info.event.extendedProps.hasUpdates) {
      this.pendingUpdates = this.pendingUpdates.filter(update => update.id !== info.event.id)
      this.hasUnsavedChanges = this.pendingSlots.length > 0 || this.pendingUpdates.length > 0
      this.updateUI()
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
    const totalChanges = this.pendingSlots.length + this.pendingUpdates.length
    
    if (totalChanges === 0) {
      alert('No changes to save')
      return
    }

    this.saveButtonTarget.disabled = true
    this.saveButtonTarget.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Saving...'

    const promises = []
    
    // Save new slots
    this.pendingSlots.forEach(slot => {
      promises.push(
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
        }).then(response => response.json()).then(result => ({ type: 'create', result }))
      )
    })
    
    // Save updated slots
    this.pendingUpdates.forEach(update => {
      promises.push(
        fetch(`/users/${this.instructorIdValue}/availabilities/${update.id}`, {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
          },
          body: JSON.stringify({
            instructor_availability: {
              start_time: update.start_time,
              end_time: update.end_time
            }
          })
        }).then(response => response.json()).then(result => ({ type: 'update', result, event: update.event }))
      )
    })

    Promise.all(promises).then(results => {
      // Remove all pending events and reset updated events
      this.calendar.getEvents().forEach(event => {
        if (event.extendedProps.pending) {
          event.remove()
        } else if (event.extendedProps.hasUpdates) {
          // Reset the updated event's appearance
          event.setExtendedProp('hasUpdates', false)
          event.setProp('backgroundColor', '#28a745')
          event.setProp('borderColor', '#1e7e34')
        }
      })

      // Add the newly created events with proper IDs
      results.forEach(({ type, result, event }) => {
        if (type === 'create' && result.id) {
          this.calendar.addEvent(result)
        } else if (type === 'update' && event) {
          // Update the existing event with the server response
          event.setExtendedProp('hasUpdates', false)
          event.setProp('backgroundColor', '#28a745')
          event.setProp('borderColor', '#1e7e34')
        }
      })

      const newSlots = results.filter(r => r.type === 'create').length
      const updatedSlots = results.filter(r => r.type === 'update').length
      
      this.pendingSlots = []
      this.pendingUpdates = []
      this.hasUnsavedChanges = false
      this.updateUI()
      
      let message = 'Successfully saved changes!'
      if (newSlots > 0 && updatedSlots > 0) {
        message = `Successfully created ${newSlots} new slots and updated ${updatedSlots} existing slots!`
      } else if (newSlots > 0) {
        message = `Successfully created ${newSlots} new availability slots!`
      } else if (updatedSlots > 0) {
        message = `Successfully updated ${updatedSlots} availability slots!`
      }
      
      alert(message)
    }).catch(error => {
      console.error('Error saving changes:', error)
      alert('Error saving some changes. Please try again.')
    }).finally(() => {
      this.saveButtonTarget.disabled = false
      this.saveButtonTarget.innerHTML = '<i class="fas fa-save me-1"></i>Save Changes'
    })
  }

  clearPendingSlots() {
    const totalChanges = this.pendingSlots.length + this.pendingUpdates.length
    
    if (totalChanges === 0) {
      alert('No pending changes to clear')
      return
    }

    if (confirm(`Clear ${totalChanges} pending changes?`)) {
      // Remove all pending events from calendar and reset updated events
      this.calendar.getEvents().forEach(event => {
        if (event.extendedProps.pending) {
          event.remove()
        } else if (event.extendedProps.hasUpdates) {
          // Revert the updated event to its original state
          // Note: This would require storing original state, for now we'll just reset appearance
          event.setExtendedProp('hasUpdates', false)
          event.setProp('backgroundColor', '#28a745')
          event.setProp('borderColor', '#1e7e34')
        }
      })

      this.pendingSlots = []
      this.pendingUpdates = []
      this.hasUnsavedChanges = false
      this.updateUI()
      
      // Refresh the calendar to reload original data
      this.calendar.refetchEvents()
    }
  }

  updateUI() {
    const totalChanges = this.pendingSlots.length + this.pendingUpdates.length
    
    console.log('updateUI called:', {
      pendingSlots: this.pendingSlots.length,
      pendingUpdates: this.pendingUpdates.length,
      totalChanges: totalChanges,
      hasSaveButtonTarget: this.hasSaveButtonTarget
    })
    
    if (this.hasSaveButtonTarget) {
      this.saveButtonTarget.disabled = totalChanges === 0
      
      // Update button text based on what needs to be saved
      if (totalChanges === 0) {
        this.saveButtonTarget.innerHTML = '<i class="fas fa-save me-1"></i>No Changes'
      } else if (this.pendingSlots.length > 0 && this.pendingUpdates.length > 0) {
        this.saveButtonTarget.innerHTML = `<i class="fas fa-save me-1"></i>Save ${totalChanges} Changes`
      } else if (this.pendingSlots.length > 0) {
        this.saveButtonTarget.innerHTML = `<i class="fas fa-plus me-1"></i>Save ${this.pendingSlots.length} New Slots`
      } else {
        this.saveButtonTarget.innerHTML = `<i class="fas fa-edit me-1"></i>Save ${this.pendingUpdates.length} Updates`
      }
    }
    
    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.disabled = totalChanges === 0
    }
    
    if (this.hasPendingCountTarget) {
      this.pendingCountTarget.textContent = totalChanges
      this.pendingCountTarget.style.display = totalChanges > 0 ? 'inline' : 'none'
    }
  }
}
