class CampaignAnalysisController < ApplicationController
  def show
    load_campaign
    @location_link_graph = LocationLinkGraph.transform(@validation_results.validation_links) if @validation_results.present?
  end

  def status
    load_campaign
    status = 'processing'
    error_cause = nil
    if @processing_status.present? && @processing_status['status'] == 'error'
      status = 'error'
      error_cause = "#{@processing_status['message']} [#{@processing_status['cause']}]"
    end
    render json: {status: status, ready: @campaign_container.present? && @validation_results.present?, error_cause: error_cause, uuid: @upload_uuid}
  end

  def processing
    @upload_uuid = params[:uuid]
  end

  def recent
    if !Rails.env.development? && (params[:magic].blank? || params[:magic] != ENV['RECENT_UPLOADS_PASSWORD'])
      render :file => "public/404.html", :status => :not_found
      return
    end
    limit = params[:limit]&.to_i || 20
    limit = 20 if limit < 1 || limit > 200
    @uploads = CampaignUpload.order(uploaded_at: :desc).limit(limit)
  end

  private
  def load_campaign
    persistence = Campaign::Persistence.new
    @upload_uuid = params[:uuid]
    @processing_status = persistence.load_processing_status(@upload_uuid)
    @campaign_container = persistence.load_container(@upload_uuid)
    @validation_results = persistence.load_validation(@upload_uuid)
    @campaign_monster_stats = MonsterStatsAdapter.new.adapt(@validation_results&.monster_stats)
    @xp_stats = XpStatsAdapter.new.adapt(@validation_results&.monster_stats, @validation_results&.xp_grants)
  end
end
