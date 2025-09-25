import { Controller } from "@hotwired/stimulus"

// YouTube Video Preview Controller
// Connects to data-controller="youtube-preview"
//
// Usage:
//   <div data-controller="youtube-preview">
//     <input data-youtube-preview-target="urlInput" data-action="input->youtube-preview#updatePreview">
//     <div data-youtube-preview-target="preview"></div>
//   </div>
export default class extends Controller {
  static targets = ["urlInput", "preview"]

  connect() {
    // Show preview if there's already a URL (for edit forms)
    if (this.urlInputTarget.value.trim()) {
      this.updatePreview()
    }
  }

  updatePreview() {
    const url = this.urlInputTarget.value.trim()
    
    if (!url) {
      this.clearPreview()
      return
    }

    const videoId = this.extractVideoId(url)
    
    if (videoId) {
      this.showPreview(videoId)
    } else {
      this.showError()
    }
  }

  extractVideoId(url) {
    // Support various YouTube URL formats
    const patterns = [
      /(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]+)/,
      /youtube\.com\/.*[?&]v=([a-zA-Z0-9_-]+)/
    ]

    for (const pattern of patterns) {
      const match = url.match(pattern)
      if (match) {
        return match[1]
      }
    }
    
    return null
  }

  showPreview(videoId) {
    const thumbnailUrl = `https://img.youtube.com/vi/${videoId}/maxresdefault.jpg`
    
    this.previewTarget.innerHTML = `
      <div class="mt-3">
        <h6 class="text-muted mb-2">
          <i class="fas fa-eye me-2"></i>Video Preview
        </h6>
        <div class="card">
          <div class="card-body p-2">
            <div class="row align-items-center">
              <div class="col-4">
                <img src="${thumbnailUrl}" 
                     class="img-fluid rounded"
                     alt="Video thumbnail"
                     onerror="this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYwIiBoZWlnaHQ9IjkwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxyZWN0IHdpZHRoPSIxMDAiIGhlaWdodD0iMTAwJSIgZmlsbD0iI2RkZCIvPjx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSIjOTk5Ij5ObyBUaHVtYm5haWw8L3RleHQ+PC9zdmc+'">
              </div>
              <div class="col-8">
                <div class="d-flex align-items-center mb-2">
                  <i class="fab fa-youtube text-danger me-2"></i>
                  <small class="text-muted">YouTube Video</small>
                </div>
                <p class="mb-1 small">
                  <strong>Video ID:</strong> <code>${videoId}</code>
                </p>
                <p class="mb-0 small text-success">
                  <i class="fas fa-check me-1"></i>
                  Valid YouTube URL detected
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    `
  }

  showError() {
    this.previewTarget.innerHTML = `
      <div class="mt-3">
        <div class="alert alert-warning py-2 mb-0">
          <small>
            <i class="fas fa-exclamation-triangle me-2"></i>
            Please enter a valid YouTube URL (youtube.com/watch, youtu.be, or youtube.com/embed)
          </small>
        </div>
      </div>
    `
  }

  clearPreview() {
    this.previewTarget.innerHTML = ''
  }
}