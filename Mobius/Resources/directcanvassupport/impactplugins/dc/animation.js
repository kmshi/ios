ig.module(
	'plugins.dc.animation'
)
.requires(
	'impact.animation'
)
.defines(function(){


ig.Animation.inject({
	update: function() {
		var frameTotal = (this.timer.delta() / this.frameTime).floor();
		this.loopCount = (frameTotal / this.sequence.length).floor();
		if( this.stop && this.loopCount > 0 ) {
			this.frame = this.sequence.length - 1;
		}
		else {
			this.frame = frameTotal % this.sequence.length;
		}
		this.tile = this.sequence[ this.frame ];
	},

	draw: function( targetX, targetY ) {
		if(AppMobi.isnative) {
			var bbsize = Math.max(this.sheet.width, this.sheet.height);
			
			// On screen?
			if(
			   targetX > ig.system.width || targetY > ig.system.height ||
			   targetX + bbsize < 0 || targetY + bbsize < 0
			) {
				return;
			}
			
			if( this.angle == 0 ) {
				ig.system.context.drawImageTile( 
					this.sheet.image.data, 
					targetX, targetY, 
					this.tile,
					this.sheet.width, this.sheet.height, 
					this.flip.x, this.flip.y, this.alpha 
				);
			}
			else {
				this.sheet.image.drawRotatedTile(
					-this.pivot.x, -this.pivot.y,
					this.tile, this.sheet.width, this.sheet.height,
					this.flip.x, this.flip.y,
					targetX + this.pivot.x, targetY + this.pivot.y, this.angle				
				);
			}
		} else {
			this.parent( targetX, targetY );
		}
	}
});	


});