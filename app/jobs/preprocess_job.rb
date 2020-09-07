# frozen_string_literal: true

class PreprocessJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  def perform(preprocess)
    # abort if this steps batch already has a running job or was cancelled
    return if preprocess.batch.running? || cancelled?

    preprocess.batch.run! # update status to running
    preprocess.update(started_at: Time.now.utc)

    (1..10).each do |_i|
      preprocess.update(step_num_row: preprocess.step_num_row += 1)
      # do some work!
      sleep 1
    end

    preprocess.batch.finished! # we'll call it good for now
  rescue StandardError => e
    # something really bad happened! we need to make this prominent somewhere ...
    preprocess.batch.failed!
    Rails.logger.error(e.backtrace)
  ensure
    # we'll close up files etc.
    preprocess.update(completed_at: Time.now.utc)
    1
  end
end
