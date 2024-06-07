/**
 * INITIALIZE CCRZ namespace
 */
if(!this.CCRZ) {
	this.CCRZ = {};
}
//console.debug('initialized CCRZ');

(function(CCRZ, $) {

	CCRZ.VERSION = "3.85";

	CCRZ.pagevars = {};

	CCRZ.remoteAction = {};

	CCRZ.models = {};

	CCRZ.collections = {};

	CCRZ.data = {};

	CCRZ.views = {};

	CCRZ.templates = {};

	CCRZ.dynamicViews = [];

	CCRZ.root = this;

	CCRZ.console = function(){
		var retVer = {
			log:function(){},
			debug: function(){},
			info: function(){},
			warn: function(){},
			error:function(){},
			assert:function(){},
			dir:function(){},
			dirxml:function(){},
			trace:function(){},
			group:function(){},
			groupEnd:function(){},
			time:function(){},
			timeEnd:function(){},
			profile:function(){},
			count:function(){}
		};

		try{
			if(CCRZ.logOn){
				// retVer = ('console' in window)?window.console:retVer;
				if('console' in window){
					retVer = _.extend(retVer,{
						log:function(msg,lvl,tm,sub,l){
							var smsg = _.isUndefined(msg)?'undefined':(_.isObject(JSON)?JSON.stringify(msg):msg);
							window.console.log('['+(l||'c')+']['+(tm||(new Date()).getTime())+']['+(lvl||'DEBUG')+']['+(sub||'none')+'] '+smsg);
						}
					});
				}
			}
		}catch(e){}
		return retVer;
	}();

	CCRZ.util = {
		template: function(id) {
			var source = $('#' + id).html();
			source = _.isUndefined(source)?'':source;
			return Handlebars.compile(source);
		}
	};

	//Adds createView function to CCRZ.util.  Pass an object of the form
	 // {
	 //		desktop:{
	 //		   template: 'mydesktoptemplate',
	 //		   target: 'mydesktoptarget'
	 //		},
	 //		tablet:{
	 //		   template: 'mytablettemplate',
	 //		   target: 'mytablettarget'
	 //		},
	 //		phone:{
	 //		   template: 'myphonetemplate',
	 //		   target: 'myphonetarget'
	 //		}
	 // }
	 // To fully specify.  In addition, any of the Backbone functions can be provides in the passed object as well including
	 // any functions that should be defined as part of CCRZ.CloudCraze.view
	 // If absolutely nothing is defined then desktop template will be 'Standard-View-Desktop', the target will be standardDesktopContainer
	 // and the tablet will use the desktop as the reference.  In all cases the div with the class phone_center_column will be used unless
	 // specifically set to something different.
	 // The templates and targets have a fallback mechanism in that if nothing is defined for the tablet then the desktop will be used.	 If nothing
	 // is defined for the phone then the tablet will be used (except as noted above).
	 // Finally, if the template follows a standard pattern XXXX-View-YYYY where XXXX is some name and YYYY is Desktop, Tablet, or Phone
	 // then a templatePrefix can be specified.
	 //@TODO - Incorporate this into the template definition from above
	 CCRZ.util = _.extend(CCRZ.util||{},function(){
	 //TODO - Turn this into a jquery function $.ccrz()
		 var ex = function(o){
			 var ret = $(o);
			 return (0===ret.length)?false:ret;
		 }
		 var fr = function(nm){//util func, searches passed object, by id, by class, then returns false
			 return ex(nm)||ex('#'+nm)||ex('.'+nm)||false;
		 };
		 var ro = function(defs,fallback){//realize the template object and target
			 fallback = fallback||{template:false,target:false};
			 var templateResolved = fr(defs.template);
			 if(templateResolved){
				 defs.template = Handlebars.compile(templateResolved.html());
			 }else{
				 defs.template = fallback.template;
			 }
			 defs.target = fr(defs.target)||fallback.target;
			 return defs;
		 };

		 var rndr = function(cnf){
			 this.setElement(cnf.target);
			 this.$el.html(cnf.template(this.model.toJSON()));
		 };

		 return{
			 createView: function(viewConf){
				 viewConf = viewConf||{};
				 var lconf = _.extend({desktop:{},tablet:{},phone:{},templatePrefix:false},viewConf);//Start with an empty config, then add viewConf
				 var tmplPrefix = lconf.templatePrefix;
				 if(tmplPrefix){//if a prefix is defined default if not already specified
					 lconf.desktop = _.defaults(lconf.desktop,{template:tmplPrefix + '-View-Desktop'});
					 if(!CCRZ.disableAdaptive){
						 lconf.tablet  = _.defaults(lconf.tablet, {template:tmplPrefix + '-View-Tablet'});
						 lconf.phone   = _.defaults(lconf.phone,  {template:tmplPrefix + '-View-Phone'});
					 }
				 }else{
					 lconf.desktop = _.defaults(lconf.desktop,{template:'Standard-View-Desktop'});
				 }
				 lconf.desktop = _.defaults(lconf.desktop,{target:'standardDesktopContainer'});
				 if(!CCRZ.disableAdaptive){
					 lconf.phone = _.defaults(lconf.phone,{target:fr('.phone_center_column')});//Define standard phone target if not already defined
				 }

				 ro(lconf.desktop);//Define desktop config with no defaults (they are set previously)
				 if(!CCRZ.disableAdaptive){
					 ro(lconf.tablet,lconf.desktop);//Define tablet config, fallback to desktop
					 ro(lconf.phone,lconf.tablet);//Define phone config, fallback to tablet
				 }

				 //If the desktop and table targets and templates are the same we don't need to provide the default rendering behavior
				 //Since this will reset the display
				 if((lconf.desktop.target == lconf.tablet.target) && (lconf.desktop.template == lconf.tablet.template)){
					 return new (CCRZ.CloudCrazeView.extend(_.extend({
							init: function(){
								this.render();
							},
							renderPhone	 : _.partial(rndr,lconf.phone),
							renderDesktop: _.partial(rndr,lconf.desktop),
							model : new (Backbone.Model.extend({}))()
						 },viewConf)))();
				 }else{
					 return new (CCRZ.CloudCrazeView.extend(_.extend({
							init: function(){
								this.render();
							},
							renderPhone	 : _.partial(rndr,lconf.phone),
							renderTablet : _.partial(rndr,lconf.tablet),
							renderDesktop: _.partial(rndr,lconf.desktop),
							model : new (Backbone.Model.extend({}))()
						 },viewConf)))();
					 }
			 }
		};
	 }());


	CCRZ.display = (function(){
		var baseline = {
				isPhone: function(){return false;},
				isTablet: function(){return false;},
				isDesktop: function(){return true;},
				currentView: '',
				setCurrentView: function() {
					if(this.isPhone()) {
						this.currentView = 'phone';
					} else if(this.isTablet()) {
						this.currentView = 'tablet';
					} else if(this.isDesktop()) {
						this.currentView = 'desktop';
					}
				}
		};
		if(!CCRZ.disableAdaptive){
			if(Modernizr.mq('only all')){//IE8 returns false here
				baseline.isPhone   = function() { return Modernizr.mq('(max-width: 584px)'); };
				baseline.isTablet  = function() { return Modernizr.mq('(min-width: 585px) and (max-width: 800px)'); };
				baseline.isDesktop = function() { return Modernizr.mq('(min-width: 801px)'); };
			}else if(('documentElement' in document) && ('clientWidth' in document.documentElement)){
				var sw = function(min,max){
					try{
						min = min||0;
						max = max||100000;
						return (document.documentElement.clientWidth>min && document.documentElement.clientWidth<max);
					}catch(e){return false;}
				};
				baseline.isPhone  = function(){return sw(0,585);};
				baseline.isTablet = function(){return sw(585,800);};
				baseline.isDesktop = function(){return sw(801);};
			}
		}
		return baseline;
	})();

	CCRZ.handleModalDisplay = function() {
		if(!Modernizr.input.placeholder){
			$('[placeholder]').on('focus', (function() {
				var input = $(this);
				if (input.val() == input.attr('placeholder')) {
					input.val('');
					input.removeClass('placeholder');
				}
			})).blur(function() {
				var input = $(this);
				if (input.val() == '' || input.val() == input.attr('placeholder')) {
					input.addClass('placeholder');
					input.val(input.attr('placeholder'));
				}
			}).blur();
			$('[placeholder]').parents('form').submit(function() {
				$(this).find('[placeholder]').each(function() {
					var input = $(this);
					if (input.val() == input.attr('placeholder')) {
						input.val('');
					}
				});
			});
		}
	};

	/**
	 * CCRZ functions
	 */

	CCRZ.getQueryParam = function(name) {
		//name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
		var regexS = "[\\?&]" + name + "=([^&#]*)";
		var regex = new RegExp(regexS);
		var results = regex.exec(window.location.href);
		if(results !== null) {
			return results[1];
		}
		return "";
	};

	CCRZ.buildQueryString = function (inputQueryString){
		var queryString = inputQueryString;

		if(inputQueryString.toLowerCase().indexOf("cartid") === -1 && CCRZ.pagevars.currentCartID) {
			queryString ? queryString += '&' : queryString += '?';
			queryString += 'cartId=' + CCRZ.pagevars.currentCartID;
		}
		if(inputQueryString.toLowerCase().indexOf("portaluser") === -1 && CCRZ.pagevars.portalUserId) {
			queryString ? queryString += '&' : queryString += '?';
			queryString += 'portalUser=' + CCRZ.pagevars.portalUserId;
		}
		if(inputQueryString.toLowerCase().indexOf("store") === -1 && CCRZ.pagevars.storeName) {
			queryString ? queryString += '&' : queryString += '?';
			queryString += 'store=' + CCRZ.pagevars.storeName;
		}
		if(inputQueryString.toLowerCase().indexOf("effectiveaccount") === -1 && CCRZ.pagevars.effAccountId) {
			queryString ? queryString += '&' : queryString += '?';
			queryString += 'effectiveAccount=' + CCRZ.pagevars.effAccountId;
		}
		if(inputQueryString.toLowerCase().indexOf("grid") === -1 && CCRZ.pagevars.priceGroupId) {
			queryString ? queryString += '&' : queryString += '?';
			queryString += 'grid=' + CCRZ.pagevars.priceGroupId;
		}
		if(inputQueryString.toLowerCase().indexOf("cclcl") === -1 && CCRZ.pagevars.userLocale){
			queryString ? queryString += '&' : queryString += '?';
			queryString += 'cclcl=' + CCRZ.pagevars.userLocale;
		}

		return queryString;
	};

	CCRZ.setCookie = function(c_name, value, expiredays) {
		//alert('Cookie Name :' + c_name + ' Value :' + value);
		var exdate = new Date();
		exdate.setDate(exdate.getDate() + expiredays);
		document.cookie = c_name + "=" + window.escape(value) + ";secure;samesite=strict;" + ((expiredays === null) ? "" : ";expires=" + exdate.toGMTString());
	};

	CCRZ.setCookieWithPath = function(c_name, value, expiredays, path) {
		var exdate = new Date();
		exdate.setDate(exdate.getDate() + expiredays);
		document.cookie = c_name + "=" + window.escape(value) + ";secure;samesite=strict;" + ((expiredays === null) ? "" : ";expires=" + exdate.toGMTString())+";path="+path;
	};

	CCRZ.getCookie = function(c_name) {
		if (document.cookie.length > 0) {
			var c_start = document.cookie.indexOf(c_name + "=");
			if (c_start !== -1) {
				c_start = c_start + c_name.length + 1;
				var c_end = document.cookie.indexOf(";", c_start);
				if (c_end === -1) {
					c_end = document.cookie.length;
				}
				return window.unescape(document.cookie.substring(c_start, c_end));
			}
		}
		return "";
	};

	CCRZ.checkCookie = function() {
		var username = this.getCookie('username');
		if (username !== null && username !== "") {
			window.alert('Welcome again ' + username + '!');
		} else {
			username = window.prompt('Please enter your name:', "");
			if (username !== null && username !== "") {
				this.setCookie('username', username, 365);
			}
		}
	};

	CCRZ.numbersonly = function(e) {
		var isValid = true;
		var unicode = e.charCode ? e.charCode : e.keyCode;
		if(unicode !== 8) { // if the key isn't the backspace key (which we should allow)
			if(unicode < 48 || unicode > 57) { // if not a number
				isValid = false; //disable key press
			}
		}
		return isValid;
	};

	 /* PO Attachment Changes Begin */
	CCRZ.showAttachmentSection = function(){
		jQuery("#attholder").show();
		jQuery("#attachmentSection").show();
		jQuery("#attpopup").show();
		return false;
	};

	CCRZ.hideAttachmentSection = function() {
		jQuery("#attholder").hide();
		jQuery("#attachmentSection").hide();
		jQuery("#attpopup").hide();
		return false;
	};

	CCRZ.resetAttachmentSection = function(){
		document.getElementById('attachmentSection').innerHTML = document.getElementById('attachmentSection').innerHTML;
		CCRZ.hideAttachmentSection();
	};
	/* PO Attachment Changes End */

	CCRZ.searchFocus = function(element) {
		if (element.value === element.defaultValue) {
			element.value = '';
		}
	};

	CCRZ.searchBlur = function(element) {
		if (element.value === '') {
			element.value = element.defaultValue;
		}
	};

	CCRZ.noenter = function(ev)	 {
		if (window.event && window.event.keyCode === 13 || ev.which === 13) {
			performSearch();
			return false;
		} else {
			return true;
		}
	};

	CCRZ.createPageMessage = function(severity, classToAppend, msgLabel) {
		var errContext = new Object();
		errContext.messages = new Array();
		var message = new Object();
		message.type = 'CUSTOM';
		message.classToAppend = classToAppend;
		message.severity = severity;
		if (CCRZ.pagevars.pageLabels[msgLabel])
			message.message = CCRZ.pagevars.pageLabels[msgLabel];
		else
			message.message = msgLabel;
		errContext.messages[0] = message;
		return errContext;
	};

	CCRZ.createPageMessageBean = function(severity, classToAppend, msgLabel) {
		var message = new Object();
		message.type = 'CUSTOM';
		message.classToAppend = classToAppend;
		message.severity = severity;
		if (CCRZ.pagevars.pageLabels[msgLabel])
			message.message = CCRZ.pagevars.pageLabels[msgLabel];
		else
			message.message = msgLabel;
		return message;
	};

	CCRZ.getPageConfig = function(configName, defaultVal) {
		configName = configName.toLowerCase();
		if (CCRZ.pagevars.pageConfig == null || CCRZ.pagevars.pageConfig[configName] == null)
			return defaultVal;
		else {
			var configVal = CCRZ.pagevars.pageConfig[configName];
			if (configVal.toLowerCase() == 'true')
				return true;
			else if (configVal.toLowerCase() == 'false')
				return false;
			else
				return configVal;
		}
	};

	CCRZ.handleValidationErrors = function(event, validator, sectionClass, buildErrorsOnly, additionalErrors) {
		if (validator && validator.numberOfInvalids() && validator.errorList.length > 0) {
			var errContext = new Object();
			errContext.messages = new Array();
			if (!buildErrorsOnly)
				errContext = CCRZ.createPageMessage('ERROR', sectionClass, 'FIELD_VALIDATION_ERRORS');
			for (var x=0;x<validator.errorList.length;x++)
				errContext.messages[x+1] = CCRZ.createPageMessageBean('ERROR', sectionClass, validator.errorList[x].message);
			if (buildErrorsOnly)
				return errContext.messages;
			else {
				if (additionalErrors)
					errContext.messages.concat(additionalErrors);
				CCRZ.pubSub.trigger("pageMessage", errContext);
				$("." + sectionClass).show();
			}
		}
		else if (additionalErrors) {
			errContext = CCRZ.createPageMessage('ERROR', sectionClass, 'FIELD_VALIDATION_ERRORS');
			errContext.messages.concat(additionalErrors);
			CCRZ.pubSub.trigger("pageMessage", errContext);
			$("." + sectionClass).show();
		}
		else {
			if (buildErrorsOnly)
				return null;
			else
				$("." + sectionClass).hide();
		}
	};

	CCRZ.display.setCurrentView();

	//TEJ
	CCRZ.remoting = _.extend(CCRZ.remoting||{},{
		rbind: _.bind(_.bind,_,Visualforce.remoting.Manager.invokeAction,Visualforce.remoting.Manager),
		remoteBind: function(ctrl,methods){
			if(ctrl && methods){
				var ctrlObj = CCRZ[ctrl]||{};
				CCRZ[ctrl] = ctrlObj;
				$.each(methods,function(){
					ctrlObj[this.m] = CCRZ.remoting.rbind(this.r);
				});
			}
		}
	});

	CCRZ.processPageLabelMap = function(labelName, params) {
		var retLabel;

		if (labelName) {
			if (!CCRZ.pagevars.storeSettings.DisplayPageLabelNames__c && CCRZ.pagevars.pageLabels && !_.isUndefined(CCRZ.pagevars.pageLabels[labelName])){
				retLabel = CCRZ.pagevars.pageLabels[labelName];
				if(_.isNull(retLabel)){
					retLabel = '';
				}else if (!_.isUndefined(params) && params.length > 0) {
					retLabel = new Handlebars.SafeString(substitute(retLabel,params));
				} else {
					retLabel = new Handlebars.SafeString(retLabel);
				}
			} else {
				if (CCRZ.pagevars.storeSettings.DisplayPageLabelNames__c){
					retLabel = "[" + labelName + "]";
				}else{
					retLabel = labelName;
			}
		}
		}

		if(!retLabel) {
			retLabel = '';
		}

		return retLabel;
	};

	CCRZ.insertTokens = function(displayText, params) {
		var retLabel = displayText;

		if (retLabel)
		{
			if (!_.isUndefined(params) && params.length > 0) {
				retLabel = new Handlebars.SafeString(substitute(retLabel,params));
			} else {
				retLabel = new Handlebars.SafeString(retLabel);
			}
		}

		return retLabel;
	};

	CCRZ.processImageURL = function(obj, styleClass, options) {
		var lobj = obj||{};
		var imgSrc = "";
		if (lobj.sourceType === "Attachment"){
			imgSrc = CCRZ.pagevars.attachmentURL + lobj.uri;
		}else if (lobj.imageFullPath){
			imgSrc = lobj.imageFullPath;
		}else if (lobj.uri){
			imgSrc = lobj.uri;
		}else if (lobj.fullImageURL){
			imgSrc = lobj.fullImageURL;
		}
		return imgSrc;
	};

	CCRZ.pageLabelMultiString = function(labelName,params){
		var labelParams = Array.prototype.slice.call(params,2);
		for(var i =0; i<labelParams.length; i++)
		{
			labelParams[i] = _.escape(labelParams[i]);
		}

		if(_.isUndefined(params[1])){
			return CCRZ.processPageLabelMap(labelName);
		}else{
				return CCRZ.processPageLabelMap(labelName+params[1],labelParams);
		}
	};

	CCRZ.processPageLabelPrefixMap = function(prefix, labelName, params){
		var retLabel = false;
		if(prefix){
			var adjusted = prefix + labelName;
			if(CCRZ.pagevars.pageLabels[adjusted]){
				retLabel = CCRZ.processPageLabelMap(adjusted,params);
			}
		}

		if(false===retLabel){
			retLabel = CCRZ.processPageLabelMap(labelName,params);
		}

		return retLabel;
	};


	CCRZ.util.isValidNumericInput = function(event) {
		var isValid = false;
		var e = event || window.event;
		var key = e.keyCode || e.which;

		CCRZ.console.log('key=' + key);

		/*CCRZ-1956
		  In Firefox, special character events are still fired on keypress, so we need to allow a special set of them.
		  When these are fired, it breaks the convention of other browsers, and which is set to 0, and only e.keyCode is set
		  Normal number key presses, do not exibit this behavior and are mapped on e.which.
		*/
		//watch out for home/end/% (35/36/37 codes) keyCodes which do show up on FF
		if(e.which == 0 && (e.keyCode == 35 || e.keyCode == 36 || e.keyCode == 37) ){
			CCRZ.console.log('keyCode was 35,36, or 37');
			return true;
		}
		//also watch out for `/-/'/. (96/45/39/46/ codes) keyCodes which do show up on FF
		if(e.which == 0 && (e.keyCode == 96 || e.keyCode == 45 || e.keyCode == 39 || e.keyCode == 46) ){
			CCRZ.console.log('keyCode was 96,45, 39 or 46');
			return true;
		}

		//No special keys detected, or not FF...so we only need to check for the correct key press from e.which
		if (!e.altKey && !e.ctrlKey &&
			// numbers
			(key >= 48 && key <= 57) ||
			// Backspace and Tab and Enter
			key == 8 || key == 9 || key == 13 ){

				isValid = true;
		}
		return isValid;
	};

	CCRZ.util.scrubQuantity = function(qty, def) {
		var cleanQty = def || 1;

		if($.isNumeric(qty)) {
			var qtyFloat = parseFloat(qty);
			var qtyInt = parseInt(qty);
			if(CCRZ.pagevars.pageConfig.isTrue('c.noqty')){
				if(qtyInt >= 0 && qtyFloat === qtyInt) {
					cleanQty = qty;
				 }
			}else{
				if(qtyInt > 0 && qtyFloat === qtyInt) {
					cleanQty = qty;
				 }
			}
		}
		return cleanQty;
	}

	CCRZ.util.nmlook = function(nm){//Should this return false if something fails?
		var ctx = CCRZ.root;
		var ns = nm.split('.');
		var fnc = ns.pop();
		for(var i=0;i<ns.length;i++)ctx=ctx[ns[i]];
		return ctx[fnc];
	};

	CCRZ.util.formatPrice = function(p,c){
		return formatPrice(p,c);
	}

	//CCRZ-2214
	CCRZ.pagevars.queryParams = function(){
		var r = {};
		if(location.search){
			var s = location.search.slice(1).split('&');
			var i;
			for(i=0;i<s.length;i++){
				var p = s[i].split('=');
				var n = p[0];
				var v = decodeURIComponent(p[1] || '');
				if(r[n]){
					if(_.isArray(r[n])){
						r[n].push(v);
					}else{
						r[n] = [r[n],v];
					}
				}else{
					r[n] = v;
				}
			}
		}
		return r;
	}();

	CCRZ.reloadCurrentPage = function() {

		var shortURL = window.location.href;
		var reloadLocation = shortURL;
		//check for an existing cart id in the url (also make sure to resolve ID vs Id by forcing to match)
		var checkCartId = shortURL.replace('cartID=','cartId=').split('cartId=');

		//used to parse the parameters after the cartId
		var paramCartId = null;
		var paramEnd = null;

		//check if we have any existing cartID
		if(checkCartId.length > 1){
			//we have an existing cart ID, check if its blank
			var paramsString = checkCartId[1];
			//ensure that our url ends with an & to make future parsing easier
			if('&' !== paramsString.substr(-1)){
				paramsString = paramsString + '&';
			}

			//break up the url on the first parameter from cart id
			paramCartId = paramsString.substr(0,paramsString.indexOf('&'));
			paramEnd = paramsString.substr(paramsString.indexOf('&')+1);
			//check if there are any params after the cart Id
			if(!paramEnd){
				reloadLocation = checkCartId[0] + "cartId="+ CCRZ.pagevars.currentCartID + '&reloaded=true';
			}else{
				//if there are, then append them afterwards
				reloadLocation = checkCartId[0] + "cartId="+ CCRZ.pagevars.currentCartID + '&reloaded=true&' + paramEnd;
			}

		}else{
			//no previous existing cartID param, so add it

			//make sure the url properly inserts a ? if one is missing..
			if(shortURL.indexOf('?') >= 0){
				reloadLocation = shortURL+"&cartId=" + CCRZ.pagevars.currentCartID+"&reloaded=true";
			}else{
				reloadLocation = shortURL+"?cartId=" + CCRZ.pagevars.currentCartID+"&reloaded=true";
			}
		}

		CCRZ.console.log('reload url is: '+reloadLocation);
		document.location = reloadLocation;
	};

	CCRZ.reloadPageWithParam = function(urlParam, paramValue) {

		var shortURL = window.location.href;
		var reloadLocation = shortURL;


		//validate input parameters first
		if(!urlParam){
			//we didnt get a real valid url parameter or value so just reload
			CCRZ.console.log('no params, reload url is: '+reloadLocation);
			document.location = reloadLocation;
		}

		if(!paramValue){
			//we didnt get a param value, so treat it as a blank value
			paramValue = '';
		}


		//check for an existing parameter in the url       //(also make sure to resolve ID vs Id by forcing to match)
		var checkCartId = shortURL.split(urlParam);

		//used to parse the parameters after the cartId
		var paramCartId = null;
		var paramEnd = null;

		//check if we have any existing url param
		if(checkCartId.length > 1){
			//we have an existing url param, check if its blank
			var paramsString = checkCartId[1];
			//ensure that our url ends with an & to make future parsing easier
			if('&' !== paramsString.substr(-1)){
				paramsString = paramsString + '&';
			}

			//break up the url on the first parameter from cart id
			paramCartId = paramsString.substr(0,paramsString.indexOf('&'));
			//note that this trims off the old value of the parameter
			paramEnd = paramsString.substr(paramsString.indexOf('&')+1);
			//check if there are any params after the cart Id
			if(!paramEnd){
				reloadLocation = checkCartId[0] + urlParam + "=" + paramValue +'&';
			}else{
				//if there are, then append them afterwards
				reloadLocation = checkCartId[0] + urlParam + "=" + paramValue + '&' + paramEnd;
			}

		}else{
			//no previous existing url param, so add it

			//make sure the url properly inserts a ? if one is missing..
			if(shortURL.indexOf('?') >= 0){
				//reloadLocation = shortURL+"&cartId=" + CCRZ.pagevars.currentCartID+"&reloaded=true";
				  reloadLocation = shortURL+"&" + urlParam + "=" + paramValue;
			}else{
				//reloadLocation = shortURL+"?cartId=" + CCRZ.pagevars.currentCartID+"&reloaded=true";
				  reloadLocation = shortURL+"?" + urlParam + "=" + paramValue;
			}
		}

		CCRZ.console.log('reload url is: '+reloadLocation);
		document.location = reloadLocation;
	};

	//this method will attempt to set the url to the new url, WITHOUT reloading the page
	//NOTE: This method only works on HTML 5 supported browsers, otherwise this is a no op
	CCRZ.setURLNoReload = function(newURL) {
		if(window.history && window.history.replaceState){
			var stateObj = {};
			window.history.replaceState(stateObj, "", newURL);
		}
	};

	CCRZ.goToHomePage = function(url, isCanonical){
		var isCsr = CCRZ.pagevars.portalUserId ? true : false;
		if(isCsr) {
			var csrLanding = CCRZ.pagevars.pageConfig.get('hp.csrlanding') ? CCRZ.pagevars.pageConfig.get('hp.csrlanding') : 'homepage';
			url = '/apex/' + csrLanding;
		}

		const linkType = CCRZ.getPageConfig('hp.type', 'visualforce').toLowerCase();
		if(linkType === 'external'){
			// This returns the external URL- SF community requires for it to start with http for a full (not relative) path.
			url =  CCRZ.getPageConfig('hp.exturl', '');
		}else if(linkType === 'community' && !isCsr && url.indexOf('/s/') === -1){
			url += '/s/'; // Necessary to not lose parameters. i.e. /DefaultStore/s/
		} else {
			if (CCRZ.pagevars.namespace.length > 0) {
				url += '/' + CCRZ.pagevars.namespace.substring(0,CCRZ.pagevars.namespace.length-1) + '__HomePage';
			} else {
				url += '/HomePage';
			}
		}

		if(isCanonical){
			if(url.toLowerCase().indexOf("cclcl") === -1 && CCRZ.pagevars.userLocale){
				url += '?cclcl=' + CCRZ.pagevars.userLocale;
			}
		}else{
			url += CCRZ.buildQueryString('');
		}

		return linkType !== 'community' ? url : url.replace('cclcl', 'language');
	};

	CCRZ.goToPDP = function(objLink){
		var product = null;
		if (objLink !== null) {
			product = $(objLink).data("product");
		}
		if(product === null) {
			product = arguments[1];
		}
		var productSku;
		if(product.linkURL){
			productSku = product.linkURL; // This case handles CC Menu
		}else if(product.sku){
			productSku = product.sku; // This case handles PLP, PDP, Featured Products, CC Promo/Splash
		}else if(product.SKU){
			productSku = product.SKU; // This case handles LLI Checkout, PCP
		}else if(product.productSKU){
			productSku = product.productSKU; // This case handles LLI Order Detail
		}
		var productUrl = CCRZ.pageUrls.productDetails + CCRZ.buildQueryString("?sku=" + encodeURIComponent(productSku)); // OOTB PDP URL requires sku parameter - do not set the sku param for friendly URLs
		if(CCRZ.pagevars.useFriendlyUrls && !_.isUndefined(product.friendlyUrl)){
			// Use friendly URLs
			// If the friendly URL leads with a '/' and the currSiteURL trails with a '/' - make sure one of them gets removed before concatenating
			if (product.friendlyUrl.startsWith('/') && CCRZ.pagevars.currSiteURL.endsWith('/')) {
				product.friendlyUrl = product.friendlyUrl.substring(1);
			}
			productUrl = CCRZ.pagevars.currSiteURL + product.friendlyUrl + CCRZ.buildQueryString('');
		}
		return productUrl;
	};

	CCRZ.goToPLP = function(objLink){
		var category = null;
		if(objLink !== null) {
			category = $(objLink).data("category");
		}
		if(category === null) {
			category = arguments[1];
		}
		var categoryId;
		if(category.linkURL){
			categoryId = category.linkURL; // This case handles CC Menu
		}else if(category.id){
			categoryId = category.id; // This case handles Product List Page (Sub-categories)
		}else if(category.categoryId) {
			categoryId = category.categoryId; // This case handles CC Promos
		}else if(category.sfid) {
			categoryId = category.sfid; // This case handles Category Tree cache
		}else if(category.category){
		    categoryId = category.category.sfid; // This Case Handles The Breadcrumb
        }

		// OOTB PLP URL requires categoryid parameter - do not set the categoryid param for friendly URLs
		var categoryUrl = CCRZ.pageUrls.productList + CCRZ.buildQueryString("?categoryId=" + categoryId);
		if(CCRZ.pagevars.useFriendlyUrls && !_.isUndefined(category.friendlyUrl)){
			// Use friendly URLs
			// If the friendly URL leads with a '/' and the currSiteURL trails with a '/' - make sure one of them gets removed before concatenating
			if (category.friendlyUrl.startsWith('/') &&  CCRZ.pagevars.currSiteURL.endsWith('/')) {
				category.friendlyUrl = category.friendlyUrl.substring(1);
			}
			categoryUrl = CCRZ.pagevars.currSiteURL + category.friendlyUrl + CCRZ.buildQueryString('');
		}

		return categoryUrl;
	};

	CCRZ.reformatMedia = function(productMedia){
		//now set up the selected image
		productMedia.sourceType = productMedia.productMediaSource;
		productMedia.mediaName = productMedia.URI;
		//used to clean up source type code
		var sourceType = productMedia.sourceType;
		if('Attachment' == sourceType){
			var mediaAttachments = productMedia.attachmentsS
			if(null != mediaAttachments){
				var mediaAttachment = _.first(mediaAttachments);

				productMedia.uri = mediaAttachment.sfid;
				productMedia.mediaName = mediaAttachment.sfdcName;
			}
		}
		else if('URI' == sourceType){
			productMedia.uri = productMedia.URI;
		}
		else if('Static Resource' == sourceType){
			productMedia.uri = productMedia.filePath;
			productMedia.staticRes = productMedia.staticResourceName;
		}
		return productMedia;
	}
})(this.CCRZ, jQuery);

