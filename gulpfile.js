"use strict"

var gulp = require("gulp"),
    purescript = require("gulp-purescript");

var sources = [
    "src/**/*.purs",
    "bower_components/purescript-*/src/**/*.purs"
];
var foreigns = [
    "src/**/*.js",
    "bower_components/purescript-*/src/**/*.js"
];

var exampleSources = [
    "example/src/**/*.purs"
];

var exampleForeigns = [
    "example/src/**/*.js"
];

gulp.task("make", function() {
    return purescript.psc({
        src: sources,
        ffi: foreigns
    });
});

gulp.task("make-example", function() {
    return purescript.psc({
        src: sources.concat(exampleSources),
        ffi: foreigns.concat(exampleForeigns),
        output: "example/node_modules"
    });
});

gulp.task("docs", function() {
    return purescript.pscDocs({
        src: sources,
        docgen: {
            "Selenium": "docs/Selenium.md",
            "Selenium.ActionSequence": "docs/Selenium/ActionSequence.md",
            "Selenium.Browser": "docs/Selenium/Browser.md",
            "Selenium.Builder": "docs/Selenium/Builder.md",
            "Selenium.Key": "docs/Selenium/Key.md",
            "Selenium.MouseButton": "docs/Selenium/MouseButton.md",
            "Selenium.Remote": "docs/Selenium/Remote.md",
            "Selenium.ScrollBehaviour": "docs/Selenium/ScrollBehaviour.md",
            "Selenium.Types": "docs/Selenium/Types.md",
            "Selenium.Monad": "docs/Selenium/Monad.md",
            "Selenium.Combinators": "docs/Selenium/Combinators.md",
            "Selenium.XHR": "docs/Selenium/XHR.md"
        }
    });
});

gulp.task("default", ["make", "docs"]);
