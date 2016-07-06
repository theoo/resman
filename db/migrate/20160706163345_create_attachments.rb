class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string  :title
      t.integer :attachable_id, null: false
      t.string  :attachable_type, null: false

      t.timestamps null: false
    end
    add_attachment :attachments, :file

    add_index :attachments, [:attachable_type, :attachable_id]

  end
end
