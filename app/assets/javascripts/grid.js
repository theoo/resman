// Grid class
var Grid = Class.create({

initialize: function(parent, cols, rows, tile_size)
{
  // Params
  this.parent = parent;
  this.cols = cols;
  this.rows = rows;
  this.tile_size = tile_size;
  this.max_width  = this.cols * this.tile_size;
  this.max_height = this.rows * this.tile_size;  

  // Canvas
  this.canvas = Raphael(this.parent, this.max_width, this.max_height);
},

set_handlers: function(handlers)
{
  this.handlers = handlers;
},

apply_handlers: function(element, properties)
{
  for(i in this.handlers)
    (function(func){ Element.observe(element.node, i, function(event){ func(event, element, properties); }); })(this.handlers[i]);
},

add_item: function(properties)
{
  switch(properties.type)
  {
    case 'block':
    {
    	var block = this.canvas.rect(properties.rect[0] * this.tile_size, properties.rect[1] * this.tile_size, properties.rect[2] * this.tile_size, properties.rect[3] * this.tile_size);
    	block.attr({fill: properties.color, 'stroke-width': 0});
    	if(properties.fade)
    	{
    	  var color = Raphael.getRGB(properties.color);
    	  function h(N) {
         if (N==null) return "00";
         N=parseInt(N); if (N==0 || isNaN(N) || N < 0) return "00";
         N=Math.max(0,N); N=Math.min(N,255); N=Math.round(N);
         return "0123456789ABCDEF".charAt((N-N%16)/16)
              + "0123456789ABCDEF".charAt(N%16);
        }
        var n = 100;
        var to = '#' + h(color.r - n) + h(color.g - n) + h(color.b - n);
        var fadeout = function(b){ block.animate({fill: to}, 2000, fadein); };
        var fadein  = function(b){ block.animate({fill: properties.color}, 2000, fadeout); };
        fadeout(block);
  	  }
    	this.apply_handlers(block, properties);
      return block;
    }
    case 'text':
    {
      var adapt = properties.value.toString().length == 1 ? this.tile_size/4 : 0;
      if(properties.value.toString().match(/[a-z]+/i))
        adapt = this.tile_size/3;
      var text = this.canvas.text(properties.x * this.tile_size + adapt, properties.y * this.tile_size + this.tile_size/2, properties.value);
      text.attr({fill: properties.color, font: '12px Verdana', 'text-anchor': properties.align == 'center' ? 'middle' : 'start'});
    	//this.apply_handlers(text, properties);
      return text;
    }
    case 'line':
    {
      var line = this.canvas.path({stroke: properties.color, 'stroke-width': properties.width}).moveTo((properties.x1 * this.tile_size) + 0.5, properties.y1 * this.tile_size).lineTo((properties.x2 * this.tile_size) + 0.5, properties.y2 * this.tile_size);
    	//this.apply_handlers(line, properties);
      return line;
    }
  }  
},

add_items: function(items)
{  
  for(var i = 0; i < items.length; ++i)
    this.add_item(items[i]);
}

}); // Class.create
