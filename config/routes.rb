Rails.application.routes.draw do
  get 'campaign/upload', to: 'campaign_upload#index', as: 'campaign_upload_index'
  post 'campaign/upload/create', to: 'campaign_upload#create'
  get 'campaign/analysis/:uuid', to: 'campaign_analysis#show', as: 'campaign_analysis_show'
  get 'campaign/analysis/processing/:uuid', to: 'campaign_analysis#processing', as: 'campaign_analysis_processing'
  get 'campaign/analysis/status/:uuid', to: 'campaign_analysis#status', as: "campaign_analysis_status"
  get 'campaign/analysis/recent/list', to: 'campaign_analysis#recent', as: "campaign_analysis_recent"
  get 'campaign/combat/:uuid', to: 'fight_club#show', as: 'fight_club_show'
  get 'campaign/combat/:uuid/details/:fight_club_id', to: 'fight_club#show_details', as: 'fight_club_show_details'
  get 'campaign/combat/start/:uuid', to: 'fight_club#start', as: 'fight_club_start'
  get 'campaign/combat/processing/:uuid', to: 'fight_club#processing', as: 'fight_club_processing'
  get 'campaign/combat/status/:uuid', to: 'fight_club#status', as: "fight_club_status"
  get 'about', to: 'home#about'
  get 'contact', to: 'home#contact'
  get 'resources', to: 'home#resources'
  root "home#home"
end
