ig.module(
	'plugins.dc.font'
)
.requires(
	'impact.font'
)
.defines(function(){


ig.Font.inject({
	load: function( loadCallback ) {
		if( this.loaded ) {
			if( loadCallback ) {
				loadCallback( this.path, true );
			}
			return;
		}
		else if( !this.loaded && ig.ready ) {
			this.loadCallback = loadCallback || null;
			this.data = new _native.Font( this.path, this.onload.bind(this) );
		}
		else {
			ig.addResource( this );
		}
		ig.Image.cache[this.path] = this;
	},

	onload: function( width, height ) {
		this.width = width;
		this.height = height;
		this.loaded = true;
		
		if( this.loadCallback ) {
			this.loadCallback( this.path, true );
		}
	},

	draw: function( text, x, y, align ) {
		if( !this.loaded ) { return; }
		ig.system.context.drawFont(this.data,text.toString(),x,y,(align||0));
	}
});


});