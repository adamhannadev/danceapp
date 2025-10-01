class FiguresController < ApplicationController
  before_action :set_figure, only: [:show, :edit, :update, :destroy]
  before_action :ensure_instructor_or_admin!, except: [:index, :show]
  before_action :ensure_admin!, only: [:import, :upload_import]

  def index
    @figures_data = FigureIndexService.new(filter_params).call
    
    # Extract data for the view
    @figures = @figures_data[:figures]
    @dance_styles = @figures_data[:dance_styles]
    @dance_levels = @figures_data[:dance_levels]
    
    # Extract statistics
    stats = @figures_data[:stats]
    @total_figures = stats[:total_figures]
    @core_figures_count = stats[:core_figures_count]
    @variations_count = stats[:variations_count]
  end

  def show
    @figure_details = FigureDetailService.new(@figure).call
    
    # Extract data for the view
    @student_progresses = @figure_details[:student_progresses]
    @progress_stats = @figure_details[:progress_stats]
    @related_figures = @figure_details[:related_figures]
  end

  def new
    @figure = Figure.new
    @form_data = FigureFormService.new.call
  end

  def create
    @figure = Figure.new(figure_params)
    
    if FigureCreationService.new(@figure, current_user).call
      redirect_to @figure, notice: 'Figure was successfully created.'
    else
      @form_data = FigureFormService.new.call
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @form_data = FigureFormService.new.call
  end

  def update
    if FigureUpdateService.new(@figure, figure_params, current_user).call
      redirect_to @figure, notice: 'Figure was successfully updated.'
    else
      @form_data = FigureFormService.new.call
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if FigureDeletionService.new(@figure, current_user).call
      redirect_to figures_url, notice: 'Figure was successfully deleted.'
    else
      redirect_to @figure, alert: 'Unable to delete figure. It may have associated student progress.'
    end
  end

  def import
    # This method just shows the import form (GET request)
    # POST processing is handled by upload_import
  end

  def upload_import
    unless params[:file].present?
      redirect_to import_figures_path, alert: 'Please select a file to upload.'
      return
    end
    
    result = FigureImportService.new(params[:file], current_user).call
    
    if result[:success]
      # Only store summary information in flash to avoid cookie overflow
      details = result[:details] || {}
      summary = {
        created_count: details[:created] || 0,
        updated_count: details[:updated] || 0,
        skipped_count: details[:skipped] || 0,
        error_count: details[:errors]&.count || 0,
        warning_count: details[:warnings]&.count || 0
      }
      
      # Store only summary in flash
      flash[:import_summary] = summary
      redirect_to figures_path, notice: result[:message]
    else
      # For errors, store limited error details
      details = result[:details] || {}
      error_summary = {
        error_count: details[:errors]&.count || 0,
        first_few_errors: details[:errors]&.first(3) || []  # Only first 3 errors
      }
      
      flash[:import_error_summary] = error_summary
      redirect_to import_figures_path, alert: result[:message]
    end
  end

  private

  def set_figure
    @figure = Figure.find(params[:id])
  end

  def figure_params
    params.require(:figure).permit(:figure_number, :name, :dance_style_id, :dance_level_id, 
                                   :measures, :components, :is_core, :video)
  end

  def filter_params
    params.permit(:dance_style_id, :dance_level_id, :is_core, :search, :page)
  end
end
