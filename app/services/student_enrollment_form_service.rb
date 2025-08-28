class StudentEnrollmentFormService
  def call
    {
      dance_styles: dance_styles_grouped,
      dance_levels: dance_levels_grouped,
      all_dance_styles: DanceStyle.all.order(:name),
      all_dance_levels: DanceLevel.ordered
    }
  end

  private

  def dance_styles_grouped
    {
      'American Smooth' => DanceStyle.smooth.order(:name),
      'American Rhythm' => DanceStyle.rhythm.order(:name),
      'Social' => DanceStyle.social.order(:name),
      'International Standard' => DanceStyle.where(category: 'International Standard').order(:name),
      'International Latin' => DanceStyle.where(category: 'International Latin').order(:name)
    }.reject { |_category, styles| styles.empty? }
  end

  def dance_levels_grouped
    {
      'Bronze' => DanceLevel.bronze.ordered,
      'Silver' => DanceLevel.silver.ordered,
      'Gold' => DanceLevel.gold.ordered
    }.reject { |_category, levels| levels.empty? }
  end
end