/////////////////// end ccrz def


accounting.settings.number = _.defaults({
	precision: 2
}, accounting.settings.number);


//CURRENCY FIX
Handlebars.registerHelper('price', function(amount,currency,options) {
	if(!_.isNull(amount) && !_.isUndefined(amount)) {
	if(_.isUndefined(options)){
		return new Handlebars.SafeString(formatPrice(amount,false));
	}else{
		return new Handlebars.SafeString(formatPrice(amount,currency));
	}
	} else {
		var undefinedMsg = CCRZ.pagevars.pageLabels['price_undefined'];
		//if page label 'price_undefined' is an empty string, js treat it as a undefined.
		//following code make sure undefinedMsg is not a null.
		if(_.isNull(undefinedMsg) || _.isUndefined(undefinedMsg)) {
			undefinedMsg = '&nbsp;';
		}
		return new Handlebars.SafeString(undefinedMsg);
	}
});

Handlebars.registerHelper('priceAbs', function(amount,currency,options) {
	var absVal = Math.abs(amount);
	if(_.isUndefined(options)){
		return new Handlebars.SafeString(formatPrice(absVal,false));
	}else{
		return new Handlebars.SafeString(formatPrice(absVal,currency));
	}
});

Handlebars.registerHelper('date', function(milsec) {
	var params = Array.prototype.slice.call(arguments, 1);
	var thisDate = new Date(milsec);
	return thisDate.toLocaleDateString.apply(thisDate, params);
});

