// Karma configuration
// Generated on Wed Oct 28 2015 12:06:01 GMT-0700 (PDT)

module.exports = function(config) {
config.set({
    // base path that will be used to resolve all patterns (eg. files, exclude)
    //basePath: '',

    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['jasmine'],

    // list of files / patterns to load in the browser
    files: [
       //'app/assets/client/app/**/*.ts',
       'vendor/assets/bower_components/jquery/dist/jquery.js',
       'vendor/assets/bower_components/q/q.js',
       'vendor/assets/bower_components/lodash/lodash.js',
       'vendor/assets/bower_components/moment/moment.js',
       'vendor/assets/bower_components/angular/angular.js',
       'vendor/assets/bower_components/angular-aria/angular-aria.js',
       'vendor/assets/bower_components/angular-messages/angular-messages.js',
       'vendor/assets/bower_components/angular-animate/angular-animate.js',
       'vendor/assets/bower_components/ngstorage/ngStorage.js',
       'vendor/assets/bower_components/angular-material/angular-material.js',
       'vendor/assets/bower_components/angular-ui-router/release/angular-ui-router.js',

       'vendor/assets/bower_components/angular-mocks/angular-mocks.js',
       'app/assets/client/test/templates.ts',
       
       'app/assets/client/app/services/powur.services.ts',
       'app/assets/client/app/core/powur.core.ts',
       
       'app/assets/client/app/core/decimal-part.filter.ts',
       'app/assets/client/app/core/remove-extra-characters.filter.ts',
       'app/assets/client/app/core/truncate-name.filter.ts',
       'app/assets/client/app/core/whole-number.filter.ts',

       'app/assets/client/test/core/**/*.ts',
      //  'app/assets/client/test/core/decimal-part.filter.ts',
      //  'app/assets/client/test/core/remove-extra-characters.filter.ts',
      //  'app/assets/client/test/core/truncate-name.filter.ts',
      //  'app/assets/client/test/core/whole-number.filter.ts',
    ],
    
    // list of files to exclude
    exclude: [
    ],


    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
      '**/*.ts': ['typescript']
    },

    typescriptPreprocessor: {
      // options passed to the typescript compiler
      options: {
        sourceMap: false, // (optional) Generates corresponding .map file.
        target: 'ES5', // (optional) Specify ECMAScript target version: 'ES3' (default), or 'ES5'
        module: 'amd', // (optional) Specify module code generation: 'commonjs' or 'amd'
        noImplicitAny: true, // (optional) Warn on expressions and declarations with an implied 'any' type.
        noResolve: true, // (optional) Skip resolution and preprocessing.
        removeComments: true, // (optional) Do not emit comments to output.
        concatenateOutput: false // (optional) Concatenate and emit output to single file. By default true if module option is omited, otherwise false.
      },
      // extra typing definitions to pass to the compiler (globs allowed)
      typings: [
        'app/assets/client/typings/**/*.d.ts'
      ],
      // transforming the filenames
      transformPath: function(path) {
        return path.replace(/\.ts$/, '.js');
      }
    },

    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['progress'],


    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_DEBUG,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,


    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['PhantomJS', 'Chrome'],


    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: false,

    // Concurrency level
    // how many browser should be started simultanous
    concurrency: Infinity,
    
    plugins: [
        "karma-jasmine",

        //"karma-sourcemap-loader",
        //"karma-junit-reporter",

        "karma-chrome-launcher",
        "karma-phantomjs-launcher",

        "karma-typescript-preprocessor"
    ],
  })
}
