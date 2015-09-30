/// <reference path='../typings/tsd.d.ts' />
declare var controllerModule: ng.IModule;

module powur.controllers {
    enum EventType {
        News,
        Award,
        Star,
        Phone,
    }
    
    class Presenter {
        firstName: string;
        lastName: string;
        title: string;
        company: string;
        profileUrl: string;       
    }
    
    class EventItem {
        presenter: Presenter;
        start: Date;
        //end: Date;
        type: EventType;
        title: string;
        description: string;        
    }
    
    export interface IEventsController {
        
    }
    
    class EventsController implements IEventsController {
        public static ControllerId: string = 'EventsController';
        public static $inject: Array<string> = ['$log', '$interval'];
     
        public calendarOptions: any;
     
        public events: Array<EventItem> = [];
        
        constructor(private $log: ng.ILogService, private $interval: ng.IIntervalService) {
            var self = this;
            self.$log.debug(EventsController.ControllerId + ':ctor');
            
            // sample data
            self.events = [
                { presenter: {
                    firstName: 'Jonathan', lastName: 'Budd', title: 'CEO', company: 'POWUR', profileUrl: 'assets/img/profile/profile1.png',
                }, type: EventType.News, start: moment().subtract('h', 6).toDate(), title: 'POWUR BETA 2.0 PREVIEW', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer a iaculis lorem. Mauris lobortis odio at nunc vulputate, sed fermentum nisl molestie.'},
                { presenter: {
                    firstName: 'Jonathan', lastName: 'Budd', title: 'CEO', company: 'POWUR', profileUrl: 'assets/img/profile/profile2.png',
                }, type: EventType.Award, start: moment().subtract('h', 3).toDate(), title: 'POWUR BETA 2.0 PREVIEW', description: 'Praesent sed porttitor turpis. Suspendisse potenti. Pellentesque dapibus metus non elit aliquam gravida.'},
                { presenter: {
                    firstName: 'Jonathan', lastName: 'Budd', title: 'CEO', company: 'POWUR', profileUrl: 'assets/img/profile/profile1.png',
                }, type: EventType.Star, start: moment().subtract('h', 6).toDate(), title: 'POWUR BETA 2.0 PREVIEW', description: 'Praesent egestas id arcu et rutrum. Morbi molestie posuere elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.'},
                { presenter: {
                    firstName: 'Jonathan', lastName: 'Budd', title: 'CEO', company: 'POWUR', profileUrl: 'assets/img/profile/profile1.png',
                }, type: EventType.Phone, start: moment().subtract('h', 6).toDate(), title: 'POWUR BETA 2.0 PREVIEW', description: 'Ut blandit nisl vel laoreet tristique. In tortor nulla, malesuada a urna in, volutpat maximus tellus.'},
            ];
            
            // self.$interval(() => {
            //     // date
            //     self.events[0].start = moment(self.events[0].start).subtract(1, 's').toDate();
            // }, 200, 0, true);
            
            self.calendarOptions = {
                header:{
                    left: 'month basicWeek basicDay agendaWeek agendaDay',
                    center: 'title',
                    right: 'today prev,next'
                },
                //dayClick: self.alertEventOnClick,
                //eventDrop: self.alertOnDrop,
                //eventResize: self.alertOnResize
            };
        }        
        
        public getHumanize(d: any): string {
            return moment.duration(moment().diff(moment(d))).humanize();
        }
        
        public share(type: any, item: EventItem) {
            
        }
    }    
    
    controllerModule.controller(EventsController.ControllerId, EventsController);
}
