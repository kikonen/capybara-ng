module Angular
#
# TODO KI NOT USED
#
class Driver
  include Capybara::DSL

  DEFER_LABEL = 'NG_DEFER_BOOTSTRAP!';

  WEB_ELEMENT_FUNCTIONS = [
    'click', 'sendKeys', 'getTagName', 'getCssValue', 'getAttribute', 'getText',
    'getSize', 'getLocation', 'isEnabled', 'isSelected', 'submit', 'clear',
    'isDisplayed', 'getOuterHtml', 'getInnerHtml', 'getId'
  ]

  DEFAULT_RESET_URL = 'data:text/html,<html></html>'
  DEFAULT_GET_PAGE_TIMEOUT = 10000


  def initialize(opt)
    @element = ElementHelper.new(self)

    # All get methods will be resolved against this base URL. Relative URLs are =
    # resolved the way anchor tags resolve.
    #
    # @type {string}
    @baseUrl = opt[:base_url] || '';

    #
    # The css selector for an element on which to find Angular. This is usually
    # 'body' but if your ng-app is on a subsection of the page it may be
    # a subelement.
    #
    # @type {string}
    @rootEl = opt[:root_element] || 'body';

    #
    # If true, Protractor will not attempt to synchronize with the page before
    # performing actions. This can be harmful because Protractor will not wait
    # until $timeouts and $http calls have been processed, which can cause
    # tests to become flaky. This should be used only when necessary, such as
    # when a page continuously polls an API using $timeout.
    #
    # @type {boolean}
    @ignoreSynchronization = false;

    #
    # Timeout in milliseconds to wait for pages to load when calling `get`.
    #
    # @type {number}
    @getPageTimeout = DEFAULT_GET_PAGE_TIMEOUT;

    #
    # An object that holds custom test parameters.
    #
    # @type {Object}
    @params = {};

    #
    # The reset URL to use between page loads.
    #
    # @type {string}
    @resetUrl = DEFAULT_RESET_URL;

    #
    # Information about mock modules that will be installed during every
    # get().
    #
    # @type {Array<{name: string, script: function|string, args: Array.<string>}>}
    @mockModules = [];

    @addBaseMockModules_();

    @functions = ClientScript.functions
  end

  # @see http://artsy.github.io/blog/2012/02/03/reliably-testing-asynchronous-ui-w-slash-rspec-and-capybara/
  def wait_for_dom(timeout = Capybara.default_wait_time)
    uuid = SecureRandom.uuid
    page.find("body")
    page.evaluate_script <<-EOS
    _.defer(function() {
      $('body').append("<div id='#{uuid}'></div>");
    });
  EOS
    page.find("##{uuid}")
  end

  def setup
    <<-FN
  // These functions should delegate to the webdriver instance, but should
  // wait for Angular to sync up before performing the action. This does not
  // include functions which are overridden by protractor below.
  var methodsToSync = ['getCurrentUrl', 'getPageSource', 'getTitle'];

  // Mix all other driver functionality into Protractor.
  for (var method in webdriverInstance) {
    if(!this[method] && typeof webdriverInstance[method] == 'function') {
      if (methodsToSync.indexOf(method) !== -1) {
        mixin(this, webdriverInstance, method, this.waitForAngular.bind(this));
      } else {
        mixin(this, webdriverInstance, method);
      }
    }
  }
FN
  end

  def page
    Capybara.current_session
  end

  def wait_for_angular
    return if @ignoreSynchronization
    result = page.evaluate_script(functions[:waitForAngular])

    <<-FN
Protractor.prototype.waitForAngular = function() {
  if (this.ignoreSynchronization) {
    return webdriver.promise.fulfilled();
  }
  return this.driver.executeAsyncScript(
    clientSideScripts.waitForAngular, this.rootEl).then(function(browserErr) {
      if (browserErr) {
        throw 'Error while waiting for Protractor to ' +
              'sync with the page: ' + JSON.stringify(browserErr);
      }
    }).then(null, function(err) {
      var timeout;
      if (/asynchronous script timeout/.test(err.message)) {
        // Timeout on Chrome
        timeout = /-?[\d\.]*\ seconds/.exec(err.message);
      } else if (/Timed out waiting for async script/.test(err.message)) {
        // Timeout on Firefox
        timeout = /-?[\d\.]*ms/.exec(err.message);
      } else if (/Timed out waiting for an asynchronous script/.test(err.message)) {
        // Timeout on Safari
        timeout = /-?[\d\.]*\ ms/.exec(err.message);
      }
      if (timeout) {
        throw 'Timed out waiting for Protractor to synchronize with ' +
            'the page after ' + timeout + '. Please see ' +
            'https://github.com/angular/protractor/blob/master/docs/faq.md';
      } else {
        throw err;
      }
    });
};
FN
  end

  def findElement
    <<-FN
/**
 * Waits for Angular to finish rendering before searching for elements.
 * @see webdriver.WebDriver.findElement
 * @return {!webdriver.WebElement}
 */
function(locator) {
  return this.element(locator).getWebElement();
};
FN
  end

  def findElements
    <<-FN
/**
 * Waits for Angular to finish rendering before searching for elements.
 * @see webdriver.WebDriver.findElements
 * @return {!webdriver.promise.Promise} A promise that will be resolved to an
 *     array of the located {@link webdriver.WebElement}s.
 */
