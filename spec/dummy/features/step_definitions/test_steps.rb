Given(/^I am testing angularJS$/) do
  ng_root_selector '#app'
  visit 'http://localhost:4000'
end

Then(/^I will try to evaluate expression$/) do
  expect(ng_eval('1 + 1')).to be 2
end
