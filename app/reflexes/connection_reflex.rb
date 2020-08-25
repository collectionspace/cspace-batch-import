# frozen_string_literal: true

class ConnectionReflex < ApplicationReflex
  def primary
    connection = Connection.find(element.dataset['id'])
    connection.update(primary: true)
  end
end
