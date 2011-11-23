// Set up the global 'window' object
window = this; // Make 'window' the global scope

//allow binding
Function.prototype.bind = function(bind) {
	var self = this;
	return function(){
		var args = Array.prototype.slice.call(arguments);
		return self.apply(bind || null, args);
	};
};

AppMobi = {
	//event hook callbacks: AppMobi.wasShown, AppMobi.willBeHidden
	wasShown: function(){},
	willBeHidden: function(){},
	updateFPS: function(fps){},
	
	// AppMobi.context provides basic utility functions, such as timers
	// and device properties
	context: new _native.AppMobi(),
	
	//setup webview - provides access to parent AppMobiWebView
	webview: {
		//webview.execute to execute javascript in webview
		execute: function(js){ AppMobi.context.executeJavascriptInWebView(js); }
	},
	
	//setup canvas
	canvas: {
		context: new _native.ScreenCanvas(),
		getContext: function(){ return this.context; }
	},
    
    isnative: true
};

// temporary workaround for namespace change for DirectCanvas
AppMobi.native = AppMobi.context;

Canvas = AppMobi.canvas;

localStorage = new _native.LocalStorage();

devicePixelRatio = AppMobi.context.devicePixelRatio;
if( AppMobi.context.landscapeMode ) {
	innerWidth = AppMobi.context.screenWidth;
	innerHeight = AppMobi.context.screenHeight;
}
else {
	innerWidth = AppMobi.context.screenWidth;
	innerHeight = AppMobi.context.screenHeight;
}

screen = {
	availWidth: innerWidth,
	availHeight: innerHeight
};

navigator = {
	userAgent: AppMobi.context.userAgent
};

// AppMobi.context.log only accepts one param; console.log accepts multiple params
// and joins them
console = {
	log: function() {
		var args = Array.prototype.join.call(arguments, ', ');
		AppMobi.context.log( args );
	}
};

setTimeout = function(cb, t){ return AppMobi.context.setTimeout(cb, t); };
setInterval = function(cb, t){ return AppMobi.context.setInterval(cb, t); };
clearTimeout = function(id){ return AppMobi.context.clearTimeout(id); };
clearInterval = function(id){ return AppMobi.context.clearInterval(id); };


// The native Audio class mimics the HTML5 Audio element; we
// can use it directly as a substitute 
Audio = _native.Audio;

// Set up a fake HTMLElement and document object, so DirectCanvas is happy
HTMLElement = function( tagName ){ 
	this.tagName = tagName;
	this.children = [];
};

HTMLElement.prototype.appendChild = function( element ) {
	this.children.push( element );
	
	// If the child is a script element, begin loading it
	if( element.tagName == 'script' ) {
		var id = AppMobi.context.setTimeout( function(){
			AppMobi.context.include( element.src ); 
			if( element.onload ) {
				element.onload();
			}
		}, 1 );
	}
};

Image = function() {
    var _src = '';
    /*
    failed: false,
    loadCallback: null,
     */
    
    this.prototype = new HTMLElement('image');

    this.data = null;
    this.src = null;//instead of path
    this.height = 0;
    this.width = 0;
    this.loaded = false;
    this.onabort = null;
    this.onerror = null;
    this.onload = null;//instead of loadCallback
    this._onload = function( width, height ) {
		this.width = width;
		this.height = height;
		this.loaded = true;
	};
    this._onload2 = function() {
		if( this.onload ) {
			this.onload( this.src, true );
		}
	};
    this.__defineGetter__("src", function(){
        return _src;
    });
    
    this.__defineSetter__("src", function(val){
        _src = val;
        this.data = new _native.Texture( this.src, this._onload.bind(this) );
        this._onload2();//call after assigning this.data, which needs to be available for the onload
    });
    
    return this;
}

document = {
	location: { href: 'index' },
	
	head: new HTMLElement( 'head' ),
	body: new HTMLElement( 'body' ),
	
	createElement: function( name ) {
		if( name == 'canvas' ) {
			return new _native.Canvas();
		} else if ( name == 'image') {
			return new Image();
        } else {
            return new HTMLElement( 'script' );
        }
	},
	
	getElementById: function( id ){	
		return null;
	},
	
	getElementsByTagName: function( tagName ){
		if( tagName == 'head' ) {
			return [document.head];
		}
	},
	
	addEventListener: function( type, callback ){
		if( type == 'DOMContentLoaded' ) {
			setTimeout( callback, 1 );
		}
	}
};
addEventListener = function( type, callback ){};


