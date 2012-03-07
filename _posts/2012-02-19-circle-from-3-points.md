---
layout: post
title: Formula for Circle from 3 Points
synopsis: Calculating the properties of a circle from 3 arbitrary points in space.
topics:
  - algorithm
  - generative art
  - code
---

It goes like this--You have 3 points and you want to solve for a circle whose permitter runs through each point.  I've used this nifty way of defining a circle on two separate projects in the past.  One was for a game I was making, and the other was for an interactive visualization. You're probably more interested in dropping it into your own code, vs. understanding all the nitty-gritty maths of how it works. So I'll spare you those details.  See the examples below to view it in action and to help you get ideas flowing.

<script type="text/javascript">

//  ------------------------------------------------------
//  ECMAScript doesn't providate a method to round to a
//  desired precision, so we we'll use our own

function precision(number, digits)
{
	var multiple = Math.pow(10, digits);
	return Math.round(number*multiple)/multiple;
}


//  ------------------------------------------------------
//  Solves for a circle who perimeter runs through three
//  points in a 2d space. Returns false if there is no
//  solution to the inputs

function circle3pt(p1, p2 /* middle */, p3)
{
	var yda = p2.y - p1.y;
	var xda = p2.x - p1.x;
	var ydb = p3.y - p2.y;
	var xdb = p3.x - p2.x;

	if (xda == 0 || xdb == 0)
		return false;

	var as = yda/xda;
	var bs = ydb/xdb;
	
	if (bs-as == 0 || as == 0)
		return false;

	var cx = (as*bs*(p1.y-p3.y) + bs*(p1.x + p2.x) - as*(p2.x+p3.x))/(2*(bs-as));
	var cy = -1*(cx - (p1.x+p2.x)/2)/as + (p1.y+p2.y)/2;
	var v = {x: p2.x-cx, y: p2.y-cy};
	return {x: cx, y: cy, r: Math.sqrt(v.x*v.x + v.y*v.y)};
}

//  ------------------------------------------------------
//  Linear interpolation

function lerp(a,b,p)
{
	return a+(b-a)*p;
}


//  ------------------------------------------------------
//  OMG Circles

var OMG_Circles = {
	create: function(canvas_id, generator, style)
	{
		var canvas = $(canvas_id);
		if (!canvas[0].getContext)
			return false;
		
		var ctx = canvas[0].getContext("2d");
		ctx.save();
		style(ctx, generator(canvas.width(), canvas.height()))
		ctx.restore();
		return true;
	}, style:
	{
		plain: function (ctx, circles)
		{
			for (var i=0;i<circles.length;++i)
			{
				ctx.strokeStyle = "#c96d41";
				ctx.beginPath();
				ctx.arc(circles[i].circle.x,circles[i].circle.y,circles[i].circle.r,0,Math.PI*2,true);
				ctx.closePath();
				ctx.stroke();
			}
			
			for (var i=0;i<circles.length;++i)
			{
				for (var j=0;j<3;++j)
				{
					ctx.fillStyle = j == 1 ? "#4f8821" : "#443447";
					
					var p = circles[i].vertices[j];
					ctx.beginPath();
					ctx.arc(p.x,p.y,3,0,Math.PI*2,true);
					ctx.closePath();
					ctx.fill();
				}
			}
		}, shaded: function (ctx, circles)
		{
			circles = circles.reverse();
			
			var highlight = 5;
			var highlight_offset = 3;
			
			var shadow = 12;
			var shadow_offset = 10;
			for (var i=0;i<circles.length;++i)
			{
				// highlight
				ctx.save();
				ctx.strokeStyle = "rgba(209,183,106, 0.2)";
				ctx.lineWidth = highlight;
				ctx.beginPath();
				ctx.arc(circles[i].circle.x-highlight_offset,circles[i].circle.y-highlight_offset,circles[i].circle.r,0,Math.PI*2,true);
				ctx.closePath();
				ctx.stroke();
				ctx.restore();
				
				// shadow
				ctx.save();
				ctx.strokeStyle = "rgba(43,29,42, 0.05)";
				ctx.lineWidth = shadow;
				ctx.beginPath();
				ctx.arc(circles[i].circle.x+shadow_offset,circles[i].circle.y,circles[i].circle.r,0,Math.PI*2,true);
				ctx.closePath();
				ctx.stroke();
				ctx.restore();
				
				// body
				var r = Math.round(lerp(67,199,i/circles.length));
				var g = Math.round(lerp(52,126,i/circles.length));
				var b = Math.round(lerp(71,91,i/circles.length));
				ctx.fillStyle = "rgb(" + r + "," + g + "," + b + ")";
				ctx.beginPath();
				ctx.arc(circles[i].circle.x,circles[i].circle.y,circles[i].circle.r,0,Math.PI*2,true);
				ctx.closePath();
				ctx.fill();
			}
		}, line: function (ctx, circles)
		{
			for (var i=1;i<circles.length;++i)
			{
				var a = circles[i-1].circle;
				var b = circles[i].circle;
				
				ctx.strokeStyle = "rgba(0,0,0,0.1)";
				ctx.lineWidth = 15;
				ctx.beginPath();
				ctx.arc(circles[i].circle.x,circles[i].circle.y,circles[i].circle.r+10,0,Math.PI*2,true);
				ctx.closePath();
				ctx.stroke();
				
				
				
				ctx.fillStyle = "#4f8821";
				ctx.beginPath();
				ctx.arc(circles[i].circle.x,circles[i].circle.y,4,0,Math.PI*2,true);
				ctx.closePath();
				ctx.fill();
				
				
				var c = Math.round(lerp(0,200,i/circles.length));
				ctx.strokeStyle = "rgb(" + c + "," + c + "," + c + ")";
				ctx.lineWidth = 1;
				
				var step = Math.PI/16;
				for (var theta=0;theta<2*Math.PI;theta+=step)
				{
					ctx.save();
					ctx.beginPath();
					ctx.moveTo(a.x + Math.cos(theta)*a.r, a.y + Math.sin(theta)*a.r);
					ctx.lineTo(b.x + Math.cos(theta)*b.r, b.y + Math.sin(theta)*b.r);
					ctx.closePath();
					ctx.stroke();
					ctx.restore();
				}
				

				ctx.beginPath();
				ctx.arc(circles[i].circle.x,circles[i].circle.y,circles[i].circle.r,0,Math.PI*2,true);
				ctx.closePath();
				ctx.stroke();
			}
		}
	}
};


