// module Selenium.Remote

var remote = require('selenium-webdriver/remote');

exports.fileDetector = function () {
  return new remote.FileDetector();
};
