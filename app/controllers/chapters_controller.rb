class ChaptersController < ApplicationController
  before_action :set_chapter, only: [:show, :update, :destroy]

  # GET /chapters
  def index
    @chapters = Chapter.all
    render json: @chapters
  end

  # GET /chapters/:id
  def show
    render json: @chapter.as_json(include: :child_chapters)
  end

  # POST /chapters
  def create
    @chapter = Chapter.new(chapter_params)

    if @chapter.save
      render json: @chapter, status: :created
    else
      render json: { errors: @chapter.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /chapters/:id
  def update
    if @chapter.update(chapter_params)
      render json: @chapter
    else
      render json: { errors: @chapter.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /chapters/:id
  def destroy
    @chapter.destroy
    head :no_content
  end

  private

  def set_chapter
    @chapter = Chapter.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Chapter not found" }, status: :not_found
  end

  def chapter_params
    params.require(:chapter).permit(:title, :notes, :youtube_url, :body, :chapter_id)
  end
end