Handlebars.registerHelper('time', function(milsec) {
	var params = Array.prototype.slice.call(arguments, 1);
	var thisDate = new Date(milsec);
	return thisDate.toLocaleTimeString.apply(thisDate, params);
});

Handlebars.registerHelper('datetime', function(milsec) {
	var params = Array.prototype.slice.call(arguments, 1);
	var thisDate = new Date(milsec);
	return thisDate.toLocaleString.apply(thisDate, params);
});

Handlebars.registerHelper('formatName', function(formatLabel, givenName, familyName) {
	//note this allows for additional names to be passed if desired (for middle or other name values)
	var params = Array.prototype.slice.call(arguments, 1);
	//escape all the params
	for(var i = 0; i < params.length; i++) { params[i] = _.escape(params[i]); }
	if (formatLabel) {
		//pull the page label and format with the params
		return CCRZ.processPageLabelMap(formatLabel, params);
	}else {
		//if no page label is provided, then use this default formatting of given name
		return CCRZ.insertTokens("{0} {1}", params);
	}
});

Handlebars.registerHelper('productImage', function(obj) {
	var lobj = obj||{};
	if (lobj.sourceType === "Attachment")
		return new Handlebars.SafeString(CCRZ.pagevars.attachmentURL + lobj.uri);
	else if (lobj.imageFullPath)
		return new Handlebars.SafeString(lobj.imageFullPath);
	else if (lobj.uri)
		return new Handlebars.SafeString(lobj.uri);
	else
		return new Handlebars.SafeString("noImage");
});

