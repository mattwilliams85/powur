/// <reference path='../typings/tsd.d.ts' />
/// <reference path='boot.ts' />
module powur.directives {
	class InviteProgress {
		public static DirectiveId: string = 'inviteProgress';	
		
		constructor(private $log: ng.ILogService) {
			return <any>{
				compile: function (element, attrs, transclude) {
					if (element.length === 1) {
						var node = element[0];
					
						var width = node.getAttribute('data-progress-width') || '165';
						var height = node.getAttribute('data-progress-height') || '165';
					
						var canvas = document.createElement('canvas');
						canvas.setAttribute('width', width);
						canvas.setAttribute('height', height);
						canvas.setAttribute('data-progress-model', node.getAttribute('data-progress-model'));
					
						node.parentNode.replaceChild(canvas, node);
					
						var circleWidth = node.getAttribute('data-circle-width') || '10';
					
						var circleBackgroundColor = node.getAttribute('data-circle-background-color') || '#cccccc';
						var circleForegroundColor = node.getAttribute('data-circle-foreground-color') || '#2583a8';
						//var labelColor = node.getAttribute('data-label-color') || '#12eeb9';
					
						var circleRadius = node.getAttribute('data-circle-radius') || '70';
					
						//var labelFont = node.getAttribute('data-label-font') || '50pt Calibri';
					
						return {
							pre: function (scope, instanceElement, instanceAttributes, controller) {
								var expression = canvas.getAttribute('data-progress-model');
								
								scope.$watch(expression, function (newValue, oldValue) {
									var ctx = canvas.getContext('2d');
									ctx.clearRect(0, 0, width, height);
						
									var x = width / 2;
									var y = height / 2;
									ctx.beginPath();
									ctx.arc(x, y, parseInt(circleRadius), 0, Math.PI * 2, false);
									ctx.lineWidth = parseInt(circleWidth);
									ctx.strokeStyle = circleBackgroundColor;
									ctx.stroke();
						
									// ctx.font = labelFont;
									// ctx.textAlign = 'center';
									// ctx.textBaseline = 'middle';
									// ctx.fillStyle = labelColor;
									// ctx.fillText(newValue.label, x, y);
						
									var startAngle = - (Math.PI / 2);
									var endAngle = ((Math.PI * 2 ) * newValue.percentage) - (Math.PI / 2);
									var anticlockwise = false;
									ctx.beginPath();
									ctx.arc(x, y, parseInt(circleRadius), startAngle, endAngle, anticlockwise);
									ctx.lineWidth = parseInt(circleWidth);
									ctx.strokeStyle = circleForegroundColor;
									ctx.stroke();
								}, true);
							}, //pre
							post: function postLink(scope, instanceElement, instanceAttributes, controller) {}
						}; // return
					} // if
				}, // compile
				replace: true
			};
		}
	}
	
	//(<any>InviteProgress).$inject = ['$log'];
	directiveModule.directive(InviteProgress.DirectiveId, ['$log', ($log) => { return new InviteProgress($log) }]);
	
	directiveModule.directive('angRoundProgress', [function () {
  var compilationFunction = function (templateElement, templateAttributes, transclude) {
    if (templateElement.length === 1) {
      var node = templateElement[0];

      var width = node.getAttribute('data-round-progress-width') || '400';
      var height = node.getAttribute('data-round-progress-height') || '400';

      var canvas = document.createElement('canvas');
      canvas.setAttribute('width', width);
      canvas.setAttribute('height', height);
      canvas.setAttribute('data-round-progress-model', node.getAttribute('data-round-progress-model'));

      node.parentNode.replaceChild(canvas, node);

      var outerCircleWidth = node.getAttribute('data-round-progress-outer-circle-width') || '10';

      var outerCircleBackgroundColor = node.getAttribute('data-round-progress-outer-circle-background-color') || '#cccccc';
      var outerCircleForegroundColor = node.getAttribute('data-round-progress-outer-circle-foreground-color') || '#2583a8';
      var labelColor = node.getAttribute('data-round-progress-label-color') || '#12eeb9';

      var outerCircleRadius = node.getAttribute('data-round-progress-outer-circle-radius') || '100';

      var labelFont = node.getAttribute('data-round-progress-label-font') || '50pt Calibri';

      return {
        pre: function preLink(scope, instanceElement, instanceAttributes, controller) {
          var expression = canvas.getAttribute('data-round-progress-model');
          scope.$watch(expression, function (newValue, oldValue) {
            // Create the content of the canvas
            var ctx = canvas.getContext('2d');
            ctx.clearRect(0, 0, width, height);

            // The "background" circle
            var x = width / 2;
            var y = height / 2;
            ctx.beginPath();
            ctx.arc(x, y, parseInt(outerCircleRadius), 0, Math.PI * 2, false);
            ctx.lineWidth = parseInt(outerCircleWidth);
            ctx.strokeStyle = outerCircleBackgroundColor;
            ctx.stroke();

            // The inner number
            ctx.font = labelFont;
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            ctx.fillStyle = labelColor;
            ctx.fillText(newValue.label, x, y);

            // The "foreground" circle
            var startAngle = - (Math.PI / 2);
            var endAngle = ((Math.PI * 2 ) * newValue.percentage) - (Math.PI / 2);
            var anticlockwise = false;
            ctx.beginPath();
            ctx.arc(x, y, parseInt(outerCircleRadius), startAngle, endAngle, anticlockwise);
            ctx.lineWidth = parseInt(outerCircleWidth);
            ctx.strokeStyle = outerCircleForegroundColor;
            ctx.stroke();
          }, true);
        },
        post: function postLink(scope, instanceElement, instanceAttributes, controller) {}
      };
    }
  };

  var roundProgress = {
    compile: compilationFunction,
    replace: true
  };
  return roundProgress;
}]);
}