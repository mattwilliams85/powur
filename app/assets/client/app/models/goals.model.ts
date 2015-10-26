/// <reference path='siren.model.ts' />

module powur {
    'use strict';

    export class GoalsModel extends SirenModel {
      getRequirements(): ng.IPromise<ISirenModel> {
        return this.getEntity(SirenModel, 'goals-requirements');
      }
    }
}
