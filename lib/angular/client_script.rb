module Angular
module ClientScript
#
# Log calls
#
  FN_nglog = <<-FN
function(method, params) {
  console.log('NG: ' + method + '(' + params.join(', ') + ')')
};
FN

# /**
#  * Wait until Angular has finished rendering and has
#  * no outstanding $http calls before continuing.
#  *
#  * Asynchronous.
#  *
#  * @param {string} selector The selector housing an ng-app
#  * @param {function} callback callback
#  */
  FN_waitForAngular = <<-FN
function(selector, callback) {
  nglog("waitForAngular", [selector, callback]);

  var el = document.querySelector(selector);
  return el;
  try {
    if (angular.getTestability) {
      angular.getTestability(el).whenStable(callback);
    } else {
      angular.element(el).injector().get('$browser').
          notifyWhenNoOutstandingRequests(callback);
    }
  } catch (e) {
    callback(e);
  }
};
FN

# /**
#  * Find a list of elements in the page by their angular binding.
#  *
#  * @param {string} binding The binding, e.g. {{cat.name}}.
#  * @param {boolean} exactMatch Whether the binding needs to be matched exactly
#  * @param {Element} using The scope of the search.
#  * @param {string} rootSelector The selector to use for the root app element.
#  *
#  * @return {Array.<Element>} The elements containing the binding.
#  */
  FN_findBindings = <<-FN
function(binding, exactMatch, using, rootSelector) {
  nglog("findBindings", [binding, exactMatch, using, rootSelector]);

  rootSelector = rootSelector || 'body';
  using = using || document.querySelector(rootSelector);

  if (angular.getTestability) {
    return angular.getTestability(using).
        findBindings(using, binding, exactMatch);
  }

  var bindings = using.getElementsByClassName('ng-binding');
  var matches = [];
  for (var i = 0; i < bindings.length; ++i) {
    var dataBinding = angular.element(bindings[i]).data('$binding');
    if(dataBinding) {
      var bindingName = dataBinding.exp || dataBinding[0].exp || dataBinding;
      if (exactMatch) {
        var matcher = new RegExp('({|\\\\s|$|\\\\|)' + binding + '(}|\\\\s|^|\\\\|)');
        if (matcher.test(bindingName)) {
          matches.push(bindings[i]);
        }
      } else {
        if (bindingName.indexOf(binding) != -1) {
          matches.push(bindings[i]);
        }
      }

    }
  }
  return matches; /* Return the whole array for webdriver.findElements. */
};
FN

# /**
#  * Find a list of element Ids in the page by their angular binding.
#  *
#  * @param {string} binding The binding, e.g. {{cat.name}}.
#  * @param {boolean} exactMatch Whether the binding needs to be matched exactly
#  * @param {Element} using The scope of the search.
#  * @param {string} rootSelector The selector to use for the root app element.
#  *
#  * @return {Array.<Element>} The elements containing the binding.
#  */
  FN_findBindingsIds = <<-FN
function(binding, exactMatch, using, rootSelector) {
  nglog("findBindingsIds", [binding, exactMatch, using, rootSelector]);

  var elements = findBindings(binding, exactMatch, using, rootSelector);
  return createCapybaraNgMatches(elements);
};
FN

# /**
#  * Find an array of elements matching a row within an ng-repeat.
#  * Always returns an array of only one element for plain old ng-repeat.
#  * Returns an array of all the elements in one segment for ng-repeat-start.
#  *
#  * @param {string} repeater The text of the repeater, e.g. 'cat in cats'.
#  * @param {number} index The row index.
#  * @param {Element} using The scope of the search.
#  * @param {string} rootSelector The selector to use for the root app element.
#  *
#  * @return {Array.<Element>} The row of the repeater, or an array of elements
#  *     in the first row in the case of ng-repeat-start.
#  */
  FN_findRepeaterRows = <<-FN
