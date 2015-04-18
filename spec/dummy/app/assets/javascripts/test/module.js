//
//= require jquery-2.1.3/jquery
//= require lodash-3.0.0/lodash
//
//= require angular-1.3.15/angular
//
"use strict";

angular.module('test', [])
.controller('TestController', function() {
  this.name = 'bar';
  this.items = [
    {
      id: 1,
      label: 'Foo'
    },
    {
      id: 2,
      label: 'Bar'
    }
  ];
});
