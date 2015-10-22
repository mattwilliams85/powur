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
            var deviceWidth = (window.innerWidth > 0) ? window.innerWidth : screen.width;
            var diameter = (deviceWidth>720) ? 170 : 132;
            var radius = (deviceWidth>720) ? 80 : 60;
            var progressWidth =(deviceWidth>720) ? 10 : 5;
            var width = node.getAttribute('data-progress-width') || diameter;
            var height = node.getAttribute('data-progress-height') || diameter;
            console.log(diameter);

            canvas.setAttribute('width', width);
            canvas.setAttribute('height', height);
            canvas.setAttribute('data-progress-model', node.getAttribute('data-progress-model'));

            node.parentNode.replaceChild(canvas, node);

            var circleWidth = node.getAttribute('data-circle-width') || progressWidth;
            var circleRadius = node.getAttribute('data-circle-radius') || radius;
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
              var inverseProgress = 1 - newValue.expiration_progress;
              if (inverseProgress < 0) inverseProgress = 0;
              var endAngle = ((Math.PI * 2 ) * inverseProgress) - (Math.PI / 2);
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
