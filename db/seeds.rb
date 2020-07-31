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
  email: ENV.fetch('CSPACE_BATCH_IMPORT_SUPERUSER_EMAIL', 'superuser@collectionspace.org')
) do |user|
  user.active = true
  user.enabled = true
  user.group = Group.default
  user.password = ENV.fetch('CSPACE_BATCH_IMPORT_SUPERUSER_PASSWORD', 'password')
  user.password_confirmation = ENV.fetch('CSPACE_BATCH_IMPORT_SUPERUSER_PASSWORD', 'password')
  user.role = Role.admin
end

if ENV['RAILS_ENV'] == 'development'
  groups = [
    { name: 'Fish', domain: 'fish.net', enabled: false },
    { name: 'Fruit', domain: 'fruit.com', enabled: true },
    { name: 'Veg', domain: 'veg.edu', enabled: true }
  ]
  groups.each do |food|
    Group.find_or_create_by!(name: food[:name]) do |group|
      group.description = "#{food[:name]} group."
      group.enabled = food[:enabled]
    end
  end

  users = [
    { email: 'manager@fish.net', group: Group.find_by_name('Fish'), role: Role.manager },
    { email: 'salmon@fish.net', group: Group.find_by_name('Fish'), role: Role.member },
    { email: 'tuna@fish.net', group: Group.find_by_name('Fish'), role: Role.member },
    { email: 'manager@fruit.com', group: Group.find_by_name('Fruit'), role: Role.manager },
    { email: 'apple@fruit.com', group: Group.find_by_name('Fruit'), role: Role.member },
    { email: 'banana@fruit.com', group: Group.find_by_name('Fruit'), role: Role.member },
    { email: 'manager@veg.edu', group: Group.find_by_name('Veg'), role: Role.manager },
    { email: 'brocolli@veg.edu', group: Group.find_by_name('Veg'), role: Role.member },
    { email: 'carrot@veg.edu', group: Group.find_by_name('Veg'), role: Role.member }
  ]
  users.each do |food|
    User.find_or_create_by!(
      email: food[:email]
    ) do |user|
      user.enabled = true
      user.group = food[:group]
      user.password = 'password'
      user.password_confirmation = 'password'
      user.role = food[:role]
    end
  end
end