Handlebars.registerHelper('displaySVG', function(obj, styleClass, options) {
	var imgSrc = CCRZ.processImageURL(obj, styleClass, options);
	var width = '';
	var height = '';
	if (options && options.hash['width'])
		width = "width='"+options.hash['width']+"'";
	if (options && options.hash['height'])
		height = "height='"+options.hash['height']+"'";

	if (imgSrc.length > 0)
		return new Handlebars.SafeString("<object " + width + " " + height + " type='image/svg+xml' data='" + imgSrc + "' ></object>");
	else
		return new Handlebars.SafeString("&nbsp;");
});

Handlebars.registerHelper('displayImage', function(obj, styleClass, options) {
	if(options && options.hash['src']){
		var imgSrc = _.escape(options.hash['src']);
	}else{
		var imgSrc = CCRZ.processImageURL(obj, styleClass, options);
	}
	var alt = "";
	if (options && options.hash['alt'])
		alt = _.escape(options.hash['alt']);
	var dataId = "";
	if (options && options.hash['dataId'])
		dataId = _.escape(options.hash['dataId']);
	if (imgSrc.length > 0)
		return new Handlebars.SafeString("<img class='" + styleClass + "' src='" + imgSrc + "' alt='" + alt + "' data-id='" + dataId + "' />");
	else
		return new Handlebars.SafeString("<img class='" + styleClass + " " + CCRZ.pagevars.userLocale + " noImg' alt='" + alt + "' data-id='" + dataId + "' />");
});

