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
