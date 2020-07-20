# frozen_string_literal: true

ActionView::Base.field_error_proc = proc { |html_tag, instance|
  html = %(<div class="field_with_errors">#{html_tag}</div>).html_safe

  form_fields = %w[textarea input select]

  elements = Nokogiri::HTML::DocumentFragment.parse(html_tag).css 'label, ' + form_fields.join(', ')

  elements.each do |e|
    next unless form_fields.include?(e.node_name)

    errors = [instance.error_message].flatten.uniq.collect do |error|
      "#{instance.class.field_type.humanize} #{error}"
    end
    html = %(<div class="field_with_errors">#{html_tag}</div><small class="has-text-danger">&nbsp;#{errors.join(', ')}</small>).html_safe
  end

  html
}
