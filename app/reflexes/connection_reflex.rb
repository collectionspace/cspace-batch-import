# frozen_string_literal: true

class ConnectionReflex < ApplicationReflex
  def primary
    connection = Connection.find(element.dataset['id'])
    connection.update(primary: true)
  end

  def selected
    @connection = Connection.find(element.value.to_i)
  end
end
