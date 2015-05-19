;(function() {
  'use strict';

  angular.module('widgets.fileS3Uploader', [])
  .directive('fileS3Uploader', function() {
    return {
      restrict: 'AE',
      scope: {
        data: '=',
        mode: '@',
        autoUpload: '@',
        showProgress: '@'
      },
      templateUrl: 'file-s3-uploader/templates/index.html',
      controller: 'FileS3UploaderCtrl'
    };
  });

})();