function(repeater, index, using, rootSelector) {
  console.log("findRepeaterRows", repeater, index, using, rootSelector);

  rootSelector = rootSelector || 'body';
  using = using || document.querySelector(rootSelector);

  var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\\\:'];
  var rows = [];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeatElems[i].getAttribute(attr).indexOf(repeater) != -1) {
        rows.push(repeatElems[i]);
      }
    }
  }
  /* multiRows is an array of arrays, where each inner array contains
     one row of elements. */
  var multiRows = [];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat-start';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeatElems[i].getAttribute(attr).indexOf(repeater) != -1) {
        var elem = repeatElems[i];
        var row = [];
        while (elem.nodeType != 8 ||
            elem.nodeValue.indexOf(repeater) == -1) {
          if (elem.nodeType == 1) {
            row.push(elem);
          }
          elem = elem.nextSibling;
        }
        multiRows.push(row);
      }
    }
  }
  return [rows[index]].concat(multiRows[index]);
};
FN

# /**
#  * Find an array of element ids matching a row within an ng-repeat.
#  * Always returns an array of only one element for plain old ng-repeat.
#  * Returns an array of all the elements in one segment for ng-repeat-start.
#  *
#  * @param {string} repeater The text of the repeater, e.g. 'cat in cats'.
#  * @param {number} index The row index.
#  * @param {Element} using The scope of the search.
#  * @param {string} rootSelector The selector to use for the root app element.
#  *
#  * @return {Array.<Element>} The row of the repeater, or an array of elements
#  *     in the first row in the case of ng-repeat-start.
#  */
  FN_findRepeaterRowsIds = <<-FN
function(repeater, index, using, rootSelector) {
  nglog("findRepeaterRowsIds", [repeater, index, using, rootSelector]);

  var elements = findRepeaterRows(repeater, index, using, rootSelector);
  return createCapybaraNgMatches(elements);
};
FN

 # /**
 # * Find all rows of an ng-repeat.
 # *
 # * @param {string} repeater The text of the repeater, e.g. 'cat in cats'.
 # * @param {Element} using The scope of the search.
 # * @param {string} rootSelector The selector to use for the root app element.
 # *
 # * @return {Array.<Element>} All rows of the repeater.
 # */
  FN_findAllRepeaterRows = <<-FN
function(repeater, using, rootSelector) {
  nglog("findAllRepeaterRows", [repeater, using, rootSelector]);

  rootSelector = rootSelector || 'body';
  using = using || document.querySelector(rootSelector);

  var rows = [];
  var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\\\:'];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeatElems[i].getAttribute(attr).indexOf(repeater) != -1) {
        rows.push(repeatElems[i]);
      }
    }
  }
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat-start';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeatElems[i].getAttribute(attr).indexOf(repeater) != -1) {
        var elem = repeatElems[i];
        while (elem.nodeType != 8 ||
            elem.nodeValue.indexOf(repeater) == -1) {
          if (elem.nodeType == 1) {
            rows.push(elem);
          }
          elem = elem.nextSibling;
        }
      }
    }
  }
  return rows;
};
FN

 # /**
 # * Find all rows ids of an ng-repeat.
 # *
 # * @param {string} repeater The text of the repeater, e.g. 'cat in cats'.
 # * @param {Element} using The scope of the search.
 # * @param {string} rootSelector The selector to use for the root app element.
 # *
 # * @return {Array.<Element>} All rows of the repeater.
 # */
  FN_findAllRepeaterRowsIds = <<-FN
function(repeater, using, rootSelector) {
  nglog("findAllRepeaterRowsIds", [repeater, using, rootSelector]);

  var elements = findAllRepeaterRows(repeater, using, rootSelector);
  return createCapybaraNgMatches(elements);
};
FN

# /**
#  * Find an element within an ng-repeat by its row and column.
#  *
#  * @param {string} repeater The text of the repeater, e.g. 'cat in cats'.
#  * @param {number} index The row index.
#  * @param {string} binding The column binding, e.g. '{{cat.name}}'.
#  * @param {Element} using The scope of the search.
#  * @param {string} rootSelector The selector to use for the root app element.
#  *
#  * @return {Array.<Element>} The element in an array.
#  */
  FN_findRepeaterElement = <<-FN
