// module Selenium.Browser

exports._browserCapabilities = function(br) {
    return {browserName: br};
};

exports.versionCapabilities = function(v) {
    return {version: v};
};

exports.platformCapabilities = function(p) {
    return {platform: p};
};
