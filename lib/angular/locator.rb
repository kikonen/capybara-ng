module Angular
#
# TODO KI NOT USED
#
module Locator
  def binding
<<-FN
/**
 * Find an element by binding.
 *
 * @view
 * <span>{{person.name}}</span>
 * <span ng-bind="person.email"></span>
 *
 * @example
 * var span1 = element(by.binding('person.name'));
 * expect(span1.getText()).toBe('Foo');
 *
 * var span2 = element(by.binding('person.email'));
 * expect(span2.getText()).toBe('foo@bar.com');
 *
 * @param {string} bindingDescriptor
 * @return {{findElementsOverride: findElementsOverride, toString: Function|string}}
 */
function(bindingDescriptor) {
  return {
    findElementsOverride: function(driver, using, rootSelector) {
      return driver.findElements(
          webdriver.By.js(clientSideScripts.findBindings,
              bindingDescriptor, false, using, rootSelector));
    },
    toString: function toString() {
      return 'by.binding("' + bindingDescriptor + '")';
    }
  };
};
FN
  end


  def exactBinding
<<-FN
/**
 * Find an element by exact binding.
 *
 * @view
 * <span>{{ person.name }}</span>
 * <span ng-bind="person-email"></span>
 * <span>{{person_phone|uppercase}}</span>
 *
 * @example
 * expect(element(by.exactBinding('person.name')).isPresent()).toBe(true);
 * expect(element(by.exactBinding('person-email')).isPresent()).toBe(true);
 * expect(element(by.exactBinding('person')).isPresent()).toBe(false);
 * expect(element(by.exactBinding('person_phone')).isPresent()).toBe(true);
 * expect(element(by.exactBinding('person_phone|uppercase')).isPresent()).toBe(true);
 * expect(element(by.exactBinding('phone')).isPresent()).toBe(false);
 *
 * @param {string} bindingDescriptor
 * @return {{findElementsOverride: findElementsOverride, toString: Function|string}}
 */
function(bindingDescriptor) {
  return {
    findElementsOverride: function(driver, using, rootSelector) {
      return driver.findElements(
          webdriver.By.js(clientSideScripts.findBindings,
              bindingDescriptor, true, using, rootSelector));
    },
    toString: function toString() {
      return 'by.exactBinding("' + bindingDescriptor + '")';
    }
  };
};
FN
  end

  def model
<<-FN
/**
 * Find an element by ng-model expression.
 *
 * @alias by.model(modelName)
 * @view
 * <input type="text" ng-model="person.name"/>
 *
 * @example
 * var input = element(by.model('person.name'));
 * input.sendKeys('123');
 * expect(input.getAttribute('value')).toBe('Foo123');
 *
 * @param {string} model ng-model expression.
 */
function(model) {
  return {
    findElementsOverride: function(driver, using, rootSelector) {
      return driver.findElements(
          webdriver.By.js(
              clientSideScripts.findByModel, model, using, rootSelector));
    },
    toString: function toString() {
      return 'by.model("' + model + '")';
    }
  };
};
FN
  end

  def buttonText
<<-FN
/**
 * Find a button by text.
 *
 * @view
 * <button>Save</button>
 *
 * @example
 * element(by.buttonText('Save'));
 *
 * @param {string} searchText
 * @return {{findElementsOverride: findElementsOverride, toString: Function|string}}
 */
function(searchText) {
  return {
    findElementsOverride: function(driver, using, rootSelector) {
      return driver.findElements(
          webdriver.By.js(clientSideScripts.findByButtonText,
              searchText, using, rootSelector));
    },
    toString: function toString() {
      return 'by.buttonText("' + searchText + '")';
    }
  };
};
FN
  end

  def partialButtonText
<<-FN
/**
 * Find a button by partial text.
 *
 * @view
 * <button>Save my file</button>
 *
 * @example
 * element(by.partialButtonText('Save'));
 *
 * @param {string} searchText
 * @return {{findElementsOverride: findElementsOverride, toString: Function|string}}
 */
function(searchText) {
  return {
    findElementsOverride: function(driver, using, rootSelector) {
      return driver.findElements(
          webdriver.By.js(clientSideScripts.findByPartialButtonText,
              searchText, using, rootSelector));
    },
    toString: function toString() {
      return 'by.partialButtonText("' + searchText + '")';
    }
  };
};
FN
  end

  def repeater
