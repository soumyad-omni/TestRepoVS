({
    initCmp : function(component, event) {
        console.log(Math.pow(2, 6));
        component.set('v.dealModelWrapper',null);
        component.set("v.spinner",true);
        var action = component.get("c.getQuote");
        action.setStorable();
        action.setParams({ quoteId : component.get("v.recordId"),calc_gsa:'X',calc_margin:'X',calc_disc:''});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var dealModelWrapper = response.getReturnValue();
                console.log('====dealModelWrapper===',dealModelWrapper);
                if(!dealModelWrapper.isError){
                    component.set('v.dealModelWrapper',dealModelWrapper);
                    component.set('v.reset', true);
                }else{
                    this.showToast(dealModelWrapper.errMsg, 'Error Message', 'error');
                }
                this.refreshToggleSection(component, event);
                component.set('v.disableCalculateButton',false);
            }
            else {
                var errors = response.getError();
                //console.log('error : '+response.getError()+' '+errors[0].Message);
                this.showToast(errors[0], 'Error Message', 'error');
            }
            component.set('v.spinner',false);//Hiding loader
        });
        $A.enqueueAction(action);
    },
    calculateDiscount : function(component, event){
        component.set('v.reset', true);
        component.set('v.disableSave',false);
        component.set('v.disablePDF',false);
        component.set('v.disableCalculateButton',true);
        var dealModelW = component.get('v.dealModelWrapper');
        var sapDiscount = parseFloat(dealModelW.data.ES_MARGIN_HDR.DISCOUNT_EXT); //Already applied discount (SAP Discount)
        var bookingPrice = parseFloat(dealModelW.data.ES_MARGIN_HDR.BOOKING_EXT) + parseFloat(dealModelW.data.ES_MARGIN_HDR.DISCOUNT_EXT); //Actual booking price --> Booking price + SAP Discount
        //IBA-1476 START     
        var professionalServicesValue = dealModelW.professionalServicesValue;
        var discountablePartTotal =  dealModelW.discountable;
        var residentOperatorValue = dealModelW.residentOperatorValue;
        var residentOperatorDuration = dealModelW.residentOperatorDuration;
        //IBA-1476 END
        //IBA-1573 START
        var isQuoteOmnicellServiceOrderType = dealModelW.isQuoteOmnicellServiceOrderType;
        var earlyAdopterFlag = dealModelW.earlyAdopterFlag;
        //IBA-1573 END
        var cost = parseFloat(dealModelW.totalProductCost); //Total Product Cost
        console.log('cost : '+cost);
        var gsaNetPrice = parseFloat(dealModelW.gsaNetPrice);// GSA Net Price
        var discOnDiscountableOnly = parseFloat(dealModelW.data.ZCRMFM_MARGIN_OVERCAST.DISC_ON_DISC_ONLY); // Disc on Discountable Only (DISC ON DISC ONLY)
        var totalDiscountableBookings = parseFloat(dealModelW.data.ZCRMFM_MARGIN_OVERCAST.DISC_ON_DISC_ONLY)+ parseFloat(dealModelW.data.ZCRMFM_MARGIN_OVERCAST.DISCOUNTABLE_ONLY); //Disc on Disc only + Discountable Bookings
        var discOnNonDiscountableOnly = parseFloat(dealModelW.data.ZCRMFM_MARGIN_OVERCAST.DISC_ON_NON_DISC); // Disc on Non Discountable Only (DISC ON NON DISC)
        var commissionValue = parseFloat(dealModelW.data.ES_MARGIN_HDR.COMMISSION_EXT);// Commission Value
        var orderNetPrice = parseFloat(dealModelW.data.ES_GSA_CALC.ORDER_PRICE); //Order Net Price (Order Price)
        var leaseTerm = parseFloat(dealModelW.data.ES_MARGIN_HDR.LEASE_TERM); //Lease Term
        var freeLeaseTerm = parseFloat(dealModelW.data.ES_MARGIN_HDR.FREE_LEASE); //free lease term
        var subscriptionTerm = parseFloat(dealModelW.subscriptionTerm); //subscriptionTerm added by Jay CR-18666
        var divisor = (leaseTerm - freeLeaseTerm) <= 0 ?  1 : (leaseTerm - freeLeaseTerm);
        if(dealModelW.isQuoteOmnicellServiceOrderType)
        {
            divisor = (subscriptionTerm - freeLeaseTerm) <= 0 ?  1 : (subscriptionTerm - freeLeaseTerm);
            totalDiscountableBookings = parseFloat(dealModelW.data.ZCRMFM_MARGIN_OVERCAST.DISC_ON_DISC_ONLY) + parseFloat(dealModelW.data.ES_MARGIN_HDR.DISCOUNT_BASE); //soumyad sf-bug-1018
        }
        var customerValuePrice = parseFloat(dealModelW.data.ES_MARGIN_HDR.VAL_CUST_EXT);//Customer Value Price (val cust ext)
        var newDiscountPercentage = dealModelW.discountPercentage != null ? parseFloat(dealModelW.discountPercentage) : 0; //New discount % = discount % entered in the calculation box
        var oldDiscountPercentage = parseFloat(dealModelW.oldDiscountPercentage); // old discount percentage
        var newDiscountAmt = dealModelW.discountAmount != null ? parseFloat(dealModelW.discountAmount) : 0; //New Discount Amount [The discount provided on the screen]
        console.log('t.......' +newDiscountAmt);
        var oldDiscountAmt = parseFloat(dealModelW.oldDiscountAmount); // Old Discount Amount -- SAP Discount
        var oldAdditionalDiscount = dealModelW.oldAdditionalDiscount; // Old Additioanl Discount 
        var additionalDiscount = dealModelW.additionalDiscount; // additional discount
        var usaListPrice = parseFloat(dealModelW.data.ES_MARGIN_HDR.USA_LPRICE_EXT);
        var contractListPrice = parseFloat(dealModelW.data.ES_MARGIN_HDR.CONT_LPRICE_EXT);
        var USAListPricePercentage = 0.00;
        var ContractListPricePercentage = 0.00;
        var basediscount = parseFloat(dealModelW.data.ES_MARGIN_HDR.DISCOUNT_BASE); 
        //BUG 1018 Declaration for Basdiscount Changes by PadmadealModelW.data.ES_MARGIN_HDR.DISCOUNT_BASE;
        if(oldAdditionalDiscount != additionalDiscount || newDiscountAmt != oldDiscountAmt || newDiscountPercentage != oldDiscountPercentage){
            console.log('=====newDiscountAmt======',newDiscountAmt);
            dealModelW.oldDiscountAmount = newDiscountAmt;
            dealModelW.oldDiscountPercentage = newDiscountPercentage;
            dealModelW.oldAdditionalDiscount = additionalDiscount;
        }else{
            return;
        }
        if(dealModelW.isQuoteOmnicellServiceOrderType){
            var convertedNewDiscount = (newDiscountPercentage/100)*basediscount; 
            //Bug1018 for as-a-service Quotes should use Basediscount changes byPadma
        }   
        else{
            var convertedNewDiscount = (newDiscountPercentage/100)*totalDiscountableBookings; 
        } 
        //===================If additional discount is checked, Apply discount on top of the given discount.========================
        if(additionalDiscount){
            console.log('====convertedNewDiscount====',convertedNewDiscount);
            console.log('====totalNewDiscount====',totalNewDiscount);
            console.log('====contractListPrice====',contractListPrice);
            console.log('====customerValuePrice====',customerValuePrice);
            console.log('====usaListPrice====',usaListPrice);
            console.log('====USAListPricePercentage====',USAListPricePercentage);
            var totalNewDiscount = (newDiscountAmt + convertedNewDiscount + sapDiscount );//New Dis + Old Disc
            var customerPrice = customerValuePrice - (newDiscountAmt + convertedNewDiscount);
            console.log('totalNewDiscount : '+totalNewDiscount);
            if(customerPrice < 0){
                this.showToast('Customer price should not be less than zero :'+customerPrice, 'Error!', 'error');
                return;
            }
            
            
            dealModelW.discount = totalNewDiscount;
            var newBookingPrice = bookingPrice - totalNewDiscount;
            console.log('newBookingPrice : '+newBookingPrice);
            dealModelW.customerValuePrice = customerPrice;
            dealModelW.bookingPrice = newBookingPrice;
            dealModelW.totalMargin = newBookingPrice - cost;
            dealModelW.marginProduct = ((newBookingPrice - cost)/newBookingPrice)*100;
            dealModelW.commissionValue = commissionValue -(newDiscountAmt + convertedNewDiscount);
            dealModelW.orderNetPrice = customerPrice / divisor; //OrderNet Price = Customer price / divisor
            dealModelW.gsaPrice = dealModelW.orderNetPrice - gsaNetPrice;
            dealModelW.discountable = dealModelW.discountable - (newDiscountAmt + convertedNewDiscount); //Discountable Bookings
            dealModelW.basediscount = dealModelW.basediscount - (newDiscountAmt + convertedNewDiscount); // soumyad SF-bug-1018
            //dealModelW.USAListPricePercentage = (totalNewDiscount/usaListPrice)*100; //Commented by Rajat to fix SF-BUG-298
            dealModelW.USAListPricePercentage = (1-(customerPrice/usaListPrice))*100;  //Added by Rajat to fix SF-BUG-298
            dealModelW.ContractListPricePercentage = (totalNewDiscount/contractListPrice)*100;
            
        }else { 
            
            //==================================if additional is not checked, Apply fresh discount===============================
            
            var totalNewDiscount = newDiscountAmt + convertedNewDiscount;
            var customerPrice = customerValuePrice + sapDiscount - totalNewDiscount;
            if(customerPrice < 0){
                this.showToast('Customer price should not be less than zero :'+customerPrice, 'Error!', 'error');
                return;
            }
            var newBookingPrice = bookingPrice - totalNewDiscount;
            dealModelW.customerValuePrice = customerPrice;
            dealModelW.bookingPrice = newBookingPrice;
            dealModelW.discount = totalNewDiscount;
            dealModelW.totalMargin = newBookingPrice - cost;
            dealModelW.marginProduct = newBookingPrice != 0 ? ((newBookingPrice - cost)/newBookingPrice)*100 : 0;
            dealModelW.commissionValue = commissionValue + sapDiscount - totalNewDiscount;
            dealModelW.orderNetPrice = customerPrice/ divisor; //Order Net Price = Customer Price - Divisor
            dealModelW.gsaPrice = dealModelW.orderNetPrice - gsaNetPrice;
            var discOnNonDiscountableOnly = parseFloat(dealModelW.data.ZCRMFM_MARGIN_OVERCAST.DISC_ON_NON_DISC);
            dealModelW.nonDiscountablePrice = parseFloat(dealModelW.nonDiscountablePrice) + discOnNonDiscountableOnly;
            var discOnDiscountableOnly = parseFloat(dealModelW.data.ZCRMFM_MARGIN_OVERCAST.DISC_ON_DISC_ONLY);
            dealModelW.discountable = dealModelW.discountable + discOnDiscountableOnly - totalNewDiscount;
            dealModelW.basediscount = dealModelW.basediscount + discOnDiscountableOnly - totalNewDiscount; // soumyad SF-bug-1018
            dealModelW.USAListPricePercentage = (totalNewDiscount/usaListPrice)*100;
            dealModelW.ContractListPricePercentage = (totalNewDiscount/contractListPrice)*100;
            
        }
        //IBA-1476 fix START
        //dealModelW.monthly = dealModelW.orderNetPrice-(dealModelW.professionalServicesValue/divisor); //soumyad sf-bug-1018   
        var remaningTotalBooking = 0;
        var totalDiscount = 0;
        if(newDiscountAmt > 0  && newDiscountPercentage <= 0) {
            remaningTotalBooking = bookingPrice - (professionalServicesValue + (residentOperatorValue * residentOperatorDuration ));
            totalDiscount = newDiscountAmt;
            dealModelW.monthly = (remaningTotalBooking - totalDiscount)/subscriptionTerm;
            //IBA-1573 fix
            if(isQuoteOmnicellServiceOrderType === true && earlyAdopterFlag === true) {
              dealModelW.monthly = dealModelW.monthly +  residentOperatorValue;
            }
        }
        if(newDiscountPercentage > 0  && newDiscountAmt <= 0) {
            remaningTotalBooking = bookingPrice - (professionalServicesValue + (residentOperatorValue * residentOperatorDuration ));
            totalDiscount = (discountablePartTotal*newDiscountPercentage)/100;
            dealModelW.monthly = (remaningTotalBooking - totalDiscount)/subscriptionTerm;
            //IBA-1573 fix
            if(isQuoteOmnicellServiceOrderType === true && earlyAdopterFlag === true) {
              dealModelW.monthly = dealModelW.monthly +  residentOperatorValue;
            }
        }
        //IBA-1476 fix END
        dealModelW.result = dealModelW.gsaPrice > 0 ? 'GSA Test Passed.' : 'GSA Test Failed.';
        component.set('v.dealModelWrapper',dealModelW);
        // component.set('v.reset', false);
    },
    reset : function(component, event){
        component.set('v.reset', true);
        var dealModelW = component.get('v.dealModelWrapper');
        component.set('v.disablePDF',true);
        component.set('v.disableCalculateButton',false);
        dealModelW.usaListPrice = dealModelW.data.ES_MARGIN_HDR.USA_LPRICE_EXT;
        dealModelW.nonDiscountablePrice = dealModelW.data.ZCRMFM_MARGIN_OVERCAST.NON_DISCOUNTABLE;
        dealModelW.totalMaterial = dealModelW.data.ES_MARGIN_HDR.COST_EXT;
        dealModelW.contractListPrice = dealModelW.data.ES_MARGIN_HDR.CONT_LPRICE_EXT;
        dealModelW.discountable = dealModelW.data.ZCRMFM_MARGIN_OVERCAST.DISCOUNTABLE_ONLY;
        dealModelW.totalLabor = dealModelW.data.ES_MARGIN_HDR.LABOR_EXT;
        dealModelW.discount = dealModelW.data.ES_MARGIN_HDR.DISCOUNT_EXT;
        dealModelW.bookingPrice = dealModelW.data.ES_MARGIN_HDR.BOOKING_EXT;
        dealModelW.totalOverhead = dealModelW.data.ES_MARGIN_HDR.OVERHEAD_EXT;
        dealModelW.customerValuePrice = dealModelW.data.ES_MARGIN_HDR.VAL_CUST_EXT;
        dealModelW.totalMargin = dealModelW.data.ES_MARGIN_HDR.MARGIN_EXT;
        dealModelW.totalProductCost = dealModelW.data.ES_MARGIN_HDR.COST_EXT + dealModelW.data.ES_MARGIN_HDR.LABOR_EXT + dealModelW.data.ES_MARGIN_HDR.OVERHEAD_EXT;
        dealModelW.commissionValue = dealModelW.data.ES_MARGIN_HDR.COMMISSION_EXT;
        dealModelW.marginProduct = dealModelW.data.ES_MARGIN_HDR.MARGIN_PRODUCT;
        dealModelW.orderNetPrice = dealModelW.data.ES_GSA_CALC.ORDER_PRICE;
        dealModelW.gsaNetPrice = dealModelW.data.ES_GSA_CALC.GSA_PRICE;
        dealModelW.gsaPrice = dealModelW.data.ES_GSA_CALC.DIFF_PRICE;
        dealModelW.result = dealModelW.data.ES_GSA_CALC.RESULT;
        dealModelW.USAListPricePercentage = (dealModelW.data.ES_MARGIN_HDR.DISCOUNT_EXT/dealModelW.data.ES_MARGIN_HDR.USA_LPRICE_EXT) * 100; //USA List Price Percentage
        dealModelW.ContractListPricePercentage = (dealModelW.data.ES_MARGIN_HDR.DISCOUNT_EXT/dealModelW.data.ES_MARGIN_HDR.CONT_LPRICE_EXT) * 100; //Contract List Price Percentage.
        dealModelW.additionalDiscount = true;
        dealModelW.oldAdditionalDiscount = true;
        dealModelW.discountAmount = 0.00;
        dealModelW.oldDiscountAmount = 0.00;
        dealModelW.discountPercentage = 0.00;
        dealModelW.oldDiscountPercentage = 0.00;
        dealModelW.basediscount = dealModelW.data.ES_MARGIN_HDR.DISCOUNT_BASE; //soumyad sf-bug-1018
        dealModelW.monthly = dealModelW.data.ZCRMFM_MARGIN_OVERCAST.EV_MONTHLY_CHARGE; //soumyad sf-bug-1018
        component.set('v.dealModelWrapper',dealModelW);
    },
    
    savePDF : function(component, event){
        var recordId = component.get('v.pdfRecordId');
        var dealModelW = component.get('v.dealModelWrapper');
        if (dealModelW.isQuoteOmnicellServiceOrderType)
        {
            window.open('/apex/DealModelingXRPdf?id='+recordId,'_blank');
        }
        else
        {
            window.open('/apex/DealModelingPdf?id='+recordId,'_blank');
        }
        
    },
    save : function(component, event, isPDF){
        component.set('v.disablePDF',true);
        component.set("v.spinner",true);
        var dealModelW = component.get('v.dealModelWrapper');
        console.log(JSON.stringify(dealModelW));
        var action = component.get("c.saveCalculation");
        action.setStorable();
        action.setParams({dealModelW:JSON.stringify(dealModelW), quoteId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.disablePDF',false);
                component.set('v.pdfRecordId',response.getReturnValue());
                this.savePDF(component, event);
                //this.showToast('Record created successfully!', 'Success!', 'success');
            }
            else {
                var errors = response.getError();
                this.showToast(errors[0], 'Error Message', 'error');
            }
            component.set('v.spinner',false);//Hiding loader
        });
        $A.enqueueAction(action);
    },
    toggleSection : function(component, event){
        var sectionId = event.getSource().get("v.id");
        var iconId1 = sectionId + '-icon-1';
        var iconId2 = sectionId + '-icon-2';
        $A.util.toggleClass(component.find(sectionId), 'slds-is-open');
        $A.util.toggleClass(component.find(iconId1), 'slds-hide');
        $A.util.toggleClass(component.find(iconId2), 'slds-hide');
    },
    refreshToggleSection : function(component, event){
        this.refreshToggle(component, event, 'section-1');
        this.refreshToggle(component, event, 'section-2');
        this.refreshToggle(component, event, 'section-3');
        this.refreshToggle(component, event, 'section-4');
        this.refreshToggle(component, event, 'section-5');
    },
    refreshToggle: function(component, event, sectionId){
        var icon1 = sectionId+'-icon-1';
        var icon2 = sectionId+'-icon-2';
        if($A.util.hasClass(component.find(sectionId), "slds-is-open") 
           && !$A.util.hasClass(component.find(icon1), "slds-hide")){
            $A.util.toggleClass(component.find(icon1), 'slds-hide');
            $A.util.toggleClass(component.find(icon2), 'slds-hide');
        } else if(!$A.util.hasClass(component.find(sectionId), "slds-is-open")
                  && $A.util.hasClass(component.find(icon1), "slds-hide")){
            $A.util.toggleClass(component.find(icon1), 'slds-hide');
            $A.util.toggleClass(component.find(icon2), 'slds-hide');
        }
    },
    isNumberKey : function(component, event){
        var inputId = event.getSource().get("v.id");
        var inputValue = event.getSource().get("v.value");
        var ex = /^[0-9]+\.?[0-9]*$/;
        if(inputValue != null && ex.test(inputValue) == false){
            inputValue = inputValue.substring(0,inputValue.length - 1);
        }
        if(inputId === 'disPerId'){
            if(parseInt(inputValue) > 100){
                inputValue = inputValue.substring(0,inputValue.length - 1);
            }
            component.set('v.dealModelWrapper.discountPercentage',inputValue == 0 ? null : inputValue);
        }else {
            component.set('v.dealModelWrapper.discountAmount',inputValue == 0 ? null : inputValue);
        }
    },
    onKeyUp: function(component, event){
        var inputId = event.getSource().get("v.id");
        var inputValue = event.getSource().get("v.value");
        var ex = /^[0-9]+\.?[0-9]*$/;
        if(inputValue != null && ex.test(inputValue) == false){
            inputValue = inputValue.substring(0,inputValue.length - 1);
        }
        if(inputId === 'disPerId'){
            if(parseInt(inputValue) > 100){
                inputValue = inputValue.substring(0,inputValue.length - 1);
            }
            component.set('v.dealModelWrapper.discountPercentage',inputValue);
        }else {
            component.set('v.dealModelWrapper.discountAmount', inputValue);
        }
    },
    showToast : function(errorMsg, title, toastType) {
        
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams({
                title : title,
                message: errorMsg,
                type: toastType
            });
            toastEvent.fire();
        }else{
            alert(errorMsg);
        }
    },
})