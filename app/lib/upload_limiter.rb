class UploadLimiter
  SECONDS_BETWEEN_ATTEMPTS = 5
  MAX_ATTEMPTS_PER_PERIOD = 5
  PERIOD_DURATION_SECONDS = 60

  def below_limit?(remote_ip)
    !recent?(remote_ip) && !too_many?(remote_ip)
  end

  def recent?(remote_ip)
    UploadAttempt.where(uploader_ip: remote_ip) \
      .where("uploaded_at > ?", SECONDS_BETWEEN_ATTEMPTS.seconds.ago).count > 0
  end

  def too_many?(remote_ip)
    UploadAttempt.where(uploader_ip: remote_ip) \
      .where("uploaded_at > ?", PERIOD_DURATION_SECONDS.seconds.ago).count >= MAX_ATTEMPTS_PER_PERIOD
  end

  def save_attempt!(remote_ip)
    UploadAttempt.create!(uploader_ip: remote_ip, uploaded_at: DateTime.now.utc)
  end
end