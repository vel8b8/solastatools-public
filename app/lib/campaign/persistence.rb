class Campaign::Persistence
  REDIS_KEY_EXPIRATION_SECONDS = 60 * 60 * 24 * 7

  def save_container(uuid, campaign_container)
    save(key_for(:container, uuid), campaign_container)
  end

  # return: Campaign::Container
  def load_container(uuid)
    load(key_for(:container, uuid))
  end

  def save_validation(uuid, validation_results)
    save(key_for(:validation, uuid), validation_results)
  end

  # return: CampaignValidator::Results
  def load_validation(uuid)
    load(key_for(:validation, uuid))
  end

  def key_for(context, uuid)
    "#{uuid}:#{context}"
  end

  private
  def save(key, object)
    raise StandardError, "Invalid key" if key.blank?
    marshaled = Marshal.dump(object)
    marshaled = Base64.encode64(marshaled)
    StRedis.client.setex(key, REDIS_KEY_EXPIRATION_SECONDS, marshaled)
  end

  def load(key)
    marshaled = StRedis.client.get(key)
    if marshaled.blank?
      Rails.logger.warn("Failed to find saved key=#{key}")
      return nil
    end
    marshaled = Base64.decode64(marshaled)
    Marshal.load(marshaled)
  end
end