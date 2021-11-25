Rails.application.routes.draw do
  get 'campaign/upload', to: 'campaign_upload#index', as: 'campaign_upload_index'
  post 'campaign/upload/create', to: 'campaign_upload#create'
  get 'campaign/analysis/:uuid', to: 'campaign_analysis#show', as: 'campaign_analysis_show'
  get 'campaign/analysis/processing/:uuid', to: 'campaign_analysis#processing', as: 'campaign_analysis_processing'
  get 'campaign/analysis/status/:uuid', to: 'campaign_analysis#status', as: "campaign_analysis_status"
  get 'campaign/analysis/recent/list', to: 'campaign_analysis#recent', as: "campaign_analysis_recent"
  get 'about', to: 'home#about'
  get 'contact', to: 'home#contact'
  get 'resources', to: 'home#resources'
  root "home#home"
end
