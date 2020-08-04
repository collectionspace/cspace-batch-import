# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Group.find_or_create_by!(
  name: ENV.fetch('CSPACE_BATCH_IMPORT_DEFAULT_GROUP', 'Default')
) do |group|
  group.description = 'Default group.'
end

Role.find_or_create_by!(name: 'Admin')
Role.find_or_create_by!(name: 'Manager')
Role.find_or_create_by!(name: 'Member')

User.find_or_create_by!(
  email: ENV.fetch('CSPACE_BATCH_IMPORT_SUPERUSER_EMAIL', 'superuser@collectionspace.org')
) do |user|
  user.enabled = true
  user.password = ENV.fetch('CSPACE_BATCH_IMPORT_SUPERUSER_PASSWORD', 'password')
  user.password_confirmation = ENV.fetch('CSPACE_BATCH_IMPORT_SUPERUSER_PASSWORD', 'password')
  user.role = Role.admin
end

if ENV.fetch('RAILS_ENV', 'development') == 'development'
  groups = [
    { name: 'Fish', domain: 'fish.net', enabled: false },
    { name: 'Fruit', domain: 'fruit.com' },
    { name: 'Veg', domain: 'veg.edu' }
  ]
  groups.each do |food|
    Group.find_or_create_by!(name: food[:name]) do |group|
      group.description = "#{food[:name]} group."
      group.domain = food[:domain]
      group.enabled = food[:enabled] if food[:enabled]
    end
  end

  User.find_or_create_by!(
    email: 'admin@collectionspace.org'
  ) do |user|
    user.enabled = true
    user.password = ENV.fetch('CSPACE_BATCH_IMPORT_SUPERUSER_PASSWORD', 'password')
    user.password_confirmation = ENV.fetch('CSPACE_BATCH_IMPORT_SUPERUSER_PASSWORD', 'password')
    user.role = Role.admin
  end

  users = [
    { email: 'manager@fish.net', role: Role.manager },
    { email: 'salmon@fish.net' },
    { email: 'tuna@fish.net' },
    { email: 'manager@fruit.com', role: Role.manager },
    { email: 'apple@fruit.com' },
    { email: 'banana@fruit.com' },
    { email: 'manager@veg.edu', role: Role.manager },
    { email: 'brocolli@veg.edu' },
    { email: 'carrot@veg.edu' }
  ]
  users.each do |food|
    User.find_or_create_by!(
      email: food[:email]
    ) do |user|
      user.enabled = true
      user.password = 'password'
      user.password_confirmation = 'password'
      user.role = food[:role] if food[:role]
    end
  end
end
