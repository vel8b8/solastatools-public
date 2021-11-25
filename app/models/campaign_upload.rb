class CampaignUpload < ApplicationRecord
  MAX_JSON_BYTE_SIZE=12*1024*1024
  has_one_attached :campaign_json
  validate :json_blob_integrity

  def json_blob_integrity
    if !campaign_json.attached?
      errors.add(:campaign_json, "no attached json")
    elsif campaign_json.blob.blank?
      errors.add(:campaign_json, "missing json blob")
    elsif campaign_json.blob.content_type != 'text/json' && campaign_json.blob.content_type != 'application/json'
      Rails.logger.warn("CampaignUpload validation failure. blob is not json: #{campaign_json.blob.content_type}")
      errors.add(:campaign_json, "blob is not json")
    elsif campaign_json.blob.byte_size > MAX_JSON_BYTE_SIZE
      errors.add(:campaign_json, "json too large: #{campaign_json.blob.byte_size} bytes")
    end
  end
end
