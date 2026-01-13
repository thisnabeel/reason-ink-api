class PhrasesController < ApplicationController
  before_action :set_phrase, only: [:show, :update, :destroy]

  # GET /phrases
  def index
    @phrases = Phrase.all
    render json: @phrases
  end

  # GET /phrases/:id
  def show
    render json: @phrase
  end

  # POST /phrases
  def create
    @phrase = Phrase.new(phrase_params)

    if @phrase.save
      render json: @phrase, status: :created
    else
      render json: { errors: @phrase.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /phrases/:id
  def update
    if @phrase.update(phrase_params)
      render json: @phrase
    else
      render json: { errors: @phrase.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /phrases/:id
  def destroy
    @phrase.destroy
    head :no_content
  end

  private

  def set_phrase
    @phrase = Phrase.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Phrase not found" }, status: :not_found
  end

  def phrase_params
    params.require(:phrase).permit(:body, :concept_id, :explanation)
  end
end
