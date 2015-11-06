/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../../app/core/remove-extra-characters.filter.ts' />

describe('removeExtraChars', () => {
  beforeEach(() => {
      angular.mock.module('powur.core');
  });
  
  it('should initialize correctly', inject(($filter: ng.IFilterService) => {
    var removeExtraChars = $filter('removeExtraChars');
    expect(removeExtraChars).toBeDefined();
    expect(removeExtraChars).not.toBeNull();
  }));

  it('should replace first _ with spaces', inject((removeExtraCharsFilter: any) => {
    expect(removeExtraCharsFilter('abc_def')).toBe('abc def');
    expect(removeExtraCharsFilter('__aaa__')).toBe(' _aaa__');
  }));
});