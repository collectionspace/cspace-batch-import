require 'test_helper'

class ConnectionTest < ActiveSupport::TestCase
  test 'disabling connection unsets primary (default)' do
    c1 = connections(:core_superuser)
    assert(c1.primary?)
    c1.update(enabled: false)
    assert_not(c1.primary?)
  end

  test 'set primary (default) exclusively' do
    c1 = connections(:core_superuser)
    c2 = connections(:fcart_superuser)
    assert(c1.primary?)
    assert_not(c2.primary?)
    c2.update(primary: true)
    c1.reload
    assert_not(c1.primary?)
    assert(c2.primary?)
  end
end
