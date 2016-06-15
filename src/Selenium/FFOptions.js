//module Selenium.FFOptions

exports._newFFOptions = function(cb, eb) {
    try {
        var firefox = require("selenium-webdriver/firefox"),
            newOpts = new firefox.Options();
        return cb(newOpts);
    }
    catch (e) {
        return eb(e);
    }
};

exports._setBinary = function(binPath) {
    return function(opts) {
        return function(cb) {
            return cb(opts.setBinary(binPath));
        };
    };
};

exports._useMarionette = function(use) {
    return function(opts) {
        return function(cb) {
            return cb(opts.useMarionette(use));
        };
    };
};

exports._setProfile = function(profile) {
    return function(opts) {
        return function(cb) {
            return cb(opts.setProfile(profile));
        };
    };
};

exports.toCapabilities = function(opts) {
    return function(cb) {
        return cb(opts.toCapabilities());
    };
};