function(repeater, index, binding, using, rootSelector) {
  nglog("findRepeaterElement", [repeater, index, binding, using, rootSelector]);

  var matches = [];
  rootSelector = rootSelector || 'body';
  using = using || document.querySelector(rootSelector);

  var rows = [];
  var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\\\:'];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeatElems[i].getAttribute(attr).indexOf(repeater) != -1) {
        rows.push(repeatElems[i]);
      }
    }
  }
  /* multiRows is an array of arrays, where each inner array contains
     one row of elements. */
  var multiRows = [];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat-start';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeatElems[i].getAttribute(attr).indexOf(repeater) != -1) {
        var elem = repeatElems[i];
        var row = [];
        while (elem.nodeType != 8 ||
            (elem.nodeValue && elem.nodeValue.indexOf(repeater) == -1)) {
          if (elem.nodeType == 1) {
            row.push(elem);
          }
          elem = elem.nextSibling;
        }
        multiRows.push(row);
      }
    }
  }
  var row = rows[index];
  var multiRow = multiRows[index];
  var bindings = [];
  if (row) {
    if (angular.getTestability) {
      matches.push.apply(
          matches,
          angular.getTestability(using).findBindings(row, binding));
    } else {
      if (row.className.indexOf('ng-binding') != -1) {
        bindings.push(row);
      }
      var childBindings = row.getElementsByClassName('ng-binding');
      for (var i = 0; i < childBindings.length; ++i) {
        bindings.push(childBindings[i]);
      }
    }
  }
  if (multiRow) {
    for (var i = 0; i < multiRow.length; ++i) {
      var rowElem = multiRow[i];
      if (angular.getTestability) {
        matches.push.apply(
            matches,
            angular.getTestability(using).findBindings(rowElem, binding));
      } else {
        if (rowElem.className.indexOf('ng-binding') != -1) {
          bindings.push(rowElem);
        }
        var childBindings = rowElem.getElementsByClassName('ng-binding');
        for (var j = 0; j < childBindings.length; ++j) {
          bindings.push(childBindings[j]);
        }
      }
    }
  }
  for (var i = 0; i < bindings.length; ++i) {
    var dataBinding = angular.element(bindings[i]).data('$binding');
    if(dataBinding) {
      var bindingName = dataBinding.exp || dataBinding[0].exp || dataBinding;
      if (bindingName.indexOf(binding) != -1) {
        matches.push(bindings[i]);
      }
    }
  }
  return matches;
};
FN

# /**
#  * Find an element ids within an ng-repeat by its row and column.
#  *
#  * @param {string} repeater The text of the repeater, e.g. 'cat in cats'.
#  * @param {number} index The row index.
#  * @param {string} binding The column binding, e.g. '{{cat.name}}'.
#  * @param {Element} using The scope of the search.
#  * @param {string} rootSelector The selector to use for the root app element.
#  *
#  * @return {Array.<Element>} The element in an array.
#  */
  FN_findRepeaterElementIds = <<-FN
function(repeater, index, binding, using, rootSelector) {
  nglog("findRepeaterElementIds", [repeater, index, binding, using, rootSelector]);

  var elements = findRepeaterElement(repeater, index, binding, using, rootSelector);
  return createCapybaraNgMatches(elements);
};
FN

# /**
#  * Find the elements in a column of an ng-repeat.
#  *
#  * @param {string} repeater The text of the repeater, e.g. 'cat in cats'.
#  * @param {string} binding The column binding, e.g. '{{cat.name}}'.
#  * @param {Element} using The scope of the search.
#  * @param {string} rootSelector The selector to use for the root app element.
#  *
#  * @return {Array.<Element>} The elements in the column.
#  */
  FN_findRepeaterColumn = <<-FN
