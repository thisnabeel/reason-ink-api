class QuizChoicesController < ApplicationController
  before_action :set_quiz_choice, only: [:show, :update, :destroy]

  # GET /quiz_choices
  def index
    @quiz_choices = QuizChoice.all
    render json: @quiz_choices
  end

  # GET /quiz_choices/:id
  def show
    render json: @quiz_choice
  end

  # POST /quiz_choices
  def create
    @quiz_choice = QuizChoice.new(quiz_choice_params)

    if @quiz_choice.save
      render json: @quiz_choice, status: :created
    else
      render json: { errors: @quiz_choice.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /quiz_choices/:id
  def update
    if @quiz_choice.update(quiz_choice_params)
      render json: @quiz_choice
    else
      render json: { errors: @quiz_choice.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /quiz_choices/:id
  def destroy
    @quiz_choice.destroy
    head :no_content
  end

  private

  def set_quiz_choice
    @quiz_choice = QuizChoice.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "QuizChoice not found" }, status: :not_found
  end

  def quiz_choice_params
    params.require(:quiz_choice).permit(:body, :correct, :position, :quiz_id)
  end
end