Handlebars.registerHelper('productLink', function(product, styleClass, options){
	// Determine product SKU
	var SKU = '';
	if(!_.isUndefined(product)){
	    if(product.linkURL){
			SKU = product.linkURL; // This case handles CC Menu
		}else if(product.sku){
			SKU = product.sku; // This case handles PLP, PDP, Featured Products, CC Promo/Splash
		}else if(product.SKU){
			SKU = product.SKU; // This case handles LLI Checkout, PCP
		}else if(product.productSKU){
			SKU = product.productSKU; // This case handles LLI Order Detail
		}

 		// This is what ultimately composes the data-product attribute in the href
		var linkObj = {'name': product.name, 'SKU': SKU, 'friendlyUrl': product.friendlyUrl, 'openInNewWindow': product.openInNewWindow};
		var productJSON = _.escape(JSON.stringify(linkObj));
 	}

	// Determine link content (text/image)
	var content = '';
	var promo = '';
	if(product && product.name){
		content = _.escape(product.name); // Default link text is the product name
	}
	if(options && options.hash['image'])
		content = options.hash['image'];
	if(options && options.hash['text']){
	    // displayProductName, often used in conjunction with this, will also escape html character codes
	    // but we can't assume that only displayProductName will provide this value, so we unescape/escape
		content = _.escape(_.unescape(options.hash['text']));
	}
	if(options && options.hash['promo'])
		promo = options.hash['promo'];
	var href = CCRZ.goToPDP(null, product);
	if(product.openInNewWindow || product.isNewWindow){
		return new Handlebars.SafeString("<a href='" + href + "' target=\"_blank\" onClick=\"return CCRZ.openPDP(this)\" class=\"" + styleClass + " gp_prod" + "\" data-product= '" + productJSON + "' data-id= '" + SKU + "' data-promo='"+ promo +"'>" + content + "</a>")
	} else {
		return new Handlebars.SafeString("<a href='" + href + "' onClick=\"return CCRZ.openPDP(this)\" class=\"" + styleClass + " gp_prod" + "\" data-product= '" + productJSON + "' data-id= '" + SKU + "' data-promo='"+ promo +"'>" + content + "</a>");
	}
});

Handlebars.registerHelper('categoryLink', function(category, styleClass, options){
	var tmpCategory = _.clone(category);
	// Remove the shortDesc and longDesc - no reason other than to avoid printing/passing these fields
	if(tmpCategory && tmpCategory.shortDesc){
		delete tmpCategory.shortDesc;
	}
	if(tmpCategory && tmpCategory.longDesc){
		delete tmpCategory.longDesc;
	}
	var categoryJSON = _.escape(JSON.stringify(tmpCategory));
	var content = '';
	var promo = '';
	if(tmpCategory && tmpCategory.name){
		content = _.escape(tmpCategory.name); // Default link text is the category name
	}else if(tmpCategory && tmpCategory.category && tmpCategory.category.name){
	    content = _.escape(tmpCategory.category.name); // Default link text is the category name
    }

	var linkTarget = '';
	if(options && options.hash['image'])
		content = options.hash['image'];
	if(options && options.hash['text']){
		content = _.escape(options.hash['text']);
	}
	if(options && options.hash['promo'])
		promo = options.hash['promo'];
	var href = CCRZ.goToPLP(null, category);
	if(category.openInNewWindow || category.isNewWindow){
		return new Handlebars.SafeString("<a href='" + href + "' target=\"_blank\" onClick=\"return CCRZ.openPLP(this)\" class=\"" + styleClass + " gp_cat" + "\" data-category= '" + categoryJSON + "' data-promo='"+ promo +"'>" + content + "</a>");
	} else {
		return new Handlebars.SafeString("<a href='" + href + "' onClick=\"return CCRZ.openPLP(this)\" class=\"" + styleClass + " gp_cat" + "\" data-category= '" + categoryJSON + "' data-promo='"+ promo +"'>" + content + "</a>");
	}
});

