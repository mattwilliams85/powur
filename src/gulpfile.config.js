'use strict';
var GulpConfig = (function () {
    function gulpConfig() {
        this.source = './app/assets/javascripts/';
        this.sourceApp = this.source;

        this.tsOutputPath = './build/client/js';
        this.allJavaScript = [this.source + '/**/*.js'];
        this.allTypeScript = this.sourceApp + '/**/*.ts';

        this.typings = './app/assets/javascripts/typings/';
        this.libraryTypeScriptDefinitions = './app/assets/javascripts/typings/**/*.ts';
    }
    return gulpConfig;
})();
module.exports = GulpConfig;