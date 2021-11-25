class CampaignUploadController < ApplicationController
  def create
    if rate_limit!
      redirect_to campaign_upload_index_path(error_message: "Please wait a moment before uploading again.")
      return
    end
    begin
      campaign_upload = CampaignUpload.create!(adapt_campaign_upload_params)
      CampaignUploadWorker.perform_async(campaign_upload.id)
      redirect_to campaign_analysis_processing_path(campaign_upload.uuid)
    rescue StandardError => err
      Rails.logger.error("Failed to create CampaignUpload. error=#{err.message} trace=#{err.backtrace&.join('\n')&.truncate(300)}")
      redirect_to campaign_upload_index_path(error_message: sanitize_error(err.message))
    end
  end

  def index
    @prior_upload_error = params[:error_message]
  end

  private

  def rate_limit!
    limiter = UploadLimiter.new
    return true unless limiter.below_limit?(request.remote_ip)
    limiter.save_attempt!(request.remote_ip)
    false
  end

  def sanitize_error(message)
    return nil if message.nil?
    msg = message
    msg.gsub!(/Validation failed: +/, "")
    msg&.truncate(100)
  end

  def adapt_campaign_upload_params
    {
      uuid: SecureRandom.uuid,
      campaign_json: params[:campaign_json],
      filename: params[:campaign_json]&.original_filename&.strip&.truncate(100),
      uploaded_at: DateTime.now.utc,
      uploader_ip: request.remote_ip
    }
  end
end
