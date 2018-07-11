var exec = require('cordova/exec');

const PLUGIN_NAME = 'AppleWallet';

var AppleWallet = {
    testFunc : function(phrase, cb) {
        exec(cb, null, PLUGIN_NAME, [phrase])
    }
}

module.exports = AppleWallet;