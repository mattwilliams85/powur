/// <reference path='../../typings/tsd.d.ts' />

module powur {
  'use strict';

  class ServiceModel {
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
  }

  export class Field {
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
        } else {
          this.$error = error;
        }
        this._defer.reject(response);
      } else {
        this._defer.resolve(response);
      }
    }

    private failCallback = (response: ng.IHttpPromiseCallbackArg<any>) => {
      console.log('fail!!!!');
      this._defer.reject(response);
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
      
      this.http(requestConfig).then(this.successCallback, this.failCallback);

      return this._defer.promise;
    }
  }

  export class Entity {
    static fromJson(value: any) {
      return new Entity(value);
    }

    private _http: ng.IHttpService;
    private _q: ng.IQService;

    class: string[];
    href: string;
    rel: string[];

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
      this.class = data.class;
      this.href = data.href;
      this.rel = data.rel;
    }

    hasRel(r: string): boolean {
      return this.rel.indexOf(r) !== -1;
    }

    get<T extends ISirenModel>(ctor: { new(data: any): T; }): ng.IPromise<T> {
      var defer = this.q.defer<T>();

      this.http.get(this.href).then((response: ng.IHttpPromiseCallbackArg<any>) => {
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
    entities: Array<Entity|ISirenModel>;
    hasClass(s: string): boolean;
    action(name: string): Action;
    entity(name: string): Entity|ISirenModel;
    getEntity<T extends ISirenModel>(c: { new(d: any): T; }, rel: string): ng.IPromise<T>;
  }

  export class SirenModel extends ServiceModel {
    private _data: any;

    get class(): string[] {
      return this._data.class;
    }
    rel: string[];
    properties: any;
    actions: Action[] = [];
    entities: Array<Entity|ISirenModel> = [];

    private parseEntity(entity: any): Entity|ISirenModel {
      if (entity.href) return new Entity(entity);
      var model: ISirenModel = new SirenModel(entity);
      if (model.hasClass('list')) {
        model.entities = entity.entities.map((ent: any): ISirenModel => {
          return new SirenModel(ent);
        });
      }
      return model;
    }

    private replaceEntityRef(rel: string, entity: ISirenModel): void {
      for (var i = 0; i != this.entities.length; i++) {
        var entityRef: any = this.entities[i];
        if (entityRef.hasRel(rel)) {
          entity.rel = entityRef.rel;
          this.entities[i] = entity;
          break;
        }
      }
    }

    constructor(data: any, rel?: string[]) {
      super();
      this._data = data;
      this.rel = rel || data.rel;
      this.properties = data.properties || {};
      this.actions = (data.actions || []).map(Action.fromJson)
      this.entities = (data.entities || []).map(this.parseEntity);
    }

    hasClass(name: string): boolean {
      return this.class.indexOf(name) !== -1;
    }

    hasRel(r: string): boolean {
      return this.rel && this.rel.indexOf(r) !== -1;
    }

    action(name: string): Action {
      if (!this.actions) return null;
      for (var i = 0; i != this.actions.length; i++) {
        var action: Action = this.actions[i];
        if (action.name === name) return action;
      }
      return null;
    }

    entity(rel: string): Entity|ISirenModel {
      if (!this.entities) return null;
      for (var i = 0; i != this.entities.length; i++) {
        var entity: any = this.entities[i];
        if (entity.hasRel(rel)) return entity;
      }
      return null;
    }

    getEntity<T extends ISirenModel>(ctor: { new(d: any): T; }, rel: string): ng.IPromise<T> {
      var defer = this.q.defer<T>();

      var entity: any = this.entity(rel);
      if (entity instanceof Entity) {
        entity.get(ctor).then((model: T) => {
          this.replaceEntityRef(rel, model);
          defer.resolve(model);
        }, (response: ng.IHttpPromiseCallbackArg<any>) => {
          defer.reject(response);
        })
      } else {
        defer.resolve(entity);
      }

      return defer.promise;
    }
  }
}
