/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../../app/core/truncate-name.filter.ts' />

describe('truncateName', () => {
  beforeEach(() => {
    angular.mock.module('powur.core');

    angular.mock.module(($provide: any) => {
          $provide.value('$window', { innerWidth: 500 });
      });
  });
  
  it('should initialize correctly', inject(($filter: ng.IFilterService) => {
    var truncateName = $filter('truncateName');
    expect(truncateName).toBeDefined();
    expect(truncateName).not.toBeNull();
  }));

  it('should cut/trancate < 720', inject((truncateNameFilter: any) => {
    expect(truncateNameFilter('abc')).toBe('a.');
  }));

  it('should cut/trancate >= 7', inject((truncateNameFilter: any) => {
    expect(truncateNameFilter('1234567')).toBe('1.');
  }));
});

describe('truncateName with 800', () => {
  beforeEach(() => {
    angular.mock.module('powur.core');

    angular.mock.module(($provide: any) => {
          $provide.value('$window', { innerWidth: 800 });
      });
  });
  
  it('should initialize correctly', inject(($filter: ng.IFilterService) => {
    var truncateName = $filter('truncateName');
    expect(truncateName).toBeDefined();
    expect(truncateName).not.toBeNull();
  }));

  it('should cut/trancate > 720', inject((truncateNameFilter: any) => {
    expect(truncateNameFilter('abc')).toBe('abc');
  }));

  it('should cut/trancate >= 7', inject((truncateNameFilter: any) => {
    expect(truncateNameFilter('1234567')).toBe('1.');
  }));
});