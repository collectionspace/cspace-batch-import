# frozen_string_literal: true

require 'test_helper'

class ConnectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:superuser)
    @connection = connections(:core)
  end

  test 'should get new' do
    get new_connection_url
    assert_response :success
  end

  # TODO
  # test 'should create connection' do
  #   assert_difference('Connection.count') do
  #     post connections_url, params: { connection: {} }
  #   end

  #   assert_redirected_to connection_url(Connection.last)
  # end

  test 'should redirect show connection' do
    get connection_url(@connection)
    assert_response :redirect
  end

  test 'should get edit' do
    get edit_connection_url(@connection)
    assert_response :success
  end

  # TODO
  # test 'should update connection' do
  #   patch connection_url(@connection), params: { connection: {} }
  #   assert_redirected_to connection_url(@connection)
  # end

  test 'should destroy connection' do
    assert_difference('Connection.count', -1) do
      delete connection_url(@connection)
    end

    assert_redirected_to edit_user_path(users(:superuser))
  end
end