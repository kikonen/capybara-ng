# bind logic to capybara
class Capybara::Session
  include ::Angular::DSL

  def ng_session_options
    @ng_session_options ||= {}
  end
end