function(repeater, binding, using, rootSelector) {
  nglog("findRepeaterColumn", [repeater, binding, using, rootSelector]);

  var matches = [];
  rootSelector = rootSelector || 'body';
  using = using || document.querySelector(rootSelector);

  var rows = [];
  var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\\\:'];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeatElems[i].getAttribute(attr).indexOf(repeater) != -1) {
        rows.push(repeatElems[i]);
      }
    }
  }
  /* multiRows is an array of arrays, where each inner array contains
     one row of elements. */
  var multiRows = [];
  for (var p = 0; p < prefixes.length; ++p) {
    var attr = prefixes[p] + 'repeat-start';
    var repeatElems = using.querySelectorAll('[' + attr + ']');
    attr = attr.replace(/\\\\/g, '');
    for (var i = 0; i < repeatElems.length; ++i) {
      if (repeatElems[i].getAttribute(attr).indexOf(repeater) != -1) {
        var elem = repeatElems[i];
        var row = [];
        while (elem.nodeType != 8 ||
            (elem.nodeValue && elem.nodeValue.indexOf(repeater) == -1)) {
          if (elem.nodeType == 1) {
            row.push(elem);
          }
          elem = elem.nextSibling;
        }
        multiRows.push(row);
      }
    }
  }
  var bindings = [];
  for (var i = 0; i < rows.length; ++i) {
    if (angular.getTestability) {
      matches.push.apply(
          matches,
          angular.getTestability(using).findBindings(rows[i], binding));
    } else {
      if (rows[i].className.indexOf('ng-binding') != -1) {
        bindings.push(rows[i]);
      }
      var childBindings = rows[i].getElementsByClassName('ng-binding');
      for (var k = 0; k < childBindings.length; ++k) {
        bindings.push(childBindings[k]);
      }
    }
  }
  for (var i = 0; i < multiRows.length; ++i) {
    for (var j = 0; j < multiRows[i].length; ++j) {
      if (angular.getTestability) {
        matches.push.apply(
            matches,
            angular.getTestability(using).findBindings(multiRows[i][j], binding));
      } else {
        var elem = multiRows[i][j];
        if (elem.className.indexOf('ng-binding') != -1) {
          bindings.push(elem);
        }
        var childBindings = elem.getElementsByClassName('ng-binding');
        for (var k = 0; k < childBindings.length; ++k) {
          bindings.push(childBindings[k]);
        }
      }
    }
  }
  for (var j = 0; j < bindings.length; ++j) {
    var dataBinding = angular.element(bindings[j]).data('$binding');
    if (dataBinding) {
      var bindingName = dataBinding.exp || dataBinding[0].exp || dataBinding;
      if (bindingName.indexOf(binding) != -1) {
        matches.push(bindings[j]);
      }
    }
  }
  return matches;
};
FN

# /**
#  * Find the elements in a column of an ng-repeat.
#  *
#  * @param {string} repeater The text of the repeater, e.g. 'cat in cats'.
#  * @param {string} binding The column binding, e.g. '{{cat.name}}'.
#  * @param {Element} using The scope of the search.
#  * @param {string} rootSelector The selector to use for the root app element.
#  *
#  * @return {Array.<Element>} The elements in the column.
#  */
  FN_findRepeaterColumnIds = <<-FN
function(repeater, binding, using, rootSelector) {
  nglog("findRepeaterColumnIds", [repeater, binding, using, rootSelector]);

  var elements = findRepeaterColumn(repeater, binding, using, rootSelector);
  return createCapybaraNgMatches(elements);
};
FN

# /**
#  * Find elements by model name.
#  *
#  * @param {string} model The model name.
#  * @param {Element} using The scope of the search.
#  * @param {string} rootSelector The selector to use for the root app element.
#  *
#  * @return {Array.<Element>} The matching elements.
#  */
  FN_findByModel = <<-FN
function(model, using, rootSelector) {
  nglog("findByModel", [model, using, rootSelector]);

  rootSelector = rootSelector || 'body';
  using = using || document.querySelector(rootSelector);

  if (angular.getTestability) {
    return angular.getTestability(using).
        findModels(using, model, true);
  }

  var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\\\:'];
  for (var p = 0; p < prefixes.length; ++p) {
    var selector = '[' + prefixes[p] + 'model="' + model + '"]';
    var elements = using.querySelectorAll(selector);
    if (elements.length) {
      return elements;
    }
  }
};
FN

# /**
#  * Find element ids by model name.
#  *
#  * @param {string} model The model name.
#  * @param {Element} using The scope of the search.
#  * @param {string} rootSelector The selector to use for the root app element.
#  *
#  * @return {Array.<Element>} The matching elements.
#  */
  FN_findByModelIds = <<-FN
function(model, using, rootSelector) {
  nglog("findByModelIds", [model, using, rootSelector]);

  var elements = findByModel(model, using, rootSelector);
  return createCapybaraNgMatches(elements);
};
FN

# /**
#  * Find elements by options.
#  *
#  * @param {string} optionsDescriptor The descriptor for the option
#  *     (i.e. fruit for fruit in fruits).
#  * @param {Element} using The scope of the search.
#  * @param {string} rootSelector The selector to use for the root app element.
#  *
#  * @return {Array.<Element>} The matching elements.
#  */
  FN_findByOptions = <<-FN
