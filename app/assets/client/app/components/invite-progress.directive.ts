/// <reference path='../_references.ts' />

module powur {
    class InviteProgress {
        static DirectiveId: string = 'pwInviteProgress';
        static $inject: Array<string> = ['$log'];
        
        constructor($log: ng.ILogService) {
            return <any>{
                link: function (scope: ng.IScope, element: JQuery, attributes: any) {
                    if (element.length === 1) {
                        var node = <any>element[0];
                        var canvas = document.createElement('canvas');
                    
                        var width = node.getAttribute('data-progress-width') || '170';
                        var height = node.getAttribute('data-progress-height') || '170';
                    
                        canvas.setAttribute('width', width);
                        canvas.setAttribute('height', height);
                        canvas.setAttribute('data-progress-model', node.getAttribute('data-progress-model'));
                    
                        node.parentNode.replaceChild(canvas, node);
                    
                        var circleWidth = node.getAttribute('data-circle-width') || '10';
                        var circleRadius = node.getAttribute('data-circle-radius') || '75';
                        var circleBackgroundColor = node.getAttribute('data-circle-background-color') || '#cccccc';
                        var circleForegroundColor = attributes.circleForegroundColor || '#2583a8';
                    
                        var expression = canvas.getAttribute('data-progress-model');
                        var anticlockwise = canvas.getAttribute('data-anticlockwise') == 'true';
                        
                        var ctx = node.ctx = canvas.getContext('2d');
                        
                        scope.$watch(expression, function (newValue: any, oldValue: any) {
                            ctx.clearRect(0, 0, width, height);
                
                            var x = width / 2;
                            var y = height / 2;
                            ctx.beginPath();
                            ctx.arc(x, y, parseInt(circleRadius), 0, Math.PI * 2, false);
                            ctx.lineWidth = parseInt(circleWidth);
                            ctx.strokeStyle = circleBackgroundColor;
                            ctx.stroke();
                
                            var startAngle = - (Math.PI / 2);
                            var endAngle = ((Math.PI * 2 ) * newValue.percentage) - (Math.PI / 2);
                            ctx.beginPath();
                            ctx.arc(x, y, parseInt(circleRadius), startAngle, endAngle, anticlockwise);
                            ctx.lineWidth = parseInt(circleWidth);
                            ctx.strokeStyle = circleForegroundColor;
                            ctx.stroke();
                        }, true);
                    }; // if
                } // link
            }; // return
        } // ctor
    } // class
    
    directiveModule.directive(InviteProgress.DirectiveId, <any>InviteProgress);
}
