require "../jira/jira"
require "../jira/jira_config"
require "file_utils"
require "totem"
require "totem/config_types/env"
require "../slugify/slugify"
require "../config/config"
require "../git/git"
require "../geera"

module Geera
  class Cli
    def start(argv)
      if argv.empty?
        puts "No command passed"
        exit
      end
      command = argv[0]
      case command
      when "configure"
        puts "Geera [v#{Geera::VERSION}]"
        configure
      else
        if Config.exists?
          @config = Config.load
          jump_to_branch(command)
        else
          puts "[Error] Configuration doesn't exist. Create configuration by typing 'geera configure' in your console"
        end
      end
    end

    def get_issue_or_exit(issue_name) : Geera::Issue
      jira_client = Jira.new(@config.not_nil!.domain, @config.not_nil!.login, @config.not_nil!.token)
      begin
        return jira_client.get_issue issue_name
      rescue
        puts "Given issue [#{issue_name}] doesn't exist"
        exit
      end
    end

    def jump_to_branch(command)
      issue_name = @config.not_nil!.project_key.not_nil!.upcase + "-" + command

      Git.fetch
      existing_branch = Git.find_branch_starting_with "#{issue_name}-"
      if existing_branch.empty?
        issue = get_issue_or_exit(issue_name)
        branch_name = get_slugified_branch_name(issue, issue_name)
        Git.create_and_checkout branch_name
      else
        Git.checkout existing_branch
      end
    end

    def get_slugified_branch_name(issue, issue_name)
      slugify = Geera::Slugify.new
      slug_type = issue.not_nil!.fields.issuetype.name
      slug_name = slugify.slugify issue.not_nil!.fields.summary
      slug_type.downcase + "/" + issue_name + "-" + slug_name
    end

    def starts_with_project_key?(command)
      @config.not_nil!.project_key.not_nil!.downcase.starts_with?(command.downcase)
    end

    def configure
      domain, login, token = get_config_from_user
      if domain.empty? || login.empty? || token.empty?
        puts "[Error] You need to pass domain, login and Jira API token"
        exit
      end

      jira = Jira.new(domain, login, token)
      jira.configure
      Config.store jira.get_config
    end

    def get_config_from_user : Tuple(String, String, String | Nil)
      puts "Connect your Atlassian account by passing your company domain and credentials:\n\n"
      print "Domain (from url: https://XXXXX.atlassian.net) where XXXXX is your company domain: "
      domain = gets.not_nil!
      print "Atlassian email: "
      login = gets.not_nil!
      print "Atlassian API token: "
      token = (STDIN.noecho &.gets.try &.chomp).not_nil!
      puts "\n"
      return domain, login, token
    end
  end
end
