/*
 * jQuery Currency v0.5
 * Simple, unobtrusive currency converting and formatting
 *
 * Copyright 2011, Gilbert Pellegrom
 * Free to use and abuse under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 * 
 * http://dev7studios.com
 */

 /* MODIFIED BY CLOUDCRAZE */

(function($) {

    $.fn.currency = function(method) {

        var methods = {

            init : function(options) {
                var settings = $.extend({}, this.currency.defaults, options);
                return this.each(function() {
                    var $element = $(this),
                         element = this;
                    var value = 0;
                    
                    if($element.is(':input')){
                        value = $element.val();
                    } else {
                        value = $element.text();
                    }
                    
                    if(helpers.isNumber(value)){
                    
                        if(settings.convertFrom != ''){
                            if($element.is(':input')){
                                $element.val(value +' '+ settings.convertLoading);
                            } else {
                                $element.html(value +' '+ settings.convertLoading);
                            }
                            $.post(settings.convertLocation, { amount: value, from: settings.convertFrom, to: settings.region }, function(data){
                                value = data;
                                if($element.is(':input')){
                                    $element.val(helpers.format_currency(value, settings));
                                } else {
                                    $element.html(helpers.format_currency(value, settings));
                                }
                            });
                        } else {
                            if($element.is(':input')){
                                $element.val(helpers.format_currency(value, settings));
                            } else {
                                $element.html(helpers.format_currency(value, settings));
                            }
                        }
                    
                    }
                    
                });

            }

        }

        var helpers = {

            format_currency: function(amount, settings) {
				if(_.isNull(settings.currencySymbol)) {
                var bc = settings.region;
                var currency_before = '';
                var currency_after = '';
                
                if(bc == 'ALL') currency_before = 'Lek';
                if(bc == 'ARS') currency_before = '$';
                if(bc == 'AWG') currency_before = 'f';
                if(bc == 'AUD') currency_before = '$';
                if(bc == 'BSD') currency_before = '$';
                if(bc == 'BBD') currency_before = '$';
                if(bc == 'BYR') currency_before = 'p.';
                if(bc == 'BZD') currency_before = 'BZ$';
                if(bc == 'BMD') currency_before = '$';
                if(bc == 'BOB') currency_before = '$b';
                if(bc == 'BAM') currency_before = 'KM';
                if(bc == 'BWP') currency_before = 'P';
                if(bc == 'BRL') currency_before = 'R$';
                if(bc == 'BND') currency_before = '$';
                if(bc == 'CAD') currency_before = '$';
                if(bc == 'KYD') currency_before = '$';
                if(bc == 'CLP') currency_before = '$';
                if(bc == 'CNY') currency_before = '&yen;';
                if(bc == 'COP') currency_before = '$';
                if(bc == 'CRC') currency_before = 'c';
                if(bc == 'HRK') currency_before = 'kn';
                if(bc == 'CZK') currency_before = 'Kc';
                if(bc == 'DKK') currency_before = 'kr';
                if(bc == 'DOP') currency_before = 'RD$';
                if(bc == 'XCD') currency_before = '$';
                if(bc == 'EGP') currency_before = '&pound;';
                if(bc == 'SVC') currency_before = '$';
                if(bc == 'EEK') currency_before = 'kr';
                if(bc == 'EUR') currency_before = '&euro;';
                if(bc == 'FKP') currency_before = '&pound;';
                if(bc == 'FJD') currency_before = '$';
                if(bc == 'GBP') currency_before = '&pound;';
                if(bc == 'GHC') currency_before = 'c';
                if(bc == 'GIP') currency_before = '&pound;';
                if(bc == 'GTQ') currency_before = 'Q';
                if(bc == 'GGP') currency_before = '&pound;';
                if(bc == 'GYD') currency_before = '$';
                if(bc == 'HNL') currency_before = 'L';
                if(bc == 'HKD') currency_before = '$';
                if(bc == 'HUF') currency_before = 'Ft';
                if(bc == 'ISK') currency_before = 'kr';
                if(bc == 'IDR') currency_before = 'Rp';
                if(bc == 'IMP') currency_before = '&pound;';
                if(bc == 'JMD') currency_before = 'J$';
                if(bc == 'JPY') currency_before = '&yen;';
                if(bc == 'JEP') currency_before = '&pound;';
                if(bc == 'LVL') currency_before = 'Ls';
                if(bc == 'LBP') currency_before = '&pound;';
                if(bc == 'LRD') currency_before = '$';
                if(bc == 'LTL') currency_before = 'Lt';
                if(bc == 'MYR') currency_before = 'RM';
                if(bc == 'MXN') currency_before = '$';
                if(bc == 'MZN') currency_before = 'MT';
                if(bc == 'NAD') currency_before = '$';
                if(bc == 'ANG') currency_before = 'f';
                if(bc == 'NZD') currency_before = '$';
                if(bc == 'NIO') currency_before = 'C$';
                if(bc == 'NOK') currency_before = 'kr';
                if(bc == 'PAB') currency_before = 'B/.';
                if(bc == 'PYG') currency_before = 'Gs';
                if(bc == 'PEN') currency_before = 'S/.';
                if(bc == 'PLN') currency_before = 'zl';
                if(bc == 'RON') currency_before = 'lei';
                if(bc == 'SHP') currency_before = '&pound;';
                if(bc == 'SGD') currency_before = '$';
                if(bc == 'SBD') currency_before = '$';
                if(bc == 'SOS') currency_before = 'S';
                if(bc == 'ZAR') currency_before = 'R';
                if(bc == 'SEK') currency_before = 'kr';
                if(bc == 'CHF') currency_before = 'CHF';
                if(bc == 'SRD') currency_before = '$';
                if(bc == 'SYP') currency_before = '&pound;';
                if(bc == 'TWD') currency_before = 'NT$';
                if(bc == 'TTD') currency_before = 'TT$';
                if(bc == 'TRY') currency_before = 'TL';
                if(bc == 'TRL') currency_before = '&pound;';
                if(bc == 'TVD') currency_before = '$';
                if(bc == 'GBP') currency_before = '&pound;';
                if(bc == 'USD') currency_before = '$';
                if(bc == 'UYU') currency_before = '$U';
                if(bc == 'VEF') currency_before = 'Bs';
                if(bc == 'ZWD') currency_before = 'Z$';
       		} else {
				currency_before = settings.currencySymbol;
				currency_after = settings.currencySymbol;
			}        
                if( currency_before == '' && currency_after == '' ) currency_before = '$';
                
                var output = '';
                if(!settings.hidePrefix) output += currency_before;
                output += helpers.number_format( amount, settings.decimals, settings.decimal, settings.thousands );
                if(!settings.hidePostfix) output += currency_after;
                return output;
            },
            
            // Kindly borrowed from http://phpjs.org/functions/number_format
            number_format: function(number, decimals, dec_point, thousands_sep) {
                number = (number + '').replace(/[^0-9+\-Ee.]/g, '');
                var n = !isFinite(+number) ? 0 : +number,
                    prec = !isFinite(+decimals) ? 0 : Math.abs(decimals),
                    sep = (typeof thousands_sep === 'undefined') ? ',' : thousands_sep,
                    dec = (typeof dec_point === 'undefined') ? '.' : dec_point,
                    s = '',
                    toFixedFix = function (n, prec) {
                        var k = Math.pow(10, prec);
                        return '' + Math.round(n * k) / k;
                    };
                // Fix for IE parseFloat(0.55).toFixed(0) = 0;
                s = (prec ? toFixedFix(n, prec) : '' + Math.round(n)).split('.');
                if (s[0].length > 3) {
                    s[0] = s[0].replace(/\B(?=(?:\d{3})+(?!\d))/g, sep);
                }
                if ((s[1] || '').length < prec) {
                    s[1] = s[1] || '';
                    s[1] += new Array(prec - s[1].length + 1).join('0');
                }
                return s.join(dec);
            },
            
            isNumber: function(n) {
                return !isNaN(parseFloat(n)) && isFinite(n);
            }
            
        }

        if (methods[method]) {
            return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
        } else if (typeof method === 'object' || !method) {
            return methods.init.apply(this, arguments);
        } else {
            $.error( 'Method "' +  method + '" does not exist in currency plugin!');
        }

    }

    $.fn.currency.defaults = {
        region: 'USD', // The 3 digit ISO code you want to display your currency in
        thousands: ',', // Thousands separator
        decimal: '.',   // Decimal separator
        decimals: 2, // How many decimals to show
        hidePrefix: false, // Hide any prefix
        hidePostfix: false, // Hide any postfix
        convertFrom: '', // If converting, the 3 digit ISO code you want to convert from,
        convertLoading: '(Converting...)', // Loading message appended to values while converting
        convertLocation: 'convert.php' // Location of convert.php file
    }

    $.fn.currency.settings = {}

})(jQuery);
;

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



;

