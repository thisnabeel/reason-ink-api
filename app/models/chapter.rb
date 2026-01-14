class Chapter < ApplicationRecord
  # Self-referential association: a chapter can belong to another chapter
  belongs_to :parent_chapter, class_name: "Chapter", foreign_key: "chapter_id", optional: true
  has_many :child_chapters, class_name: "Chapter", foreign_key: "chapter_id", dependent: :nullify
end
