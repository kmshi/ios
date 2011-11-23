ig.module(
	'plugins.dc.loader'
)
.requires(
	'impact.loader'
)
.defines(function(){


ig.Loader.inject({	
	_currentResource: 0,
	
	load: function() {		
		if( !this.resources.length ) {
			this.end();
			return;
		}
		ig.system.context.clear();
		ig.system.context.present();
		for( var i = 0; i < this.resources.length; i++ ) {
			this.loadResource( this.resources[i] );
		}
	},
	
	end: function() {
		AppMobi.context.hideLoadingScreen();
		this.parent();
	}
});


});