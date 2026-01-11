class QuizzesController < ApplicationController
  before_action :set_quiz, only: [:show, :update, :destroy]

  # GET /quizzes
  def index
    @quizzes = Quiz.all
    render json: @quizzes
  end

  # GET /quizzes/:id
  def show
    render json: @quiz.as_json(include: :quiz_choices)
  end

  # POST /quizzes
  def create
    @quiz = Quiz.new(quiz_params)

    if @quiz.save
      render json: @quiz, status: :created
    else
      render json: { errors: @quiz.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /quizzes/:id
  def update
    if @quiz.update(quiz_params)
      render json: @quiz
    else
      render json: { errors: @quiz.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /quizzes/:id
  def destroy
    @quiz.destroy
    head :no_content
  end

  private

  def set_quiz
    @quiz = Quiz.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Quiz not found" }, status: :not_found
  end

  def quiz_params
    params.require(:quiz).permit(:question, :quizable_type, :quizable_id, :position, :jeopardy, :quiz_set_id)
  end
end
