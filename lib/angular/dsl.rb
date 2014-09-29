module Angular
module DSL
  def ng
    @ng ||= Angular::Setup.new(Capybara.current_session)
  end

  def wait_angular
    ng.install
    Waiter.new(page).wait_until_ready
  end

  #
  # @return node first matching query
  #
  def ng_repeater_row(repeater, row = 0)
    ng_repeater_rows(repeater, row).first
  end

  #
  # @return node first matching query
  #
  def ng_binding(binding, exact = false, using = nil , rootSelector = 'body')
    ng_bindings(binding, exact, using , rootSelector).first
  end

  #
  # @return node first matching query
  #
  def ng_model(model, using = nil , rootSelector = 'body')
    ng_models(model, using, rootSelector).first
  end

  #
  # @return [node, ...]
  #
  def ng_repeater_rows(repeater, row = 0)
    wait_angular
    result = page.evaluate_script("findRepeaterRows('#{repeater}', #{row});");
    raise NotFound.new("repeater-row: #{repeater}") if result.nil? || result.empty?
    [Capybara::Selenium::Node.new(page.driver, result[0])]
  end

  #
  # @return [node, ...]
  #
  def ng_bindings(binding, exact = false, using = nil , rootSelector = 'body')
    wait_angular
    result = page.evaluate_script("findBindings('#{binding}', #{exact});");
    raise NotFound.new("binding: #{binding}") if result.nil? || result.empty?
    [Capybara::Selenium::Node.new(page.driver, result[0])]
  end

  #
  # @return [node, ...]
  #
  def ng_models(model, using = nil , rootSelector = 'body')
    wait_angular
    result = page.evaluate_script("findByModel('#{model}');");
    raise NotFound.new("model: #{model}") if result.nil? || result.empty?
    [Capybara::Selenium::Node.new(page.driver, result[0])]
  end
end
end
