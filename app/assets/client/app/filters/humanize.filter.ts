/// <reference path='../_references.ts' />

module powur {
    class HumanizeFilter {
        static FilterId: string = 'humanize';
        static $inject: Array<string> = ['$log'];
        
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
