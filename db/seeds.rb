# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

unless Group.default_created?
  Group.create!(
    id: 1,
    name: 'Default',
    description: 'Default group.'
  )
end

unless User.admin_created?
  User.create!(
    email: ENV.fetch('CSPACE_BATCH_IMPORT_ADMIN_EMAIL', 'admin@collectionspace.org'),
    active: true,
    admin: true,
    group_id: 1,
    password: ENV.fetch('CSPACE_BATCH_IMPORT_ADMIN_PASSWORD', 'password'),
    password_confirmation: ENV.fetch('CSPACE_BATCH_IMPORT_ADMIN_PASSWORD', 'password')
  )
  User.create!(
    email: 'minion@collectionspace.org',
    active: true,
    group_id: 1,
    password: 'password',
    password_confirmation: 'password'
  )
end
