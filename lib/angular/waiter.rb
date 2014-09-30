module Angular
  class Waiter
    def initialize(setup)
      @setup = setup
      @page = @setup.page
    end

    def wait_until_ready
      return unless @setup.angular_app?

      @setup.install

      setup_waiter
      start = Time.now
      until ready?
        timeout! if timeout?(start)
        setup_waiter if @setup.page_reloaded?
        sleep(0.01)
      end
    end

    private

    def timeout?(start)
      Time.now - start > Capybara.default_wait_time
    end

    def timeout!
      raise TimeoutError.new("timeout while waiting for angular")
    end

    def ready?
      @page.evaluate_script("window.ngReady")
    end

    def setup_waiter
      script = <<-JS
        window.ngReady = false;
        (function() {
          var app = angular.element(document.querySelector('[ng-app], [data-ng-app]'));
          var injector = app.injector();
          var callback = function() {
            window.ngReady = true;
          };

          try {
            if (angular.getTestability) {
              angular.getTestability(el).whenStable(callback);
            } else {
              injector.get('$browser').notifyWhenNoOutstandingRequests(callback);
            }
          } catch (e) {
            callback(e);
          }
        })();
      JS
      @page.execute_script script
    end
  end
end
