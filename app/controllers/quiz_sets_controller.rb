class QuizSetsController < ApplicationController
  before_action :set_quiz_set, only: [:show, :update, :destroy]

  # GET /quiz_sets
  def index
    @quiz_sets = QuizSet.all
    render json: @quiz_sets
  end

  # GET /quiz_sets/:id
  def show
    render json: @quiz_set
  end

  # POST /quiz_sets
  def create
    @quiz_set = QuizSet.new(quiz_set_params)

    if @quiz_set.save
      render json: @quiz_set, status: :created
    else
      render json: { errors: @quiz_set.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /quiz_sets/:id
  def update
    if @quiz_set.update(quiz_set_params)
      render json: @quiz_set
    else
      render json: { errors: @quiz_set.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /quiz_sets/:id
  def destroy
    @quiz_set.destroy
    head :no_content
  end

  private

  def set_quiz_set
    @quiz_set = QuizSet.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "QuizSet not found" }, status: :not_found
  end

  def quiz_set_params
    params.require(:quiz_set).permit(:title, :description, :quiz_setable_type, :quiz_setable_id, :position, :pop_quizable)
  end
end
