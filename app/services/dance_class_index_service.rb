class DanceClassIndexService
  def initialize(filter_params)
    @filter_params = filter_params
  end

  def call
    {
      dance_classes: filtered_classes,
      dance_styles: DanceStyle.all.order(:name),
      instructors: User.instructors.order(:first_name, :last_name)
    }
  end

  private

  def base_classes
    DanceClass.includes(:dance_style, :dance_level, :instructor, :location)
              .order(:name)
  end

  def filtered_classes
    classes = base_classes
    
    if @filter_params[:dance_style_id].present?
      classes = classes.where(dance_style_id: @filter_params[:dance_style_id])
    end
    
    if @filter_params[:instructor_id].present?
      classes = classes.where(instructor_id: @filter_params[:instructor_id])
    end
    
    # Add pagination
    if defined?(Kaminari)
      classes.page(@filter_params[:page]).per(12)
    else
      classes.limit(50) # Fallback limit
    end
  end
end
