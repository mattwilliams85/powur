/// <reference path='../../typings/tsd.d.ts' />

module powur {
  'use strict';

  export class ServiceModel {
    private _http: ng.IHttpService;
    private _q: ng.IQService;

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

    constructor(http?: ng.IHttpService, q?: ng.IQService) {
      this._http = http;
      this._q = q;
    }
  }

  export class EntityRef extends ServiceModel {
    class: string[];
    href: string;
    rel: string[];

    private parameterizeUrl(params?: any): string {
      var href = decodeURIComponent(this.href);
      if (!params) return href;
      angular.forEach(params, function(v, k) {
        var re = new RegExp(`\{${k}\}`);
        href = href.replace(re, v);
      });
      return href;
    }

    constructor(data: any) {
      super();
      angular.copy(data, this);
    }

    hasRel(r: string): boolean {
      return this.rel.indexOf(r) !== -1;
    }

    get<T extends ISirenModel>(ctor: { new (data: any): T; }, params?: any): ng.IPromise<T> {
      var url = this.parameterizeUrl(params);

      var defer = this.q.defer<T>();
      this.http.get(url).then((response: ng.IHttpPromiseCallbackArg<any>) => {
        if (!response.data) {
          console.log('no data!', response);
        }
        defer.resolve(new ctor(response.data));
      }, (response: ng.IHttpPromiseCallbackArg<any>) => {
        defer.reject(response);
      });
      return defer.promise;
    }
  }

  export interface ISirenModel {
    class: string[];
    rel: string[];
    properties: any;
    actions: Action[];
    entities: ISirenModel[];
    entityRefs: EntityRef[];
    hasClass(s: string): boolean;
    hasRel(s: string): boolean;
    action(name: string): Action;
    getEntity<T extends ISirenModel>(c: { new (d: any): T; }, rel: string, params?: any): ng.IPromise<T>;
  }

  export class Field {
    static fromJson(value: any) {
      return new Field(value);
    }
    name: string;
    value: string;
    type: string;
    required: boolean;
    $error: any;

    constructor(data: any) {
      angular.copy(data, this);
    }
  }

  export class Action extends ServiceModel {
    static fromJson(value: any, parent: ISirenModel) {
      return new Action(value, parent);
    }
    parent: ISirenModel;
    fields: Field[];
    href: string;
    method: string;
    name: string;
    submitting: boolean = false;
    $error: any;
    defer: ng.IDeferred<ng.IHttpPromiseCallbackArg<any>>;

    // get fields(): Field[] {
    //   return this._fields;
    // }

    // set fields(value: any) {
    //   this._fields = (value.fields || []).map(Field.fromJson);
    // }

    private clearErrors() {
      this.fields.forEach(f => { delete f.$error; });
      delete this.$error;
    }

    private httpConfig(): any {
      var data: any = {};
      angular.forEach(this.fields, function(field: Field) {
        data[field.name] = field.value;
      });
      var config: any = { method: this.method, url: this.href };
      var dataKey = this.method === 'GET' ? 'params' : 'data';
      config[dataKey] = data;

      return config;
    }

    private httpSuccess = (response: ng.IHttpPromiseCallbackArg<any>) => {
      var data = response.data;
      var error = data.error;
      this.submitting = false;

      if (error) {
        if (error.input) {
          var errorField = this.field(error.input);
          if (errorField) errorField.$error = error;
        } else {
          this.$error = error;
        }
        this.defer.reject(response);
      } else {
        this.defer.resolve(response);
      }
    }

    private httpFail = (response: ng.IHttpPromiseCallbackArg<any>) => {
      this.submitting = false;
      this.defer.reject(response);
    }

    constructor(data: any, parent: ISirenModel) {
      super();

      this.href = data.href;
      this.method = data.method;
      this.name = data.name;
      this.fields = (data.fields || []).map(Field.fromJson);
      this.parent = parent;
    }

    field(name: string): Field {
      for (var i = 0; i !== this.fields.length; i++) {
        var field = this.fields[i];
        if (field.name === name) return field;
      }
      return undefined;
    }

    submit(config?: any): ng.IPromise<ng.IHttpPromiseCallbackArg<any>> {
      this.submitting = true;
      this.clearErrors();
      var defaults = this.httpConfig();
      var requestConfig = angular.extend({}, defaults, config);

      this.defer = this.q.defer<ng.IHttpPromiseCallbackArg<any>>();
      this.http(requestConfig).then(this.httpSuccess, this.httpFail);
      return this.defer.promise;
    }

    clearValues(): void {
      this.fields.forEach(f => {
        delete f.value;
      });
    }
  }
}
