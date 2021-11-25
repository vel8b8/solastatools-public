class CreateCampaignUploads < ActiveRecord::Migration[6.1]
  def change
    create_table :campaign_uploads do |t|
      t.string :uuid
      t.string :filename
      t.string :uploader_ip
      t.string :author
      t.datetime :uploaded_at
      t.datetime :processed_at
      t.timestamps
    end
    add_index :campaign_uploads, :uuid, name: 'campaign_uploads_uuid'
    add_index :campaign_uploads, :uploader_ip, name: 'campaign_uploads_uploader_ip'
    add_index :campaign_uploads, :author, name: 'campaign_uploads_author'
    add_index :campaign_uploads, :uploaded_at, name: 'campaign_uploads_uploaded_at'
  end
end
