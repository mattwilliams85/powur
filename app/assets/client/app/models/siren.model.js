/// <reference path='../../typings/tsd.d.ts' />
var __extends = (this && this.__extends) || function (d, b) {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
    d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
};
var powur;
(function (powur) {
    'use strict';
    var ServiceModel = (function () {
        function ServiceModel() {
        }
        Object.defineProperty(ServiceModel.prototype, "http", {
            get: function () {
                if (!this._http) {
                    this._http = angular.element(document).injector().get('$http');
                }
                return this._http;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(ServiceModel.prototype, "q", {
            get: function () {
                if (!this._q) {
                    this._q = angular.element(document).injector().get('$q');
                }
                return this._q;
            },
            enumerable: true,
            configurable: true
        });
        return ServiceModel;
    })();
    var Field = (function () {
        function Field(data) {
            this.name = data.name;
            this.type = data.type;
            this.value = data.value;
        }
        Field.fromJson = function (value) {
            return new Field(value);
        };
        return Field;
    })();
    powur.Field = Field;
    var Action = (function () {
        function Action(data) {
            var _this = this;
            this.submitting = false;
            this.successCallback = function (response) {
                var data = response.data;
                var error = data.error;
                _this.submitting = false;
                if (error) {
                    if (error.input) {
                        var errorField = _this.field(error.input);
                        if (errorField)
                            errorField.$error = error;
                    }
                    else {
                        _this.$error = error;
                    }
                    _this._defer.reject(response);
                }
                else {
                    _this._defer.resolve(response);
                }
            };
            this.failCallback = function (response) {
                _this._defer.reject(response);
            };
            this.href = data.href;
            this.method = data.method;
            this.name = data.name;
            this.fields = (data.fields || []).map(Field.fromJson);
        }
        Action.fromJson = function (value) {
            return new Action(value);
        };
        Action.prototype.clearErrors = function () {
            this.fields.forEach(function (f) {
                delete f.$error;
            });
            delete this.$error;
        };
        Action.prototype.defaultHttpConfig = function () {
            var data = {};
            angular.forEach(this.fields, function (field) {
                data[field.name] = field.value;
            });
            var config = { method: this.method, url: this.href };
            var dataKey = this.method === 'GET' ? 'params' : 'data';
            config[dataKey] = data;
            return config;
        };
        Object.defineProperty(Action.prototype, "http", {
            get: function () {
                if (!this._http) {
                    this._http = angular.element(document).injector().get('$http');
                }
                return this._http;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(Action.prototype, "q", {
            get: function () {
                if (!this._q) {
                    this._q = angular.element(document).injector().get('$q');
                }
                return this._q;
            },
            enumerable: true,
            configurable: true
        });
        Action.prototype.field = function (name) {
            for (var i = 0; i != this.fields.length; i++) {
                var field = this.fields[i];
                if (field.name === name)
                    return field;
            }
            return null;
        };
        Action.prototype.submit = function (config) {
            this.submitting = true;
            this.clearErrors();
            var defaults = this.defaultHttpConfig();
            var requestConfig = angular.extend({}, defaults, config);
            this._defer = this.q.defer();
            this.http(requestConfig).then(this.successCallback, this.failCallback);
            return this._defer.promise;
        };
        return Action;
    })();
    powur.Action = Action;
    var Entity = (function () {
        function Entity(data) {
            this.class = data.class;
            this.href = data.href;
            this.rel = data.rel;
        }
        Entity.fromJson = function (value) {
            return new Entity(value);
        };
        Object.defineProperty(Entity.prototype, "http", {
            get: function () {
                if (!this._http) {
                    this._http = angular.element(document).injector().get('$http');
                }
                return this._http;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(Entity.prototype, "q", {
            get: function () {
                if (!this._q) {
                    this._q = angular.element(document).injector().get('$q');
                }
                return this._q;
            },
            enumerable: true,
            configurable: true
        });
        Entity.prototype.hasRel = function (r) {
            return this.rel.indexOf(r) !== -1;
        };
        Entity.prototype.get = function (ctor, params) {
            var defer = this.q.defer();
            var href = decodeURIComponent(this.href);
            if (params) {
                angular.forEach(params, function (v, k) {
                    var re = new RegExp("{" + k + "}");
                    href = href.replace(re, v);
                });
            }
            this.http.get(href).then(function (response) {
                defer.resolve(new ctor(response.data));
            }, function (response) {
                defer.reject(response);
            });
            return defer.promise;
        };
        return Entity;
    })();
    powur.Entity = Entity;
    ng.IPromise();
})(powur || (powur = {}));
var SirenModel = (function (_super) {
    __extends(SirenModel, _super);
    function SirenModel(data, rel) {
        _super.call(this);
        this.actions = [];
        this.entities = [];
        this._data = data;
        this.rel = rel || data.rel;
        this.properties = data.properties || {};
        this.actions = (data.actions || []).map(Action.fromJson);
        this.entities = (data.entities || []).map(this.parseEntity);
    }
    Object.defineProperty(SirenModel.prototype, "class", {
        get: function () {
            return this._data.class;
        },
        enumerable: true,
        configurable: true
    });
    SirenModel.prototype.parseEntity = function (entity) {
        if (entity.href)
            return new Entity(entity);
        var model = new SirenModel(entity);
        if (model.hasClass('list')) {
            model.entities = entity.entities.map(function (ent) {
                return new SirenModel(ent);
            });
        }
        return model;
    };
    SirenModel.prototype.replaceEntityRef = function (rel, entity) {
        for (var i = 0; i != this.entities.length; i++) {
            var entityRef = this.entities[i];
            if (entityRef.hasRel(rel)) {
                entity.rel = entityRef.rel;
                this.entities[i] = entity;
                break;
            }
        }
    };
    SirenModel.prototype.hasClass = function (name) {
        return this.class.indexOf(name) !== -1;
    };
    SirenModel.prototype.hasRel = function (r) {
        return this.rel && this.rel.indexOf(r) !== -1;
    };
    SirenModel.prototype.action = function (name) {
        if (!this.actions)
            return null;
        for (var i = 0; i != this.actions.length; i++) {
            var action = this.actions[i];
            if (action.name === name)
                return action;
        }
        return null;
    };
    SirenModel.prototype.entity = function (rel) {
        if (!this.entities)
            return null;
        for (var i = 0; i != this.entities.length; i++) {
            var entity = this.entities[i];
            if (entity.hasRel(rel))
                return entity;
        }
        return null;
    };
    SirenModel.prototype.getEntity = function (ctor, rel, params) {
        var _this = this;
        var defer = this.q.defer();
        var entity = this.entity(rel);
        if (entity instanceof Entity) {
            entity.get(ctor, params).then(function (model) {
                _this.replaceEntityRef(rel, model);
                defer.resolve(model);
            }, function (response) {
                defer.reject(response);
            });
        }
        else {
            defer.resolve(entity);
        }
        return defer.promise;
    };
    return SirenModel;
})(ServiceModel);
exports.SirenModel = SirenModel;
