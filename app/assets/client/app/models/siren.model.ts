/// <reference path='../../typings/tsd.d.ts' />

module powur {
  'use strict';

  class Field {
    name: string;
    type: string;
    value: string;
    $error: any;

    static fromJson(value: any) {
      return new Field(value);
    }

    constructor(data: any) {
      this.name = data.name;
      this.type = data.type;
      this.value = data.value;
    }
  }

  export class Action {
    static fromJson(value: any) {
      return new Action(value);
    }
    
    private _http: ng.IHttpService;
    private _q: ng.IQService;
    private _defer: ng.IDeferred<ng.IHttpPromiseCallbackArg<any>>;
    
    success: (r: ng.IHttpPromiseCallbackArg<any>) => void;
    fail: (r: ng.IHttpPromiseCallbackArg<any>) => void;

    href: string;
    method: string;
    name: string;
    fields: Field[];
    submitting: boolean = false;
    $error: any;

    private clearErrors() {
      this.fields.forEach(f => {
        delete f.$error;
      });
      delete this.$error;
    }

    private defaultHttpConfig(): any {
      var data: any = {};
      angular.forEach(this.fields, function(field: Field) {
        data[field.name] = field.value;
      });
      var config: any = { method: this.method, url: this.href };
      var dataKey = this.method === 'GET' ? 'params' : 'data';
      config[dataKey] = data;

      return config;
    }

    private successCallback = (response: ng.IHttpPromiseCallbackArg<any>) => {
      var data = response.data;
      var error = data.error;
      this.submitting = false;

      if (error) {
        if (error.input) {
          var errorField = this.field(error.input);
          if (errorField) errorField.$error = error;
        }
        this._defer.reject(response);
      } else {
        this._defer.resolve(response);
      }
    }

    get http(): ng.IHttpService {
      if (!this._http) {
        this._http = angular.element(document).injector().get('$http');
      }
      return this._http;
    }

    get q(): ng.IQService {
      if (!this._q) {
        this._q = angular.element(document).injector().get('$q');
      }
      return this._q;
    }

    constructor(data: any) {
      this.href = data.href;
      this.method = data.method;
      this.name = data.name;
      this.fields = (data.fields || []).map(Field.fromJson);
    }

    field(name: string): Field {
      for (var i = 0; i != this.fields.length; i++) {
        var field = this.fields[i];
        if (field.name === name) return field;
      }
      return null;
    }

    submit(config?: any): ng.IPromise<ng.IHttpPromiseCallbackArg<any>> {
      this.submitting = true;
      this.clearErrors();
      var defaults = this.defaultHttpConfig();
      var requestConfig = angular.extend({}, defaults, config);
      
      this._defer = this.q.defer<ng.IHttpPromiseCallbackArg<any>>();
      
      this.http(requestConfig).then(this.successCallback);

      return this._defer.promise;
    }
  }

  export interface ISirenModel {
    class: string[];
    actions: Action[];
    hasClass(s: string): boolean;
    action(name: string): Action;
  }

  export class SirenModel {
    private _data: any;

    get class(): string[] {
      return this._data.class;
    }
    actions: Action[] = [];

    constructor(data: any) {
      this._data = data;
      this.actions = this.parseActions(data.actions || []);
    }

    hasClass(name: string) : boolean {
      return this.class.indexOf(name) !== -1;
    }

    action(name: string) : Action {
      for (var i = 0; i != this.actions.length; i++) {
        var action: Action = this.actions[i];
        if (action.name === name) return action;
      }
      return null;
    }

    private parseActions(json: any) {
      return json.map(Action.fromJson);
    }
  }
}
