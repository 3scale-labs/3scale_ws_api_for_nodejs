try {
	try{
    	module.exports = require('./o3.node').root
	} catch(ex) {
    	module.exports = require('../build/default/o3.node').root
	}
} catch (ex) {
    if (process.platform == "cygwin")
		module.exports = require('./o3-win32.node').root;
	else if (process.platform == "darwin") 
        module.exports = require('./o3-osx64.node').root;
    else{
        try{ 	                           
            module.exports = require('./o3-lin32.node').root;
        } catch(x){
            module.exports = require('./o3-lin64.node').root;
        }
    }
}
