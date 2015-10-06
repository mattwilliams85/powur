/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../../typings/references.d.ts' />

module powur {
  'use strict';

  export class Siren {
    class: string[];

    constructor(data: any) {
      this.class = data.class;
    }
  }
}
