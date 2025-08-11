class StudentEnrollmentFormService
  def call
    {
      dance_styles: DanceStyle.all.order(:name),
      dance_levels: DanceLevel.all.order(:level_number)
    }
  end
end