Handlebars.registerHelper('goHome', function(obj, styleClass, id, options){
	if(options && options.hash['image'])
		content = options.hash['image'];
	if(options && options.hash['text']){
		content = _.escape(_.unescape(options.hash['text']));
	}
	if(options && options.hash['icon']) {
		content = options.hash['icon'];
	}

	var baseUrl = CCRZ.pagevars.currSiteURL;

	return new Handlebars.SafeString("<a id='" + id + "'  href='" + baseUrl + "' onClick=\"CCRZ.openHome('" + baseUrl + "')\" class='" + styleClass  + " gp_home" + "'>" + content + "</a>")
});

var windowObjectReference = null;

CCRZ.openPDP = function(e){
	if (!e) e = window.event;
	var target = e.target || e.srcElement;

	if (CCRZ.ga) {
		CCRZ.ga.handleProductDetails(e);
	}

	var link = CCRZ.goToPDP(e);

	if(target === "_blank"){
		if(windowObjectReference == null || windowObjectReference.closed) {
			windowObjectReference = window.open(link);
		} else {
			windowObjectReference.focus();
		}
	} else {
		window.location = link;
	}
	return false;
};

CCRZ.openPLP = function(e){
	if (!e) e = window.event;
	var target = e.target || e.srcElement;

	if (CCRZ.ga) {
		CCRZ.ga.handleProductList(e);
	}

	var link = CCRZ.goToPLP(e);

	if(target === "_blank"){
		if(windowObjectReference == null || windowObjectReference.closed) {
			windowObjectReference = window.open(link);
		} else {
			windowObjectReference.focus();
		}
	} else {
		window.location = link;
	}
	return false;
};

CCRZ.openHome = function(url){
	window.location = CCRZ.goToHomePage(url, false);
};

Handlebars.registerHelper('displayIcon', function(iconName, options) {
	return new Handlebars.SafeString("<i class=\"fa fa-" + iconName + "\" aria-hidden=\"true\"></i>");
});

Handlebars.registerHelper('unescape', function(html){
	return (html) ? new Handlebars.SafeString(html) : '';
});

Handlebars.registerHelper('stringify', function(context) {
	return JSON.stringify(context);
});

Handlebars.registerHelper('each_upto', function(ary, max, options) {
	if(!ary || ary.length === 0)
		return options.inverse(this);

	var result = [ ];
	for(var i = 0; i < max && i < ary.length; ++i) {
		ary[i].index = i;
		result.push(options.fn(ary[i]));
	}
	return result.join('');
});

Handlebars.registerHelper('ifEquals', function(v1, v2, options) {
	  if(v1 === v2) {
		return options.fn(this);
	  }
	  return options.inverse(this);
});

Handlebars.registerHelper('ifContains', function(v1, v2, options) {
	if(v1 && v2){
		if(v1.includes(v2)){
			return options.fn(this);
		}
	}
	return options.inverse(this);
});

Handlebars.registerHelper('ifNotEquals', function(v1, v2, options) {
	  if (v1 !== v2) {
		return options.fn(this);
	  }
	  return options.inverse(this);
});

Handlebars.registerHelper("eachStyles", function(array, numCols, stylePrefix, options) {
	if (array && array.length > 0) {
		var buffer = "";
		for (var i = 0, j = array.length; i < j; i++) {
			var item = array[i];
			item.styleClass = stylePrefix + (i % numCols).toString();
			buffer += options.fn(item);
		}
		return buffer;
	}
	else
		return options.inverse(this);
});

Handlebars.registerHelper("eachMapEntry", function(mapData, options) {
	if (mapData) {
		var buffer = "";
		for (var key in mapData) {
			var item = mapData[key];
			item.groupName = key;
			buffer += options.fn(item);
		}
		return buffer;
	}
	else
		return options.inverse(this);
});


Handlebars.registerHelper( 'eachInMap', function ( map, fn1, fn2 ){
	var custCall = !_.isUndefined(fn2);
	var block  = custCall?fn2:fn1;
	var arr	   = _.pairs(map);
	if(custCall){
		try{
			var mapFunc = CCRZ.util.nmlook(fn1);
			if(!_.isFunction(mapFunc)){
				throw "Not a function!";
			}
			try{
				arr = mapFunc(arr);
			}catch(e1){
				CCRZ.console.log('Error during call');
				CCRZ.console.log(e1);
			}
		}catch(e2){
			mapFunc = false;
			CCRZ.console.log('Unable to lookup function '+fn1);
			CCRZ.console.log(e2);
		}
	}
   var out = '';
	for(var i=0;i<arr.length;i++){
		out += block.fn({key : arr[i][0], value:arr[i][1]});
	}
   return out;
} );

Handlebars.registerHelper("selectGeo", function(name, entries, value, styleClass, prefix, placeholder) {
	var fullStyles = styleClass + " " + prefix + "Field " + prefix + name;
	var fullName = '';
	if (prefix && (prefix.indexOf('.', prefix.length - 1) !== -1))
		fullName = prefix + name;
	else
		fullName = prefix + 'Address.' + name;
	if (entries && entries.length > 0) {
		var buffer = "<select name='" + fullName + "Code' class='" + fullStyles + "'>";
		for (var i = 0, j = entries.length; i < j; i++) {
			buffer += "<option value='" + entries[i].value + "'";
			if (value && value == entries[i].value)
				buffer += " selected";
			buffer += ">" + entries[i].label + "</option>";
		}
		buffer += "</select>";
		return buffer;
	}
	else {
		var buffer2 = "<input name='" + fullName  + "' class='" + fullStyles + "' value='" + value + (placeholder ? "' placeholder='" +  placeholder : "") + "' maxLength='255'>";
		return buffer2;
	}
});
Handlebars.registerHelper('displayEProductMedia', function(productMedia, options){
	var formattedMediaObj = CCRZ.reformatMedia(productMedia);
	var type = formattedMediaObj.sourceType;
	var url = formattedMediaObj.uri;
	var staticRes = formattedMediaObj.staticRes;

	var buffer = "";
	if (type == "URI")
		return new Handlebars.SafeString(url);
	else if (type == "Attachment")
		return new Handlebars.SafeString(CCRZ.pagevars.attachmentURL + url);
	else {
		if (options.hash['locale'])
			url = options.hash['locale'] + "/" + url;
		if (typeof staticRes != "undefined"){
			//resolve the namespace if it is not already in there (reference cc_util_UserInterface.getImageFromStaticResource)
			if(staticRes.indexOf('__') != -1) {
				if(staticRes.startsWith('c__')) {
					//static resources from subscriber org
					staticRes = staticRes.slice(3);
				}
			} else {
				var nspace = CCRZ.pagevars.namespace;
				//only if we get a set namespace we need to add it in
				if(nspace){
					//the pagevar is set by the storefront template pages ctrl...and always adds a dot at the end
					if(nspace.endsWith('.')){
						nspace = nspace.slice(0, nspace.length-1);
					}
					staticRes = nspace  + '__' + staticRes;
				}
			}
			return new Handlebars.SafeString(CCRZ.pagevars.staticResourceMap[staticRes] + "/" + url);
		}else{
			return new Handlebars.SafeString(CCRZ.pagevars.themeBaseURL + url);
		}
	}
});

