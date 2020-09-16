# frozen_string_literal: true

class PreprocessJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  def perform(preprocess)
    step = StepService.new(step: preprocess, save_to_file: false)
    return if step.cut_short?

    step.kickoff!

    # this is fake placeholder stuff for now
    unless Rails.env.test?
      (1..10).each do |_i|
        break if step.cancelled?

        step.nudge!

        # do some work!
        sleep 1
        # Example: error during step
        # if _i == 5
        #   preprocess.batch.failed!
        #   preprocess.increment_error!
        # end
      end
    end

    # we'll call it good for now
    step.complete!
  rescue StandardError => e
    # something really bad happened! we need to make this prominent somewhere ...
    step.failed!
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace)
  end
end
