class CreateUploadAttempts < ActiveRecord::Migration[6.1]
  def change
    create_table :upload_attempts do |t|
      t.string :uploader_ip
      t.datetime :uploaded_at
      t.timestamps
    end
    add_index :campaign_uploads, [:uploader_ip, :uploaded_at], name: 'campaign_uploads_uploader_ip_upld_at'
  end
end
