import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "content", "checkbox", "signButton", "closeButton", "cancelButton"]
  static values = { 
    waiverContent: String,
    userId: Number,
    returnUrl: String,
    mode: String,
    required: { type: Boolean, default: false }
  }

  connect() {
    console.log('Waiver modal controller connected')
    console.log('Values:', {
      userId: this.userIdValue,
      required: this.requiredValue,
      mode: this.modeValue,
      returnUrl: this.returnUrlValue
    })
    this.setupModal()
  }

  setupModal() {
    // Determine modal behavior based on context
    const isRequired = this.requiredValue || !this.hasUserIdValue
    
    console.log('Setting up modal, isRequired:', isRequired)
    
    try {
      // Initialize Bootstrap modal with appropriate settings
      this.modal = bootstrap.Modal.getOrCreateInstance(this.modalTarget, {
        backdrop: isRequired ? 'static' : true,
        keyboard: !isRequired
      })
      console.log('Modal initialized successfully')
    } catch (error) {
      console.error('Error initializing modal:', error)
      // Fallback initialization
      this.modal = null
    }
    
    // Hide/show close buttons based on requirement
    if (isRequired) {
      if (this.hasCloseButtonTarget) {
        this.closeButtonTarget.style.display = 'none'
        console.log('Hidden close button for required modal')
      }
      if (this.hasCancelButtonTarget) {
        this.cancelButtonTarget.style.display = 'none'
        console.log('Hidden cancel button for required modal')
      }
    }
    
    // Add event listeners
    this.modalTarget.addEventListener('shown.bs.modal', () => {
      console.log('Modal shown')
      this.resetForm()
    })
    
    this.modalTarget.addEventListener('hidden.bs.modal', () => {
      console.log('Modal hidden')
    })
  }

  show() {
    if (this.modal) {
      this.modal.show()
    } else {
      // Fallback to Bootstrap's static method
      const modal = bootstrap.Modal.getOrCreateInstance(this.modalTarget)
      modal.show()
      this.modal = modal
    }
    this.resetForm()
  }

  hide() {
    if (this.modal) {
      this.modal.hide()
    } else {
      // Fallback to Bootstrap's static method
      const modal = bootstrap.Modal.getInstance(this.modalTarget)
      if (modal) {
        modal.hide()
      } else {
        // Last resort - hide the modal element directly
        this.modalTarget.classList.remove('show')
        this.modalTarget.style.display = 'none'
        document.body.classList.remove('modal-open')
        const backdrop = document.querySelector('.modal-backdrop')
        if (backdrop) backdrop.remove()
      }
    }
  }

  resetForm() {
    this.checkboxTarget.checked = false
    this.updateSignButton()
  }

  toggleAgreement() {
    this.updateSignButton()
  }

  updateSignButton() {
    if (this.checkboxTarget.checked) {
      this.signButtonTarget.disabled = false
      this.signButtonTarget.classList.remove('btn-secondary')
      this.signButtonTarget.classList.add('btn-success')
    } else {
      this.signButtonTarget.disabled = true
      this.signButtonTarget.classList.remove('btn-success')
      this.signButtonTarget.classList.add('btn-secondary')
    }
  }

  async signWaiver() {
    if (!this.checkboxTarget.checked) {
      return
    }

    try {
      this.signButtonTarget.disabled = true
      this.signButtonTarget.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Signing...'

      // If user is logged in (existing user updating profile), sign via API
      if (this.hasUserIdValue && this.userIdValue) {
        const response = await fetch('/waiver/sign', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
          },
          body: JSON.stringify({
            user_id: this.userIdValue
          })
        })

        const result = await response.json()

        if (result.success) {
          this.signButtonTarget.innerHTML = '<i class="fas fa-check me-2"></i>Signed Successfully!'
          this.signButtonTarget.classList.remove('btn-success')
          this.signButtonTarget.classList.add('btn-outline-success')
          
          setTimeout(() => {
            try {
              this.hide()
            } catch (error) {
              console.error('Error hiding modal:', error)
            }
            this.showAlert('success', 'Waiver signed successfully!')
            
            if (this.returnUrlValue) {
              window.location.href = this.returnUrlValue
            } else {
              window.location.reload()
            }
          }, 1500)
        } else {
          throw new Error(result.message || 'Failed to sign waiver')
        }
      } else {
        // For registration flow or new users, just mark as signed locally
        console.log('Handling registration flow waiver signing...')
        this.signButtonTarget.innerHTML = '<i class="fas fa-check me-2"></i>Signed Successfully!'
        this.signButtonTarget.classList.remove('btn-success')
        this.signButtonTarget.classList.add('btn-outline-success')
        
        // Mark as signed immediately
        this.markWaiverSignedInForm()
        
        // Dispatch custom event for registration forms
        this.modalTarget.dispatchEvent(new CustomEvent('waiver:signed', {
          bubbles: true,
          detail: { signedAt: new Date().toISOString() }
        }))
        
        setTimeout(() => {
          try {
            this.hide()
          } catch (error) {
            console.error('Error hiding modal:', error)
            // Force hide the modal
            this.modalTarget.style.display = 'none'
            document.body.classList.remove('modal-open')
            const backdrop = document.querySelector('.modal-backdrop')
            if (backdrop) backdrop.remove()
          }
          this.showAlert('success', 'Waiver signed! You can now complete your registration.')
        }, 1500)
      }
    } catch (error) {
      console.error('Error signing waiver:', error)
      this.showAlert('danger', 'Failed to sign waiver. Please try again.')
      this.resetSignButton()
    }
  }

  markWaiverSignedInForm() {
    console.log('Marking waiver as signed in form...')
    
    // Update hidden field for form submission - use the correct field name
    const waiverField = document.getElementById('waiver_signed_field') || 
                       document.querySelector('input[name="user[waiver_signed_at]"]')
    if (waiverField) {
      waiverField.value = new Date().toISOString()
      console.log('Updated waiver field:', waiverField.value)
    } else {
      console.log('Waiver field not found, creating one...')
      // Create the field if it doesn't exist
      const form = document.querySelector('form')
      if (form) {
        const hiddenInput = document.createElement('input')
        hiddenInput.type = 'hidden'
        hiddenInput.name = 'user[waiver_signed_at]'
        hiddenInput.value = new Date().toISOString()
        form.appendChild(hiddenInput)
      }
    }

    // Show signed indicator
    const indicator = document.getElementById('waiverSignedIndicator')
    if (indicator) {
      indicator.classList.remove('d-none')
      indicator.style.display = 'block'
      console.log('Showed waiver indicator')
    }

    // Update trigger button
    const triggerBtn = document.getElementById('waiverTriggerBtn')
    if (triggerBtn) {
      triggerBtn.innerHTML = '<i class="fas fa-check-circle me-2"></i>Waiver Signed'
      triggerBtn.classList.remove('btn-outline-primary')
      triggerBtn.classList.add('btn-success')
      triggerBtn.disabled = true
      console.log('Updated trigger button')
    }

    // Enable submit button if it's disabled
    const submitBtn = document.getElementById('submitBtn') || 
                     document.querySelector('input[type="submit"], button[type="submit"]')
    if (submitBtn) {
      submitBtn.disabled = false
      submitBtn.classList.remove('btn-secondary')
      submitBtn.classList.add('btn-primary')
      console.log('Enabled submit button')
    }
  }

  resetSignButton() {
    this.signButtonTarget.disabled = false
    this.signButtonTarget.innerHTML = '<i class="fas fa-pen-nib me-2"></i>Sign Waiver'
  }

  showAlert(type, message) {
    // Create and show Bootstrap alert
    const alertHtml = `
      <div class="alert alert-${type} alert-dismissible fade show" role="alert">
        <i class="fas fa-${type === 'success' ? 'check-circle' : 'exclamation-triangle'} me-2"></i>
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    `
    
    // Insert alert at top of page
    const container = document.querySelector('.container-fluid') || document.body
    container.insertAdjacentHTML('afterbegin', alertHtml)
  }
}