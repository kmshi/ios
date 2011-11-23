// this code dumps out the direct canvas object tree

function dump(arr,level) {
    var dumped_text = "";
    if(!level) level = 0;
    
    var level_padding = "";
    for(var j=0;j<level+1;j++) level_padding += "    ";
    
    if(typeof(arr) == 'object') {  
        for(var item in arr) {
            var value = arr[item];
            
            if(typeof(value) == 'object') { 
                dumped_text += level_padding + "'" + item;
                if(this!=value)dumped_text += "' ...\n" + dump(value,level+1);//do not recurse
				else dumped_text += " (self)" + "' ...\n";
            } else if(typeof(value) == 'function') {
                dumped_text += level_padding + "'" + item + "' => \"" + "(function)" + "\"\n";
            } else {
                dumped_text += level_padding + "'" + item + "' => \"" + value + "\"\n";
            }
        }
    } else { 
        dumped_text = "===>"+arr+"<===("+typeof(arr)+")";
    }
    return dumped_text;
}

//var theDump = dump(window);
//console.log("theDump: " + theDump);
