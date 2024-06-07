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
				timeout : 30000
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