function(optionsDescriptor, using, rootSelector) {
  nglog("findByOptions", [optionsDescriptor, using, rootSelector]);

  rootSelector = rootSelector || 'body';
  using = using || document.querySelector(rootSelector);

  var prefixes = ['ng-', 'ng_', 'data-ng-', 'x-ng-', 'ng\\\\:'];
  for (var p = 0; p < prefixes.length; ++p) {
    var selector = '[' + prefixes[p] + 'options="' + optionsDescriptor + '"] option';
    var elements = using.querySelectorAll(selector);
    if (elements.length) {
      return elements;
    }
  }
};
FN

# /**
#  * Find elements by options.
#  *
#  * @param {string} optionsDescriptor The descriptor for the option
#  *     (i.e. fruit for fruit in fruits).
#  * @param {Element} using The scope of the search.
#  * @param {string} rootSelector The selector to use for the root app element.
#  *
#  * @return {Array.<Element>} The matching elements.
#  */
  FN_findByOptionsIds = <<-FN
function(optionsDescriptor, using, rootSelector) {
  nglog("findByOptionsIds", [optionsDescriptor, using, rootSelector]);

  var elements = findByOptions(optionsDescriptor, using, rootSelector);
  return createCapybaraNgMatches(elements);
};
FN

# /**
#  * Find buttons by textual content.
#  *
#  * @param {string} searchText The exact text to match.
#  * @param {Element} using The scope of the search.
#  * @param {string} rootSelector The selector to use for the root app element.
#  *
#  * @return {Array.<Element>} The matching elements.
#  */
  FN_findByButtonText = <<-FN
function(searchText, using, rootSelector) {
  nglog("findByButtonText", [searchText, using, rootSelector]);

  rootSelector = rootSelector || 'body';
  using = using || document.querySelector(rootSelector);

  var elements = using.querySelectorAll('button, input[type="button"], input[type="submit"]');
  var matches = [];
  for (var i = 0; i < elements.length; ++i) {
    var element = elements[i];
    var elementText;
    if (element.tagName.toLowerCase() == 'button') {
      elementText = element.innerText || element.textContent;
    } else {
      elementText = element.value;
    }
    if (elementText.trim() === searchText) {
      matches.push(element);
    }
  }

  return matches;
};
FN

# /**
#  * Find buttons by textual content.
#  *
#  * @param {string} searchText The exact text to match.
#  * @param {Element} using The scope of the search.
#  * @param {string} rootSelector The selector to use for the root app element.
#  *
#  * @return {Array.<Element>} The matching elements.
#  */
  FN_findByPartialButtonText = <<-FN
function(searchText, using, rootSelector) {
  nglog("findByPartialButtonText", [searchText, using, rootSelector]);

  rootSelector = rootSelector || 'body';
  using = using || document.querySelector(rootSelector);

  var elements = using.querySelectorAll('button, input[type="button"], input[type="submit"]');
  var matches = [];
  for (var i = 0; i < elements.length; ++i) {
    var element = elements[i];
    var elementText;
    if (element.tagName.toLowerCase() == 'button') {
      elementText = element.innerText || element.textContent;
    } else {
      elementText = element.value;
    }
    if (elementText.indexOf(searchText) > -1) {
      matches.push(element);
    }
  }

  return matches;
};
FN

# /**
#  * Find elements by css selector and textual content.
#  *
#  * @param {string} cssSelector The css selector to match.
#  * @param {string} searchText The exact text to match.
#  * @param {Element} using The scope of the search.
#  * @param {string} rootSelector The selector to use for the root app element.
#  *
#  * @return {Array.<Element>} An array of matching elements.
#  */
  FN_findByCssContainingText = <<-FN
function(cssSelector, searchText, using, rootSelector) {
  nglog("findByCssContainingText", [cssSelector, searchText, using, rootSelector]);

  rootSelector = rootSelector || 'body';
  using = using || document.querySelector(rootSelector);

  var elements = using.querySelectorAll(cssSelector);
  var matches = [];
  for (var i = 0; i < elements.length; ++i) {
    var element = elements[i];
    var elementText = element.innerText || element.textContent;
    if (elementText.indexOf(searchText) > -1) {
      matches.push(element);
    }
  }
  return matches;
};
FN

