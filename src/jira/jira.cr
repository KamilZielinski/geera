require "http/client"
require "./jira_config"
require "json"

module Geera
  class Board
    JSON.mapping(
      id: Int32,
      name: String,
      self: String
    )
  end

  class Boards
    JSON.mapping(
      values: Array(Board)
    )
  end

  class Location
    JSON.mapping(
      name: String,
      projectId: Int32,
      projectKey: String
    )
  end

  class Project
    JSON.mapping(
      location: Location
    )
  end

  class Issue
    JSON.mapping(
      fields: IssueFields
    )
  end

  class IssueFields
    JSON.mapping(
      summary: String,
      issuetype: IssueType
    )
  end

  class IssueType
    JSON.mapping(
      name: String
    )
  end

  class Jira
    getter domain : String
    getter subdomain : String | Nil
    getter login : String | Nil
    getter token : String | Nil
    getter project_id : Int32 | Nil
    getter project_key : String | Nil

    getter client : HTTP::Client | Nil

    def initialize(domain, @login, @token)
      @domain = "#{domain.not_nil!}.atlassian.net"
      @subdomain = domain

      HTTP::Client.new(@domain, 443, true) do |client|
        client.basic_auth(@login, @token)
        client.before_request do |request|
          request.headers["Accept"] = "application/json"
          request.headers["X-Atlassian-Token"] = "no-check"
        end
        @client = client
      end
    end

    def configure
      boards = get_boards
      selected_board = gets.not_nil!.chomp.to_i
      project = get_project(boards, selected_board)
      @project_id = project.location.projectId
      @project_key = project.location.projectKey
    end

    def get_boards
      puts "Select your teams' board:"
      sorted_boards = fetch_boards.values.sort { |a, b| a.name <=> b.name }
      sorted_boards.each do |board|
        puts "#{board.id}. #{board.name}"
      end
      sorted_boards
    end

    # TODO this needs to go through pages to get all boards. Currenly it gets only first page
    private def fetch_boards : Geera::Boards
      response = @client.not_nil!.get("/rest/agile/1.0/board")
      puts response.status_code
      if response.success?
        Boards.from_json(response.body)
      else
        raise "[Error] Couldn't read response from Jira API"
      end
    end

    def get_project(boards, board_id)
      board = boards.not_nil!.find { |i| i.id == board_id }
      response = http_get board.not_nil!.self
      if response.success?
        Project.from_json(response.body)
      else
        raise "[Error] Couldn't read response from Jira API"
      end
    end

    def get_issue(issue_key)
      response = @client.not_nil!.get("/rest/agile/1.0/issue/#{issue_key}")
      if response.success?
        Issue.from_json(response.body)
      else
        raise "[Error] Couldn't read response from Jira API"
      end
    end

    def http_get(jira_path)
      path = jira_path.sub("https://#{@domain.not_nil!}", "")
      response = @client.not_nil!.get(path)
    end

    def get_config : Geera::JiraConfig
      Geera::JiraConfig.new(
        @subdomain,
        @login,
        @token,
        @project_id,
        @project_key
      )
    end
  end
end
