class FiguresController < ApplicationController
  before_action :set_figure, only: [:show, :edit, :update, :destroy]

  def index
    @figures = Figure.includes(:dance_style, :dance_level)
    
    # Filter by dance style
    if params[:dance_style_id].present?
      @figures = @figures.where(dance_style_id: params[:dance_style_id])
    end
    
    # Filter by dance level
    if params[:dance_level_id].present?
      @figures = @figures.where(dance_level_id: params[:dance_level_id])
    end
    
    # Filter by core/variation
    if params[:is_core].present?
      @figures = @figures.where(is_core: params[:is_core] == 'true')
    end
    
    # Search by name or figure number
    if params[:search].present?
      @figures = @figures.where(
        "name ILIKE ? OR figure_number ILIKE ?", 
        "%#{params[:search]}%", "%#{params[:search]}%"
      )
    end
    
    @figures = @figures.by_number.page(params[:page]).per(20)
    
    # For filtering dropdowns
    @dance_styles = DanceStyle.order(:name)
    @dance_levels = DanceLevel.order(:level_number)
    
    # Statistics
    @total_figures = Figure.count
    @core_figures_count = Figure.core_figures.count
    @variations_count = Figure.variations.count
  end

  def show
    @student_progresses = @figure.student_progresses.includes(:user).recent
  end

  def new
    @figure = Figure.new
    @dance_styles = DanceStyle.order(:name)
    @dance_levels = DanceLevel.order(:level_number)
  end

  def create
    @figure = Figure.new(figure_params)
    
    if @figure.save
      redirect_to @figure, notice: 'Figure was successfully created.'
    else
      @dance_styles = DanceStyle.order(:name)
      @dance_levels = DanceLevel.order(:level_number)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @dance_styles = DanceStyle.order(:name)
    @dance_levels = DanceLevel.order(:level_number)
  end

  def update
    if @figure.update(figure_params)
      redirect_to @figure, notice: 'Figure was successfully updated.'
    else
      @dance_styles = DanceStyle.order(:name)
      @dance_levels = DanceLevel.order(:level_number)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @figure.destroy
    redirect_to figures_url, notice: 'Figure was successfully deleted.'
  end

  def import
    # Placeholder for CSV import functionality
    if request.post?
      # Handle CSV upload logic here
      redirect_to figures_path, notice: 'Import functionality coming soon!'
    end
  end

  private

  def set_figure
    @figure = Figure.find(params[:id])
  end

  def figure_params
    params.require(:figure).permit(:figure_number, :name, :dance_style_id, :dance_level_id, 
                                   :measures, :components, :is_core)
  end
end
