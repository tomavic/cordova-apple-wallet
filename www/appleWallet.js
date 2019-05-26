var exec = require('cordova/exec');
var PLUGIN_NAME = 'AppleWallet';


var executeCallback = function(callback, message) {
    if (typeof callback === 'function') {
        callback(message);
    }
};

var AppleWallet = {

    /**
     * @function isAvailable
     * @description a function to determine if the current device supports Apple Pay Provision
     * @param {Function} [successCallback] - Optional success callback, recieves message object.
     * @param {Function} [errorCallback] - Optional error callback, recieves message object.
     * @returns {Promise<boolean>} - boolean value ensures that wallet is isAvailable
     */
    isAvailable: function(successCallback, errorCallback) {
        return new Promise(function(resolve, reject) {
            exec(function(message) {
                executeCallback(successCallback, message);
                resolve(message);
            }, function(message) {
                executeCallback(errorCallback, message);
                reject(message);
            }, PLUGIN_NAME, 'isAvailable', []);
        });
    },
    /**
     * @function checkCardEligibility
     * @description to check out if card eligable to be added
     * @param {primaryAccountIdentifier} [String] - Your card unique identifier that used in card in-app provisioning
     * @param {Function} [successCallback] - Optional success callback, recieves message object.
     * @param {Function} [errorCallback] - Optional error callback, recieves message object.
     * @returns {Promise<boolean>} boolean value ensures that card is eligable
     */
    checkCardEligibility: function(primaryAccountIdentifier, successCallback, errorCallback) {
        return new Promise(function(resolve, reject) {
            exec(function(message) {
                executeCallback(successCallback, message);
                resolve(message);
            }, function(message) {
                executeCallback(errorCallback, message);
                reject(message);
            }, PLUGIN_NAME, 'checkCardEligibility', [primaryAccountIdentifier]);
        });
    },
    /**
     * @function checkCardEligibilityBySuffix
     * @description a function to check existence and eligibility to add a card
     * @param {String} [cardSuffix] - The card number suffix ex: last 4 or 6 digits
     * @param {Function} [successCallback] - Optional success callback, recieves message object.
     * @param {Function} [errorCallback] - Optional error callback, recieves message object.
     * @returns {Promise<boolean>} boolean value ensures that card is eligable
     */
	checkCardEligibilityBySuffix: function(cardSuffix, successCallback, errorCallback) {
        return new Promise(function(resolve, reject) {
            exec(function(message) {
                executeCallback(successCallback, message);
                resolve(message);
            }, function(message) {
                executeCallback(errorCallback, message);
                reject(message);
            }, PLUGIN_NAME, 'checkCardEligibilityBySuffix', [cardSuffix]);
        });
    },
    /**
     * @function checkPairedDevices
     * @description to check if there is any paired devices so that you can toggle visibility of 'Add to Watch' button
     * @param {Function} [successCallback] - Optional success callback, recieves message object.
     * @param {Function} [errorCallback] - Optional error callback, recieves message object.
     * @returns {Promise<Object>} object contains boolean value that ensure that there is already a paired Watch
     */
    checkPairedDevices: function(successCallback, errorCallback) {
        return new Promise(function(resolve, reject) {
            exec(function(message) {
                executeCallback(successCallback, message);
                resolve(message);
            }, function(message) {
                executeCallback(errorCallback, message);
                reject(message);
            }, PLUGIN_NAME, 'checkPairedDevices', []);
        });
    },
    /**
     * @function checkPairedDevicesBySuffix
     * @description a function to check if there is any paired devices by suffix
     * @param {String} [cardSuffix] - The card number suffix ex: last 4 or 6 digits
     * @param {Function} [successCallback] - Optional success callback, recieves message object.
     * @param {Function} [errorCallback] - Optional error callback, recieves message object.
     * @returns {Promise<Object>} object contains boolean values that ensure that card is already exists in wallet or paired-watch
     */
    checkPairedDevicesBySuffix: function(cardSuffix, successCallback, errorCallback) {
        return new Promise(function(resolve, reject) {
            exec(function(message) {
                executeCallback(successCallback, message);
                resolve(message);
            }, function(message) {
                executeCallback(errorCallback, message);
                reject(message);
            }, PLUGIN_NAME, 'checkPairedDevicesBySuffix', [cardSuffix]);
        });
    },
    /**
     * @function startAddPaymentPass
     * @description a function with the configuration data as a param needed to instantiate a new PKAddPaymentPassViewController object.
     * @param {Object} [cardData] - an object implements cardData Interface
     * @param {Function} [successCallback] - Optional success callback, recieves message object.
     * @param {Function} [errorCallback] - Optional error callback, recieves message object.
     * @returns {Promise<Object>} - an object contains certificates and signatures
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
     * @description completion handler that takes encrypted card data returned from you server side, in order to get the final response from Apple to know if the card is added succesfully or not.
     * @param {Object} [encCardData] - an object implements encryptedCardData Interface
     * @param {Function} [successCallback] - Optional success callback, recieves message object.
     * @param {Function} [errorCallback] - Optional error callback, recieves message object.
     * @returns {Promise<String>} - A string value either 'success' or 'error'
     */
    completeAddPaymentPass: function(encCardData, successCallback, errorCallback) {
        return new Promise(function(resolve, reject) {
            exec(function(message) {
                executeCallback(successCallback, message);
                resolve(message);
            }, function(message) {
                executeCallback(errorCallback, message);
                reject(message);
            }, PLUGIN_NAME, 'completeAddPaymentPass', [encCardData]);
        });
    },
}

module.exports = AppleWallet;