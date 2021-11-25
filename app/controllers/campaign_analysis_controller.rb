class CampaignAnalysisController < ApplicationController
  def show
    load_campaign
    @location_link_graph = LocationLinkGraph.transform(@validation_results.validation_links) if @validation_results.present?
  end

  def status
    load_campaign
    render json: {ready: @campaign_container.present? && @validation_results.present?, uuid: @upload_uuid}
  end

  def processing
    @upload_uuid = params[:uuid]
  end

  def recent
    @uploads = CampaignUpload.order(uploaded_at: :desc).limit(20)
  end

  private
  def load_campaign
    persistence = Campaign::Persistence.new
    @upload_uuid = params[:uuid]
    @campaign_container = persistence.load_container(@upload_uuid)
    @validation_results = persistence.load_validation(@upload_uuid)
    @campaign_monster_stats = MonsterStatsAdapter.new.adapt(@validation_results&.monster_stats)
    @xp_stats = XpStatsAdapter.new.adapt(@validation_results&.monster_stats, @validation_results&.xp_grants)
  end
end
