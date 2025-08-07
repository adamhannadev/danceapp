class DanceCategoriesController < ApplicationController
  before_action :set_dance_category, only: %i[ show edit update destroy ]

  # GET /dance_categories or /dance_categories.json
  def index
    @dance_categories = DanceCategory.all
  end

  # GET /dance_categories/1 or /dance_categories/1.json
  def show
  end

  # GET /dance_categories/new
  def new
    @dance_category = DanceCategory.new
  end

  # GET /dance_categories/1/edit
  def edit
  end

  # POST /dance_categories or /dance_categories.json
  def create
    @dance_category = DanceCategory.new(dance_category_params)

    respond_to do |format|
      if @dance_category.save
        format.html { redirect_to @dance_category, notice: "Dance category was successfully created." }
        format.json { render :show, status: :created, location: @dance_category }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @dance_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dance_categories/1 or /dance_categories/1.json
  def update
    respond_to do |format|
      if @dance_category.update(dance_category_params)
        format.html { redirect_to @dance_category, notice: "Dance category was successfully updated." }
        format.json { render :show, status: :ok, location: @dance_category }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @dance_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dance_categories/1 or /dance_categories/1.json
  def destroy
    @dance_category.destroy!

    respond_to do |format|
      format.html { redirect_to dance_categories_path, status: :see_other, notice: "Dance category was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dance_category
      @dance_category = DanceCategory.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def dance_category_params
      params.require(:dance_category).permit(:name)
    end
end