<<-FN
/**
 * Find elements inside an ng-repeat.
 *
 * @view
 * <div ng-repeat="cat in pets">
 *   <span>{{cat.name}}</span>
 *   <span>{{cat.age}}</span>
 * </div>
 *
 * <div class="book-img" ng-repeat-start="book in library">
 *   <span>{{$index}}</span>
 * </div>
 * <div class="book-info" ng-repeat-end>
 *   <h4>{{book.name}}</h4>
 *   <p>{{book.blurb}}</p>
 * </div>
 *
 * @example
 * // Returns the DIV for the second cat.
 * var secondCat = element(by.repeater('cat in pets').row(1));
 *
 * // Returns the SPAN for the first cat's name.
 * var firstCatName = element(by.repeater('cat in pets').
 *     row(0).column('{{cat.name}}'));
 *
 * // Returns a promise that resolves to an array of WebElements from a column
 * var ages = element.all(
 *     by.repeater('cat in pets').column('{{cat.age}}'));
 *
 * // Returns a promise that resolves to an array of WebElements containing
 * // all top level elements repeated by the repeater. For 2 pets rows resolves
 * // to an array of 2 elements.
 * var rows = element.all(by.repeater('cat in pets'));
 *
 * // Returns a promise that resolves to an array of WebElements containing all
 * // the elements with a binding to the book's name.
 * var divs = element.all(by.repeater('book in library').column('book.name'));
 *
 * // Returns a promise that resolves to an array of WebElements containing
 * // the DIVs for the second book.
 * var bookInfo = element.all(by.repeater('book in library').row(1));
 *
 * // Returns the H4 for the first book's name.
 * var firstBookName = element(by.repeater('book in library').
 *     row(0).column('{{book.name}}'));
 *
 * // Returns a promise that resolves to an array of WebElements containing
 * // all top level elements repeated by the repeater. For 2 books divs
 * // resolves to an array of 4 elements.
 * var divs = element.all(by.repeater('book in library'));
 */
function(repeatDescriptor) {
  return {
    findElementsOverride: function(driver, using, rootSelector) {
      return driver.findElements(
        webdriver.By.js(clientSideScripts.findAllRepeaterRows,
            repeatDescriptor, using, rootSelector));
    },
    toString: function toString() {
      return 'by.repeater("' + repeatDescriptor + '")';
    },
    row: function(index) {
      return {
        findElementsOverride: function(driver, using, rootSelector) {
          return driver.findElements(
            webdriver.By.js(clientSideScripts.findRepeaterRows,
                repeatDescriptor, index, using, rootSelector));
        },
        toString: function toString() {
          return 'by.repeater(' + repeatDescriptor + '").row("' + index + '")"';
        },
        column: function(binding) {
          return {
            findElementsOverride: function(driver, using, rootSelector) {
              return driver.findElements(
                  webdriver.By.js(clientSideScripts.findRepeaterElement,
                      repeatDescriptor, index, binding, using, rootSelector));
            },
            toString: function toString() {
              return 'by.repeater("' + repeatDescriptor + '").row("' + index +
                '").column("' + binding + '")';
            }
          };
        }
      };
    },
    column: function(binding) {
      return {
        findElementsOverride: function(driver, using, rootSelector) {
          return driver.findElements(
              webdriver.By.js(clientSideScripts.findRepeaterColumn,
                  repeatDescriptor, binding, using, rootSelector));
        },
        toString: function toString() {
          return 'by.repeater("' + repeatDescriptor + '").column("' +
            binding + '")';
        },
        row: function(index) {
          return {
            findElementsOverride: function(driver, using, rootSelector) {
              return driver.findElements(
                  webdriver.By.js(clientSideScripts.findRepeaterElement,
                      repeatDescriptor, index, binding, using, rootSelector));
            },
            toString: function toString() {
              return 'by.repeater("' + repeatDescriptor + '").column("' +
                binding + '").row("' + index + '")';
            }
          };
        }
      };
    }
  };
};
FN
  end

  def cssContainingText
<<-FN
/**
 * Find elements by CSS which contain a certain string.
 *
 * @view
 * <ul>
 *   <li class="pet">Dog</li>
 *   <li class="pet">Cat</li>
 * </ul>
 *
 * @example
 * // Returns the DIV for the dog, but not cat.
 * var dog = element(by.cssContainingText('.pet', 'Dog'));
 */
function(cssSelector, searchText) {
  return {
    findElementsOverride: function(driver, using, rootSelector) {
      return driver.findElements(
        webdriver.By.js(clientSideScripts.findByCssContainingText,
        cssSelector, searchText, using, rootSelector));
    },
    toString: function toString() {
      return 'by.cssContainingText("' + cssSelector + '", "' + searchText + '")';
    }
  };
};
FN
  end

  def options
<<-FN
/**
 * Find an element by ng-options expression.
 *
 * @alias by.options(optionsDescriptor)
 * @view
 * <select ng-model="color" ng-options="c for c in colors">
 *   <option value="0" selected="selected">red</option>
 *   <option value="1">green</option>
 * </select>
 *
 * @example
 * var allOptions = element.all(by.options('c for c in colors'));
 * expect(allOptions.count()).toEqual(2);
 * var firstOption = allOptions.first();
 * expect(firstOption.getText()).toEqual('red');
 *
 * @param {string} optionsDescriptor ng-options expression.
 */
function(optionsDescriptor) {
  return {
    findElementsOverride: function(driver, using, rootSelector) {
      return driver.findElements(
          webdriver.By.js(clientSideScripts.findByOptions, optionsDescriptor,
              using, rootSelector));
    },
    toString: function toString() {
      return 'by.option("' + optionsDescriptor + '")';
    }
  };
};
FN
  end
end
end
