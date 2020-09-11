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

  def toggle_hide
    hide = element.dataset['value'].to_sym
    session[hide] ||= false # make sure there's a default (not hidden)
    session[hide] = !session[hide]
  end
end
