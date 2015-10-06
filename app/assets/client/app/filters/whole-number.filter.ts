/// <reference path='../_references.ts' />

module powur {
    class WholeNumberFilter {
        public static FilterId: string = 'wholeNumber';
        public static $inject: Array<string> = ['$log'];
        
        constructor(private $log: ng.ILogService) {
            var toCommas = (v: number): string => {
                return v.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
            };
            
            var init = (input: number, withCommas: boolean = true): string => {
                var v = Math.floor(input);
                return withCommas ? toCommas(v) : v.toString();                                
            };
            
            return <any>init;
        } // ctor
    } // class
    
    directiveModule.filter(WholeNumberFilter.FilterId, <any>WholeNumberFilter);
}
