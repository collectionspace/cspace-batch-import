# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:admin) { User.find_by_email('admin@collectionspace.org') }
  let(:minion) { User.find_by_email('minion@collectionspace.org') }
  let(:outcast) { User.find_by_email('outcast@collectionspace.org') }

  it 'can identify admin status' do
    expect(admin.admin?).to be true
    expect(minion.admin?).to be false
  end

  it 'can identify inactive status' do
    expect(admin.active?).to be true
    expect(minion.active?).to be true
    expect(outcast.active?).to be false
  end

  it 'can identify when a user is self' do
    expect(admin.is?(minion)).to be false
    expect(admin.is?(admin)).to be true
  end

  it 'has set a group for the user' do
    expect(admin.group).to_not be nil
    expect(admin.group.name).to eq(Group.default_group_name)
  end
end
