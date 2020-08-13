require 'test_helper'

class MapperTest < ActiveSupport::TestCase
  test 'scopes the profiles correctly' do
    assert_includes Mapper.mapper_profiles, 'core'
  end

  test 'reports found status correctly' do
    refute(mappers(:anthro_collectionobject).found?)
    assert(mappers(:core_collectionobject).found?)
  end
end