function(locator) {
  return this.element.all(locator).getWebElements();
};
FN
  end

  def isElementPresent
    <<-FN
/**
 * Tests if an element is present on the page.
 * @see webdriver.WebDriver.isElementPresent
 * @return {!webdriver.promise.Promise} A promise that will resolve to whether
 *     the element is present on the page.
 */
function(locatorOrElement) {
  var element = (locatorOrElement instanceof webdriver.promise.Promise) ?
      locatorOrElement : this.element(locatorOrElement);
  return element.isPresent();
};
FN
  end

  def get
    <<-FN
/**
 * See webdriver.WebDriver.get
 *
 * Navigate to the given destination and loads mock modules before
 * Angular. Assumes that the page being loaded uses Angular.
 * If you need to access a page which does not have Angular on load, use
 * the wrapped webdriver directly.
 *
 * @param {string} destination Destination URL.
 * @param {number=} opt_timeout Number of milliseconds to wait for Angular to
 *     start.
 */
function(destination, opt_timeout) {
  var timeout = opt_timeout ? opt_timeout : this.getPageTimeout;
  var self = this;

  destination = this.baseUrl.indexOf('file://') === 0 ?
    this.baseUrl + destination : url.resolve(this.baseUrl, destination);

  if (this.ignoreSynchronization) {
    return this.driver.get(destination);
  }

  this.driver.get(this.resetUrl);
  this.driver.executeScript(
      'window.name = "' + DEFER_LABEL + '" + window.name;' +
      'window.location.replace("' + destination + '");');

  // We need to make sure the new url has loaded before
  // we try to execute any asynchronous scripts.
  this.driver.wait(function() {
    return self.driver.executeScript('return window.location.href;').
        then(function(url) {
          return url !== self.resetUrl;
        }, function(err) {
          if (err.code == 13) {
            // Ignore the error, and continue trying. This is because IE
            // driver sometimes (~1%) will throw an unknown error from this
            // execution. See https://github.com/angular/protractor/issues/841
            // This shouldn't mask errors because it will fail with the timeout
            // anyway.
            return false;
          } else {
            throw err;
          }
        });
  }, timeout,
  'Timed out waiting for page to load after ' + timeout + 'ms');

  // Make sure the page is an Angular page.
  self.driver.executeAsyncScript(clientSideScripts.testForAngular,
        Math.floor(timeout / 1000)).
      then(function(angularTestResult) {
        var hasAngular = angularTestResult[0];
        if (!hasAngular) {
          var message = angularTestResult[1];
          throw new Error('Angular could not be found on the page ' +
              destination + ' : ' + message);
        }
      }, function(err) {
        throw 'Error while running testForAngular: ' + err.message;
      });

  // At this point, Angular will pause for us until angular.resumeBootstrap
  // is called.
  var moduleNames = [];
  for (var i = 0; i < this.mockModules_.length; ++i) {
    var mockModule = this.mockModules_[i];
    var name = mockModule.name;
    moduleNames.push(name);
    var executeScriptArgs = [mockModule.script].concat(mockModule.args);
    this.driver.executeScript.apply(this, executeScriptArgs).
        then(null, function(err) {
          throw 'Error while running module script ' + name +
              ': ' + err.message;
        });
  }

  return this.driver.executeScript(
      'angular.resumeBootstrap(arguments[0]);',
      moduleNames);
};
FN
  end

  def refresh
    <<-FN
/**
 * See webdriver.WebDriver.refresh
 *
 * Makes a full reload of the current page and loads mock modules before
 * Angular. Assumes that the page being loaded uses Angular.
 * If you need to access a page which does not have Angular on load, use
 * the wrapped webdriver directly.
 *
 * @param {number=} opt_timeout Number of seconds to wait for Angular to start.
 */
 = function(opt_timeout) {
  var timeout = opt_timeout || 10;
  var self = this;

  if (self.ignoreSynchronization) {
    return self.driver.navigate().refresh();
  }

  return self.driver.executeScript('return window.location.href').then(function(href) {
    return self.get(href, timeout);
  });
};
FN
  end

  def navigate
    <<-FN
/**
 * Mixin navigation methods back into the navigation object so that
 * they are invoked as before, i.e. driver.navigate().refresh()
 */
function() {
  var nav = this.driver.navigate();
  mixin(nav, this, 'refresh');
  return nav;
};
FN
  end

  def setLocation
    <<-FN
/**
 * Browse to another page using in-page navigation.
 *
 * @param {string} url In page URL using the same syntax as $location.url()
 * @returns {!webdriver.promise.Promise} A promise that will resolve once
 *    page has been changed.
 */
function(url) {
  this.waitForAngular();
  return this.driver.executeScript(clientSideScripts.setLocation, this.rootEl, url)
    .then(function(browserErr) {
      if (browserErr) {
        throw 'Error while navigating to \'' + url + '\' : ' +
            JSON.stringify(browserErr);
      }
    });
};
FN
  end

  def getLocationAbsUrl
<<-FN
/**
 * Returns the current absolute url from AngularJS.
 */
function() {
  this.waitForAngular();
  return this.driver.executeScript(clientSideScripts.getLocationAbsUrl, this.rootEl);
};
FN
  end
end
end
