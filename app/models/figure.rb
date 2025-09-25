class Figure < ApplicationRecord
  # Associations
  belongs_to :dance_style
  belongs_to :dance_level
  has_many :student_progresses, dependent: :destroy
  has_many :students, through: :student_progresses, source: :user

  # Validations
  validates :figure_number, presence: true, uniqueness: { scope: [:dance_style_id, :dance_level_id] }
  validates :name, presence: true
  validates :measures, presence: true, numericality: { greater_than: 0 }
  validates :video, format: { 
    with: /\A(https?:\/\/)?(www\.)?(youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)[\w-]+(&[\w=]*)*\z/i,
    message: "must be a valid YouTube URL"
  }, allow_blank: true

  # Scopes
  scope :core_figures, -> { where(is_core: true) }
  scope :variations, -> { where(is_core: false) }
  scope :by_number, -> { 
    order(
      Arel.sql("
        CAST(REGEXP_REPLACE(figure_number, '[^0-9].*', '', 'g') AS INTEGER),
        CASE WHEN figure_number ~ '^[0-9]+$' THEN 0 ELSE 1 END,
        figure_number
      ")
    )
  }

  # Instance methods
  def to_s
    "#{figure_number} - #{name}"
  end

  def core_figure?
    is_core
  end

  def variation?
    !is_core
  end

  def components_list
    components.split(',').map(&:strip) if components.present?
  end

  def full_description
    "#{dance_style.name} #{dance_level.name}: #{figure_number} - #{name}"
  end

  # YouTube video methods
  def has_video?
    video.present?
  end

  def youtube_video_id
    return nil unless has_video?
    
    # Extract video ID from various YouTube URL formats
    if video.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]+)/)
      $1
    end
  end

  def youtube_embed_url
    return nil unless youtube_video_id
    "https://www.youtube.com/embed/#{youtube_video_id}"
  end

  def youtube_thumbnail_url
    return nil unless youtube_video_id
    "https://img.youtube.com/vi/#{youtube_video_id}/maxresdefault.jpg"
  end
end
