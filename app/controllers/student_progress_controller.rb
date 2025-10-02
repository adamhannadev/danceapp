class StudentProgressController < ApplicationController
  before_action :set_user, only: [:index, :show, :update, :mark_progress, :enroll]
  before_action :set_student_progress, only: [:show, :update, :mark_progress]
  before_action :ensure_instructor_or_admin!, only: [:all_students, :enroll, :update, :mark_progress]
  before_action :check_student_access, only: [:index, :show]

  def index
    @progress_data = StudentProgressIndexService.new(@user, filter_params).call
  end

  def all_students
    @students_data = AllStudentsProgressService.new.call
  end

  def show
    @progress_details = StudentProgressDetailService.new(@student_progress).call
  end

  def update
    if StudentProgressUpdateService.new(@student_progress, progress_params, current_user).call
      redirect_to @student_progress, notice: 'Progress updated successfully!'
    else
      render :show, status: :unprocessable_entity
    end
  end

  def mark_progress
    if request.get?
      @progress_details = StudentProgressDetailService.new(@student_progress).call
      return
    end
    
    result = StudentProgressMarkingService.new(@student_progress, marking_params).call
    
    respond_to do |format|
      format.html { redirect_to @student_progress, notice: result[:message] }
      format.json { render json: result }
    end
  end

  def enroll
    if request.post?
      result = StudentEnrollmentService.new(@user, enrollment_params, current_user).call
      
      if result[:success]
        # Determine the correct path based on whether we're in admin namespace
        redirect_path = params[:user_id].present? ? 
          admin_user_student_progress_index_path(@user) : 
          student_progress_index_path
        redirect_to redirect_path, notice: result[:message]
      else
        @enrollment_form_data = StudentEnrollmentFormService.new.call
        flash.now[:alert] = result[:message]
        render :enroll, status: :unprocessable_entity
      end
    else
      @enrollment_form_data = StudentEnrollmentFormService.new.call
    end
  end

  private

  def set_user
    @user = params[:user_id].present? ? User.find(params[:user_id]) : current_user
  end

  def set_student_progress
    @student_progress = if params[:user_id].present?
      @user.student_progresses.find(params[:id])
    else
      current_user.student_progresses.find(params[:id])
    end
  end

  def progress_params
    params.require(:student_progress).permit(:movement_passed, :timing_passed, :partnering_passed, :notes)
  end

  def marking_params
    params.permit(:component, :mark_all)
  end

  def enrollment_params
    params.permit(dance_style_ids: [], dance_level_ids: [])
  end

  def filter_params
    params.permit(:dance_style_id, :dance_level_id, :page)
  end

  def check_student_access
    ensure_can_access_student!(@user)
  end
end
