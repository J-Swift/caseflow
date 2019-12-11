# frozen_string_literal: true

class Metrics::Base
  self.abstract_class = true
  attr_reader :date_range

  delegate :start_date, :end_date, to: :date_range

  def initialize(date_range)
    @date_range = date_range
  end

  def call; end

  def id; end

  def name; end
end