jQuery(function($) {

	"use strict";
	
	function Remote(response) {
		this.totalPageLoads = 0;
		this.response = response;
		
		this.invoke = function(className, methodName, args){
			var argArray = new Array();
			var hasOnSuccess = false;
			var hasOnError = false;
			var options = {};
			
			
			for(var i = 0; i<args.length;i++){
				if(_.isFunction(args[i])){
				// if(Object.prototype.toString.call(args[i]) == "[object Function]"){
					if(!hasOnSuccess){
						this.onSuccess = args[i];
						hasOnSuccess = true;
					}else if(!hasOnError){
						this.onError = args[i];
						hasOnError = true;
					}
				}else if(hasOnSuccess || hasOnError){
					options = args[i];
				}else{
					if(typeof args[i] === 'undefined'){
						argArray.push({});
					}else{
						argArray.push(args[i]);
					}
					
				}
			}
			
			var sfopt = _.extend({
				escape : true,
				buffer : true,
				timeout : 120000
			},_.pick(options,'escape','buffer','timeout'));

			var ccrzopt = _.extend({
				nmsp   : (CCRZ.pagevars.namespace) ? CCRZ.pagevars.namespace.replace(/^[.\s]+|[.\s]+$/g, "") : false
			},_.pick(options,'nmsp'));

			var remoteCallout = CCRZ.remoting.rbind(this.getFullName(className, methodName, ccrzopt));
			argArray.push(_.bind(this.response, this));
			argArray.push(sfopt);
			remoteCallout.apply(this, argArray);
		};
	
		this.getFullName = function(className, method, options){
			var namespace = options.nmsp?(options.nmsp+'.'):'';
			return namespace + className + '.' + method;
		};

		//@TODO - REMOVE ONCE CONFIRMED NO LONGER USED
		this.shift = function(args, offset){
			var argArray = new Array();
			for(var i = offset; i < args.length; i++){
				argArray.push(args[i]);
			}
			return argArray;
		};
		
		
		this.createOverlay = function(){
            if (!CCRZ.disableAdaptive) {
                if(Modernizr.mq('only all')){
                    return "<div id='overlay'><div class='circleContainer'><div class='circle'></div><div class='circle1'></div></div></div>";
                }else{
                    return "<div id='overlay'><div class='circleContainer'><img src='" + CCRZ.pagevars.themeBaseURL + "images/loading.gif' alt='loading...' /></div></div>";
                }
            } else {
            	return "<div id='overlay' class='modal-backdrop fade in'></div>";
			}
		};
		
		this.startPageLoad = function(){
			if(CCRZ.display.isPhone()){
				this.totalPageLoads++;
				$(".loadingContainer").show();
			}
		};
		
		this.stopPageLoad = function(){
			if(CCRZ.display.isPhone()){
				this.totalPageLoads--;
				if(this.totalPageLoads <= 0){
					$(".loadingContainer").hide();
				}
			}
		};
		this.loadOverlay = function(container){
			/*
			$(container).prepend(this.createOverlay());
			$("#overlay").css({
				  width   : container.outerWidth() + 3,
				  height  : container.outerHeight()
			});
			$(".circleContainer").css({
			  top  : (container.height() / 2) - 30,
			  left : (container.width() / 2)
			});
			$("#overlay").show();
			*/
			$(container).prepend(this.createOverlay());
			if (!CCRZ.disableAdaptive) {
				$("#overlay").css({
					width: $(window).width() / 2,
					height: $(window).height() / 2,
					top: $(window).height() / 4,
					left: $(window).width() / 4
				});
				$(".circleContainer").css({
					top: $(window).height() / 5,
					left: $(window).width() / 5
				});
			}
			$("#overlay").show();
			
		};
		this.unloadOverlay = function(){
			$("#overlay").remove();
		};

		this.logResponse = function(data){
			try{
				if(data && data.log && _.isArray(data.log)){
					for(var i=0;i<data.log.length;i++){
						CCRZ.console.log(data.log[i].val,data.log[i].lvl,data.log[i].ts,data.log[i].sub,'r');
					}
	}
			}catch(e){}
		}
	}

	CCRZ.RemoteInvocation = {
			// retrieve current values from CCRZ.pagevars
			getRemoteContext : function() {
				CCRZ.pagevars.remoteContext.currentCartId = CCRZ.pagevars.currentCartID;
				return CCRZ.pagevars.remoteContext;
			},

			//Normal invocation method
			invoke : function(method){
				var r = new Remote(this.response);
				return r.invoke(this.className, method, _.rest(arguments));
			},

			invokePageLoading : function(method){
				var r = new Remote(this.responsePageLoading);
				r.startPageLoad();
				return r.invoke(this.className, method, _.rest(arguments));
			},

			invokeContainerLoading : function(objContainer, method){
				if(CCRZ.display.isPhone()){
					return this.invokePageLoading.apply(this, _.rest(arguments));
				}else{
					var r = new Remote(this.responseContainerLoading);
					r.loadOverlay(objContainer);
					return r.invoke(this.className, method, _.rest(arguments,2));
				}
			},

			//Context methods - the object returned from this.getRemoteContext() will automatically be added to the call stack
			//as the first parameter ==> cc_RemoteActionContext
			invokeCtx : function(method){
				var args = _.toArray(arguments);
				args.splice(1,0,this.getRemoteContext());
				return this.invoke.apply(this,args);
			},
			
			invokePageLoadingCtx : function(method){
				var args = _.toArray(arguments);
				args.splice(1,0,this.getRemoteContext());
				return this.invokePageLoading.apply(this,args);
			},
			
			invokeContainerLoadingCtx: function(objContainer, method){
				var args = _.toArray(arguments);
				args.splice(2,0,this.getRemoteContext());
				return this.invokeContainerLoading.apply(this,args);
			},
			
			responsePageLoading : function(data, event){
				this.logResponse(data);
				this.onSuccess(data, event);
				this.stopPageLoad();
			},
			
			responseContainerLoading : function(data, event){
				this.logResponse(data);
				this.onSuccess(data, event);
				this.unloadOverlay();
			},
			
			response : function(data, event){
				this.logResponse(data);
				this.onSuccess(data, event);
			}
		};
	
	
	CCRZ.CloudCrazeModel = Backbone.Model.extend(CCRZ.RemoteInvocation).extend({//Future model specific
	});
	
	CCRZ.CloudCrazeCollection = Backbone.Collection.extend(CCRZ.RemoteInvocation).extend({//Future collection specific
	});
	
	
	CCRZ.CloudCrazeView = Backbone.View.extend(CCRZ.RemoteInvocation).extend({
		viewName : false,
		managedSubView : false,
		initialize : function(options){
			if(_.isUndefined(this.options)){
				this.options = options;
			}
			if(CCRZ.display && CCRZ.display.currentView){
				this.currentView = CCRZ.display.currentView;
			}

			if(!this.managedSubView && !CCRZ.disableAdaptive){
				CCRZ.dynamicViews.push(this);
			}
			if(typeof(this.init) == "function")
				this.init(options);
		},
		preViewChanged : function(oldView,newView){},
		viewChanged: function() {
			if(this.currentView !== CCRZ.display.currentView) {
				this.preViewChanged(this.currentView,CCRZ.display.currentView);
				this.currentView = CCRZ.display.currentView;
				return true;
			}
			return false;
		},
		
		renderViewChanged: function() {
			CCRZ.display.setCurrentView();
			if(this.viewChanged()) {
				this.render();
			}
		},

		preRender : function(){},
		postRender: function(){},
		preRenderPhone :   function(){},
		preRenderTablet:   function(){},
		preRenderDesktop:  function(){},
		postRenderPhone:   function(){},
		postRenderTablet:  function(){},
		postRenderDesktop: function(){},
		
		render : function(){
			this.preRender();
			if(CCRZ.display.isPhone() && typeof(this.renderPhone) == "function"){
				this.preRenderPhone();
				this.renderPhone();
				this.postRenderPhone();
			}else if(CCRZ.display.isTablet() && typeof(this.renderTablet) == "function"){
				this.preRenderTablet();
				this.renderTablet();
				this.postRenderPhone();
			}else{
				this.preRenderDesktop();
				this.renderDesktop();
				this.postRenderDesktop();
			}
			this.postRender();
			if(this.viewName) {
				var eventName = "view:"+this.viewName+":refresh";
				CCRZ.console.log('trigger='+ eventName + ' context=' + this);
				CCRZ.pubSub.trigger(eventName, this);
				
			}
			/*
				As part of our SEO improvement W-5544209
				we now generate a value for href attribute on prods and cats.
				In order to have our parameters up to date at all times, we do not want to follow the generated
				href, but rather go thru the onClick behavior.
				This prevents default action on click and will follow onClick method.
				We've found this to be the best location so all the links can be handled in the order as they render.
				It also means this check is done also for views that don't have links, but for the time being we
				found this to be the best acceptable solution.
			 */
			$(".gp_cat, .gp_prod, .gp_home").click(function(event) {
				event.preventDefault();
				event.stopPropagation();
				return false;
			});

			return this;
		}
	});
	CCRZ.CloudCrazePageable = Backbone.PageableCollection.extend( {
		sync: function (method, model, options) {
			var self = this;
			self.searchFormData = self.searchFormData || {};
				
			if (self.mode === "infinite") {
				if(typeof(self.fetchNavData) === "function") {
					var success = options.success;
					var currentPage = self.state.currentPage;
					var links = self.links;
					self.searchFormData = _.extend(self.searchFormData, {
						numPerPage : self.state.pageSize,
						currPage : self.state.currentPage
					});
					self.fetchNavData(self.state, JSON.stringify(self.searchFormData), function(response) {
						if (success) {
							links[self.state.firstPage]='Page=' + self.state.firstPage + '';
							links[currentPage]='Page=' + (currentPage) + '';
							
							success(self, response, options);
						}
					});
				}
			} else if (self.mode === "client") {
				if(typeof(self.fetchAllNavData) === "function") {
					var success = options.success;
					var currentPage = self.state.currentPage;
					var links = self.links;
					self.searchFormData = _.extend(self.searchFormData, {
						ascending : _.isUndefined(self.searchFormData.ascending)?"true":self.searchFormData.ascending
					});
					self.fetchAllNavData(self.state, JSON.stringify(self.searchFormData), function(response) {
						if (success) {
							//links[self.state.firstPage]='Page=' + self.state.firstPage + '';
							//links[currentPage]='Page=' + (currentPage) + '';
							if(Backbone.VERSION === '0.9.10'){
							success(self, response, options);
							}else{
								success.call(self, response);
							}
						}
					});
				}
			}
			//return (BBColProto.sync || Backbone.sync).call(self, method, model, options);
		}
	});
	CCRZ.CloudCrazePageable = CCRZ.CloudCrazePageable.extend(CCRZ.RemoteInvocation);
});

;