//  ------------------------------------------------------
//  Generate and draw

$(function ()
{
	function example01_generator(w, h)
	{
		var a = [];
		var points = [{x: 100, y: 150},{x: 50, y: 35},{x: 75, y: 25}];
		a.push({vertices: points, circle: circle3pt(points[0], points[1], points[2])});
		return a;
	}
	
	function example02_generator(w, h)
	{
		var a = [];
		var center = {x: 40, y: h/2}
		
		for (var i=0;i<40;++i)
		{
			var xo = i*10;
			var yo = 40 + Math.cos(i/Math.PI)*30;
			var points = [{x: center.x + xo, y: center.y + yo},{x: center.x, y: center.y},{x: center.x + xo, y: center.y}];
			a.push({vertices: points, circle: circle3pt(points[0], points[1], points[2])});
		}
		return a;
	}
	
	function example03_generator(w, h)
	{
		var a = [];
		var center = {x: -100, y: 100}
		
		for (var i=0;i<40;++i)
		{
			var xo = i*10;
			var yo = 40 + Math.tan(i/Math.PI)*30;
			var points = [{x: center.x + xo, y: center.y + yo},{x: center.x, y: center.y},{x: center.x + xo, y: center.y}];
			a.push({vertices: points, circle: circle3pt(points[0], points[1], points[2])});
		}
		return a;
	}
	
	function example04_generator(w, h)
	{
		var a = [];
		var center = {x: 80, y: h/2 - 80}
		
		for (var i=0;i<120;++i)
		{
			var xo = i*2;
			var xo2 = i*2;
			var yo = 40 + Math.abs(Math.sin(i/Math.PI/2 + Math.PI/2)*30);
			var yo2 = Math.sin(i*Math.PI/60)*100 + 100;
			var points = [{x: center.x + xo, y: center.y + yo},{x: center.x-10, y: center.y+90},{x: center.x + xo2, y: center.y + yo2}];
			a.push({vertices: points, circle: circle3pt(points[0], points[1], points[2])});
		}
		return a;
	}
	
	
	OMG_Circles.create("#example01", example01_generator, OMG_Circles.style.plain);
	
	OMG_Circles.create("#example02_plain", example02_generator, OMG_Circles.style.plain);
	OMG_Circles.create("#example02_shaded", example02_generator, OMG_Circles.style.shaded);
	OMG_Circles.create("#example02_line", example02_generator, OMG_Circles.style.line);
	
	OMG_Circles.create("#example03_plain", example03_generator, OMG_Circles.style.plain);
	OMG_Circles.create("#example03_shaded", example03_generator, OMG_Circles.style.shaded);
	OMG_Circles.create("#example03_line", example03_generator, OMG_Circles.style.line);
	
	OMG_Circles.create("#example04_plain", example04_generator, OMG_Circles.style.plain);
	OMG_Circles.create("#example04_shaded", example04_generator, OMG_Circles.style.shaded);
	OMG_Circles.create("#example04_line", example04_generator, OMG_Circles.style.line);
});

