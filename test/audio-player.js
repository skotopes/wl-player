var AudioPlayer = function () {
	var instances = [];
	var activePlayerID;
	var playerURL = "";
	var defaultOptions = {};
	var currentVolume = -1;
	
	function getPlayer(playerID) {
		if (document.all && !window[playerID]) {
			for (var i = 0; i < document.forms.length; i++) {
				if (document.forms[i][playerID]) {
					return document.forms[i][playerID];
					break;
				}
			}
		}
		return document.all ? window[playerID] : document[playerID];
	}
	
	function addListener (playerID, type, func) {
		getPlayer(playerID).addListener(type, func);
	}
	
	return {
		setup: function (url, options) {
			playerURL = url;
			defaultOptions = options;
			if (defaultOptions.hasOwnProperty('playerWidth')) {
			  defaultOptions.width = defaultOptions.playerWidth;
			}
			if (defaultOptions.hasOwnProperty('playerHeight')) {
			  defaultOptions.height = defaultOptions.playerHeight;
			}
		},
    
    onPlay: function(playerID) {
      // console.log('play', playerID);
      for (var i=0, l=instances.length; i<l; i++) {
        if (instances[i] != playerID) {
          this.getPlayer(instances[i]).pause();
        }
      }
    },
    
    onPause: function(playerID) {
      // console.log('pause', playerID);
    },
    
		getPlayer: function (playerID) {
			return getPlayer(playerID);
		},
		
		addListener: function (playerID, type, func) {
			addListener(playerID, type, func);
		},
		
		embed: function (elementID, options) {
			var instanceOptions = {};
			var key;
			var so;
			var bgcolor;
			var wmode;
			
			var flashParams = {};
			var flashVars = {};
			var flashAttributes = {};
	
			// Merge default options and instance options
			for (key in defaultOptions) {
				instanceOptions[key] = defaultOptions[key];
			}
			for (key in options) {
				instanceOptions[key] = options[key];
			}
			
			if (instanceOptions.transparentpagebg == "yes") {
				flashParams.bgcolor = "#FFFFFF";
				flashParams.wmode = "transparent";
			} else {
				if (instanceOptions.pagebg) {
					flashParams.bgcolor = "#" + instanceOptions.pagebg;
				}
				flashParams.wmode = "opaque";
			}
			
			flashParams.menu = "false";
			
			for (key in instanceOptions) {
				if (key == "pagebg" || key == "width" || key == "height" || key == "transparentpagebg") {
					continue;
				}
				flashVars[key] = instanceOptions[key];
			}
			
			flashAttributes.name = elementID;
			flashAttributes.style = "outline: none";
			
			flashVars.playerID = elementID;
			
			swfobject.embedSWF(playerURL, elementID, instanceOptions.width.toString(), instanceOptions.height.toString(), "9", false, flashVars, flashParams, flashAttributes);
			
			instances.push(elementID);
		}
		
	}
	
}();
