// module Selenium

require("chromedriver");

var webdriver = require("selenium-webdriver"),
    By = webdriver.By,
    fs = require("fs"),
    path = require("path");

exports._get = function(driver) {
    return function(url) {
        return function(eb, cb) {
            driver.get(url).then(cb, eb);
        };
    };
};

exports._setFileDetector = function(driver) {
    return function(detector) {
        return function (eb, cb) {
            try {
                driver.setFileDetector(detector);
                return cb();
            } catch (e) {
                return eb(e);
            }
        };
    };
};

exports._wait = function(promise) {
    return function(timeout) {
        return function(driver) {
            return function(eb, cb) {
                try {
                    driver.wait(promise, timeout)
                    .then(function() {
                        promise().then(function(res) {
                            if (res) {
                                cb();
                            } else {
                                eb(new Error("wait promise has returned false"));
                            }
                        }, eb);
                    }, eb);
                }
                catch (e) {
                    eb(e);
                }
            };
        };
    };
};

exports._quit = function(driver) {
    return function(eb, cb) {
        driver.quit().then(cb,eb);
    };
};

exports._byClassName = function(className) {
    return function(eb, cb) {
        try {
            return cb(By.className(className));
        }
        catch (e) {
            return eb(e);
        }
    };
};

exports._byCss = function(selector) {
    return function(eb, cb) {
        try {
            return cb(By.css(selector));
        }
        catch (e) {
            return eb(e);
        }
    };
};

exports._byId = function(id) {
    return function(eb, cb) {
        try {
            return cb(By.id(id));
        }
        catch (e) {
            return eb(e);
        }
    };
};

exports._byName = function(name) {
    return function(eb, cb) {
        try {
            return cb(By.name(name));
        }
        catch (e) {
            return eb(e);
        }
    };
};

exports._byXPath = function(xpath) {
    return function(eb, cb) {
        try {
            return cb(By.xpath(xpath));
        }
        catch (e) {
            return eb(e);
        }
    };
};

function _find(nothing) {
    return function(just) {
        return function(driver) {
            return function(by) {
                return function(eb, cb) {
                    driver.findElement(by).then(function(el) {
                        return cb(just(el));
                    }, function() {
                        return cb(nothing);
                    });
                };
            };
        };
    };
}

function _exact(driver) {
    return function(by) {
        return function(eb, cb) {
            driver.findElement(by).then(cb, eb);
        };
    };
}

exports.showLocator = function(locator) {
  return locator.toString();
}

exports._findExact = _exact;
exports._childExact = _exact;

exports._findElement = _find;

exports._findChild = _find;

function _finds(parent) {
    return function(by) {
        return function(eb, cb) {
            return parent.findElements(by).then(function(children) {
                return cb(children);
            }, eb)
        };
    };
}

exports._findElements = _finds;
exports._findChildren = _finds;

exports._sendKeysEl = function(keys) {
    return function(el) {
        return function(eb, cb) {
            el.sendKeys(keys).then(cb, eb);
        };
    };
};

exports._getCssValue = function(el) {
    return function(str) {
        return function(eb, cb) {
            return el.getCssValue(str).then(cb, eb);
        };
    };
};

exports._getAttribute = function(nothing) {
    return function(just) {
        return function(el) {
            return function(str) {
                return function(eb, cb) {
                    return el.getAttribute(str).then(function(attr) {
                        if (attr === null) {
                            cb(nothing);
                        } else {
                            cb(just(attr));
                        }
                    }, eb);
                };
            };
        };
    };
};

exports._getText = function(el) {
    return function(eb, cb) {
        return el.getText().then(cb, eb);
    };
};

exports._isDisplayed = function(el) {
    return function(eb, cb) {
        return el.isDisplayed().then(function(is) {
            return cb(is);
        }, eb);
    };
};

exports._isEnabled = function(el) {
    return function(eb, cb) {
        return el.isEnabled().then(function(is) {
            return cb(is);
        }, eb);
    };
};

exports._getCurrentUrl = function(driver) {
    return function(eb, cb) {
        return driver.getCurrentUrl().then(cb, eb);
    };
};