jQuery(function($) {

	"use strict";


	CCRZ.models.CartTotalMod = CCRZ.CloudCrazeModel.extend();

	CCRZ.models.CountryModel =CCRZ.CloudCrazeModel.extend();
	CCRZ.models.StateModel = CCRZ.CloudCrazeModel.extend();


	CCRZ.models.GeoModel = CCRZ.CloudCrazeModel.extend({
		initialize : function(){
			this.stateList = new CCRZ.collections.StateList();
			this.countryList = new CCRZ.collections.CountryList();
		},
		fetch : function(callback){
			var m = this;
			this.stateList.fetch(function(){
				m.countryList.fetch(function(){
					callback();
				});
			});
		},
		filterStates: function(countryVal) {
			var filteredStates = this.stateList.where({countryCode: countryVal});
			var temp = new CCRZ.collections.StateList();
			temp.reset(filteredStates);
			return temp;
		}
	});

	CCRZ.collections.CountryList = CCRZ.CloudCrazeCollection.extend({
		model : CCRZ.models.CountryModel,
		className: 'cc_RemoteActionController',
		fetch : function(callback){
			var list = this;

			if(CCRZ.pagevars.pageConfig.isTrue('dspl.skct')){
				list.reset([{ 'label':CCRZ.pagevars.pageLabels['CountryList_Label'] ,  'value':CCRZ.pagevars.pageLabels['CountryList_Value']}]);
				callback();
			}else{
				this.invoke(
					'getCountries',
					CCRZ.pagevars.storefrontName,
					function(response){
						response = _.map( response, function(country){
								country.label = CCRZ.processPageLabelPrefixMap('CNTRY_', country.label);
								return country;
							}
						);
						list.reset(response);
						callback();
					},
					{escape:true}
				);
			}
		}
	});
	CCRZ.collections.StateList = CCRZ.CloudCrazeCollection.extend({
		model : CCRZ.models.StateModel,
		className: 'cc_RemoteActionController',
		fetch : function(callback){
			var list = this;

			if(CCRZ.pagevars.pageConfig.isTrue('dspl.skst')){
				list.reset([{ 'countryCode':CCRZ.pagevars.pageLabels['CountryList_Value'], 'label':CCRZ.pagevars.pageLabels['StateList_Label'], 'value':CCRZ.pagevars.pageLabels['StateList_Value']}]);
				callback();
			}else{
				this.invoke(
					'getStates',
					function(response){
						response = _.map( response, function(state){
							state.label = CCRZ.processPageLabelPrefixMap('STATE_', state.label);
							return state;
						}
					);
						list.reset(response);
						callback();
					},
					{escape:true}
				);
			}
		}
	});

	CCRZ.views.StateView = CCRZ.CloudCrazeView.extend({
		template: CCRZ.util.template('StateField'),
		viewName : "StateView",

		render: function(name, value, styles, stateList, classPrefix, ele, placeholder) {
			var v = this;
			v.data = {};
			v.data.name = name;
			v.data.value = value;
			v.data.styles = styles;
			v.data.placeholder = placeholder;
			v.data.classPrefix = classPrefix;
			v.data.stateList = stateList;
			v.setElement(ele);
			v.$el.html(v.template(v.data));
			CCRZ.pubSub.trigger("view:"+this.viewName+":refresh", this);
		}
	});

	CCRZ.models.Cart = CCRZ.CloudCrazeModel.extend({

		className : 'cc_RemoteActionController',

		fetch : function(callback){
			var model = this;
			this.invokeCtx("fetchCart",
				function(result, event){
					result = result.data;
					if (event.status) {
						model.set({
							"encryptedId": result.encryptedId,
							"name": result.name,
							"sfid": result.sfid,
							"subTotal": result.subTotal,
							"messages": result.messages,
							"preventCheckout": result.preventCheckout,
							"allowCheckout": result.allowCheckout,
							"totalInfo": result.totalInfo,
							"hasCoupon" : result.hasCoupon,
							"couponName" : result.couponName
						});
						model.set('cartItems', new CCRZ.collections.CartItems(result.cartItems, { cart: model }));
						model.trigger('refreshedFromServer');

						model.set("tax", model.get("subTotal") * 0.06);
						if(CCRZ.reviewModel && CCRZ.reviewthis.get("shippingMethod")){
							model.set("shippingPrice", CCRZ.reviewthis.get("shippingMethod").price);
						}
						model.set("total", model.get("tax") + model.get("subTotal") + model.get("shippingPrice"));
					}
					callback();
			});
		},

		applyCoupon: function(couponCode, callback){
			var that = this;
			this.invokeCtx('applyCoupon',couponCode,function(response){
				callback(response);
			});
		},

		clearCoupon: function(callback){
			var that = this;
			this.invokeCtx('clearCoupon',function(response){
				callback(response);
			});
		},

		save: function(callback) {
			var hasChanged = this.hasChanged();
			if(!hasChanged) {
				this.get('cartItems').each(function(item) {
					if(!hasChanged && item.hasChanged()) {
						hasChanged = true;
					}
				});
			}

			if(hasChanged) {
				var cartjson = JSON.stringify(this.toJSON());
				var model = this;
				this.invokeContainerLoading($(".cartContainer"), 'saveCart', CCRZ.pagevars.storefrontName, CCRZ.pagevars.portalUserId, cartjson,
					function(result, event){
						model.updateModel(result, event);
						callback();
					}
				);

			} else {
				callback();
			}
		},

		fetchExtPricing: function(callback) {
			var model = this;
			if (!CCRZ.pagevars.currencyCode)
				CCRZ.pagevars.currencyCode = CCRZ.userIsoCode;
			this.invokeContainerLoading(
				$(".cartContainer"),
				'fetchExtPricing', CCRZ.pagevars.storefrontName, CCRZ.pagevars.portalUserId,
				this.get('encryptedId'),
				CCRZ.pagevars.currencyCode,
				function(result, event){
					if (event.status) {
						if (result.messages) {
							callback(result);
						}
						else {
							model.updateModel(result, event);
							callback(false);
						}
					}
					else {
						if (event.type == "exception") {
							if (event.xhr && event.xhr.isTimeout) {
								var errContext = CCRZ.createPageMessage('WARN', "messagingSection-Warning", 'Err_Pricing_Timeout');
								callback(errContext);
							}
							else {
								var errContext = CCRZ.createPageMessage('ERROR', "messagingSection-Error", event.message);
								callback(errContext);
							}
						}
					}
				}
			);
		},
		updateModel : function(result, event){
			if (event.status) {
				this.set({
					"encryptedId": result.encryptedId,
					"name": result.name,
					"sfid": result.sfid,
					"subTotal": result.subTotal,
					"messages": result.messages,
					"preventCheckout": result.preventCheckout,
					"allowCheckout": result.allowCheckout,
					"totalInfo": result.totalInfo
				});
				this.set('cartItems', new CCRZ.collections.CartItems(result.cartItems, { cart: this }));
				this.trigger('refreshedFromServer');
			}
		},

		removeCartItem : function(itemId, callback){
			var itemModel = this.get("cartItems").get(itemId);
			var collection = this.get("cartItems");

			this.invoke(
				'removeCartItem', CCRZ.pagevars.storefrontName, CCRZ.pagevars.portalUserId,
				this.get("encryptedId"),
				itemId,
				function(response){
					collection.remove(itemModel, {silent : false});
					callback();
				}
			);
		},

		getCartTotal : function(callback){
			var model = this;
			this.invoke("getCartTotal", this.get("encryptedId"), function(response){
				model.set({"subTotal" : response});
				callback();
			},{escape:true});
		}
	});


	CCRZ.models.CartItem = CCRZ.CloudCrazeModel.extend({
		idAttribute : "itemID"
	});

	CCRZ.collections.CartItems = CCRZ.CloudCrazeCollection.extend({
		model: CCRZ.models.CartItem,

		initialize: function(models, options) {
			this.cart = options.cart;
		}
	});

	CCRZ.currentCart = new CCRZ.models.Cart();
	_.extend(CCRZ.currentCart, Backbone.Events);
	/**
	 * Header
	 */
	CCRZ.models.cartHeaderModel = Backbone.Model.extend({
		defaults:{
			cartCount : "",
			cartTotal : "",
			cartStatus: "",
			totalInfo : ""
		}
	});
	CCRZ.models.headerModel = CCRZ.CloudCrazeModel.extend({
		className : "cc_RemoteActionController",

		defaults : {
			header : new CCRZ.models.cartHeaderModel(),
			user : CCRZ.currentUser
		},

		getCartHeader : function(callback){
			var model = this;
			if(CCRZ.pagevars.pageConfig.isTrue('h.skcall')){
				model.get("header").set({
					cartCount : '0',
					cartTotal : '0.00',
					cartStatus: '',
					totalInfo : '0.00'
				});
				callback();
			}else{
				this.invokeCtx("getHeaderInfo",
					function(response){
						if(response && response.success && response.data) {
							model.get("header").set({
								cartCount : response.data.cartCount,
								cartTotal : response.data.cartTotal,
								cartStatus : response.data.cartStatus,
								totalInfo : CCRZ.currentCart.totalInfo
							});
							model.set({
								cartId : response.data.cartId
							});
							callback();
						} else {
							callback(response);
						}
					}, {buffer:false});
			}
		},

		getCartTotal : function(callback){
			var model = this;
			this.invoke("getCartTotal", CCRZ.pagevars.storefrontName, CCRZ.pagevars.portalUserId,
				model.get("cartId"),
				function(response){
					model.get("header").set({
						cartTotal : response,
						totalInfo : CCRZ.currentCart.totalInfo
					});
					callback();
				},
			{escape:true});

		},

		getUser : function(callback){
			var model = this;
			this.invoke("getCurrentUser", CCRZ.pagevars.portalUserId, function(response){
				CCRZ.currentUser = response;
				callback();
			}, {escape:true});

		}
	});

	CCRZ.models.CartExtensionlModel = CCRZ.CloudCrazeModel.extend({
		className : "cc_RemoteActionController",

		fetch: function(cartId, callback) {
			var model = this;

			this.invoke("fetchCartExtension", CCRZ.pagevars.storefrontName, CCRZ.pagevars.portalUserId, cartId, function(response){
				model.set(model.parse(response));
				callback();
			}, {escape:true});

		}
	});


	CCRZ.models.category = CCRZ.CloudCrazeModel.extend();

	CCRZ.views.Countries = CCRZ.CloudCrazeView.extend({
		template : CCRZ.util.template('countryList'),
		viewName : "Countries",
		renderDesktop : function(ele, fieldName, className, selectedVal){
			this.model.set("fieldName",fieldName);
			this.model.set("className",className);
			this.model.set("selectedVal",selectedVal);
			ele.html(this.template(this.model.toJSON()));
		},

		update : function(){
			var v = this;
			CCRZ.currentCart.getCartTotal(function(){
				v.render();
			});

		}

	});


	CCRZ.views.CartTotal = CCRZ.CloudCrazeView.extend({
		viewName : "CartTotal",
		template : CCRZ.util.template('cart-total-phone'),
		events : {
			"click #emailLink" : "showEmailModal"
		},
		init : function(){
			this.setElement($(".total_cart"));
			this.model = new CCRZ.models.CartTotalMod();
			this.render();
		},

		renderDesktop : function(){
			this.model.set("subTotal",CCRZ.currentCart.get("subTotal"));
			this.model.set("totalInfo",CCRZ.currentCart.get("totalInfo"));
			this.$el.html(this.template(this.model.toJSON()));
		},
		update : function(){
			var v = this;
			CCRZ.currentCart.getCartTotal(function(){
				v.render();
			});

		},
		showEmailModal : function(event){
			$("#emailModal").modal('show');
		}

	});

	CCRZ.views.includedItems = CCRZ.CloudCrazeView.extend({
		template : CCRZ.util.template('includedItems-template-phone'),
		viewName : "includedItems",
		init : function(){
			if(this.model.get("desktop")){
				this.setElement($("#included_items_desktop"));
			}else{
				this.setElement($("#included_items"));
			}
			this.render();
		},

		renderDesktop : function(){
			this.$el.html(this.template(this.model.toJSON()));
		}
	});
});

function loading(objEle){
	"use strict";
	objEle.after('<img src="' + CCRZ.pagevars.themeBaseURL + 'images/loading.gif" alt="loading..." style="text-align:center;" class="ccrz_loading_gif"/>');
	objEle.hide();
}

function doneLoading(objEle){
	"use strict";
	$(".ccrz_loading_gif").remove();
	objEle.show();
}

function myFocus(element) {
	"use strict";
	if (element.value === element.defaultValue) {
		element.value = '';
	}
}

function myBlur(element) {
	"use strict";
	if (element.value === '') {
		element.value = element.defaultValue;
	}
}
function numbersonly(e) {
	"use strict";
	var unicode = e.charCode ? e.charCode : e.keyCode;
	if (unicode !== 8) { // if the key isn't the backspace key (which we should allow)
		if (unicode < 48 || unicode > 57) {// if not a number
			return false; //disable key press
		}
	}
}
function queryString(key) {
	"use strict";
	var re = new RegExp('(?:\\?|&)'+key+'=(.*?)(?=&|$)','gi');
	var r = [], m;
	while ((m=re.exec(document.location.search)) !== null) {
		r.push(m[1]);
	}
	return r;
}

$.fn.serializeObject = function() {
	"use strict";
	var o = {};
	var a = this.serializeArray();
	$.each(a, function() {
		if (o[this.name] !== undefined) {
			if (!o[this.name].push) {
				o[this.name] = [o[this.name]];
			}
			o[this.name].push(this.value || '');
		} else {
			o[this.name] = this.value || '';
		}
	});
	return o;
};

