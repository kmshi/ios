ig.module(
	'plugins.dc.system'
)
.requires(
	'impact.system'
)
.defines(function(){


ig.System.inject({
	init: function( canvasId, fps, width, height, scale ) {
		this.fps = fps;

		this.clock = new ig.Timer();
		this.canvas = Canvas;
		this.context = this.canvas.getContext('2d');
		this.resize( width, height, scale );
	},

	resize: function( width, height, scale ) {
		if(AppMobi.isnative) {
			this.width = width;
			this.height = height;
	
			this.realWidth = this.width * this.scale;
			this.realHeight = this.height * this.scale;
			this.context.width = this.width;
			this.context.height = this.height;
			this.context.globalScale = scale;
		} else {
			this.parent(width, height, scale);
		}
	},	

	run: function() {
		this.parent();
		this.context.present();
	}
	
});


});
