class CampaignUploadWorker
  include Sidekiq::Worker

  def perform(upload_id)
    begin
      execute!(upload_id)
    rescue StandardError => err
      Rails.logger.error("CampaignUploadWorker failed. upload_id=#{upload_id} error=#{err&.message} trace=#{err.backtrace&.join('\n')&.truncate(300)}")
    end
  end

  def execute!(upload_id)
    campaign_upload = CampaignUpload.find_by_id(upload_id)
    if campaign_upload.blank?
      Rails.logger.error("Failed to find CampaignUpload. upload_id=#{upload_id}")
      return
    end
    parser = CampaignParser.new(campaign_upload.uuid)
    campaign_hash = load_campaign(upload_id, campaign_upload, parser)
    GC.start(full_mark: false, immediate_sweep: true)
    Rails.logger.info("Loaded campaign upload_id=#{upload_id} key_count=#{campaign_hash.keys.count} ")
    if campaign_hash.present?
      campaign_upload.author = campaign_hash['author']
      campaign_upload.save # don't raise
    end
    container = parser.build_campaign_container(campaign_hash)
    Rails.logger.info("Built Campaign::Container upload_id=#{upload_id} uuid=#{container.uuid}")
    persistence = Campaign::Persistence.new
    persistence.save_container(container.uuid, container)
    Rails.logger.info("Saved Campaign::Container upload_id=#{upload_id} uuid=#{container.uuid}")
    validator = CampaignValidator.new
    validation_results = validator.validate(container)
    persistence.save_validation(container.uuid, validation_results)
    Rails.logger.info("Saved CampaignValidator::Results upload_id=#{upload_id} uuid=#{container.uuid}")
    campaign_upload.processed_at = DateTime.now.utc
    campaign_upload.save # don't raise
    container
  end

  def load_campaign(upload_id, campaign_upload, parser)
    begin
      in_mem_json = campaign_upload.campaign_json.download
      return parser.parse(in_mem_json)
    rescue StandardError => err
      Rails.logger.error("Failed to parse json for CampaignUpload. upload_id=#{upload_id} error=#{err.message} trace=#{err.backtrace&.join('\n')&.truncate(500)}")
      raise
    end
  end
end
