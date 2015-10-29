/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../../app/core/decimal-part.filter.ts' />

describe('decimalPart', () => {
  beforeEach(() => {
    angular.mock.module('powur.core');
  });
  
  it('should initialize correctly', inject(($filter: ng.IFilterService) => {
    var decimalPart = $filter('decimalPart');
    expect(decimalPart).toBeDefined();
    expect(decimalPart).not.toBeNull();
  }));

  it('should return decimal part only', inject((decimalPartFilter: any) => {
    expect(decimalPartFilter(123.46)).toBe('46');
    expect(decimalPartFilter(22.0)).toBe('00');
  }));
});