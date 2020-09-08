# frozen_string_literal: true

class StepChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'step'
  end
end
