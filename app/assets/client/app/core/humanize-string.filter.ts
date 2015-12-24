/// <reference path='../../typings/tsd.d.ts' />

module powur {
  class HumanizeStringFilter {
    static FilterId: string = 'humanizeString';

    constructor() {
      var init = (input: string): string => {
        return _.startCase(input);
      };

      return <any>init;
    }
  }

  angular
    .module('powur.core')
    .filter(HumanizeStringFilter.FilterId, <any>HumanizeStringFilter);
}
