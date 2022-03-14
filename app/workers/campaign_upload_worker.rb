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
      Rails.logger.error("CampaignUploadWorker Failed to find CampaignUpload. upload_id=#{upload_id}")
      return
    end
    campaign_upload.processed_at = DateTime.now.utc
    campaign_upload.save # don't raise

    parser = CampaignParser.new(campaign_upload.uuid)
    maybe_free_redis
    campaign_hash = load_campaign(upload_id, campaign_upload, parser)
    # suggest reclaim memory used by json object
    GC.start(full_mark: false, immediate_sweep: true)
    validate_upload(campaign_upload, campaign_hash)
    Rails.logger.info("Loaded campaign upload_id=#{upload_id} key_count=#{campaign_hash.keys.count} ")
    container = parser.build_campaign_container(campaign_hash)
    Rails.logger.info("Built Campaign::Container upload_id=#{upload_id} uuid=#{container.uuid}")
    persistence = Campaign::Persistence.new
    persistence.save_container(container.uuid, container)
    Rails.logger.info("Saved Campaign::Container upload_id=#{upload_id} uuid=#{container.uuid}")
    validator = CampaignValidator.new
    validation_results = validator.validate(container)
    persistence.save_validation(container.uuid, validation_results)
    Rails.logger.info("Saved CampaignValidator::Results upload_id=#{upload_id} uuid=#{container.uuid}")
    container
  end

  def maybe_free_redis
    max_memory = ENV["REDIS_MAX_MEMORY_BYTES"]&.to_i
    return if max_memory.blank?
    used_memory = StRedis.client.info["used_memory"]&.to_i
    if used_memory.present? && used_memory > max_memory
      Rails.logger.warn("CampaignUploadWorker Redis near memory limit, will flushall. used_memory=#{used_memory} max_memory=#{max_memory}")
      StRedis.client.flushall
    end
  rescue StandardError => err
    Rails.logger.error("CampaignUploadWorker Failed to maybe_free_redis. error=#{err&.message}")
  end

  def validate_upload(campaign_upload, campaign_hash)
    if campaign_hash.present? && campaign_hash.key?('author') && campaign_hash['author'].present? && campaign_hash['author'].size > 1
      campaign_upload.author = campaign_hash['author']
      campaign_upload.save!
    else
      save_processing_error(campaign_upload, 'missing_author_tag')
      raise StandardError, "Missing campaign data or author tag. upload_id=#{campaign_upload.id}"
    end
    if !campaign_hash.key?('contentType') || campaign_hash['contentType'] == 'UserLocation'
      exception_message = "Invalid campaign content type: #{campaign_hash['contentType']&.truncate(64)}"
      save_processing_error(campaign_upload, 'invalid_campaign_content_type', exception_message)
      raise StandardError, exception_message
    end
  end

  def load_campaign(upload_id, campaign_upload, parser)
    begin
      in_mem_json = campaign_upload.campaign_json.download
      return parser.parse(in_mem_json)
    rescue StandardError => err
      Rails.logger.error("Failed to parse json for CampaignUpload. upload_id=#{upload_id} error=#{err.message} trace=#{err.backtrace&.join('\n')&.truncate(500)}")
      save_processing_error(campaign_upload, 'json_parse_error', err.message)  
      raise
    end
  end

  def save_processing_error(campaign_upload, cause, error_message=nil)
    persistence = Campaign::Persistence.new
    persistence.save_processing_status(campaign_upload.uuid, {'status' => 'error', 'cause' => cause, 'uuid' => campaign_upload.uuid, 'message' => error_message})
  end
end
