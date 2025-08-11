class FigureFormService
  def call
    {
      dance_styles: DanceStyle.order(:name),
      dance_levels: DanceLevel.order(:level_number)
    }
  end
end
