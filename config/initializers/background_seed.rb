# Run seed in background on production boot to populate missing recipes.
# This avoids blocking Puma startup (which causes Render port scan timeout).
# Seeds are idempotent: existing recipes are skipped.
if Rails.env.production? && ENV["SKIP_SEED"].blank?
  Rails.application.config.after_initialize do
    Thread.new do
      sleep 10 # Let Puma bind the port first
      Rails.logger.info "Background seed: starting..."
      begin
        Rails.application.load_seed
        Rails.logger.info "Background seed: completed"
      rescue => e
        Rails.logger.error "Background seed failed: #{e.message}"
      ensure
        ActiveRecord::Base.connection_pool.release_connection
      end
    end
  end
end
