class FigureIndexService
  def initialize(filter_params)
    @filter_params = filter_params
  end

  def call
    {
      figures: filtered_figures,
      dance_styles: DanceStyle.order(:name),
      dance_levels: DanceLevel.order(:level_number),
      stats: figure_stats
    }
  end

  private

  def base_figures
    Figure.includes(:dance_style, :dance_level)
  end

  def filtered_figures
    figures = base_figures
    
    if @filter_params[:dance_style_id].present?
      figures = figures.where(dance_style_id: @filter_params[:dance_style_id])
    end
    
    if @filter_params[:dance_level_id].present?
      figures = figures.where(dance_level_id: @filter_params[:dance_level_id])
    end
    
    if @filter_params[:is_core].present?
      figures = figures.where(is_core: @filter_params[:is_core] == 'true')
    end
    
    if @filter_params[:search].present?
      search_term = "%#{@filter_params[:search]}%"
      figures = figures.where(
        "name ILIKE ? OR figure_number ILIKE ?", 
        search_term, search_term
      )
    end
    
    figures.by_number.page(@filter_params[:page]).per(20)
  end

  def figure_stats
    {
      total_figures: Figure.count,
      core_figures_count: Figure.core_figures.count,
      variations_count: Figure.variations.count
    }
  end
end
