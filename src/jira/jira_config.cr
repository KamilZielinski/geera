module Geera
  class JiraConfig
    getter domain : String | Nil
    getter login : String | Nil
    getter token : String | Nil
    getter project_id : Int32 | Nil
    getter project_key : String | Nil

    def initialize(@domain, @login, @token, @project_id, @project_key)
    end
  end
end
