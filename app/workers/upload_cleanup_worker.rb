class UploadCleanupWorker
  include Sidekiq::Worker

  def perform
    begin
      execute!
    rescue StandardError => err
      Rails.logger.error("UploadCleanupWorker failed. error=#{err&.message} trace=#{err.backtrace&.join('\n')&.truncate(300)}")
    end
  end

  def execute!(limit=nil)
    count = 0
    ActiveStorage::Attachment.where(record_type: CampaignUpload.name).where("created_at < ?", 3.days.ago).find_each do |attachment|
      count += 1
      begin
        attachment.purge
        Rails.logger.info("UploadCleanupWorker purged attachment.id=#{attachment&.id} record_id=#{attachment.record_id} blob_id=#{attachment.blob_id}")
      rescue StandardError => err
        Rails.logger.error("UploadCleanupWorker failed to purge attachment.id=#{attachment&.id} error=#{err&.message} trace=#{err.backtrace&.join('\n')&.truncate(300)}")
      end
      break if limit.present? && count > limit
    end
    Rails.logger.info("UploadCleanupWorker purged attachments. count=#{count}")
  end
end