Handlebars.registerHelper('image', function(type, url, options) {
	var buffer = "";
	if (type == "URI")
		return new Handlebars.SafeString(url);
	else if (type == "Attachment")
		return new Handlebars.SafeString(CCRZ.pagevars.attachmentURL + url);
	else {
		if (options.hash['locale'])
			url = options.hash['locale'] + "/" + url;
		if (options.hash['staticRes']){
			var staticResourceName = options.hash['staticRes'];
			//resolve the namespace if it is not already in there (reference cc_util_UserInterface.getImageFromStaticResource)
			if(staticResourceName.indexOf('__') != -1) {
				if(staticResourceName.startsWith('c__')) {
					//static resources from subscriber org
					staticResourceName = staticResourceName.slice(3);
				}
			} else {
				var nspace = CCRZ.pagevars.namespace;
				//only if we get a set namespace we need to add it in
				if(nspace){
					//the pagevar is set by the storefront template pages ctrl...and always adds a dot at the end
					if(nspace.endsWith('.')){
						nspace = nspace.slice(0, nspace.length-1);
					}
					staticResourceName = nspace  + '__' + staticResourceName;
				}
			}
			return new Handlebars.SafeString(CCRZ.pagevars.staticResourceMap[staticResourceName] + "/" + url);
		}else{
			return new Handlebars.SafeString(CCRZ.pagevars.themeBaseURL + url);
		}
	}
});

Handlebars.registerHelper('for', function(from, to, incr, block) {
	var accum = '';
	for(var i = from; i <= to; i += incr)
		accum += block.fn(i);
	return accum;
});

Handlebars.registerHelper('ifDisplay', function(configName, options) {
	var configSetting = configName.toLowerCase();
	if (CCRZ.pagevars.pageConfig !== null && CCRZ.pagevars.pageConfig[configSetting] !== null) {
		val = CCRZ.pagevars.pageConfig[configSetting];
		if (val == 'TRUE')
			return options.fn(this);
		else
			return options.inverse(this);
	}
	else
		return options.inverse(this);
});

Handlebars.registerHelper('ifNotPagevar', function(configName, options) {
	if (CCRZ.pagevars[configName] !== null) {
		val = CCRZ.pagevars[configName];
		if (val == true || val == 'true' || val == 'TRUE'){
			return options.inverse(this);
		}else{
			return options.fn(this);
		}
	}
	else {
		return options.inverse(this);
	}
});

Handlebars.registerHelper('ifStoreSetting', function(settingName, options) {
	if (CCRZ.pagevars.storeSettings !== null && CCRZ.pagevars.storeSettings[settingName] !== null) {
		val = CCRZ.pagevars.storeSettings[settingName];
		if (val === true){
			return options.fn(this);
		}else{
			return options.inverse(this);
		}
	}
	else
		return options.inverse(this);
});

Handlebars.registerHelper('ifStoreSettingEquals', function(settingName, v1, options) {
	if(CCRZ.pagevars.storeSettings !== null && CCRZ.pagevars.storeSettings[settingName] !== null) {
		val = CCRZ.pagevars.storeSettings[settingName];
		if(val === v1){
			return options.fn(this);
		}else{
			return options.inverse(this);
		}
	}
	else{
		return options.inverse(this);
	}
});


Handlebars.registerHelper('sum', function() {
	var sum = 0, v;
	var currency = false;
	//check last arg
	if(arguments){
		var argsLen = arguments.length;
		if(isNaN(parseFloat(arguments[argsLen-2]))){
			currency = arguments[argsLen-2];
			argsLen-=2;
		}
		for (var i=0; i<argsLen; i++) {
		v = parseFloat(arguments[i]);
		if (!isNaN(v))
			sum += v;
	}
	}
	return new Handlebars.SafeString(formatPrice(sum,currency));
});

Handlebars.registerHelper('pageConfigMap', function(labelName) {
	var retLabel = '';
	if(CCRZ.pagevars.pageConfig != null && CCRZ.pagevars.pageConfig[labelName] != null) {
		retLabel = CCRZ.pagevars.pageConfig[labelName];
	}
	return new Handlebars.SafeString(retLabel);
});

Handlebars.registerHelper('pageLabelMap', function(labelName) {
	var params = Array.prototype.slice.call(arguments, 1);
	return CCRZ.processPageLabelMap(labelName, params);
});

Handlebars.registerHelper('pageLabelPrefixMap', function(prefix,labelName) {
	var params = Array.prototype.slice.call(arguments, 2);
	return CCRZ.processPageLabelPrefixMap(prefix,labelName, params);
});

Handlebars.registerHelper('pageLabelMapMultiString', function(labelName) {
	return CCRZ.pageLabelMultiString(labelName,arguments);
});

//extends
Handlebars.registerHelper('subscriptionSummary', function(labelName) {
	//Get labelName,sku, and frequency
	var labelParams = Array.prototype.slice.call(arguments,0,3);
	labelParams.push(formatPrice(arguments[3]));
	return CCRZ.pageLabelMultiString(labelName,labelParams);
});


Handlebars.registerHelper('displayProductName', function(labelName, parentName, childName) {
	if (typeof parentName === 'undefined' || parentName == null || parentName == '')
		return childName;
	else {
		var params = Array.prototype.slice.call(arguments, 1);
		for(var i = 0; i < params.length; i++)
		{
			params[i] = _.escape(params[i]);
		}
		return CCRZ.processPageLabelMap(labelName, params);
	}
});

Handlebars.registerHelper('storeSetting', function(settingname) {
	var retLabel = '';
	if(CCRZ.pagevars.storeSettings != null && CCRZ.pagevars.storeSettings[settingname] != null) {
		retLabel = CCRZ.pagevars.storeSettings[settingname];
	}
	return new Handlebars.SafeString(retLabel);
});

Handlebars.registerHelper('ifGreater', function(v1, v2, options) {
	if (v1 > v2) {
		return options.fn(this);
	}
	return options.inverse(this);
});

Handlebars.registerHelper('ifLessThan', function(v1, v2, options) {
	if (v1 < v2) {
		return options.fn(this);
	}
	return options.inverse(this);
});

Handlebars.registerHelper('displayRangePrice', function(labelName, minPrice, maxPrice) {
	var retVal = '';
	if(!(_.isUndefined(minPrice) || _.isNull(minPrice) ) &&
			!(_.isUndefined(maxPrice) || _.isNull(maxPrice) ) &&
			(minPrice !== 0 || maxPrice !== 0)) {
		if(minPrice === maxPrice) {
			retVal = formatPrice(maxPrice);
		} else {
			var minP = formatPrice(minPrice);
			var maxP = formatPrice(maxPrice);
			var params = [minP, maxP];
			retVal = CCRZ.processPageLabelMap(labelName, params);
		}
	}
	return new Handlebars.SafeString(retVal);
});

Handlebars.registerHelper('linkTarget', function(openInNewWindow) {
	return (openInNewWindow) ? new Handlebars.SafeString('target="_blank"') : '';
});

Handlebars.registerHelper('ifbothPricesZero', function(price1, price2, options) {
	if((price1 !== null) && (price2!== null) && (price1 !== 0 || price2 !== 0)) {
		return options.fn(this);
	}
	return options.inverse(this);
});

Handlebars.registerHelper('selectValue', function(obj, match, eqVal, neqVal) {
	if (obj === match)
		return new Handlebars.SafeString(eqVal);
	else
		return new Handlebars.SafeString(neqVal);
});

Handlebars.registerHelper('listFind', function(match, compareList, matching, options) {
	var params = compareList.split('|');
	var found = false;
	$.each(params, function(key, value) {
		if (match === value)
			found = true;
	});
	if (found && matching)
		return options.fn(this);
	else
		return options.inverse(this);
});

//Using this explicity in a moustache causes an intermittent exception in quotedString
//This helper should be used in place of {{this}}.	E.g. {{safeQuote this}}
Handlebars.registerHelper('safeQuote',function(str){
	try{
		return quotedString(str);
	}catch(err){
		return str;
	}
});

