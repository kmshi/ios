ig.module(
	'plugins.dc.image'
)
.requires(
	'impact.image'
)
.defines(function(){

ig.Image.inject({
    
	onload: function( event ) {
        this.width = this.data.width;
		this.height = this.data.height;
		
		if( ig.system.scale != 1 ) {
			this.resize( ig.system.scale );
		}
		this.loaded = true;
		
		if( this.loadCallback ) {
			this.loadCallback( this.path, true );
		}
        
        this.data.data.SetFrameSize(this.framewidth, this.frameheight);
	},
    
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
	},
    
	drawRotatedTile2: function( targetX, targetY, tile, flipX, flipY, translateX, translateY, rotateAngle ) {
		
		if( !this.loaded ) { return; }
		
		if( flipX || flipY ) {
			ig.system.context.save();
			ig.system.context.scale( scaleX, scaleY );
		}
		ig.system.context.drawRotatedImage2(
            this.data, 
            tile,
            targetX, 
            targetY,
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