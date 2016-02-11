class Result < ActiveRecord::Base
  validates :version, presence: true
  validates :duration, presence: true
  validates :rps, presence: true
  validates :profile, presence: true
  validate :test_run_date_is_datetime

  def test_run_date_is_datetime
    errors.add(:test_run_date, 'must be a DateTime') unless DateTime.parse(test_run_date).is_a? DateTime
  end


end
