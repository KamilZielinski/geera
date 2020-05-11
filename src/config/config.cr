module Geera
  class Config
    @@config_dir = File.expand_path("~/.geera", home: true)
    @@config_path = "#{@@config_dir}/config.env"

    def self.exists?
      File.exists?(@@config_path)
    end

    def self.load : Geera::JiraConfig
      totem = Totem.from_env File.read(@@config_path)
      domain = totem.get("DOMAIN").as_s
      login = totem.get("LOGIN").as_s
      token = totem.get("TOKEN").as_s
      project_id = totem.get("PROJECT_ID").as_i
      project_key = totem.get("PROJECT_KEY").as_s
      Geera::JiraConfig.new(domain, login, token, project_id, project_key)
    end

    def self.store(config : Geera::JiraConfig)
      FileUtils.mkdir(@@config_dir) if !File.exists?(@@config_dir)

      raw = <<-EOF
      DOMAIN=#{config.domain}
      LOGIN=#{config.login}
      TOKEN=#{config.token}
      PROJECT_ID=#{config.project_id}
      PROJECT_KEY=#{config.project_key}
      EOF

      totem = Totem.from_env raw
      totem.store_file!(@@config_path, true)
      puts "New configuration has been saved at #{@@config_path}"
    end
  end
end
