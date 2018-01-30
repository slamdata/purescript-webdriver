// module Selenium.ActionSequence
var webdriver = require("selenium-webdriver");

exports._newSequence = function(driver) {
    return function(eb, cb) {
        try {
            return cb(new webdriver.ActionSequence(driver));
        }
        catch (e) {
            return eb(e);
        }
    };
};

exports._performSequence = function(sequence) {
    return function(eb, cb) {
        try {
            return sequence.perform().then(cb, eb);
        }
        catch (e) {
            return eb(e);
        }
    };
};

exports._click = function(seq, btn, el) {
    return seq.click(el, btn);
};
exports._doubleClick = function(seq, btn, el) {
    return seq.doubleClick(el, btn);
};
exports._mouseToElement = function(seq, el) {
    return seq.mouseMove(el);
};
exports._mouseToLocation = function(seq, loc) {
    return seq.mouseMove(loc);
};
exports._mouseDown = function(seq, btn, el) {
    return seq.mouseDown(el, btn);
};
exports._mouseUp = function(seq, btn, el) {
    return seq.mouseUp(el, btn);
};
exports._keyDown = function(seq, key) {
    return seq.keyDown(key);
};
exports._keyUp = function(seq, key) {
    return seq.keyUp(key);
};
exports._sendKeys = function(seq, keys) {
    return seq.sendKeys(keys);
};
exports._dndToElement = function(seq, el, tgt) {
    return seq.dragAndDrop(el, tgt);
};
exports._dndToLocation = function(seq, el, tgt) {
    return seq.dragAndDrop(el, tgt);
};
