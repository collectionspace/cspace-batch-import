# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Group.find_or_create_by!(name: Group.default_group_name) do |group|
  group.description = 'Default group.'
  group.enabled = true
end

Role.find_or_create_by!(name: 'Admin')
Role.find_or_create_by!(name: 'Manager')
Role.find_or_create_by!(name: 'Member')

User.find_or_create_by!(
  email: ENV.fetch('CSPACE_BATCH_IMPORT_SUPERUSER_EMAIL', 'admin@collectionspace.org')
) do |user|
  user.active = true
  user.enabled = true
  user.group = Group.default
  user.password = ENV.fetch('CSPACE_BATCH_IMPORT_SUPERUSER_PASSWORD', 'password')
  user.password_confirmation = ENV.fetch('CSPACE_BATCH_IMPORT_SUPERUSER_PASSWORD', 'password')
  user.role = Role.admin
end

if ENV['RAILS_ENV'] == 'development'
  Group.find_or_create_by!(name: 'WOTC') do |group|
    group.description = 'Wizards of the Coast: MTG.'
    group.enabled = true
  end

  %w[chandra jace nissa teferi ugin].each do |planeswalker|
    User.find_or_create_by!(
      email: "#{planeswalker}@wizards.com"
    ) do |user|
      user.enabled = true
      user.group = Group.where(name: 'WOTC').first
      user.password = 'password'
      user.password_confirmation = 'password'
      user.role = Role.manager if planeswalker == 'chandra'
    end
  end
end
