var exec = require('cordova/exec');
var PLUGIN_NAME = 'AppleWallet';


var executeCallback = function(callback, message) {
    if (typeof callback === 'function') {
        callback(message);
    }
};

var AppleWallet = {

    /**
     * @function available
     * @description Determines if the current device supports Apple Pay and has a supported card installed.
     * @param {Function} [successCallback] - Optional success callback, recieves message object.
     * @param {Function} [errorCallback] - Optional error callback, recieves message object.
     * @returns {Promise}
     */
    available: function(successCallback, errorCallback) {
        return new Promise(function(resolve, reject) {
            exec(function(message) {
                executeCallback(successCallback, message);
                resolve(message);
            }, function(message) {
                executeCallback(errorCallback, message);
                reject(message);
            }, PLUGIN_NAME, 'available', []);
        });
    },

    /**
     * @function startAddPaymentPass
     * @description takes card baisc data and init viewController
     * @param {Function} [successCallback] - Optional success callback, recieves message object.
     * @param {Function} [errorCallback] - Optional error callback, recieves message object.
     * @returns {Promise}
     */
    startAddPaymentPass: function(cardData, successCallback, errorCallback) {
        return new Promise(function(resolve, reject) {
            exec(function(message) {
                executeCallback(successCallback, message);
                resolve(message);
            }, function(message) {
                executeCallback(errorCallback, message);
                reject(message);
            }, PLUGIN_NAME, 'startAddPaymentPass', [cardData]);
        });
    },

    /**
     * @function completeAddPaymentPass
     * @description takes OTP data with encrypted data from Apple and enures card addition
     * @param {Function} [successCallback] - Optional success callback, recieves message object.
     * @param {Function} [errorCallback] - Optional error callback, recieves message object.
     * @returns {Promise}
     */
    completeAddPaymentPass: function(someData, successCallback, errorCallback) {
        return new Promise(function(resolve, reject) {
            exec(function(message) {
                executeCallback(successCallback, message);
                resolve(message);
            }, function(message) {
                executeCallback(errorCallback, message);
                reject(message);
            }, PLUGIN_NAME, 'completeAddPaymentPass', [someData]);
        });
    },
}

module.exports = AppleWallet;