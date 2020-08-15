# frozen_string_literal: true

class ApplicationReflex < StimulusReflex::Reflex
  # Put application wide Reflex behavior in this file.
  #
  # Example:
  #
  #   # If your ActionCable connection is: `identified_by :current_user`
  #   delegate :current_user, to: :connection
  #
  # Learn more at: https://docs.stimulusreflex.com

  def toggle_status
    model = element.dataset['model'].camelize.constantize
    id = element.dataset['id']
    record = model.find(id)
    record.update(enabled: record.enabled? ? false : true)
  end
end
