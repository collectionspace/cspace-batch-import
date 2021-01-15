class AddBatchConfigToBatches < ActiveRecord::Migration[6.0]
  def change
    add_column :batches, :batch_config, :text, default: '{}'
  end
end
