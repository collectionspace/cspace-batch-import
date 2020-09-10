# frozen_string_literal: true

class ApplicationReflex < StimulusReflex::Reflex
  # Learn more at: https://docs.stimulusreflex.com
  delegate :current_user, to: :connection

  # add a slight delay to page reload
  def reload
    sleep 0.5
  end

  def toggle_status
    model = element.dataset['model'].camelize.constantize
    record = model.find(element.dataset['id'])
    record.update(enabled: element[:checked])
  end
end
