/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../../typings/references.d.ts' />

module powur.filters {
    class HumanizeFilter {
        public static FilterId: string = 'humanize';
        public static $inject: Array<string> = ['$log'];
        
        constructor(private $log: ng.ILogService) {
            var init = (input: Date): string => {
                //TODO: change this to match design
                return moment.duration(moment().diff(moment(input))).humanize();
            };
            
            return <any>init;
        } // ctor
    } // class
    
    directiveModule.filter(HumanizeFilter.FilterId, <any>HumanizeFilter);
}