exports._getTitle = function(driver) {
    return function(eb, cb) {
        return driver.getTitle().then(cb, eb);
    };
};

exports._navigateBack = function(driver) {
    return function(eb, cb) {
        var n = new webdriver.WebDriver.Navigation(driver);
        return n.back().then(cb, eb);
    };
};

exports._navigateForward = function(driver) {
    return function(eb, cb) {
        var n = new webdriver.WebDriver.Navigation(driver);
        return n.forward().then(cb, eb);
    };
};

exports._refresh = function(driver) {
    return function(eb, cb) {
        var n = new webdriver.WebDriver.Navigation(driver);
        return n.refresh().then(cb, eb);
    };
};

exports._navigateTo = function(url) {
    return function(driver) {
        return function(eb, cb) {
            var n = new webdriver.WebDriver.Navigation(driver);
            return n.to(url).then(cb, eb);
        };
    };
};


exports._getInnerHtml = function(el) {
    return function(eb, cb) {
        el.getInnerHtml().then(cb, eb);
    };
};

exports._getSize = function(el) {
    return function(eb, cb) {
        el.getSize().then(cb, eb);
    };
};

exports._getLocation = function(el) {
    return function(eb, cb) {
        el.getLocation().then(cb, eb);
    };
};

function execute(driver) {
    return function(action) {
        return function(eb, cb) {
            driver.executeScript(action).then(cb, eb);
        };
    };
}

exports._executeStr = execute;

exports._affLocator = function(elementToAff) {
    return function(eb, cb) {
        return cb(function(el) {
            return elementToAff(el)();
        });
    };
};

exports._clearEl = function(el) {
    return function(eb, cb) {
        el.clear().then(cb, eb);
    };
};

exports._clickEl = function(el) {
    return function(eb, cb) {
        el.click().then(cb, eb);
    };
};


exports._takeScreenshot = function(driver) {
    return function(eb, cb) {
        driver.takeScreenshot()
            .then(cb, eb);
    };
};


exports._saveScreenshot = function(fileName) {
    return function(driver) {
        return function(eb, cb) {
            driver.takeScreenshot()
                .then(function(str) {
                    fs.writeFile(path.resolve(fileName),
                                 str.replace(/^data:image\/png;base64,/,""),
                                 {
                                     encoding: "base64",
                                     flag: "w+"
                                 },
                                 function(err) {
                                     if (err) return eb(err);
                                     return cb();
                                 });
                }, eb);
        };
    };
};


exports._getWindow = function(window) {
    return function(eb, cb) {
        try {
            return cb(window.manage().window());
        }
        catch (e) {
            return eb(e);
        }
    };
};

exports._getWindowPosition = function(window) {
    return function(eb, cb) {
        return window.getPosition()
            .then(cb, eb);
    };
};

exports._getWindowSize = function(window) {
    return function(eb, cb) {
        return window.getSize()
            .then(cb, eb);
    };
};

exports._maximizeWindow = function(window) {
    return function(eb, cb) {
        return window.maximize()
            .then(cb, eb);
    };
};

exports._setWindowPosition = function(loc) {
    return function(window) {
        return function(eb, cb) {
            return window.setPosition(loc.x, loc.y)
                .then(cb, eb);
        };
    };
};

exports._setWindowSize = function(size) {
    return function(window) {
        return function(eb, cb) {
            return window.setSize(size.width, size.height)
                .then(cb, eb);
        };
    };
};

exports._getWindowScroll = function(driver) {
    return function(eb, cb) {
        driver.executeScript(function() {
            return {
                x: window.scrollX,
                y: window.scrollY
            };
        }).then(cb, eb);
    };
};

exports._getWindowHandle = function(driver) {
    return function(eb, cb) {
        driver.getWindowHandle().then(cb, eb);
    };
};

exports._getAllWindowHandles = function(driver) {
    return function(eb, cb) {
        driver.getAllWindowHandles().then(cb, eb);
    };
};

exports._switchTo = function(handle) {
    return function(driver) {
        return function(eb, cb) {
            return driver.switchTo().window(handle).then(cb, eb);
        };
    };
};

exports._close = function(driver) {
    return function(eb, cb) {
        return driver.close().then(cb, eb);
    };
};
