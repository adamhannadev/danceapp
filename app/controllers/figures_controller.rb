class FiguresController < ApplicationController
  before_action :set_figure, only: [:show, :edit, :update, :destroy]
  before_action :ensure_instructor_or_admin!, except: [:index, :show]

  def index
    @figures_data = FigureIndexService.new(filter_params).call
  end

  def show
    @figure_details = FigureDetailService.new(@figure).call
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
    if request.post?
      result = FigureImportService.new(params[:file], current_user).call
      redirect_to figures_path, notice: result[:message]
    end
  end

  def upload_import
    result = FigureImportService.new(params[:file], current_user).call
    
    if result[:success]
      redirect_to figures_path, notice: result[:message]
    else
      redirect_to import_figures_path, alert: result[:message]
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

  def filter_params
    params.permit(:dance_style_id, :dance_level_id, :is_core, :search, :page)
  end
end
