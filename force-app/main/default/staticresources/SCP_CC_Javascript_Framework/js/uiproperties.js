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
