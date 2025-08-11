class DanceClassFormService
  def call
    {
      dance_styles: DanceStyle.all.order(:name),
      dance_levels: DanceLevel.all.order(:level_number),
      instructors: User.instructors.order(:first_name, :last_name),
      locations: Location.active.order(:name)
    }
  end
end
