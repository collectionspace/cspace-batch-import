# frozen_string_literal: true

if Rails.env.production?
  Lockbox.master_key = ENV.fetch('LOCKBOX_MASTER_KEY')
else
  Lockbox.master_key = '0000000000000000000000000000000000000000000000000000000000000000'
end
