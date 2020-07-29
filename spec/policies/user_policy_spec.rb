# frozen_string_literal: true

require 'rails_helper'

describe UserPolicy do
  subject { described_class }
  let(:admin) { User.find_by_email('admin@collectionspace.org') }
  let(:manager) { User.find_by_email('manager@collectionspace.org') }
  let(:minion) { User.find_by_email('minion@collectionspace.org') }

  permissions :destroy? do
    it 'denies access if user is not an admin' do
      expect(subject).not_to permit(minion, admin)
      expect(subject).not_to permit(minion, manager)
      expect(subject).not_to permit(manager, admin)
      expect(subject).not_to permit(manager, minion)
    end

    it 'grants access if user is an admin' do
      expect(subject).to permit(admin, minion)
      expect(subject).to permit(admin, manager)
    end

    it 'denies access if user is deleting self' do
      expect(subject).not_to permit(admin, admin)
      expect(subject).not_to permit(minion, minion)
    end
  end

  permissions :impersonate? do
    it 'denies access if user is not an admin to admin' do
      expect(subject).not_to permit(minion, admin)
      expect(subject).not_to permit(manager, admin)
    end

    it 'grants access if user is an admin' do
      # TODO: admin 2 admin
      expect(subject).to permit(admin, manager)
      expect(subject).to permit(admin, minion)
    end

    it 'grants access if user is a manager' do
      # TODO: manager 2 manager
      expect(subject).to permit(manager, minion)
    end

    it 'does not grant access to self' do
      expect(subject).not_to permit(admin, admin)
      expect(subject).not_to permit(manager, manager)
    end
  end

  permissions :update? do
    it 'denies access if user is not an admin' do
      expect(subject).not_to permit(minion, admin)
    end

    it 'grants access if user is an admin' do
      expect(subject).to permit(admin, minion)
    end

    it 'grants access if user is a manager' do
      expect(subject).to permit(manager, minion)
    end

    it 'grants access if user is updating self' do
      expect(subject).to permit(admin, admin)
      expect(subject).to permit(minion, minion)
    end
  end
end
