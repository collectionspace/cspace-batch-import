class AddRowResultsToStepProcesses < ActiveRecord::Migration[6.0]
  def change
    add_column :step_processes, :row_results, :json, default: {}
  end
end
