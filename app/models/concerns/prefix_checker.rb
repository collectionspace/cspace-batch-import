# frozen_string_literal: true

module PrefixChecker
  extend ActiveSupport::Concern

  def profile_must_be_prefix
    return unless profile.present? && !Mapper.profile_versions.include?(profile)

    errors.add(:profile, I18n.t('mapper.invalid_profile'))
  end
end
