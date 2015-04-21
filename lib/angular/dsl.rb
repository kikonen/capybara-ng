module Angular
#
# common options (aka. "opt"):
# - root_selector Allow overriding global/page per individual query
# - wait If true wait for AngularJS to be ready before doing quer (default: true)
#
module DSL
  def ng
    Capybara.current_session.ng
  end

  #
  # Get or set selector to find ng-app for current capybara test session
  #
  # TIP: try using '[ng-app]', which will find ng-app as attribute anywhere.
  #
  # @param root_selector if nil then return current value without change
  # @return test specific selector to find ng-app,
  # by default global ::Angular.root_selector is used.
  #
  def ng_root_selector(root_selector = nil)
    opt = ng.page.ng_session_options
    if root_selector
      opt[:root_selector] = root_selector
    end
    opt[:root_selector] || ::Angular.root_selector
  end

  #
  # Setup AngularJS test hooks in web page. In normal usage there is no need
  # to use this
  #
  def ng_install
    ng.install
  end

  #
  # Wait that AngularJS is ready
  #
  def ng_wait
    ng.ng_wait
  end

  #
  # @param opt
  # - :root_selector
  # - :wait
  # @return current location absolute url
  #
  def ng_location_abs(opt = {})
    selector = opt.delete(:root_selector) || ng_root_selector
    ng.make_call :getLocationAbsUrl, [selector], opt
  end

  #
  # @param opt
  # - :root_selector
  # - :wait
  # @return current location absolute url
  #
  def ng_location(opt = {})
    selector = opt.delete(:root_selector) || ng_root_selector
    ng.make_call :getLocation, [selector], opt
  end

  #
  # @param opt
  # - :root_selector
  # - :wait
  # @return current location
  #
  def ng_set_location(url, opt = {})
    selector = opt.delete(:root_selector) || ng_root_selector
    ng.make_call :setLocation, [selector, url], opt
  end

  #
  # @param opt
  # - :root_selector
  # - :wait
  # @return eval result
  #
  def ng_eval(expr, opt = {})
    selector = opt.delete(:root_selector) || ng_root_selector
    ng.make_call :evaluate, [selector, expr], opt
  end

  #
  # Does binding exist
  #
  # @param opt
  # - :exact
  # - :root_selector
  # - :wait
  # @return true | false
  #
  def has_ng_binding?(binding, opt = {})
    ng_bindings(model, opt)
    true
  rescue NotFound
    false
  end

  #
  # Node for nth binding match
  #
  # @param opt
  # - :row
  # - :exact
  # - :root_selector
  # - :wait
  # @return nth node
  #
  def ng_binding(binding, opt = {})
    opt[:root_selector] ||= ng_root_selector
    row = ng.row(opt)
    ng_bindings(binding, opt)[row]
  end

  #
  # All nodes matching binding
  #
  # @param opt
  # - :exact
  # - :root_selector
  # - :wait
  # @return [node, ...]
  #
  def ng_bindings(binding, opt = {})
    opt[:root_selector] ||= ng_root_selector
    ng.get_nodes_2 :findBindingsIds, [binding, opt[:exact] == true], opt
  end

  #
  # Does model exist
  #
  # @param opt
  # - :root_selector
  # - :wait
  # @return true | false
  #
  def has_ng_model?(model, opt = {})
    ng_models(model, opt)
    true
  rescue NotFound
    false
  end
  #
  # Does model not exist
  #
  # @param opt
  # - :root_selector
  # - :wait
  # @return true | false
  #
  def has_no_ng_model?(model, opt = {})
    !has_ng_model?(model, opt)
  end

  #
  # Node for nth model match
  #
  # @param opt
  # - :row
  # - :root_selector
  # - :wait
  # @return nth node
  #
  def ng_model(model, opt = {})
    opt[:root_selector] ||= ng_root_selector
    row = ng.row(opt)
    ng_models(model, opt)[row]
  end

  #
  # All nodes matching model
  #
  # @param opt
  # - :root_selector
  # - :wait
  # @return [node, ...]
  #
  def ng_models(model, opt = {})
    opt[:root_selector] ||= ng_root_selector
    ng.get_nodes_2 :findByModelIds, [model], opt
  end

  #
  # Does option exist
  #
  # @param opt
  # - :root_selector
  # - :wait
  # @return true | false
  #
  def has_ng_options?(options, opt = {})
    opt[:root_selector] ||= ng_root_selector
    ng_options(options, opt)
    true
  rescue NotFound
    false
  end

  #
  # Does option not exist
  #
  # @param opt
  # - :root_selector
  # - :wait
  # @return true | false
  #
  def has_no_ng_options?(options, opt = {})
    !has_ng_options?(options, opt)
  end

  #
  # Node for nth option
  #
  # @param opt
  # - :row
  # - :root_selector
  # - :wait
  # @return nth node
  #
  def ng_option(options, opt = {})
    opt[:root_selector] ||= ng_root_selector
    row = ng.row(opt)
    ng_options(options, opt)[row]
  end

  #
  # All option values matching option
  #
  # @param opt
  # - :root_selector
  # - :wait
  # @return [node, ...]
  #
  def ng_options(options, opt = {})
    opt[:root_selector] ||= ng_root_selector
    ng.get_nodes_2(:findByOptionsIds, [options], opt)
  end

  #
  # Does row exist
  #
  # @param opt
  # - :root_selector
  # - :wait
  # @return true | false
  #
  def has_ng_repeater_row?(repeater, opt = {})
    ng_repeater_row(repeater, opt)
    true
  rescue NotFound
    false
  end

  #
  # Does row not exist
  #
  # @param opt
  # - :root_selector
  # - :wait
  # @return true | false
  #
  def has_no_ng_repeater_row?(repeater, opt = {})
    !has_ng_repeater_rows?(repeater, opt)
  end

  #
  # Node for nth repeater row
  #
  # @param opt
  # - :row
  # - :root_selector
  # - :wait
  # @return nth node
  #
  def ng_repeater_row(repeater, opt = {})
    opt[:root_selector] ||= ng_root_selector
    row = ng.row(opt)
    data = ng.get_nodes_2(:findRepeaterRowsIds, [repeater, row], opt)
    data.first
  end

  #
  # All nodes matching repeater
  #
  # @param opt
  # - :root_selector
  # - :wait
  # @return [node, ...]
  #
  def ng_repeater_rows(repeater, opt = {})
    opt[:root_selector] ||= ng_root_selector
    ng.get_nodes_2 :findAllRepeaterRowsIds, [repeater], opt
  end

  #
  # Node for column binding value in row
  #
  # @param opt
  # - :row
  # - :root_selector
  # - :wait
  # @return nth node
  #
  def ng_repeater_column(repeater, binding, opt = {})
    opt[:root_selector] ||= ng_root_selector
    row = ng.row(opt)
    ng_repeater_columns(repeater, binding, opt)[row]
  end

  #
  # Node for column binding value in all rows
  #
  # @param opt
  # - :root_selector
  # - :wait
  # @return [node, ...]
  #
  def ng_repeater_columns(repeater, binding, opt = {})
    opt[:root_selector] ||= ng_root_selector
    ng.get_nodes_2 :findRepeaterColumnIds, [repeater, binding], opt
  end

  #
  # @param opt
  # - :row
  # - :root_selector
  # - :wait
  # @return nth node
  #
  def ng_repeater_element(repeater, index, binding, opt = {})
    opt[:root_selector] ||= ng_root_selector
    row = ng.row(opt)
    ng_repeater_elements(repeater, index, binding, opt)[row]
  end

  #
  # @param opt
  # - :root_selector
  # - :wait
  # @return [node, ...]
  #
  def ng_repeater_elements(repeater, index, binding, opt = {})
    opt[:root_selector] ||= ng_root_selector
    ng.get_nodes_2 :findRepeaterElementIds, [repeater, index, binding], opt
  end
end
end
