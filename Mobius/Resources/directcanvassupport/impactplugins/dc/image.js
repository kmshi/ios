ig.module(
	'plugins.dc.image'
)
.requires(
	'impact.image'
)
.defines(function(){


ig.Image.inject({
	drawRotatedTile: function( targetX, targetY, tile, tileWidth, tileHeight, flipX, flipY, translateX, translateY, rotateAngle ) {
		tileHeight = tileHeight ? tileHeight : tileWidth;
		
		if( !this.loaded || tileWidth > this.width || tileHeight > this.height ) { return; }
		
		var scale = ig.system.scale;
		var tileWidthScaled = tileWidth * scale;
		var tileHeightScaled = tileHeight * scale;
		
		var scaleX = flipX ? -1 : 1;
		var scaleY = flipY ? -1 : 1;
		
		if( flipX || flipY ) {
			ig.system.context.save();
			ig.system.context.scale( scaleX, scaleY );
		}
		ig.system.context.drawRotatedImage( 
			this.data, 
			( (tile * tileWidth).floor() % this.width ) * scale,
			( (tile * tileWidth / this.width).floor() * tileHeight ) * scale,
			tileWidthScaled,
			tileHeightScaled,
			ig.system.getDrawPos(targetX) * scaleX - (flipX ? tileWidthScaled : 0), 
			ig.system.getDrawPos(targetY) * scaleY - (flipY ? tileHeightScaled : 0),
			tileWidthScaled,
			tileHeightScaled,
			translateX,
			translateY,
			rotateAngle
		);
		if( flipX || flipY ) {
			ig.system.context.restore();
		}
	}
});	


});