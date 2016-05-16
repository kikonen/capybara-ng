module Angular
  class Waiter
    def initialize(setup)
      @setup = setup
      @page = @setup.page
    end

    def wait_until_ready
      return unless @setup.angular_app?

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
      Time.now - start > Angular.wait_time
    end

    def timeout!
      raise TimeoutError.new("timeout while waiting for angular")
    end

    def ready?
      @page.evaluate_script("window.ngReady")
    end

    def setup_waiter
      script = <<-JS
        (function() {
          "use strict";

          window.ngReady = false;

          window. nglog = function(method, params) {
            console.log('NG: ' + method + '(' + params.join(', ') + ')')
          };

          window.nextCapybaraId = function() {
            window.capybaraId = window.capybaraId || 1;
            return window.capybaraId++;
          };

          window.createCapybaraNgMatches = function(nodes) {
            if (!nodes) {
              return nodes;
            }

            var matches = [];
            angular.forEach(nodes, function(node) {
              if (node) {
                var match = "cb_" + window.nextCapybaraId();
                node.setAttribute('capybara-ng-match', match);
                matches.push(match);
              }
            });
            return matches;
          };

          window.clearCapybaraNgMatches = function(rootSelector) {
            rootSelector = rootSelector || 'body';
            var root = document.querySelector(rootSelector);

            var nodes = root.querySelectorAll('[capybara-ng-match]');
            angular.forEach(nodes, function(node) {
              node.removeAttribute('capybara-ng-match');
            });
          };

          var el = document.querySelector('[ng-app], [data-ng-app]');
          var app = angular.element(el);
          var injector = app.injector();
          var callback = function() {
            nglog("ready-callback", []);
            var $timeout = injector.get('$timeout');
            $timeout(function() {
              nglog("ready-$timeout", []);
              window.ngReady = true;
            }, 0);
          };

          try {
            if (angular.getTestability) {
              nglog("getTestability", [el]);
              angular.getTestability(el).whenStable(callback);
            } else {
              nglog("$browser", [el]);
              injector.get('$browser').notifyWhenNoOutstandingRequests(callback);
            }
          } catch (e) {
            nglog("callback failed", [e]);
            callback(e);
          }
        })();
      JS
      @page.execute_script script
    end
  end
end
