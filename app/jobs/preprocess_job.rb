# frozen_string_literal: true

class PreprocessJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  def perform(preprocess)
    # abort if this steps batch already has a running job or was cancelled
    return if preprocess.running? || preprocess.abort?

    preprocess.batch.run! # update status to running
    preprocess.update(started_at: Time.now.utc)

    # this is fake placeholder stuff for now
    unless Rails.env.test?
      (1..10).each do |_i|
        break if preprocess.abort?

        preprocess.increment!
        # do some work!
        sleep 1
        preprocess.update_progress
      end
    end

    # we'll call it good for now
    preprocess.batch.finished! unless preprocess.abort? || preprocess.errors?
  rescue StandardError => e
    # something really bad happened! we need to make this prominent somewhere ...
    preprocess.batch.failed! unless preprocess.batch.failed? # may already be in trouble
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace)
  ensure
    # we'll close up files etc.
    preprocess.update(completed_at: Time.now.utc)
    1
  end
end
