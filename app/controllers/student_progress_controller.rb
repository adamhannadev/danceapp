class StudentProgressController < ApplicationController
  before_action :set_user, only: [:index, :show, :update, :mark_progress, :enroll]
  before_action :set_student_progress, only: [:show, :update, :mark_progress]

  def index
    # Determine which user's progress to show
    if params[:user_id].present?
      # Admin/instructor viewing specific user's progress
      authorize_instructor_access!
      @viewing_user = User.find(params[:user_id])
      @student_progresses = @viewing_user.student_progresses.includes(:figure, :instructor)
                                         .joins(figure: [:dance_style, :dance_level])
                                         .order('dance_styles.name, dance_levels.level_number, figures.figure_number')
    else
      # User viewing their own progress
      @viewing_user = current_user
      @student_progresses = current_user.student_progresses.includes(:figure, :instructor)
                                       .joins(figure: [:dance_style, :dance_level])
                                       .order('dance_styles.name, dance_levels.level_number, figures.figure_number')
    end
    
    # Get all available dance styles for the filter dropdown
    @available_dance_styles = DanceStyle.joins(:figures)
                                       .joins("JOIN student_progresses sp ON sp.figure_id = figures.id")
                                       .where("sp.user_id = ?", @viewing_user.id)
                                       .distinct
                                       .order(:name)
    
    # Filter by dance style if selected
    @selected_style = params[:dance_style_id].present? ? DanceStyle.find(params[:dance_style_id]) : nil
    @selected_level = params[:dance_level_id].present? ? DanceLevel.find(params[:dance_level_id]) : nil
    
    # Apply filters
    filtered_progresses = @student_progresses
    if @selected_style
      filtered_progresses = filtered_progresses.where(figures: { dance_style_id: @selected_style.id })
    end
    if @selected_level
      filtered_progresses = filtered_progresses.where(figures: { dance_level_id: @selected_level.id })
    end
    
    # Paginate the filtered results
    @student_progresses_paginated = filtered_progresses.page(params[:page]).per(20)
    
    # Group by dance style for better organization (only for current page)
    @progresses_by_style = @student_progresses_paginated.group_by { |sp| sp.figure.dance_style }
    
    # Calculate overall statistics (based on all progresses, not just current page)
    @total_figures = filtered_progresses.count
    @completed_figures = filtered_progresses.completed.count
    @overall_completion = @total_figures > 0 ? (@completed_figures.to_f / @total_figures * 100).round(1) : 0
  end

  def all_students
    authorize_instructor_access!
    
    @users_with_progress = User.students
                               .joins(:student_progresses)
                               .includes(student_progresses: [{ figure: [:dance_style, :dance_level] }, :instructor])
                               .distinct
                               .order(:last_name, :first_name)
    
    # Calculate progress stats for each user
    @progress_stats = {}
    @users_with_progress.each do |user|
      total = user.student_progresses.count
      completed = user.student_progresses.completed.count
      @progress_stats[user.id] = {
        total: total,
        completed: completed,
        percentage: total > 0 ? (completed.to_f / total * 100).round(1) : 0
      }
    end
  end

  def show
    @figure = @student_progress.figure
    @dance_style = @figure.dance_style
    @dance_level = @figure.dance_level
    @instructor = @student_progress.instructor
  end

  def update
    authorize_edit_access!
    
    # Handle mark_all parameter from JavaScript
    if params[:mark_all] == 'true'
      @student_progress.update!(
        movement_passed: true,
        timing_passed: true,
        partnering_passed: true
      )
      @student_progress.mark_completed! if @student_progress.completed?
      flash[:success] = "All components marked as passed! Congratulations on completing #{@student_progress.figure.name}!"
      redirect_to @student_progress and return
    end
    
    if @student_progress.update(student_progress_params)
      # Check if all components are now passed and mark as completed
      if @student_progress.completed? && @student_progress.completed_at.nil?
        @student_progress.mark_completed!
        flash[:success] = "Congratulations! You've completed #{@student_progress.figure.name}!"
      else
        flash[:success] = "Progress updated successfully!"
      end
      
      redirect_to @student_progress
    else
      flash[:error] = "There was an error updating your progress."
      render :show
    end
  end

  def mark_progress
    authorize_edit_access!
    
    # Handle GET request - show the mark progress form
    if request.get?
      @figure = @student_progress.figure
      @dance_style = @figure.dance_style
      @dance_level = @figure.dance_level
      @instructor = @student_progress.instructor
      return
    end
    
    # Handle PATCH request - update progress
    component = params[:component]
    
    case component
    when 'movement'
      @student_progress.toggle!(:movement_passed)
    when 'timing'
      @student_progress.toggle!(:timing_passed)
    when 'partnering'
      @student_progress.toggle!(:partnering_passed)
    when 'reset'
      @student_progress.update!(
        movement_passed: false,
        timing_passed: false,
        partnering_passed: false,
        completed_at: nil
      )
      flash[:warning] = "Progress has been reset for #{@student_progress.figure.name}."
      redirect_to @student_progress and return
    end
    
    # Check if all components are now passed
    if @student_progress.completed? && @student_progress.completed_at.nil?
      @student_progress.mark_completed!
      flash[:success] = "Congratulations! You've completed #{@student_progress.figure.name}!"
    end
    
    respond_to do |format|
      format.html { redirect_to @student_progress }
      format.json { 
        render json: { 
          success: true, 
          completed: @student_progress.completed?,
          completion_percentage: @student_progress.completion_percentage
        } 
      }
    end
  end

  def enroll
    authorize_instructor_access!
    
    if params[:user_id].present?
      @student = User.find(params[:user_id])
    else
      redirect_to users_path, alert: "Please select a student to enroll." and return
    end
    
    @dance_styles = DanceStyle.all.order(:name)
    @dance_levels = DanceLevel.all.order(:level_number)
    
    if request.post?
      dance_style = DanceStyle.find(params[:dance_style_id])
      dance_level = DanceLevel.find(params[:dance_level_id])
      
      # Find all figures for this style and level
      figures = Figure.where(dance_style: dance_style, dance_level: dance_level)
      
      if figures.empty?
        flash[:warning] = "No figures found for #{dance_style.name} #{dance_level.name}"
        return
      end
      
      # Create progress records for figures that don't already exist
      created_count = 0
      figures.each do |figure|
        unless @student.student_progresses.exists?(figure: figure)
          @student.student_progresses.create!(
            figure: figure,
            instructor: current_user,
            movement_passed: false,
            timing_passed: false,
            partnering_passed: false,
            notes: "Enrolled in #{dance_style.name} #{dance_level.name}"
          )
          created_count += 1
        end
      end
      
      if created_count > 0
        flash[:success] = "Successfully enrolled #{@student.full_name} in #{dance_style.name} #{dance_level.name}. Added #{created_count} figures to their progress."
        redirect_to user_student_progress_index_path(@student)
      else
        flash[:info] = "#{@student.full_name} is already enrolled in all figures for #{dance_style.name} #{dance_level.name}"
      end
    end
  end

  private

  def set_user
    @user = params[:user_id].present? ? User.find(params[:user_id]) : current_user
  end

  def set_student_progress
    if params[:user_id].present?
      # Admin/instructor accessing specific user's progress
      authorize_instructor_access!
      @student_progress = @user.student_progresses.find(params[:id])
    else
      # User accessing their own progress
      @student_progress = current_user.student_progresses.find(params[:id])
    end
  end

  def authorize_instructor_access!
    unless current_user.admin? || current_user.instructor?
      flash[:error] = "Access denied. You don't have permission to view this content."
      redirect_to root_path
    end
  end

  def authorize_edit_access!
    # Only allow admin/instructor to edit student progress
    unless current_user.admin? || current_user.instructor?
      flash[:error] = "Access denied. Only instructors and administrators can edit student progress."
      redirect_to student_progress_index_path
    end
  end

  def student_progress_params
    params.require(:student_progress).permit(:movement_passed, :timing_passed, :partnering_passed, :notes)
  end
end
