/// <reference path='../../typings/references.d.ts' />

module powur {
    class DecimalPartFilter {
        public static FilterId: string = 'decimalPart';
        public static $inject: Array<string> = ['$log'];
        
        constructor(private $log: ng.ILogService) {
            var init = (input: number): string => {
                return (input % 1).toFixed(2).substring(2, 4);                               
            };
            
            return <any>init;
        } // ctor
    } // class
    
    directiveModule.filter(DecimalPartFilter.FilterId, <any>DecimalPartFilter);
}
