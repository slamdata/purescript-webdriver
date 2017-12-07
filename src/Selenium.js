// module Selenium

require("chromedriver");

var webdriver = require("selenium-webdriver"),
    By = webdriver.By,
    fs = require("fs"),
    path = require("path");

exports.get = function(driver) {
    return function(url) {
        return function(cb, eb) {
            driver.get(url).then(cb, eb);
        };
    };
};

exports.setFileDetector = function(driver) {
    return function(detector) {
        return function (cb, eb) {
            try {
                driver.setFileDetector(detector);
                return cb();
            } catch (e) {
                return eb(e);
            }
        };
    };
};

exports.wait = function(check) {
    return function(timeout) {
        return function(driver) {
            return function(cb, eb) {
                var p = new webdriver.promise.Promise(check);
                driver.wait(p, timeout)
                    .then(function() {
                        p.then(function(res) {
                            if (res) {
                                cb();
                            } else {
                                eb(new Error("wait promise has returned false"));
                            }
                        }, eb);
                    }, eb);
            };
        };
    };
};

exports.quit = function(driver) {
    return function(cb, eb) {
        driver.quit().then(cb,eb);
    };
};

exports.byClassName = function(className) {
    return function(cb, eb) {
        try {
            return cb(By.className(className));
        }
        catch (e) {
            return eb(e);
        }
    };
};

exports.byCss = function(selector) {
    return function(cb, eb) {
        try {
            return cb(By.css(selector));
        }
        catch (e) {
            return eb(e);
        }
    };
};

exports.byId = function(id) {
    return function(cb, eb) {
        try {
            return cb(By.id(id));
        }
        catch (e) {
            return eb(e);
        }
    };
};

exports.byName = function(name) {
    return function(cb, eb) {
        try {
            return cb(By.name(name));
        }
        catch (e) {
            return eb(e);
        }
    };
};

exports.byXPath = function(xpath) {
    return function(cb, eb) {
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
                return function(cb) {
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
        return function(cb, eb) {
            driver.findElement(by).then(cb, eb);
        };
    };
}

exports.showLocator = function(locator) {
  return locator.toString();
}

exports.findExact = _exact;
exports.childExact = _exact;

exports._findElement = _find;

exports._findChild = _find;

function _finds(parent) {
    return function(by) {
        return function(cb, eb) {
            return parent.findElements(by).then(function(children) {
                return cb(children);
            }, eb)
        };
    };
}

exports._findElements = _finds;
exports._findChildren = _finds;

exports.sendKeysEl = function(keys) {
    return function(el) {
        return function(cb, eb) {
            el.sendKeys(keys).then(cb, eb);
        };
    };
};

exports.getCssValue = function(el) {
    return function(str) {
        return function(cb, eb) {
            return el.getCssValue(str).then(cb, eb);
        };
    };
};

exports._getAttribute = function(nothing) {
    return function(just) {
        return function(el) {
            return function(str) {
                return function(cb, eb) {
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

exports.getText = function(el) {
    return function(cb, eb) {
        return el.getText().then(cb, eb);
    };
};

exports.isDisplayed = function(el) {
    return function(cb, eb) {
        return el.isDisplayed().then(function(is) {
            return cb(is);
        }, eb);
    };
};

exports.isEnabled = function(el) {
    return function(cb, eb) {
        return el.isEnabled().then(function(is) {
            return cb(is);
        }, eb);
    };
};

exports.getCurrentUrl = function(driver) {
    return function(cb, eb) {
        return driver.getCurrentUrl().then(cb, eb);
    };
};

exports.getTitle = function(driver) {
    return function(cb, eb) {
        return driver.getTitle().then(cb, eb);
    };
};

exports.navigateBack = function(driver) {
    return function(cb, eb) {
        var n = new webdriver.WebDriver.Navigation(driver);
        return n.back().then(cb, eb);
    };
};

exports.navigateForward = function(driver) {
    return function(cb, eb) {
        var n = new webdriver.WebDriver.Navigation(driver);
        return n.forward().then(cb, eb);
    };
};

exports.refresh = function(driver) {
    return function(cb, eb) {
        var n = new webdriver.WebDriver.Navigation(driver);
        return n.refresh().then(cb, eb);
    };
};

exports.navigateTo = function(url) {
    return function(driver) {
        return function(cb, eb) {
            var n = new webdriver.WebDriver.Navigation(driver);
            return n.to(url).then(cb, eb);
        };
    };
};


exports.getInnerHtml = function(el) {
    return function(cb, eb) {
        el.getInnerHtml().then(cb, eb);
    };
};

exports.getSize = function(el) {
    return function(cb, eb) {
        el.getSize().then(cb, eb);
    };
};

exports.getLocation = function(el) {
    return function(cb, eb) {
        el.getLocation().then(cb, eb);
    };
};

function execute(driver) {
    return function(action) {
        return function(cb, eb) {
            driver.executeScript(action).then(cb, eb);
        };
    };
}

exports.executeStr = execute;

exports.affLocator = function(aff) {
    return function(cb, eb) {
        return cb(function(el) {
            return new webdriver.promise.Promise(aff(el));
        });
    };
};

exports.clearEl = function(el) {
    return function(cb, eb) {
        el.clear().then(cb, eb);
    };
};

exports.clickEl = function(el) {
    return function(cb, eb) {
        el.click().then(cb, eb);
    };
};


exports.takeScreenshot = function(driver) {
    return function(cb, eb) {
        driver.takeScreenshot()
            .then(cb, eb);
    };
};


exports.saveScreenshot = function(fileName) {
    return function(driver) {
        return function(cb, eb) {
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


exports.getWindow = function(window) {
    return function(cb, eb) {
        try {
            return cb(window.manage().window());
        }
        catch (e) {
            return eb(e);
        }
    };
};

exports.getWindowPosition = function(window) {
    return function(cb, eb) {
        return window.getPosition()
            .then(cb, eb);
    };
};

exports.getWindowSize = function(window) {
    return function(cb, eb) {
        return window.getSize()
            .then(cb, eb);
    };
};

exports.maximizeWindow = function(window) {
    return function(cb, eb) {
        return window.maximize()
            .then(cb, eb);
    };
};

exports.setWindowPosition = function(loc) {
    return function(window) {
        return function(cb, eb) {
            return window.setPosition(loc.x, loc.y)
                .then(cb, eb);
        };
    };
};

exports.setWindowSize = function(size) {
    return function(window) {
        return function(cb, eb) {
            return window.setSize(size.width, size.height)
                .then(cb, eb);
        };
    };
};

exports.getWindowScroll = function(driver) {
    return function(cb, eb) {
        driver.executeScript(function() {
            return {
                x: window.scrollX,
                y: window.scrollY
            };
        }).then(cb, eb);
    };
};

exports.getWindowHandle = function(driver) {
    return function(cb, eb) {
        driver.getWindowHandle().then(cb, eb);
    };
};

exports._getAllWindowHandles = function(driver) {
    return function(cb, eb) {
        driver.getAllWindowHandles().then(cb, eb);
    };
};

exports.switchTo = function(handle) {
    return function(driver) {
        return function(cb, eb) {
            return driver.switchTo().window(handle).then(cb, eb);
        };
    };
};

exports.switchToActiveElement = function(driver) {
    return function(cb, eb) {
        return driver.switchTo().activeElement().then(cb, eb);
    };
};

exports.close = function(driver) {
    return function(cb, eb) {
        return driver.close().then(cb, eb);
    };
};
