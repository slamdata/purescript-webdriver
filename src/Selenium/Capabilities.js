// module Selenium.Capabilities

exports.emptyCapabilities = {};

exports.appendCapabilities = function(first) {
    return function(second) {
        var i, key,
            firstKeys = Object.keys(first),
            secondKeys = Object.keys(second),
            result = {};
        for (i = 0; i < firstKeys.length; i++) {
            key = firstKeys[i];
            if (first.hasOwnProperty(key)) {
                result[key] = first[key];
            }
        }
        for (i = 0; i < secondKeys.length; i++) {
            key = secondKeys[i];
            if (second.hasOwnProperty(key)) {
                result[key] = second[key];
            }
        }
        return result;
    };
};
