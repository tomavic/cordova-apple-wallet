var exec = require('cordova/exec');

const PLUGIN_NAME = 'AppleWallet';

var AppleWallet = {
    echo : function(phrase, cb) {
//         exec(cb, null, PLUGIN_NAME, [phrase]);
        exec(cb, null, PLUGIN_NAME, []);
    }
}

module.exports = AppleWallet;
