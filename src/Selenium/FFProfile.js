// module Selenium.FFProfile

exports._newFFProfile = function(cb, eb) {
    var FirefoxProfile = require('selenium-webdriver/firefox/profile.js').Profile;
    return cb(new FirefoxProfile());
};

exports._setFFPreference = function(key) {
    return function(val) {
        return function(p) {
            p.setPreference(key, val);
            return p;
        };
    };
};

exports._encode = function(p) {
    return function(cb, eb) {
        p.encode()
            .then(function(c) { return cb({firefox_profile: c});})
            .thenCatch(eb);
    };
};