;

CCRZ.uiProperties = {
	headerView: {
		desktop: {
			tmpl: 'HeaderDesktop',
			selector: '.header'
		},
		phone: {
			tmpl: 'HeaderPhone',
			selector: '#accountHeader'
		}
	},
	myAccountHeaderView: {
		desktop: {
			tmpl: 'MyAccount-Desktop',
			selector: '.loginoutsec'
		},
		phone: {
			tmpl: 'MyAccountPhone',
			selector: '.account_sign_in_products'
		}
	},
	myAccountMenuHeaderView: {
		desktop: {
			tmpl: 'MyAccountMenuHeader',
			selector: '#myAccountMenu'
		}
	},
	cartHeaderView: {
		desktop: {
			tmpl: 'CartHeaderBrowser',
			selector: '#cartHeader'
		},
		phone: {
			tmpl: 'CartHeaderPhone',
			selector: '#cartHeader'
		}
	},
	localeSwitcherView: {
		desktop: {
			tmpl: 'LocaleSwitcher-Desktop',
			selector: '.lssec'
		},
		phone: {
			tmpl: 'LocaleSwitcher-Mobile',
			selector: '.lssec'
		},
		selectModal: {
			tmpl: 'LocaleSwitcher-SelectDialog',
			selector: '#modalSecLocale'
		}
	},
	productCompareView: {
		desktop: {
			tmpl: 'ProductCompare-Desktop',
			selector: '.pcsec'
		},
		phone: {
			tmpl: 'ProductCompare-Mobile',
			selector: '.pcsec'
		},
		selectModal: {
			tmpl: 'ProductCompare-SelectDialog',
			selector: '#modalSecCompare'
		}
	},
	productListModal: {
		phone: {
			tmpl: 'ProductListHeaderPhone',
			selector: '#productListHeader'
		}
	},

	Menu: {
		desktop: {
			tmpl: 'menu-desktop-template',
			selector: '.menu_container'
		},
		phone: {
			tmpl: 'menu-mobile-template',
			selector: '.header_menu'
		},
		myAccountMenuView: {
			tmpl: 'my-account-menu-desktop-template',
			selector: '.cc_menu_my_account'
		}
	},

	autoComplete: {
		PRODUCT_SEARCH: {
			search_input:{
				minLength: 3,
				delay: 300,
				resultLimit: 10,
				position: {collision:'none flip'}
			},
			sidebarSearchText:{
				minLength: 3,
				delay: 300,
				resultLimit: 10,
				position: {collision:'none flip'}
			}
		},
		QUICK_ORDER: {
			quickOrderField:{
				minLength: 3,
				delay: 300,
				resultLimit: 10,
				position: {collision:'none flip'}
			}
		}
	},

	productSearchView: {
		desktop: {
			tmpl: 'productSearchTemplateDesktop',
			selector: '.search_form'
		},
		phone: {
			tmpl: 'productSearchTemplatePhone',
			selector: '#productSearch'
		}
	},

	CategoryTree: {
		tmpl: 'category-container-template',
		desktop: {
			left: {
				selector: '#categories-left-nav'
			},
			right: {
				selector: '#categories-right-nav'
			}
		},
		tablet: {
			selector: '#categories-right-nav'
		},
		phone: {
			selector: '.phone_center_column .home-cats'
		}
	},

	spotlightView: {
		desktop: {
			tmpl: 'Spotlight-Desktop',
			selector: '.featured-prod'
		},
		phone: {
			tmpl: 'Spotlight-Mobile',
			selector: '.phone_center_column .phone_center_mid'
		}
	},

	PromoDisp: {
		desktop: {
			tmpl: 'promo-desktop-template',
			right: {
				selector: '.promotion-box-RightNav'
			},
			left: {
				selector: '.promotion-box-LeftNav'
			},
			banner: {
				tmpl: 'promo-desktop-template-centerColumn',
				selector: '.promotion-box-Banner'
			}
		},
		tablet: {
			side: {
				selector: '.promotion-box-RightNav'
			},
			banner: {
				selector: '.promotion-box-Banner'
			}
		},
		phone: {
			tmpl: 'promo-phone-template',
			selector: '.phone_center_column .phone_center_bot'
		}
	},

	SplashDisp: {
		desktop: {
			tmpl: 'splash-desktop-template',
			selector: '.splash-promo-Desktop'
		},
 		phone: {
			tmpl: 'splash-phone-template',
			selector: '.splash-promo-Mobile'
		}
	},

	quickWishlistView: {
		desktop: {
			tmpl: 'QuickOrder-Wishlist-Desktop',
			selector: '.cart-template'
		},
		phone: {
			tmpl: 'QuickOrder-Wishlist-Mobile',
			selector: '.phone_center_column .home-template'
		}
	},
	quickWishDetailsView: {
		desktop: {
			tmpl: 'QuickOrder-WishlistItems-Desktop',
			selector: '.quickwishdesk'
		},
		phone: {
			tmpl: 'QuickOrder-WishlistItems-Mobile',
			selector: '.quickwishphone'
		}
	},

	miniCartView: {
		desktop: {
			tmpl: 'MiniCart-Desktop',
			selector: '.minicart'
		},
		phone: {
			tmpl: 'CartTemplate',
			selector: '#cartBody'
		},
		removeModal: {
			tmpl: 'MiniCart-RemoveDialog',
			selector: '#modalSec'
		},
		partial: {
			minicartAttributesDisplay: '#MiniCart-AttributeItems'
		}
	},

	QuickOrderView: {
		desktop: {
			tmpl: 'MiniQuickOrder-Desktop',
			selector: '.quick-order'
		},
		entry: {
			tmpl: 'MiniQuickOrder-Entry-Desktop'
		},
		phone: {
			selector: '.quick-order'
		}
	},

	searchWidget: {
		tmpl: 'SidebarSearch',
		desktop: {
			right: {
				selector: 'search-box-RightNav'
			},
			left: {
				selector: 'search-box-LeftNav'
			},
		}
	},

	breadcrumbView: {
		desktop: {
			tmpl: 'breadCrumbBrowser',
			selector: '#breadcrumb_desktop_container'
		},
		phone: {
			tmpl: 'breadCrumbPhone',
			selector: '#breadcrumb'
		}
	},

	productCatalogView: {
		desktop: {
			tmpl: 'productCatalogDesktop',
			selector: '.desktop_body'
		},
		phone: {
			tmpl: 'productCatalogPhone',
			selector: '.phone_center_column'
		}
	},
	productPaginationView: {
		desktop: {
			tmpl: 'navigationPanelDesktop',
			selector: '.listPaginationSec'
		},
		phone: {
			tmpl: 'navigationPanelPhone',
			selector: '.listPaginationSecPhone'
		}
	},
	productListView: {
		desktop: {
			tmpl: 'productListBrowser',
			selector: '.prodListSec'
		},
		phone: {
			tmpl: 'productListPhone',
			selector: '.prodListSecPhone'
		}
	},
	productListPageView: {
		desktop: {
			tmpl: 'Product-List-Page-View',
			selector: '.desktop_body'
		},
		header: {
			tmpl: 'Product-List-Header',
			selector: '.productListHeader'
		},
		footer: {
			tmpl: 'Product-List-Footer',
			selector: '.productListFooter'
		},
		productItems: {
			selector: '.productListContent'
		},
		productItem: {
			grid: {
				tmpl: 'Product-Item-Grid'
			},
			list: {
				tmpl: 'Product-Item-Row'
			}
		},
		partials: {
			noResultsDisplay: '#noResultsDisplay'
		}
	},
	productListFilterView: {
		desktop: {
			tmpl: "Product-List-Filter",
			selector: ".filterContainer"
		},
		ListView: {
			selector: ".specGroupContent"
		},
		ItemView:{
			tmpl: "Spec-Group-View"
		}
	},
	productCompareTrayView: {
		desktop: {
			tmpl: 'Product-Compare-Tray-View',
			selector: '.compareTray'
		}
	},
	CartDetailView: {
		desktop: {
			tmpl: 'CartDetail-View-Desktop',
			selector: '.cartContainer'
		},
		phone: {
			tmpl: 'CartDetail-View-Mobile',
			selector: '.phone_center_column'
		},
		partials: {
			emailModal: '#emailModalTemplate',
			rfqModal: '#rfqModalTemplate',
			wishModal: '#wishlistModalTemplate',
			qtyChangedModal: '#qtyChangedModalTemplate',
			refreshCartModal: '#refreshCartModalTemplate',
			refreshCartCheckoutModal: '#refreshCartCheckoutModalTemplate',
			removeInvalidModal: '#removeInvalidModalTemplate',
			cartItemsDesktop: '#CartItemDetail-View-Desktop',
			cartItemsMobile: '#CartItemDetail-View-Mobile',
			cartItemsQty: '#CartItemDetail-Qty-View',
			cartItemComment: '#CartItemDetail-Comments-View',
			cartItemAdditional: '#CartItemDetail-Additional-View',
			headerSection: '#CartDetail-Header-View',
			actionsTotals: '#CartDetail-ActionTotals-View',
			attributesDisplay: '#Cart-AttributeItems'
		},
		removeModal: {
			tmpl: 'Cart-RemoveDialog',
			selector: '#modalSec'
		},
		ciTP: {
			tmpl: 'CartItemDetail-TP-Desktop',
			selector: '.cc_prt_div_cart_collapse_'
		},
        CartIncItemsView: {
            tmpl: 'IncludedItemsBody-Data',
            selector: '.modal-body_included_items'
        },
        CartIncItemsViewV2: {
            tmpl: 'IncludedItemsBody-DataV2',
            selector: '.modal-body_included_items'
        },
        CartOrderAttrItemsView: {
            tmpl: 'IncludedAttributesBody-Data',
            selector: '.modal-order_attribute_items'
		},
        CartOrderAttrItemsViewV2: {
            tmpl: 'IncludedAttributesBody-DataV2',
            selector: '.modal-order_attribute_items'
        },
        CartAttrItemsView: {
            tmpl: 'Cart-AttributeItems',
            selector: '.modal-attribute_items'
        },
		localization: {
			'en-US': {
				date:{},
				time:{hour:'numeric',minute:'2-digit'},
				datetime:{hour:'numeric',minute:'2-digit'}
			}
		}
	},

	wishlistPickerModal: {
		desktop: {
			tmpl: 'AddtoWishlist-Desktop'
		},
		phone: {
			tmpl: 'AddtoWishlist-Phone'
		},
		selector: '.wishButtons',
		nameSelector: '.btn-group.dropdown'
	},

	productDetailView: {
		desktop: {
			tmpl: 'ProductDetail-Desktop',
			right: {
				selector: '.right_column .widgetSection'
			},
			main: {
				selector: '.prodDetailContainer'
			},
		},
		phone: {
			tmpl: 'ProductDetail-Mobile',
			selector: '.phone_center_column'
		}
	},
	aggregateView: {
		desktop: {
			tmpl: 'ProductDetail-Aggregate-Desktop',
			aggContent: {
				tmpl: 'ProductDetail-AggContent-Desktop'
			},
			mainImageContentDesktop: {
				tmpl: 'ProductDetail-AggImageContent-Desktop'
			},
			aggTP: {
				tmpl: 'ProductDetail-AggTP-Desktop'
			}
		},
		phone: {
			tmpl: 'ProductDetail-Aggregate-Mobile',
			aggContent: {
				tmpl: 'ProductDetail-AggContent-Mobile'
			}
		},
		partials: {
			mainContentDesktop: '#ProductDetail-AggContent-Desktop',
			mainImageContentDesktop: '#ProductDetail-AggImageContent-Desktop',
			mainContentPhone: '#ProductDetail-AggContent-Mobile',
			aggTP: '#ProductDetail-AggTP-Desktop'
		}
	},
	assemblyInclItemsView: {
		desktop: {
			tmpl: 'ProductDetail-IncludedSection-Desktop',
			selector: '.prodDetailContainer .includedItemsSection'
		},
		phone: {
			tmpl: 'ProductDetail-IncludedSection-Mobile',
			selector: '.phone_center_column .includedItemsSection'
		}
	},
	bundleInclItemsView: {
		desktop: {
			tmpl: 'ProductDetail-IncludedSection-Desktop',
			selector: '.prodDetailContainer .includedItemsSection'
		},
		phone: {
			tmpl: 'ProductDetail-IncludedSection-Mobile',
			selector: '.phone_center_column .includedItemsSection'
		}
	},
	tabSectionView: {
		desktop: {
			tmpl: 'ProductDetail-TabContainer-Desktop',
			selector: '.prodDetailContainer .tabSection'
		},
		phone: {
			tmpl: 'ProductDetail-TabContainer-Mobile',
			selector: '.phone_center_column .tabSection'
		}
	},
	productAttributesView: {
		tmpl: 'ProductDetail-ProductAttributes-Desktop',
		selector: '.cc_product_attributes'
	},
	productAttributesBatchHeaderView: {
		tmpl: 'ProductDetail-ProductAttributesBatchHeader-Desktop',
		selector: '.cc_product_attributes_batch_header'
	},
	productAttributesBatchView: {
		tmpl: 'ProductDetail-ProductAttributesBatch-Desktop',
		selector: '.cc_product_attributes_batch'
	},
	productAttributesBatchItemView: {
		tmpl: 'ProductDetail-ProductAttributesBatchItem-Desktop',
		selector: '.cc_product_attributes_batch_item'
	},
	productTierSectionView: {
		tmpl: 'ProductDetail-ProductPricingTiers-Desktop',
		right: {
			selector: '.right_column .'
		},
		main: {
			selector: '.prodDetailContainer .'
		},
		noSection:{
			selector: '.cc_product_pricing_tiers'
		}
	},
	widgetSectionView: {
		desktop: {
			tmpl: 'ProductDetail-WidgetContainer-Desktop',
			right: {
				selector: '.right_column .widgetSection'
			},
			main: {
				selector: '.prodDetailContainer .widgetSection'
			},
		},
		phone: {
			tmpl: 'ProductDetail-WidgetContainer-Mobile',
			selector: '.phone_center_column .widgetSection'
		}
	},
	contentSectionView: {
		desktop: {
			tmpl: 'ProductDetail-ContentSection-Desktop',
			selector: '.prodDetailContainer .'
		},
		phone: {
			tmpl: 'ProductDetail-ContentSection-Mobile',
			selector: '.phone_center_column .'
		}
	},
	nameValGroupSectionView: {
		desktop: {
			tmpl: 'ProductDetail-NameValueGroupedSection-Desktop',
			right: {
				selector: '.right_column .'
			},
			main: {
				selector: '.prodDetailContainer .'
			},
		},
		phone: {
			tmpl: 'ProductDetail-NameValueGroupedSection-Mobile',
			selector: '.phone_center_column .'
		}
	},
	nameValSectionView: {
		desktop: {
			tmpl: 'ProductDetail-NameValueSection-Desktop',
			right: {
				selector: '.right_column .'
			},
			main: {
				selector: '.prodDetailContainer .'
			},
		},
		phone: {
			tmpl: 'ProductDetail-NameValueSection-Mobile',
			selector: '.phone_center_column .'
		}
	},
	mediaSectionView: {
		desktop: {
			tmpl: 'ProductDetail-MediaSection-Desktop',
			selector: '.prodDetailContainer .'
		},
		phone: {
			tmpl: 'ProductDetail-MediaSection-Mobile',
			selector: '.phone_center_column .'
		}
	},
	sellerSectionView : {
		desktop : {
				tmpl : 'ProductDetail-SellerSection-Desktop',
				selector : '.prodDetailContainer .'
		},
		phone : {
			tmpl : 'ProductDetail-SellerSection-Desktop',
			selector : '.phone_center_column .'
		}
	},
	prodSectionView: {
		desktop: {
			right: {
				tmpl: 'ProductDetail-ProductsSectionRight-Desktop',
				selector: '.right_column .'
			},
			main: {
				tmpl: 'ProductDetail-ProductsSection-Desktop',
				selector: '.prodDetailContainer .'
			},
		},
		phone: {
			tmpl: 'ProductDetail-ProductsSection-Mobile',
			selector: '.phone_center_column .'
		}
	},
	dynamicKitView: {
		desktop: {
			flow: {
				tmpl: 'ProductDetail-DynamicFlowSection-Desktop',
			},
			tmpl: 'ProductDetail-DynamicSection-Desktop',
			selector: '.prodDetailContainer .dynamicKitSection'
		},
		phone: {
			flow: {
				tmpl: 'ProductDetail-DynamicFlowSection-Desktop',
			},
			tmpl: 'ProductDetail-DynamicSection-Mobile',
			selector: '.phone_center_column .dynamicKitSection'
		}
	},
	dynamicKitSelView: {
		desktop: {
			tmpl: 'ProductDetail-DynamicSelSection-Desktop',
			selector: '.prodDetailContainer .dynamicKitSelSection'
		},
		phone: {
			tmpl: 'ProductDetail-DynamicSelSection-Desktop',
			selector: '.phone_center_column .dynamicKitSelSection'
		}
	},
	FeatureFilterView: {
		desktop: {
			tmpl: 'FeatureFilter-View-Desktop',
			selector: '.deskLayout .filterContainer'
		},
		phone: {
			tmpl: 'FeatureFilter-View-Mobile',
			selector: '.phone_center_column .filterContainer'
		},
		Bread: {
			desktop: {
				tmpl: 'FeatureFilter-BreadCrumb-Desktop',
				selector: '.filter_breadcrumb_container_main'
			},
			phone: {
				tmpl: 'FeatureFilter-BreadCrumb-Mobile',
				selector: '.filters .filter_breadcrumb_container'
			}
		},
		filters: [
			'All'
		]
	},
	ErrorView: {
		desktop: {
			tmpl: 'Checkout-ErrorView'
		},
		phone: {
			tmpl: 'Checkout-ErrorView'
		}
	},
	AddressEntry: {
		desktop: {
			tmpl: 'UserInfo-AddressEntry-Desktop'
		},
		phone: {
			tmpl: 'UserInfo-AddressEntry-Mobile'
		}
	},
	AddressListing: {
		desktop: {
			tmpl: 'UserInfo-AddressList-Desktop'
		},
		phone: {
			tmpl: 'UserInfo-AddressList-Mobile'
		}
	},
	UserInfoView: {
		desktop: {
			tmpl: 'UserInfo-Desktop'
		},
		phone: {
			tmpl: 'UserInfo-Mobile'
		},
		partial: {
			addressEntry: '#UserInfo-AddressEdit-Desktop',
			addressSelection: '#UserInfo-AddressList-Mobile',
			addressDisplay: '#AddressDisplay'
		}
	},
	ShippingView: {
		desktop: {
			tmpl: 'Shipping-Desktop'
		},
		phone: {
			tmpl: 'Shipping-Mobile'
		}
	},
	CartOrderReviewView: {
		desktop: {
			tmpl: 'Review-Cart-Desktop'
		},
		phone: {
			tmpl: 'Review-Cart-Mobile'
		}
	},
    CartOrderReviewViewV2: {
        desktop: {
            tmpl: 'Review-Cart-DesktopV2'
        }
    },
	OrderReviewView: {
		desktop: {
			tmpl: 'Review-Desktop'
		},
		phone: {
			tmpl: 'Review-Mobile'
		},
		partial: {
			addressDisplay: '#AddressDisplay',
			includedDisplay: '#Cart-IncludedItems',
			totalsSection: '#TotalSection'
		}
	},
	PaymentView: {
		desktop: {
			tmpl: 'Payment-Desktop'
		},
		phone: {
			tmpl: 'Payment-Mobile'
		},
		partial: {
			poDisplay: '#Payment-PO',
			contractDisplay: '#Payment-Contract',
			ccDisplay: '#Payment-CC'
		}
	},
	cartCheckoutView: {
		desktop: {
			selector: '.checkoutContent'
		},
		phone: {
			selector: '.phone_center_column'
		}
	},
	CheckoutNav: {
		desktop: {
			tmpl: 'CheckoutHeader-Desktop',
			selector: '.home_slider'
		},
		phone: {
			tmpl: 'CheckoutHeader-Mobile',
			selector: '#productSearch'
		}
	},
	LLIcartCheckoutView: {
		desktop: {
			selector: '.checkoutContent'
		},
		phone: {
			selector: '.phone_center_column'
		}
	},
	LLICheckoutNav: {
		desktop: {
			tmpl: 'CheckoutHeader-LLI-Desktop',
			selector: '.home_slider'
		},
		phone: {
			tmpl: 'CheckoutHeader-LLI-Mobile',
			selector: '#productSearch'
		}
	},
	LLIShippingDetailView: {
		desktop: {
			tmpl: 'Shipping-Detail-LLI-Desktop',
		},
		phone: {
			tmpl: 'Shipping-Detail-LLI-Mobile',

		},
		addressEditModal: {
			desktop: {
				tmpl: 'Shipping-LII-Address-Edit-Modal-Desktop',
			},
			phone: {
				tmpl: 'Shipping-LII-Address-Edit-Modal-Mobile',
			},
			selector: '#modalSec'
		},
		moveItemModal: {
			tmpl: 'Shipping-LII-Move-Item-Modal',
			selector: '#modalSec'
		},
		lliAddressFormView: {
			desktop: {
				tmpl: 'LLI-AddressForm-Desktop'
			},
			phone: {
				tmpl: 'LLI-AddressForm-Mobile'
			}
		},
		partial: {
			cartItemsDesktop: '#CartItemDetail-View-Desktop',
			cartSummaryWidget: '#CartSummaryWidget-Desktop',

		}
	},
	LLIOrderReviewView: {
		desktop: {
			tmpl: 'Order-Review-LLI-Desktop',
		},
		phone: {
			tmpl: "Order-Review-LLI-Mobile"
		},
		partial: {
			cartItemDetailsReview: '#CartItemReview-View-Desktop',
			cartReviewSummary: '#CartReviewSummary-Desktop',
		}
	},
	LLIPaymentView: {
		desktop: {
			tmpl: 'LLI-Payment-Desktop',
		},
		phone: {
			tmpl: "LLI-Payment-Mobile"
		},
		partial: {
			cartPaymentSummary: '#CartPaymentSummary-Desktop',
			cartBillingAddress: '#CartBillingAddress'
		},
		addressEditModal: {
			desktop: {
			tmpl: 'Billing-LII-Address-Edit-Modal',
			selector: '#modalBillTo'
		},
			phone: {
				tmpl: 'Billing-LII-Address-Edit-Modal-Mobile',
				selector: '#modalBillTo'
			}

		},
		PaymentProcessor:{
			desktop: {
				tmpl: 'LLI-PaymentProcessor-Desktop',
				selector: '.checkoutPaymentTarget'
			},
			phone: {
				tmpl: 'LLI-PaymentProcessor-Mobile',
				selector: '.checkoutPaymentTarget'
			}
		}
	},
	AddressCarousel: {
		desktop: {
			tmpl: 'address-carousel-desktop-template',
			selector: '.addrEditCarousel'
		},
		phone: {
			tmpl: 'address-carousel-desktop-template',
			selector: '.addrEditCarousel'
		}
	},
	OrderNav: {
		desktop: {
			tmpl: 'OrderHeader-Desktop',
			selector: '.home_slider'
		},
		phone: {
			tmpl: 'OrderHeader-Mobile',
			selector: '#productSearch'
		}
	},
	OrderDetailAsyncView: {
		desktop: {
			tmpl: 'OrderDetailsAsync-View-Desktop',
			selector: '.orderContainer'
		},
		phone: {
			tmpl: 'OrderDetailsAsync-View-Mobile',
			selector: '.phone_center_column'
		},
		partial: {
			addressDisplay: '#AddressDisplay',
			includedDisplay: '#Cart-IncludedItems',
			orderAttributesDisplay: '#Cart-OrderAttributeItems',
			totalsSection: '#TotalSection',
			orderHeaderAsyncDesktop: '#OrderHeaderAsync-Desktop',
			orderItemDetail: '#OrderItemDetail-View-Desktop',
			orderItemAdditional: '#OrderItemAdditional',
		},
		OrderIncItemsView: {
			tmpl: 'IncludedItemsBody-Data',
			selector: '.modal-body_included_items'
		},
		OrderAttrItemsView: {
			tmpl: 'Cart-AttributeItems',
			selector: '.modal-attribute_items'
		}
	},
	OrderDetailView: {
		desktop: {
			tmpl: 'OrderDetails-View-Desktop',
			selector: '.orderContainer'
		},
		phone: {
			tmpl: 'OrderDetails-View-Mobile',
			selector: '.phone_center_column'
		},
		partial: {
			addressDisplay: '#AddressDisplay',
			includedDisplay: '#Cart-IncludedItems',
			orderAttributesDisplay: '#Cart-OrderAttributeItems',
			totalsSection: '#TotalSection',
			orderItemsDesktop: '#OrderItems-Desktop'
		}
	},
	OrderDetailLLIView: {
		desktop: {
			tmpl: 'OrderDetailsLLI-View-Desktop',
			selector: '.orderContainer'
		},
		phone: {
			tmpl: 'OrderDetailsLLI-View-Mobile',
			selector: '.phone_center_column'
		},
		partial: {
			orderReviewSummary: '#OrderReviewSummary-Desktop',
			orderItemsLLIDesktop: '#OrderItemsLLI-Desktop',
		}
	},
	myaccountView: {
		desktop: {
			selector: '.acctmainSection'
		},
		phone: {
			selector: '.phone_center_column'
		}
	},
	myAccountNavView: {
		desktop: {
			tmpl: 'MyAccount-Nav-Desktop',
			selector: '#MyAccount_navSection'
		},
		tablet: {
			tmpl: 'MyAccount-Nav-Tablet',
			selector: '#MyAccount_navSection_tablet'
		}
	},
	contactInfoView: {
		desktop: {
			tmpl: 'MyAccount-ContactInformation-Desktop'
		},
		phone: {
			tmpl: 'MyAccount-ContactInformation-Mobile'
		}
	},
	contactInfoEditView: {
		desktop: {
			tmpl: 'MyAccount-ContactInformationEdit-Desktop'
		},
		phone: {
			tmpl: 'MyAccount-ContactInformationEdit-Mobile'
		}
	},
	myAccountChangePasswordView: {
		desktop: {
			tmpl: 'MyAccount-ChangePassword-Desktop',
			tmplOverride: 'MyAccount-ChangePassword-Desktop-Override'
		},
		phone: {
			tmpl: 'MyAccount-ChangePassword-Mobile'
		}
	},
	myAddressBookView: {
		desktop: {
			tmpl: 'MyAccount-AddressBook-Desktop'
		},
		phone: {
			tmpl: 'MyAccount-AddressBook-Mobile'
		},
		addressEditModal: {
			tmpl: 'MyAccount-MyAddressBook-EditDialog',
			selector: '#modalSec'
		}
	},
	myOrdersView: {
		desktop: {
			tmpl: 'MyAccount-MyOrders-Desktop'
		},
		phone: {
			tmpl: 'MyAccount-MyOrders-Mobile'
		},
		cancelModal: {
			tmpl: 'MyAccount-MyOrders-CancelDialog',
			selector: '#modalSec'
		}
	},
	myCartsView: {
		desktop: {
			tmpl: 'MyAccount-MyCarts-Desktop'
		},
		phone: {
			tmpl: 'MyAccount-MyCarts-Mobile'
		}
	},
	myWalletView: {
		desktop: {
			tmpl: 'MyAccount-MyWallet-Desktop'
		},
		phone: {
			tmpl: 'MyAccount-MyWallet-Mobile'
		},
		deleteModal: {
			tmpl: 'MyAccount-MyWallet-DeleteDialog',
			selector: '#modalSec'
		}
	},
	myWishlistsView: {
		desktop: {
			tmpl: 'MyAccount-MyWishlist-Desktop'
		},
		phone: {
			tmpl: 'MyAccount-MyWishlist-Mobile'
		}
	},
	mySubscriptionSummaryView: {
		desktop: {
			tmpl: 'MyAccount-MySubscriptions-Desktop'
		},
		phone: {
			tmpl: 'MyAccount-MySubscriptions-Mobile',
			selector: '.phone_center_column'
		},
		cancelModal: {
			tmpl: 'MyAccount-MySubscriptions-CancelDialog',
			selector: '#modalSec'
		}
	},
	mySubscriptionDetailView: {
		desktop: {
			tmpl: 'SubscriptionDetail-View-Both'
		},
		phone: {
			tmpl: 'SubscriptionDetail-View-Mobile'
		},
		cancelModal: {
			tmpl: 'MyAccount-MySubscription-Detail-CancelDialog',
			selector: '#modalSecDetail'
		}
	},
	SubscriptionPaymentView: {
		SubPaymentView:{
			desktop: {
				tmpl: 'Payment-Desktop',
				selector: '.checkoutPaymentTarget'
			},
			phone: {
				tmpl: 'Payment-Mobile',
				selector: '.phone_center_column'
			}
		},
		PaymentProcessor:{
			desktop: {
				tmpl: 'PaymentProcessor-Desktop',
				selector: '.subTarget'
			},
			phone: {
				tmpl: 'PaymentProcessor-Mobile',
				selector: '.subTarget'
			}
		}
	},
	wishlistDetailsView: {
		desktop: {
			tmpl: 'MyAccount-WishlistDetail-Desktop'
		},
		phone: {
			tmpl: 'MyAccount-WishlistDetail-Mobile'
		},
		editModal: {
			tmpl: 'MyAccount-MyWishlist-EditDialog',
			selector: '#modalSec'
		}
	},
	changePasswordView: {
		desktop: {
			tmpl : 'ChangePassword-View-Desktop',
			selector : '.changePasswordContainer'
		},
		phone: {
			tmpl : 'ChangePassword-View-Phone',
			selector : '.phone_center_top'
		}
	},
	navigatePaginationView: {
		desktop: {
			tmpl: 'navigationPanelDesktop',
			selector: '.orderPaginationSec'
		},
		phone: {
			tmpl: 'navigationPanelPhone',
			selector: '.orderPaginationSecPhone'
		}
	},
	mySubscriptionSummaryNewView: {
		desktop: {
			tmpl: 'MyAccount-MySubscriptions-Desktop-New'
		},
		phone: {
			tmpl: 'MyAccount-MySubscriptions-Mobile-New',
			selector: '.phone_center_column'
		},
		cancelModal: {
			tmpl: 'MyAccount-MySubscriptions-CancelDialog',
			selector: '#modalSec'
		}
	},
	SubscriptionDetailView: {
		desktop: {
			tmpl: 'SubscriptionDetail-View-Both',
			selector: '.subContainer'
		},
		phone: {
			tmpl: 'SubscriptionDetail-View-Mobile',
			selector: '.phone_center_column'
		},
		cancelModal: {
			tmpl: 'MyAccount-MySubscription-Detail-CancelDialog',
			selector: '#modalSecDetail'
		},
		partial: {
			addressDisplay: '#AddressDisplay'
		}
	},
	myInvoicesView: {
		desktop: {
			tmpl: 'MyAccount-MyInvoices-Desktop'
		},
		phone: {
			tmpl: 'MyAccount-MyInvoices-Mobile'
		}
	},
	InvoiceDetailView: {
		desktop: {
			tmpl: 'InvoiceDetail-Desktop',
			selector: '.invoiceContainer'
		},
		phone: {
			tmpl: 'InvoiceDetail-Mobile',
			selector: '.phone_center_column'
		},
		partial: {
			addressDisplay: '#AddressDisplay'
		}
	},
	InvoicePaymentView: {
		partial: {
			addressDisplay: '#AddressDisplay'
		}
		,generic: {
			desktop: {
				tmpl: 'InvoicePayment-Generic-Desktop',
				selector: '.invoicePaymentContainer'
			},
			phone: {
				tmpl: 'InvoicePayment-Generic-Mobile',
				selector: '.phone_center_column'
			}
		}
		,summary:{
			desktop: {
				tmpl: 'InvoicePayment-Single-Desktop',
				selector: '.invoicePaymentContainer'
			},
			phone: {
				tmpl: 'InvoicePayment-Single-Mobile',
				selector: '.phone_center_column'
			}
		}
		,single:{
			desktop: {
				tmpl: 'InvoicePayment-Single-Desktop',
				selector: '.invoicePaymentContainer'
			},
			phone: {
				tmpl: 'InvoicePayment-Single-Mobile',
				selector: '.phone_center_column'
			}
		}
		,PaymentProcessor:{
			desktop: {
				tmpl: 'PaymentProcessor-Desktop',
				selector: '.invoicePaymentTarget'
			},
			phone: {
				tmpl: 'PaymentProcessor-Mobile',
				selector: '.invoicePaymentTarget'
			}
		}
	},
	PaymentDetailView: {
		desktop: {
			tmpl: 'PaymentDetail-Desktop',
			selector: '.paymentContainer'
		},
		phone: {
			tmpl: 'PaymentDetail-Mobile',
			selector: '.phone_center_column'
		},
		partial: {
			addressDisplay: '#AddressDisplay'
		}
	},
	newCustomerView: {
		desktop: {
			tmpl: 'SiteRegister-NewCustomer-Desktop',
			selector: '.newCustomerSection'
		},
		phone: {
			tmpl: 'SiteRegister-NewCustomer-Mobile',
			selector: '.phone_center_mid'
		}
	},
	loginView: {
		desktop: {
			tmpl: 'SiteLogin-Desktop',
			selector: '#login_main_content'
		},
		phone: {
			tmpl: 'SiteLogin-Phone',
			selector: '.phone_center_top'
		}
	},
	CCExceptionView: {
		desktop: {
			tmpl: 'CCException-Desktop',
			selector: '.cc-exception'
		},
		phone: {
			tmpl: 'CCException-Mobile',
			selector: '.phone_center_column .phone_center_mid'
		}
	},
	EffAccountSelView: {
		header: {
			tmpl: 'EffAcctSel-Head-View-Desktop',
			desktop: {
				selector: '.misc-function'
			},
			phone: {
				selector: '.misc-function'
			}
		},
		widget: {
			tmpl: 'EffAcctSel-Widget-View-Desktop',
			desktop: {
				selector: '.effwig'
			},
			phone: {
				selector: '.phone-eff'
			}
		}
	},
	CheckoutNewPaymentWidgetView: {
		desktop: {
			selector: 'new_payment_widget_'
		},
		phone: {
			selector: 'phone_new_payment_widget_'
		}
	},
	StoredPaymentsPOView: {
		desktop: {
			tmpl: 'MyAccount-MyWalletPO-Desktop',
			selector: '.paymentContainer'
		},
		phone: {
			tmpl: 'MyAccount-MyWalletPO-Desktop',
			selector: '.phone_center_column'
		}
	},
	CheckoutPaymentView: {
		PaymentProcessor:{
			desktop: {
				tmpl: 'PaymentProcessor-Desktop',
				selector: '.checkoutPaymentTarget'
			},
			phone: {
				tmpl: 'PaymentProcessor-Mobile',
				selector: '.checkoutPaymentTarget'
			}
		}
	},
	PaymentsPOView: {
		desktop: {
			tmpl: 'PaymentPO-Both',
			selector: '.paymentContainer'
		},
		phone: {
			tmpl: 'PaymentPO-Both',
			selector: '.phone_center_column'
		}
	},
	PaymentPageErrorView: {
		desktop: {
			tmpl: 'PaymentError-Both',
			selector: '.paymentContainer'
		},
		phone: {
			tmpl: 'PaymentError-Both',
			selector: '.phone_center_column'
		}
	},
	SellerLocatorSearchView : {
		desktop : {
			tmpl : 'sellerLocatorSearch-Both',
			selector : '.seller-locator-search'
		},
		phone: {
			tmpl: 'sellerLocatorSearch-Both',
			selector: 'seller-locator-search'
		}
	},
	SellerLocatorDetailView : {
		desktop : {
			tmpl : 'sellerDetail-Both',
			selector : '.desktop_body'
		},
		phone : {
			tmpl : 'sellerDetail-Both',
			selector : '.phone_center_mid'
		}
	},
	SellerLocatorListView : {
		desktop : {
			tmpl : 'seller-locator-list',
			selector : '.desktop_body'
		},
		phone : {
			tmpl : 'seller-locator-list',
			selector : '.phone_center_mid'
		}
	},
	ReOrderView: {
		tmpl: 'ReOrder3',
		selector: '.reorderContainer',
		OrderedItemsView: {
			tmpl: 'ReOrder-IncludedItems',
			selector: '#incItems'
		}
	},
	CartTotalsView: {
		tmpl: 'CartTotalsView',
		selector: '#cartTotals'
	},
	CartActionsView: {
		tmpl: 'CartActionsView',
		selector: '#cartActions'
	},
	CartItemsView: {
		tmpl: 'CartItemsView',
		selector: '#cartItems',
		partials: {
			cartItemsPagination: '#CartItemsPaginationView'
		}
	},
	OrderItemsView: {
		tmpl: 'OrderItemsView',
		selector: '#orderItems',
		partials: {
			orderItemsPagination: '#OrderItemsPaginationView'
		}
	}
};

