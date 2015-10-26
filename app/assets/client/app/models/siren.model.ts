/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='siren.base.ts' />

module powur {
  'use strict';

  export class SirenModel extends ServiceModel {
    private _data: any;

    get class(): string[] {
      return this._data.class;
    }
    rel: string[];
    properties: any = {};
    actions: Action[] = [];
    entityRefs: EntityRef[] = [];
    entities: ISirenModel[] = [];

    private parseEntities(): void {
      var entityList = this._data.entities;
      if (!entityList) return;

      if (this.hasClass('list')) {
        this.entities = entityList.map((value: any): ISirenModel => {
          return new SirenModel(value);
        });
      } else {
        angular.forEach(entityList, (value: any) => {
          if (value.href) {
            this.entityRefs.push(new EntityRef(value));
          } else {
            this.entities.push(new SirenModel(value));
          }
        })
      }
    }

    constructor(data: any, http?: ng.IHttpService, q?: ng.IQService) {
      super(http, q);
      this.refreshData(data);
    }

    refreshData(data: any): void {
      this._data = data;
      this.rel = data.rel;
      this.properties = data.properties || {};
      this.actions = (data.actions || []).map(Action.fromJson)
      this.parseEntities();
    }

    hasClass(name: string): boolean {
      return this.class.indexOf(name) !== -1;
    }

    removeClass(name: string) {
      var index = this.class.indexOf(name);
      this.class.splice(index, 1);
    }

    hasRel(r: string): boolean {
      return this.rel && this.rel.indexOf(r) !== -1;
    }

    action(name: string): Action {
      if (!this.actions) return undefined;
      for (var i = 0; i != this.actions.length; i++) {
        var action: Action = this.actions[i];
        if (action.name === name) return action;
      }
      return undefined;
    }

    entity(rel: string): EntityRef|ISirenModel {
      if (!this.entities) return undefined;
      for (var i = 0; i !== this.entities.length; i++) {
        var entity: ISirenModel = this.entities[i];
        if (entity.hasRel(rel)) return entity;
      }
      for (var i = 0; i !== this.entityRefs.length; i++) {
        var ref: EntityRef = this.entityRefs[i];
        if (ref.hasRel(rel)) return ref;
      }
      return undefined;
    }

    getEntity<T extends ISirenModel>(ctor: { new(d: any): T; }, rel: string, params?: any): ng.IPromise<T> {
      var defer = this.q.defer<T>();

      var entity: any = this.entity(rel);
      if (entity instanceof EntityRef) {
        entity.get(ctor, params).then((model: T) => {
          model.rel = entity.rel
          this.entities.push(model);
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
