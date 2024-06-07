
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
