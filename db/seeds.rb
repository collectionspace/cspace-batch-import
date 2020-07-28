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
  email: ENV.fetch('CSPACE_BATCH_IMPORT_ADMIN_EMAIL', 'admin@collectionspace.org')
) do |user|
  user.active = true
  user.enabled = true
  user.group = Group.default
  user.password = ENV.fetch('CSPACE_BATCH_IMPORT_ADMIN_PASSWORD', 'password')
  user.password_confirmation = ENV.fetch('CSPACE_BATCH_IMPORT_ADMIN_PASSWORD', 'password')
  user.role = Role.admin
end
