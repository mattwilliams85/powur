/// <reference path='../_references.ts' />

module powur.services {
  class CommonService {
    static ServiceId: string = 'CommonService'; 
    static $inject: Array<string> = ['$http', '$q'];   
    
    constructor(private $http: ng.IHttpService, private $q: ng.IQService) {
      return <any>{
        execute: function(action, data) {
          var dfr = $q.defer();
          data = data || {};

          $http({
            method: action.method || 'GET',
            url: action.href,
            data: data,
            params: action.params,
            type: action.type
          }).success(function(res) {
            dfr.resolve(res);
          }).error(function(err) {
            console.log('エラー', err);
            dfr.reject(err);
          });

          return dfr.promise;
        }
      };
    }
    
    public user: any;
  }
  
  serviceModule.factory(CommonService.ServiceId, CommonService);
}