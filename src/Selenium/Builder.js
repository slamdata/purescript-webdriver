// module Selenium.Builder

var webdriver = require("selenium-webdriver");

exports._newBuilder = function(eb, cb) {
    try {
        return cb(new webdriver.Builder());
    }
    catch (e) {
        return eb(e);
    }
};

exports._build = function(builder) {
    return function(eb, cb) {
        builder.build().then(cb, eb);
    };
};

exports._usingServer = function(b, s) {
    return b.usingServer(s);
};

exports._setScrollBehaviour = function(b, bh) {
    return b.setScrollBehaviour(bh);
};

exports._withCapabilities = function(b, c) {
    return b.withCapabilities(c);
};
