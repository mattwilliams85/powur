/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../../app/core/whole-number.filter.ts' />

describe('wholeNumber', () => {
  beforeEach(() => {
    angular.mock.module('powur.core');
  });
  
  it('should initialize correctly', inject(($filter: ng.IFilterService) => {
    var wholeNumber = $filter('wholeNumber');
    expect(wholeNumber).toBeDefined();
    expect(wholeNumber).not.toBeNull();
  }));

  it('should return whole part only', inject((wholeNumberFilter: any) => {
    expect(wholeNumberFilter(123.46)).toBe('123');
    expect(wholeNumberFilter(22.0)).toBe('22');
  }));
});