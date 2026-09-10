class HighlightsController < ApplicationController
  before_action :set_highlight, only: [:show, :update, :destroy]

  # GET /highlights
  def index
    @highlights = if params[:chapter_id].present?
      Highlight.where(chapter_id: params[:chapter_id])
    else
      Highlight.all
    end
    render json: @highlights
  end

  # GET /highlights/:id
  def show
    render json: @highlight
  end

  # POST /highlights
  def create
    attrs = highlight_params.to_h
    attrs["chapter_id"] ||= params[:chapter_id]
    @highlight = Highlight.new(attrs)

    if @highlight.save
      render json: @highlight, status: :created
    else
      render json: { errors: @highlight.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /highlights/:id
  def update
    if @highlight.update(highlight_params)
      render json: @highlight
    else
      render json: { errors: @highlight.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /highlights/:id
  def destroy
    @highlight.destroy
    head :no_content
  end

  private

  def set_highlight
    @highlight = Highlight.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Highlight not found" }, status: :not_found
  end

  def highlight_params
    params.require(:highlight).permit(:title, :transcript, :start_time, :end_time, :position, :chapter_id)
  end
end
