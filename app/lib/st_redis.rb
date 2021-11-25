class StRedis
  SSL_CERTS_PATH = "config/redis-ssl-certs".freeze

  def self.redis_params
    # Heroku manages ENV REDIS_URL
    redis_url = ENV["REDIS_URL"] || 'redis://localhost:6379'
    params = {
      url: redis_url
    }
    if redis_url.start_with?("rediss")
      begin
        params[:ssl_params] = {
          ca_file: "#{SSL_CERTS_PATH}/TODO.pem",
          cert: OpenSSL::X509::Certificate.new(File.read("#{SSL_CERTS_PATH}/TODO_user.crt")),
          key: OpenSSL::PKey::RSA.new(File.read("#{SSL_CERTS_PATH}/TODO_user_private.key"))
        }
      rescue StandardError => err
        Rails.logger.error("Failed to load redis ssl certs. #{err.class} #{err}")
        raise err
      end
    else
      params[:ssl_params] = { verify_mode: OpenSSL::SSL::VERIFY_NONE }
    end
    params
  end

  def self.client
    return @@redis if defined?(@@redis)
    @@redis = Redis.new(redis_params)
  end
end