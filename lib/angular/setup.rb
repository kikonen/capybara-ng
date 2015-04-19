module Angular
  class Setup
    include Log

    attr_reader :page

    def initialize(page)
      @page = page
    end

    def ng_wait
      install
      Waiter.new(self).wait_until_ready
    end

    def row(opt)
      opt.has_key?(:row) ? opt[:row] : 0
    end

    #
    # @param opt
    # - :using
    # - :root_selector
    # - :wait
    #
    def get_nodes(method, params, opt = {})
      opt = {
        nodes: true,
        using: nil,
        root_selector: ::Angular.root_selector,
      }.merge(opt)
      make_call(method, params, opt)
    end

    #
    # @param opt
    # - :using
    # - :root_selector
    # - :wait
    #
    def get_nodes_2(method, params, opt = {})
      opt = {
        nodes: false,
        using: nil,
        root_selector: ::Angular.root_selector,
      }.merge(opt)
      ids = make_call(method, params, opt)
     raise NotFound.new("#{method}: #{params} - #{opt.inspect}") if ids.nil? || ids.empty?
      make_nodes(ids, opt)
    end

    def make_nodes(ids, opt)
      result = []
      ids.each do |id|
        id = id.tr('"', '')
        selector = "//*[@capybara-ng-match='#{id}']"
        nodes = page.driver.find_xpath(selector)

        raise NotFound.new("Failed to match found id to node") if nodes.empty?
        result.concat(nodes)
      end
      page.evaluate_script("clearCapybaraNgMatches('#{opt[:root_selector]}')");
      result
    end

    #
    # @param opt
    # - :nodes
    # - :wait
    #
    def make_call(method, params, opt = {})
      opt = {
        nodes: false,
        wait: true,
      }.merge(opt)

      ng_wait if opt[:wait]

      params << opt[:using] if opt.has_key?(:using)
      params << opt[:root_selector] if opt.has_key?(:root_selector)
      js_params = params.map do |p|
        if p.nil?
          'null'
        elsif p.is_a? String
          escaped = p.gsub(/'/, "\\\\'").gsub(/"/, '\\\\"')
          "'#{escaped}'"
        else
          p.to_s
        end
      end

      js = "#{method}(#{js_params.join(', ')});"
      logger.debug js
      js_result = page.evaluate_script(js);
#      logger.debug js_result

      if opt[:nodes]
        make_result method, params, js_result
      else
        js_result
      end
    end


    def make_result(method, params, js_result)
      if js_result.nil? || js_result.empty?
        raise NotFound.new("#{method}: #{params.inspect}")
      end

      if js_result.is_a? String
        raise js_result
      end

      js_result.map do |el|
        el ? Capybara::Selenium::Node.new(page.driver, el) : nil
      end
    end

    def angular_app?
      begin
        js = "(typeof angular !== 'undefined') && "
        js += "angular.element(document.querySelector('[ng-app], [data-ng-app]')).length > 0"
        @page.evaluate_script js
      rescue Capybara::NotSupportedByDriverError
        false
      end
    end

    def page_reloaded?
      @page.evaluate_script("window.ngInstalled === undefined")
    end

    def mark_installed
      @page.evaluate_script("window.ngInstalled = true")
    end

    def install
      if page_reloaded?
        ClientScript.window_scripts.each do |f|
          @page.evaluate_script(f)
        end
        mark_installed
      end
    end
  end
end
