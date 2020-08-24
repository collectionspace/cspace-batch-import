# frozen_string_literal: true

class ApplicationReflex < StimulusReflex::Reflex
  # Learn more at: https://docs.stimulusreflex.com
  delegate :current_user, to: :connection

  def toggle_status
    model = element.dataset['model'].camelize.constantize
    id = element.dataset['id']
    record = model.find(id)
    record.update(enabled: record.enabled? ? false : true)
  end
end