require 'rails_helper'

RSpec.describe Group, type: :model do
  it 'should have the default group' do
    expect(Group.default_created?).to be true
  end
end