# /**
#  * Tests whether the angular global variable is present on a page. Retries
#  * in case the page is just loading slowly.
#  *
#  * Asynchronous.
#  *
#  * @param {number} attempts Number of times to retry.
#  * @param {function} asyncCallback callback
#  */
  FN_testForAngular = <<-FN
function(attempts, asyncCallback) {
  nglog("testForAngular", [attempts, asyncCallback]);

  var callback = function(args) {
    setTimeout(function() {
      asyncCallback(args);
    }, 0);
  };
  var check = function(n) {
    try {
      if (window.angular && window.angular.resumeBootstrap) {
        callback([true, null]);
      } else if (n < 1) {
        if (window.angular) {
          callback([false, 'angular never provided resumeBootstrap']);
        } else {
          callback([false, 'retries looking for angular exceeded']);
        }
      } else {
        window.setTimeout(function() {check(n - 1);}, 1000);
      }
    } catch (e) {
      callback([false, e]);
    }
  };
  check(attempts);
};
FN

# /**
#  * Evalute an Angular expression in the context of a given element.
#  *
#  * @param {Element} element The element in whose scope to evaluate.
#  * @param {string} expression The expression to evaluate.
#  *
#  * @return {?Object} The result of the evaluation.
#  */
  FN_evaluate = <<-FN
function(element, expression) {
  nglog("evaluate", [element, expression]);

  return angular.element(element).scope().$eval(expression);
};
FN

  FN_allowAnimations = <<-FN
function(element, value) {
  nglog("allowAnimations", [element, value]);

  var ngElement = angular.element(element);
  if (ngElement.allowAnimations) {
    // AngularDart: $testability API.
    return ngElement.allowAnimations(value);
  } else {
    // AngularJS
    var enabledFn = ngElement.injector().get('$animate').enabled;
    return (value == null) ? enabledFn() : enabledFn(value);
  }
};
FN

# /**
#  * Return the current url using $location.absUrl().
#  *
#  * @param {string} selector The selector housing an ng-app
#  */
  FN_getLocationAbsUrl = <<-FN
function(selector) {
  nglog("getLocationAbsUrl", [selector]);

  var el = document.querySelector(selector);
  if (angular.getTestability) {
    return angular.getTestability(el).
        getLocation();
  }
  return angular.element(el).injector().get('$location').absUrl();
};
FN

# /**
#  * Get current location
#  *
#  * @param {string} selector The selector housing an ng-app
#  * @param {string} url In page URL using the same syntax as $location.url(),
#  *     /path?search=a&b=c#hash
#  */
  FN_getLocation = <<-FN
function(selector) {
  nglog("getLocation", [selector]);

  var el = document.querySelector(selector);
  var $injector = angular.element(el).injector();
  var $location = $injector.get('$location');
  return $location.url();
};
FN

# /**
#  * Browse to another page using in-page navigation.
#  *
#  * @param {string} selector The selector housing an ng-app
#  * @param {string} url In page URL using the same syntax as $location.url(),
#  *     /path?search=a&b=c#hash
#  */
  FN_setLocation = <<-FN
function(selector, url) {
  nglog("setLocation", [selector, url]);

  var el = document.querySelector(selector);
  if (angular.getTestability) {
    return angular.getTestability(el).
        setLocation(url);
  }
  var $injector = angular.element(el).injector();
  var $location = $injector.get('$location');
  var $rootScope = $injector.get('$rootScope');

  if (url !== $location.url()) {
    $location.url(url);
    $rootScope.$digest();
  }
  return $location.url();
};
FN

  def self.functions
    Hash[
      self.constants.map do |cn|
        name = cn.to_s
        name = name[3, name.length].to_sym
        [name, self.const_get(cn)]
      end
    ]
  end

  def self.format_script(name, fn)
    "try { return (#{fn}).apply(this, arguments); }\n" +
    "catch(e) { throw (e instanceof Error) ? e : new Error(e); }"
  end

  def self.format_scripts
    Hash[
      functions.map do |name, fn|
        [name, format_script(name,fn)]
      end
    ]
  end

  def self.window_scripts
    functions
      .map { |name, fn| "window.#{name} = #{fn};" }
  end

end
end
