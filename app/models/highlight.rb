class Highlight < ApplicationRecord
  belongs_to :chapter

  validates :start_time, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :end_time, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :end_time_not_before_start_time

  scope :ordered, -> { order(:position, :start_time, :id) }

  def timestamp_label
    Supadata.format_timestamp(start_time)
  end

  def end_timestamp_label
    Supadata.format_timestamp(end_time)
  end

  def duration_seconds
    [end_time.to_f - start_time.to_f, 0].max
  end

  def as_json(options = {})
    super(options).merge(
      "timestamp" => timestamp_label,
      "end_timestamp" => end_timestamp_label
    )
  end

  private

  def end_time_not_before_start_time
    return if start_time.blank? || end_time.blank?
    return if end_time >= start_time

    errors.add(:end_time, "must be greater than or equal to start_time")
  end
end
