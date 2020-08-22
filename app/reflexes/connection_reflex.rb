# frozen_string_literal: true

class ConnectionReflex < ApplicationReflex
  def primary
    user = User.find(element.dataset['user-id'])
    connection = Connection.find(element.dataset['id'])
    Connection.primary(user, connection)
  end
end