Handlebars.registerHelper('insertTokens', function(displayText) {
	var params = Array.prototype.slice.call(arguments, 1);
	return CCRZ.insertTokens(displayText, params);
});

Handlebars.registerHelper('decodeHTML', function(richText) {
	return new Handlebars.SafeString(_.unescape(richText));
});

//Fallback image helper
Handlebars.registerHelper("fallbackSrc", function(src) {
	var fallback = CCRZ.pagevars.pageConfig['ui.noimage'];
	if (src) {
		return src;
	} else {
		return fallback;
	}
});

Handlebars.registerHelper('if_odd', function(conditional, options) {
    if((conditional % 2) != 0) {
        return options.fn(this);
    } else {
        return options.inverse(this);
    }
});

//IE 11 compatibility: fCheck if startWith is defined, if not then define it as a substr that compares the values
if (!String.prototype.startsWith) {
    String.prototype.startsWith = function(searchString, position){
        return this.substr(position || 0, searchString.length) === searchString;
    };
}

//IE 11 compatibility: Check if endsWith is defined, if not then define it as a substr that compares the values
if (!String.prototype.endsWith) {
	String.prototype.endsWith = function(search, this_len) {
		if (this_len === undefined || this_len > this.length) {
			this_len = this.length;
		}
		return this.substring(this_len - search.length, this_len) === search;
	};
}

if(!CCRZ.disableAdaptive){
	// Window resize listeners for pre BOOT3 views
	// Redundant for BOOT3 because renderViewChanged() will always be false, and the current view will remain 'desktop'
	$(window).on('resize', (function(){
		CCRZ.display.setCurrentView();
		$.each(CCRZ.dynamicViews, function(index, value){
			if(value && value.renderViewChanged) {
				value.renderViewChanged();
			}
		});
	}));
	$(window).on( 'orientationchange', function(e){
		CCRZ.display.setCurrentView();
		$.each(CCRZ.dynamicViews, function(index, value){
			if(value && value.renderViewChanged) {
				value.renderViewChanged();
			}
		});
	});
}

function formatPrice(amount,theCurrency){
	if('TRUE'===CCRZ.pagevars.pageConfig['pgl.curr']){
		var theCurrency = theCurrency||CCRZ.userIsoCode;
		return CCRZ.util.format(CCRZ.pagevars.pageLabels['price_'+theCurrency]||CCRZ.pagevars.pageLabels['price_Undefined']||'$#,###.00',amount);
	}else{
		var div = $("<div>" + amount + "</div>");
		div.currency({
			region : CCRZ.userIsoCode,
			decimals: CCRZ.pagevars.currencyData.decimalPoints,
			decimal: CCRZ.pagevars.currencyData.charDecimalPoint,
			thousands: CCRZ.pagevars.currencyData.charThousandsPoint,
			currencySymbol: CCRZ.pagevars.currencyData.currencySymbol,
			hidePrefix: !CCRZ.pagevars.currencyData.prefix,
			hidePostfix: CCRZ.pagevars.currencyData.prefix
		});
		return div.html();
	}
}

function substitute(str, arr) {
	var n = arr.length;
	for (var i = 0; i < n; i++) {
		var pattern = "\\{" + i + "\\}";
		var re = new RegExp(pattern, "g");
		str = str.replace(re, arr[i]);
	}
	return str;
}


CCRZ.util.formatPrefix	= /[^\d\-\+#]*/i;
CCRZ.util.formatPostfix = /[^\d\-\+\#\.]*$/i;
CCRZ.util.formatMatch	= /[^\d\-\+#]/g;

function getCSRQueryString(){
	var csrQueryString = '';
	if(CCRZ.pagevars.portalUserId != null) {
		csrQueryString = '&portalUser=' + CCRZ.pagevars.portalUserId;
	}
	if(CCRZ.pagevars.storeName != null) {
		csrQueryString += '&store=' + CCRZ.pagevars.storeName;
	}
	if(CCRZ.pagevars.effAccountId) {
		csrQueryString += '&effectiveAccount=' + CCRZ.pagevars.effAccountId;
	}
	if(CCRZ.pagevars.priceGroupId) {
		csrQueryString += '&grid=' + CCRZ.pagevars.priceGroupId;
	}
	if(CCRZ.pagevars.userLocale){
		csrQueryString += '&cclcl=' + CCRZ.pagevars.userLocale;
	}
	return csrQueryString;
}

/**
 * @preserve IntegraXor Web SCADA - JavaScript Number Formatter
 * http://www.integraxor.com/
 * author: KPL, KHL
 * (c)2011 ecava
 * Dual licensed under the MIT or GPL Version 2 licenses.
 */

////////////////////////////////////////////////////////////////////////////////
// param: Mask & Value
////////////////////////////////////////////////////////////////////////////////
CCRZ.util.format = function( m, v){
	if (!m || isNaN(+v)) {
		return v; //return as it is.
	}
	var m = m.toString();//force

	//pull out non-matching prefix chars
	var prefix	= m.match(CCRZ.util.formatPrefix).toString();
	//pull out non-matching postfix chars
	var postfix = m.match(CCRZ.util.formatPostfix).toString();

	m = m.substring(prefix.length,m.length-postfix.length);

	//convert any string to number according to formation sign.
	var v = m.charAt(0) == '-'? -v: +v;
	var isNegative = v<0? v= -v: 0; //process only abs(), and turn on flag.

	//search for separator for grp & decimal, anything not digit, not +/- sign, not #.
	var result = m.match(CCRZ.util.formatMatch);
	var Decimal = (result && result[result.length-1]) || '.'; //treat the right most symbol as decimal
	var Group = (result && result[1] && result[0]) || ',';	//treat the left most symbol as group separator

	//split the decimal for the format string if any.
	var m = m.split( Decimal);
	//Fix the decimal first, toFixed will auto fill trailing zero.
	v = v.toFixed( m[1] && m[1].length);
	v = +(v) + ''; //convert number to string to trim off *all* trailing decimal zero(es)

	//fill back any trailing zero according to format
	var pos_trail_zero = m[1] && m[1].lastIndexOf('0'); //look for last zero in format
	var part = v.split('.');
	//integer will get !part[1]
	if (!part[1] || part[1] && part[1].length <= pos_trail_zero) {
		v = (+v).toFixed( pos_trail_zero+1);
	}
	var szSep = m[0].split( Group); //look for separator
	m[0] = szSep.join(''); //join back without separator for counting the pos of any leading 0.

	var pos_lead_zero = m[0] && m[0].indexOf('0');
	if (pos_lead_zero > -1 ) {
		while (part[0].length < (m[0].length - pos_lead_zero)) {
			part[0] = '0' + part[0];
		}
	}
	else if (+part[0] == 0){
		part[0] = '';
	}

	v = v.split('.');
	v[0] = part[0];

	//process the first group separator from decimal (.) only, the rest ignore.
	//get the length of the last slice of split result.
	var pos_separator = ( szSep[1] && szSep[ szSep.length-1].length);
	if (pos_separator) {
		var integer = v[0];
		var str = '';
		var offset = integer.length % pos_separator;
		for (var i=0, l=integer.length; i<l; i++) {

			str += integer.charAt(i); //ie6 only support charAt for sz.
			//-pos_separator so that won't trail separator on full length
			if (!((i-offset+1)%pos_separator) && i<l-pos_separator ) {
				str += Group;
			}
		}
		v[0] = str;
	}

	v[1] = (m[1] && v[1])? Decimal+v[1] : "";
	return prefix+((isNegative?'-':'') + v[0] + v[1])+postfix; //put back any negation and combine integer and fraction.
};

if (typeof Number.MIN_SAFE_INTEGER === 'undefined') {
	Number.MIN_SAFE_INTEGER = -9007199254740991;
}
if (typeof Number.MAX_SAFE_INTEGER === 'undefined') {
	Number.MAX_SAFE_INTEGER = 9007199254740991;
}