</script>

### Jumping into Code

This is my Javascript implementation of the algorithm. The function **circle3pt** takes three points in two-dimensional space, and from those points algorithmically calculates the properties of the circle we want. If there isn't a solution to the inputs--like feeding it a straight line, **something a circle couldn't possibly fit**--the function will return false.  Otherwise it returns these properties about our circle:

 * Center point of the circle: (x, y)
 * Radius of circle: r

{% highlight javascript linenos %}
function circle3pt(p1, p2 /* middle */, p3)
{
	var yda = p2.y - p1.y;
	var xda = p2.x - p1.x;
	var ydb = p3.y - p2.y;
	var xdb = p3.x - p2.x;

	if (xda == 0 || xdb == 0)
		return false;

	var as = yda/xda;
	var bs = ydb/xdb;
	
	if (bs-as == 0 || as == 0)
		return false;

	var cx = (as*bs*(p1.y-p3.y) + bs*(p1.x + p2.x) - as*(p2.x+p3.x))/(2*(bs-as));
	var cy = -1*(cx - (p1.x+p2.x)/2)/as + (p1.y+p2.y)/2;
	var v = {x: p2.x-cx, y: p2.y-cy};
	return {x: cx, y: cy, r: Math.sqrt(v.x*v.x + v.y*v.y)};
}
{% endhighlight %}

### Example Usage

{% highlight javascript linenos %}
var circle = circle3pt({x: 100, y: 150},{x: 50, y: 35},{x: 75, y: 25});
var r = precision(circle.r, 2);
var x = precision(circle.x, 2);
var y = precision(circle.y, 2);
document.write("Circle centered at (" + x + ", " + y + ") with radius: " + r + ". ");
document.write("Equation (r^2 = x^2 + y^2): " + r + "^2 = " + x + "^2 + " + y + "^2");
{% endhighlight %}

<!-- more -->

Which outputs:

<script type="text/javascript">
var circle = circle3pt({x: 100, y: 150},{x: 50, y: 35},{x: 75, y: 25});
var r = precision(circle.r, 2);
var x = precision(circle.x, 2);
var y = precision(circle.y, 2);
document.write("Circle centered at (" + x + ", " + y + ") with radius: " + r + ". ");
document.write("Equation (r^2 = x^2 + y^2): " + r + "^2 = " + x + "^2 + " + y + "^2");
</script>

Visualizing it helps too, so I whipped up a tiny HTML5/Canvas circle visualizer (called OMG_Circles if you care to view source). The dots are the input points that we pass into **circle3pt**. To help you get your bearings, the green dot is the middle point of the three.

<canvas id="example01" width="175" height="175">
</canvas>

### More Examples

_We can go nuts and have fun with it too!_ It's very easy to create interesting spacial and color dynamics. All of it based off the 3 inputs to **circle3pt** and a little iteration.  Throw in a sinusoidal function or two and bam, unusual patterns start emerging all over the place and things really come to life.  For the curious adventurer types- all the code that is generating these visualizations is done inline of this page, so just view the source.

#### Visualization 1

<canvas id="example02_plain" width="300" height="400">
</canvas><canvas id="example02_shaded" width="300" height="400">
</canvas><canvas id="example02_line" width="300" height="400">
</canvas>

#### Visualization 2

<canvas id="example03_plain" width="300" height="400">
</canvas><canvas id="example03_shaded" width="300" height="400">
</canvas><canvas id="example03_line" width="300" height="400">
</canvas>

#### Visualization 3

<canvas id="example04_plain" width="300" height="400">
</canvas><canvas id="example04_shaded" width="300" height="400">
</canvas><canvas id="example04_line" width="300" height="400">
</canvas>


