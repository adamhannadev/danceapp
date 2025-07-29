import { Controller } from "@hotwired/stimulus"
import { Calendar } from '@fullcalendar/core'
import timeGridPlugin from '@fullcalendar/timegrid'
import dayGridPlugin from '@fullcalendar/daygrid'
import '@fullcalendar/core/main.css'
import '@fullcalendar/daygrid/main.css'
import '@fullcalendar/timegrid/main.css'

export default class extends Controller {
  static values = { instructorId: Number }

  connect() {
    this.calendar = new Calendar(this.element, {
      plugins: [timeGridPlugin, dayGridPlugin],
      initialView: 'timeGridWeek',
      editable: true,
      selectable: true,
      events: `/users/${this.instructorIdValue}/availabilities.json`,
      eventDrop: info => this.updateAvailability(info),
      eventResize: info => this.updateAvailability(info),
      select: info => this.createAvailability(info),
      eventClick: info => this.deleteAvailability(info)
    })
    this.calendar.render()
  }

  updateAvailability(info) {
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
    }).then(() => this.calendar.refetchEvents())
  }

  createAvailability(info) {
    fetch(`/users/${this.instructorIdValue}/availabilities`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        instructor_availability: {
          start_time: info.startStr,
          end_time: info.endStr
        }
      })
    }).then(() => this.calendar.refetchEvents())
  }

  deleteAvailability(info) {
    if (confirm('Delete this availability?')) {
      fetch(`/users/${this.instructorIdValue}/availabilities/${info.event.id}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        }
      }).then(() => this.calendar.refetchEvents())
    }
  }
}