;

/*
 * Created by salesforce.com, inc.
 * Copyright 2019 salesforce.com, inc. All rights reserved.
 * Redistribution and use in source or binary forms, with or without
 * modification is PROHIBITED.
 *
 * ccrz-analytics 4.11.0
 */
jQuery(function() {
    "use strict";
    CCRZ.ga = CCRZ.ga || false;
    if (!_.isEmpty(CCRZ.ga)) {
        /**
         * Google Analytics Pageview
         */
        CCRZ.ga.sendPageview = CCRZ.ga.sendPageview || function(context, pageData, hitCallback) {
            // assumes root path such as location.pathname
            if (pageData['page']) {
                ga(CCRZ.ga['trackerName'] + '.set', 'page', pageData['page']);
            }
            if (pageData['title']) {
                ga(CCRZ.ga['trackerName'] + '.set', 'title', pageData['title']);
            }
            ga(CCRZ.ga['trackerName']+'.set', 'anonymizeIp', CCRZ.ga['anonymizeIp']);
            ga(CCRZ.ga['trackerName']+'.send', 'pageview',
                _.extend((typeof hitCallback === 'function')? {hitCallback : hitCallback} : {}, pageData));
        };

        /**
         * Google Analytics eCommerce AddTransaction and AddItem
         */
        CCRZ.ga.sendTransaction = CCRZ.ga.sendTransaction || function(context, txnData, hitCallback) {
            // assumes order detail model
            var gaTxn = {
                'id': txnData.attributes.encryptedId
                , 'affiliation': txnData.attributes['storefront']
                , 'revenue': txnData.attributes['totalAmount']
                , 'currency': txnData.attributes['currencyCode']
            }
            if (jQuery.isNumeric(txnData.attributes['shippingCharge'])) {
                gaTxn['shipping'] = txnData.attributes['shippingCharge'];
            }
            if (jQuery.isNumeric(txnData.attributes['tax'])) {
                gaTxn['tax'] = txnData.attributes['tax'];
            }
            if (typeof hitCallback === 'function') { gaTxn['hitCallback'] = hitCallback; }
            ga(CCRZ.ga['trackerName']+'.ecommerce:addTransaction', gaTxn);
            _.each(txnData.attributes.orderItems, function(orderItem) {
                var gaItem = {
                    'id': txnData.attributes.encryptedId
                    , 'name': orderItem.mockProduct['sfdcName']
                    , 'sku': orderItem.mockProduct['SKU']
                    , 'price': orderItem['originalItemPrice']
                    , 'quantity': orderItem['quantity']
                    , 'currency': txnData.attributes['currencyCode']
                }
                ga(CCRZ.ga['trackerName']+'.ecommerce:addItem', gaItem);
            });
            ga(CCRZ.ga['trackerName']+'.ecommerce:send');
        };

        /**
         * Google Analytics eCommerce AddTransaction and AddItem for LLI Order
         */
        CCRZ.ga.sendLLIOrderTransaction = CCRZ.ga.sendLLIOrderTransaction || function(context, txnData, hitCallback) {
            // assumes lli order detail model
            var orderItems = [];
            var gaItems = [];
            var mergedGAItems = [];
            var gaTxn = {
                'id': txnData.attributes.orderEncId
                , 'affiliation': txnData.attributes.orderStorefront
                , 'revenue': txnData.attributes['orderData'].totalAmount
                , 'currency': txnData.attributes['orderData'].currencyISOCode
            }
            if (jQuery.isNumeric(txnData.attributes['orderData'].shipAmount)) {
                gaTxn['shipping'] = txnData.attributes['orderData'].shipAmount;
            }
            if (jQuery.isNumeric(txnData.attributes['orderData'].taxAmount)) {
                gaTxn['tax'] = txnData.attributes['orderData'].taxAmount;
            }
            if (typeof hitCallback === 'function') { gaTxn['hitCallback'] = hitCallback; }
            ga(CCRZ.ga['trackerName']+'.ecommerce:addTransaction', gaTxn);
            if (txnData.attributes['orderData']['EOrderItemGroupsS']) {
                _.each(txnData.attributes['orderData'].EOrderItemGroupsS.models, function (orderItemGroup) {
                    // append orderItems from all the shipping groups
                    orderItems = orderItems.concat(orderItemGroup.attributes.EOrderItemsS);
                });
            }
            _.each(orderItems, function(orderItem) {
                // prepare gaItems
                var gaItem = {
                    'id': txnData.attributes.orderEncId
                    , 'name': orderItem.productName
                    , 'sku': orderItem.productSKU
                    , 'price': orderItem.originalItemPrice
                    , 'quantity': orderItem.quantity
                    , 'currency': txnData.attributes['orderData'].currencyISOCode
                }
                gaItems.push(gaItem);
            });
            _.each(gaItems, function(gaItem) {
                // merge duplicate gaItems, adding the quantity
                if (!this[gaItem.name]) {
                    this[gaItem.name] = {
                        'id':gaItem.id
                        , 'name': gaItem.name
                        , 'sku':gaItem.sku
                        , 'quantity': 0
                        , 'price':gaItem.price
                        , 'currency': gaItem.currency };
                    mergedGAItems.push(this[gaItem.name]);
                }
                this[gaItem.name].quantity += gaItem.quantity;
            }, Object.create(null));
            _.each(mergedGAItems, function(mergedItem) {
                ga(CCRZ.ga['trackerName']+'.ecommerce:addItem', mergedItem);
            });
            ga(CCRZ.ga['trackerName']+'.ecommerce:send');
        };

        /**
         * Google Analytics Generic Event Hit
         */
        CCRZ.ga.sendEvent = CCRZ.ga.sendEvent || function(context, eventData, hitCallback) {
            // eventData.eventCategory and eventAction are required
            var gaEv = {
                'hitType': 'event'
                , 'eventCategory' : eventData['eventCategory']
                , 'eventAction' : eventData['eventAction']
            };
            if (eventData['eventLabel']) { gaEv['eventLabel'] = eventData['eventLabel']; }
            if (jQuery.isNumeric(eventData['eventValue'])) {
                gaEv['eventValue'] = eventData['eventValue'];
            }
            if (eventData['transport']) { gaEv['transport'] = eventData['transport']; } // transport:beacon support
            if (eventData['nonInteraction']) { gaEv['nonInteraction'] = eventData['nonInteraction']; } // non-interaction support
            if (typeof hitCallback === 'function') { gaEv['hitCallback'] = hitCallback; }
            ga(CCRZ.ga['trackerName']+'.send', gaEv);
        }

        /**
         * Google Analytics Exception Hit
         */
        CCRZ.ga.sendException = CCRZ.ga.sendException || function(context, exData, hitCallback) {
            var gaEx = { 'hitType': 'exception', 'exDescription': 'Exception' };
            if (exData['exDescription']) { gaEx['exDescription'] = exData['exDescription']; }
            if (exData['exFatal']) { gaEx['exFatal'] = exData['exFatal']; }
            if (typeof hitCallback === 'function') { gaEx['hitCallback'] = hitCallback; }
            ga(CCRZ.ga['trackerName']+'.send', gaEx);
        }

        /**
         * Google Analytics, Pageview Query Parameter Filter
         */
        CCRZ.ga.pageviewParams = CCRZ.ga.pageviewParams || [
            {'pathname': /.+/, 'params':['store','cclcl']}
            , {'pathname': /ProductList$/gi, 'params':['searchText','categoryId']}
            , {'pathname': /ProductDetails$/gi, 'params': ['sku']}
            , {'pathname': /Cart$/gi, 'params': ['cartId']}
            , {'pathname': /Checkout$/gi, 'params': ['cartId']}
            , {'pathname': /CheckoutNew$/gi, 'params': ['cartID']}
            , {'pathname': /OrderConfirmation$/gi, 'params': ['o']}
            , {'pathname': /OrderView$/gi, 'params': ['o']}
            , {'pathname': /CCPage$/gi, 'params': ['pagekey']}
        ];

        /**
         * B2B Commerce specific tracking
         */
        CCRZ.ga.safeParams = CCRZ.ga.safeParams || function() {
            return jQuery.param(_.omit(_.pick(CCRZ.pagevars.queryParams,
                _.chain(CCRZ.ga.pageviewParams)
                    .filter(function (val, k, o) {
                        return window.location.pathname.match(val['pathname'])
                    })
                    .pluck('params')
                    .flatten()
                    .sort()
                    .value()), _.isEmpty));
        }
        // pageview
        CCRZ.ga.sendPageview(CCRZ.pagevars, {'page':[ window.location.pathname, CCRZ.ga.safeParams() ].join('?')});

        // specific handlers
        CCRZ.ga.handleProductDetails = CCRZ.ga.handleProductDetails || function(objLink, cb) {
            var gaEv = {
                'transport': 'beacon'
                , 'eventCategory': 'Discovery'
                , 'eventAction' : 'Viewed a Product'
            };
            var promo = jQuery(objLink).attr("data-promo");
            if (promo && promo.length > 0) {
                gaEv['eventLabel'] = promo;
                gaEv['eventAction'] = 'Viewed a Promotion';
            } else {
                var dataProduct = jQuery(objLink).attr('data-product');
                var dataSku = jQuery(objLink).attr('data-id');
                if (dataSku && dataSku.length) {
                    gaEv['eventLabel'] = dataSku;
                } else if (dataProduct && dataProduct.length > 0) {
                    var parsed = JSON.parse(dataProduct);
                    gaEv['eventLabel'] = parsed['SKU'];
                }
            }
            CCRZ.ga.sendEvent(_.extend({'source': ((promo && promo.length > 0)?'Promotion':CCRZ.pagevars.currentPageName)}, CCRZ.pagevars), gaEv, cb);
        };

        CCRZ.ga.handleProductList = CCRZ.ga.handleProductList || function(objLink, cb) {
            var gaEv = {
                'transport': 'beacon'
                , 'eventCategory': 'Discovery'
                , 'eventAction': 'Viewed a Category'
            };
            var promo = jQuery(objLink).attr("data-promo");
            if (promo && promo.length > 0) {
                gaEv['eventLabel'] = promo;
                gaEv['eventAction'] = 'Viewed a Promotion';
            } else {
                var dataCategory = jQuery(objLink).attr('data-category');
                if (dataCategory && !jQuery.isEmptyObject(dataCategory)) {
                    // leftnav||topnav||breadcrumb
                    gaEv['eventLabel'] = dataCategory['categoryID'] ||
                        dataCategory['displayName'] ||
                        (dataCategory['category'] && dataCategory['category']['name']);
                }
            }
            CCRZ.ga.sendEvent(_.extend({'source': ((promo && promo.length > 0)?'Promotion':CCRZ.pagevars.currentPageName)}, CCRZ.pagevars), gaEv, cb);
        };

        CCRZ.ga.handleFeatureFilter = CCRZ.ga.handleFeatureFilter || function(objLink, cb) {
            var gaEv = {
                'transport': 'beacon'
                , 'eventCategory': 'Discovery'
                , 'eventAction' : 'Applied a Filter'
            };
            var specFormat = '{0}:{1}';
            var specName = jQuery(objLink).attr("data-spec");
            var specValue = jQuery(objLink).attr("data-value");
            if (!specValue) {
                specValue = jQuery(objLink).val();
            }
            if (jQuery.isArray(specValue)) {
                specValue = specValue.join('-')
            }
            gaEv['eventLabel'] = substitute(specFormat, [specName, specValue]);
            CCRZ.ga.sendEvent(_.extend({'source': CCRZ.pagevars.currentPageName}, CCRZ.pagevars), gaEv, cb);
        };

        CCRZ.ga.handleAddToCart = CCRZ.ga.handleAddToCart || function(addToData, cb) {
            var gaEv = {
                'transport': 'beacon'
                , 'eventCategory': 'Shopping'
                , 'eventAction' : 'Added Product To Cart'
            };
            var sku = addToData['sku'];
            if (sku && sku.length > 0) {
                gaEv['eventLabel'] = sku;
            }
            CCRZ.ga.sendEvent(_.extend({'source': CCRZ.pagevars.currentPageName}, CCRZ.pagevars), gaEv, cb);
        };

        CCRZ.ga.handleCartContinueShopping = CCRZ.ga.handleCartContinueShopping || function(cartData, cb) {
            var gaEv = {
                'transport': 'beacon'
                , 'eventCategory': 'Shopping'
                , 'eventAction' : 'Clicked Continue Shopping'
            };
            var cartId = cartData['cartId'];
            if (cartId && cartId.length > 0) {
                gaEv['eventLabel'] = cartId;
            }
            CCRZ.ga.sendEvent(_.extend({'source': CCRZ.pagevars.currentPageName}, CCRZ.pagevars), gaEv, cb);
        };

        CCRZ.ga.handleCartCheckout = CCRZ.ga.handleCartCheckout || function(cartData, cb) {
            var gaEv = {
                'transport': 'beacon'
                , 'eventCategory': 'Checkout'
                , 'eventAction' : 'Started Checkout'
            };
            var cartId = cartData['cartId'];
            if (cartId && cartId.length > 0) {
                gaEv['eventLabel'] = cartId;
            }
            CCRZ.ga.sendEvent(_.extend({'source': CCRZ.pagevars.currentPageName}, CCRZ.pagevars), gaEv, cb);
        };

        CCRZ.ga.handleApplyCoupon = CCRZ.ga.handleApplyCoupon || function(couponData, cb) {
            var gaEv = {
                'transport': 'beacon'
                , 'eventCategory': 'Shopping'
                , 'eventAction' : 'Applied a Coupon'
            };
            var couponCode = couponData['couponCode'];
            if (couponCode && couponCode.length > 0) {
                gaEv['eventLabel'] = couponCode;
            }
            CCRZ.ga.sendEvent(_.extend({'source': CCRZ.pagevars.currentPageName}, CCRZ.pagevars), gaEv, cb);
        };

        CCRZ.ga.handleSubmitOrder = CCRZ.ga.handleSubmitOrder || function(cartData, cb) {
            var gaEv = {
                'transport': 'beacon'
                , 'eventCategory': 'Checkout'
                , 'eventAction' : 'Submitted an Order'
            };
            var cartId = cartData['cartId'];
            if (cartId && cartId.length > 0) {
                gaEv['eventLabel'] = cartId;
            }
            CCRZ.ga.sendEvent(_.extend({'source': CCRZ.pagevars.currentPageName}, CCRZ.pagevars), gaEv, cb);
        };

        CCRZ.ga.handlePageMessage = CCRZ.ga.handlePageMessage || function(msgData, cb) {
            if(!jQuery.isEmptyObject(msgData) && !jQuery.isEmptyObject(msgData['messages'])) {
                var exMessages = _.filter(msgData['messages'], function(msg) {
                    return (msg['severity']=='ERROR' || msg['severity']=='CRITICAL')
                });
                if (exMessages.length > 0) {
                    _.each(exMessages, function(msg) {
                        var exDesc = msg.message;
                        if (msg['labelId'] && CCRZ.pagevars.pageLabels[msg['labelId']]) {
                            exDesc = CCRZ.pagevars.pageLabels[msg.labelId];
                        }
                        CCRZ.ga.sendException(CCRZ.pagevars, {
                            'exDescription': exDesc
                            , 'exFatal': (msg['severity']=='CRITICAL' || msg['severity']=='FATAL')
                        }, cb);
                    });
                }
            }
        }
        CCRZ.pubSub.on('pageMessage', CCRZ.ga.handlePageMessage, this);

        // productlist and search
        CCRZ.ga.handleSearch2 = CCRZ.ga.handleSearch2 || function(plpData, cb) {
            var gaEv = {
                'eventCategory': 'Discovery'
                , 'eventAction': 'Category'
            };
            if (plpData && plpData.attributes) {
                gaEv['eventValue'] = 0;
                if (jQuery.isNumeric(plpData.attributes['prodCount'])) {
                    gaEv['eventValue'] = plpData.attributes['prodCount'];
                }
                if (plpData.attributes['searchString']) {
                    gaEv['eventLabel'] = plpData.attributes['searchString'];
                    gaEv['eventCategory'] = 'Search';
                    if (gaEv['eventValue'] > 0) {
                        gaEv['eventAction'] = 'Search with Results';
                    } else {
                        gaEv['eventAction'] = "Search with No Results";
                    }
                    CCRZ.ga.sendEvent(_.extend({'source': (('Search'===gaEv['eventAction'])?'Search':'')}, CCRZ.pagevars), gaEv, cb);
                }
            }
        }
        CCRZ.pubSub.on('model:collectionsProductList:fetch', CCRZ.ga.handleSearch2);

        // promotion display
        CCRZ.ga.handlePromotions = CCRZ.ga.handlePromotions || function(cb) {
            // promo download and promo link
            jQuery('a.promo_dwnld, a.promo_ext, a.splashPromoLink').click(function (e) {
                e.stopPropagation();
                e.preventDefault();
                var promoId = jQuery(this).attr('data-promo');
                var promoHref = jQuery(this).attr('href');
                var promoTarget = jQuery(this).attr('target');
                if (promoId && promoHref) {
                    CCRZ.ga.sendEvent(_.extend({'source': 'Promotion'}, CCRZ.pagevars), {
                        'transport': 'beacon'
                        , 'eventCategory': 'Discovery'
                        , 'eventAction': 'Viewed a Promotion'
                        , 'eventLabel': promoId
                    }, function() {
                        if (typeof cb === 'function') {
                            cb();
                        }
                    });
                } else {
                    if (typeof cb === 'function') {
                        cb();
                    }
                }
                if (promoTarget === '_blank') {
                    window.open(promoHref);
                } else {
                    window.location = promoHref;
                }
                return true;
            });
        }
        CCRZ.pubSub.on('view:PromoDisp:rendered', CCRZ.ga.handlePromotions);
    }
});

