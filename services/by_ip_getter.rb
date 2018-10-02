class ByIpGetter
  MAXMIND_DB_PATH = Settings.maxmind.db_file_path

  attr_reader :ip_address

  def self.perform(*args)
    new(*args).perform
  end

  def initialize(ip_address)
    @ip_address = ip_address&.strip
  end

  def perform
    return false if ip_address.blank?

    MaxMindDB.new(MAXMIND_DB_PATH).lookup(ip_address).to_hash
  end
end
