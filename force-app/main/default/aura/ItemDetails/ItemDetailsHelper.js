({
    doInit : function(component, event) {
        
        var dealModelWrapper = component.get('v.dealModelWrapper');
        var setProductId = new Set();
        var margindetailMap = new Map();
        var reset = component.get("v.reset");
        if(dealModelWrapper && dealModelWrapper != null && dealModelWrapper.data != null && dealModelWrapper.data.ET_MARGIN_DETAILS != null){
            var products = dealModelWrapper.data.ET_MARGIN_DETAILS;
            for(var i = 0; i < products.length; i++){
                if(dealModelWrapper.data.ET_MARGIN_DETAILS[i].PRODUCT_CATEGORY === 'MAT-DIEN' || dealModelWrapper.data.ET_MARGIN_DETAILS[i].PRODUCT_CATEGORY === 'MAT-ZDIN') continue;
                
                if(reset || products[i].NON_DISCOUNTABLE === "X" || products[i].NON_DISCOUNTABLE === "x" ){
                    //Values upon screen launch
                    products[i].NEW_MARGIN_PERC = products[i].MARGIN_PERC; //Margin Percentage upon launch
                    console.log('=======Margin upon launch=========',products[i].NEW_MARGIN_PERC);
                    products[i].NEW_DISCOUNT = products[i].DISCOUNT; //Discount upon launch
                    products[i].NEW_BOOK_VAL_OMNICELL = products[i].BOOK_VAL_OMNICELL; //Book value omnicell upon launch
                    //products[i].NEW_BILL_VAL_CUST = products[i].BILL_VAL_CUST; // bill value customer upon launch
                    products[i].NEW_USA_LIST_PERCENT = products[i].DISCOUNT && products[i].USA_LIST_PRICE ? parseFloat(products[i].DISCOUNT) *100 / parseFloat(products[i].USA_LIST_PRICE) : 0.00;
                    products[i].NEW_CONTRACT_LIST_PERCENT = products[i].DISCOUNT && products[i].CONTRACT_LIST_PRICE ? parseFloat(products[i].DISCOUNT) *100 / parseFloat(products[i].CONTRACT_LIST_PRICE) :0.00;
                }else{
                    
                    ///Dicount calculation... started..
                    
                    var totalDiscountableBookings = parseFloat(dealModelWrapper.data.ZCRMFM_MARGIN_OVERCAST.DISC_ON_DISC_ONLY)+ parseFloat(dealModelWrapper.data.ZCRMFM_MARGIN_OVERCAST.DISCOUNTABLE_ONLY);
                    var discountable = dealModelWrapper.discountable; //Discountable bookings after discount is calculated.
                    var actualBookingPrice = parseFloat(products[i].BOOK_VAL_OMNICELL) + parseFloat(products[i].DISCOUNT);//actual booking amount. Book val + Discount
                    var discountItem = parseFloat(products[i].DISCOUNT); //Item level SAP Discount
                    var bookingPriceItem = parseFloat(products[i].BOOK_VAL_OMNICELL);
                    var itemCost = parseFloat(products[i].COST_TO_OMNICELL);
                    var newDiscountAmt = dealModelWrapper.discountAmount != null ? parseFloat(dealModelWrapper.discountAmount) : 0; //Discount Amount we enter
                    var newDiscountPercentage = dealModelWrapper.discountPercentage != null ? parseFloat(dealModelWrapper.discountPercentage) : 0; //Discount percentage we enter
                    var convertedNewDiscount = (newDiscountPercentage/100)*totalDiscountableBookings; //Percentage converted to amount
                    var totalNewDiscountAmount = newDiscountAmt + convertedNewDiscount; //Discount which we give
                    var newDiscount = 0.0;
                    var newBookValOmnicell = 0.0;
                    
                    if(dealModelWrapper.additionalDiscount){
                        
                        //================If Additional Discount is Checked==============================
                        
                        newDiscount = ((discountItem + totalNewDiscountAmount)*actualBookingPrice)/discountable; //Calculate Discount
                        console.log('======Additional-newDiscount1=====',newDiscount);
                        
                        newBookValOmnicell = actualBookingPrice - newDiscount;  //Calculate Booking Price
                        console.log('=======Additional- newBookValOmnicell1======',newBookValOmnicell);
                        
                    }else { 
                        
                        //================If Additional Discount is Not Checked==============================
                        
                        newDiscount = (totalNewDiscountAmount*actualBookingPrice)/discountable;
                        console.log('======No Add-newDiscount1=====',newDiscount);
                        
                        newBookValOmnicell =  actualBookingPrice - newDiscount;
                        console.log('=======No Add- newBookValOmnicell1======',newBookValOmnicell);
                    }
                    products[i].NEW_MARGIN_PERC = newBookValOmnicell != 0 ? ((newBookValOmnicell - itemCost)/newBookValOmnicell)*100 : 0;
                    products[i].NEW_DISCOUNT = newDiscount;
                    products[i].NEW_BOOK_VAL_OMNICELL = newBookValOmnicell;   
                    products[i].NEW_USA_LIST_PERCENT = newDiscount *100 / parseFloat(products[i].USA_LIST_PRICE);
                    products[i].NEW_CONTRACT_LIST_PERCENT = newDiscount *100 / parseFloat(products[i].CONTRACT_LIST_PRICE);
                    console.log('=====NEW_MARGIN_PERC=============',products[i].NEW_MARGIN_PERC);
                    console.log('=====NEW_DISCOUNT=============',products[i].NEW_DISCOUNT);
                    console.log('=====NEW_BOOK_VAL_OMNICELL=============',products[i].NEW_BOOK_VAL_OMNICELL);
                    console.log('=====NEW_USA_LIST_PERCENT=============',products[i].NEW_USA_LIST_PERCENT);
                    console.log('=====NEW_CONTRACT_LIST_PERCENT=============',products[i].NEW_CONTRACT_LIST_PERCENT);
                }
                var productId = products[i].PRODUCT_ID;
                if(!margindetailMap.has(productId)) margindetailMap.set(productId, []);
                margindetailMap.get(productId).push(products[i]);
                setProductId.add(productId);
            }
        }
        
        var action = component.get("c.getProducts");
        action.setStorable();
        action.setParams({setProductId : Array.from(setProductId)});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var lstProduct2 = response.getReturnValue();
                var productMap = new Map();
                for(var i=0; i<lstProduct2.length; i++){
                    if(!productMap.has(lstProduct2[i].DW_Product_Line__c)) productMap.set(lstProduct2[i].DW_Product_Line__c, []);
                    productMap.get(lstProduct2[i].DW_Product_Line__c).push(lstProduct2[i].External_ID__c);
                }
                var lstItemDetails = [];
                setProductId = new Set();
                for(const dwProductLine of productMap.keys()) {
                    console.log('===dwProductLine===',dwProductLine);
                    var lstProductNew = [];
                    for(const productID of productMap.get(dwProductLine)){
                        if(dwProductLine === 'FREIGHT' || dwProductLine === 'Shared' || dwProductLine == 'Other') continue;
                        if(margindetailMap.has(productID)){
                            setProductId.add(productID);
                            var products = margindetailMap.get(productID);
                            for(var i=0 ; i<products.length;i++){
                                lstProductNew.push(products[i]);
                            }	
                        }
                    }
                    console.log('===dwProductLine===',dwProductLine);
                    if(lstProductNew.length > 0) lstItemDetails.push({ title : dwProductLine, lstProduct :lstProductNew});
                }
                var lstProductNew = [];
                for(var i = 0; i < dealModelWrapper.data.ET_MARGIN_DETAILS.length; i++){
                    if(dealModelWrapper.data.ET_MARGIN_DETAILS[i].PRODUCT_CATEGORY === 'MAT-DIEN' || dealModelWrapper.data.ET_MARGIN_DETAILS[i].PRODUCT_CATEGORY === 'MAT-ZDIN') continue;
                    var productId = dealModelWrapper.data.ET_MARGIN_DETAILS[i].PRODUCT_ID;
                    if(setProductId.has(productId)) continue;
                    lstProductNew.push(dealModelWrapper.data.ET_MARGIN_DETAILS[i]);
                }
                if(lstProductNew.length > 0){
                    lstItemDetails.push({ title : 'Other', lstProduct :lstProductNew});
                }
                
                component.set('v.lstItemDetails', lstItemDetails);
                //Added by Sravan for SF-BUG-590 START
                var details = [];
                for(var item = 0; item < lstItemDetails.length; item++){
                    var totamount = 0;
                    var discamount = 0;
                    var nondiscamount = 0;
                    var listprdcts = lstItemDetails[item].lstProduct;
                    for(var ii=0;ii < listprdcts.length;ii++){
                        if(listprdcts[ii].NON_DISCOUNTABLE === 'X')
                            nondiscamount = nondiscamount+listprdcts[ii].NEW_BOOK_VAL_OMNICELL;
                        else
                            discamount = discamount+listprdcts[ii].NEW_BOOK_VAL_OMNICELL;
                        totamount = totamount+listprdcts[ii].NEW_BOOK_VAL_OMNICELL;
                    }
                    details.push({name : lstItemDetails[item].title, totalamount : totamount,discamount : discamount,nondiscamount : nondiscamount,discperc :0,discnum :0,net : totamount });
                    console.log(details[item].name+' '+details[item].price);
                }
                component.set('v.Details', details);
                //Added by Sravan for SF-BUG-590 END
            }
            else {
                console.log('====response====',response);   
            }
        });
        $A.enqueueAction(action);
    },
     //Added calculateTotalDiscount by Sravan for SF-BUG-590 START
    calculateTotalDiscount : function(component, helper){
        var ordertype = component.get("v.ordertype");
        console.log("order type 2 : "+ordertype);
        var dealModelW = component.get('v.dealModelWrapper');
        var sapDiscount = parseFloat(dealModelW.data.ES_MARGIN_HDR.DISCOUNT_EXT); //Already applied discount (SAP Discount)
        var bookingPrice = parseFloat(dealModelW.data.ES_MARGIN_HDR.BOOKING_EXT) + parseFloat(dealModelW.data.ES_MARGIN_HDR.DISCOUNT_EXT); //Actual booking price --> Booking price + SAP Discount
        console.log("Sap : "+sapDiscount + 'bookingPrice : '+bookingPrice);
        var cost = parseFloat(dealModelW.totalProductCost); //Total Product Cost
        var gsaNetPrice = parseFloat(dealModelW.gsaNetPrice);// GSA Net Price
        var discOnDiscountableOnly = parseFloat(dealModelW.data.ZCRMFM_MARGIN_OVERCAST.DISC_ON_DISC_ONLY); // Disc on Discountable Only (DISC ON DISC ONLY)
        var totalDiscountableBookings = parseFloat(dealModelW.data.ZCRMFM_MARGIN_OVERCAST.DISC_ON_DISC_ONLY)+ parseFloat(dealModelW.data.ZCRMFM_MARGIN_OVERCAST.DISCOUNTABLE_ONLY); //Disc on Disc only + Discountable Bookings
        var discOnNonDiscountableOnly = parseFloat(dealModelW.data.ZCRMFM_MARGIN_OVERCAST.DISC_ON_NON_DISC); // Disc on Non Discountable Only (DISC ON NON DISC)
        var commissionValue = parseFloat(dealModelW.data.ES_MARGIN_HDR.COMMISSION_EXT);// Commission Value
        var orderNetPrice = parseFloat(dealModelW.data.ES_GSA_CALC.ORDER_PRICE); //Order Net Price (Order Price)
        var leaseTerm = parseFloat(dealModelW.data.ES_MARGIN_HDR.LEASE_TERM); //Lease Term
        var freeLeaseTerm = parseFloat(dealModelW.data.ES_MARGIN_HDR.FREE_LEASE); //free lease term
        var divisor = (leaseTerm - freeLeaseTerm) <= 0 ?  1 : (leaseTerm - freeLeaseTerm);
        var customerValuePrice = parseFloat(dealModelW.data.ES_MARGIN_HDR.VAL_CUST_EXT);//Customer Value Price (val cust ext)
        var newDiscountPercentage = dealModelW.discountPercentage != null ? parseFloat(dealModelW.discountPercentage) : 0; //New discount % = discount % entered in the calculation box
        var oldDiscountPercentage = parseFloat(dealModelW.oldDiscountPercentage); // old discount percentage
        var newDiscountAmt = dealModelW.discountAmount != null ? parseFloat(dealModelW.discountAmount) : 0; //New Discount Amount [The discount provided on the screen]
        var oldDiscountAmt = parseFloat(dealModelW.oldDiscountAmount); // Old Discount Amount -- SAP Discount
        var oldAdditionalDiscount = dealModelW.oldAdditionalDiscount; // Old Additioanl Discount 
        var additionalDiscount = dealModelW.additionalDiscount; // additional discount
        var usaListPrice = parseFloat(dealModelW.data.ES_MARGIN_HDR.USA_LPRICE_EXT);
        var contractListPrice = parseFloat(dealModelW.data.ES_MARGIN_HDR.CONT_LPRICE_EXT);
        var USAListPricePercentage = 0.00;
        var ContractListPricePercentage = 0.00;
        
        if(oldAdditionalDiscount != additionalDiscount || newDiscountAmt != oldDiscountAmt || newDiscountPercentage != oldDiscountPercentage){
            console.log('=====newDiscountAmt======',newDiscountAmt);
            dealModelW.oldDiscountAmount = newDiscountAmt;
            dealModelW.oldDiscountPercentage = newDiscountPercentage;
            dealModelW.oldAdditionalDiscount = additionalDiscount;
        }else{
            return;
        }
        
        var convertedNewDiscount = (newDiscountPercentage/100)*totalDiscountableBookings; 
        
        //===================If additional discount is checked, Apply discount on top of the given discount.========================
        if(additionalDiscount){
            var totalNewDiscount = (newDiscountAmt + convertedNewDiscount + sapDiscount );//New Dis + Old Disc
            var customerPrice = customerValuePrice - (newDiscountAmt + convertedNewDiscount);
            
            if(customerPrice < 0){
                this.showToast('Customer price should not be less than zero :'+customerPrice, 'Error!', 'error');
                return;
            }
            console.log('====convertedNewDiscount====',convertedNewDiscount);
            console.log('====totalNewDiscount====',totalNewDiscount);
            console.log('====contractListPrice====',contractListPrice);
            console.log('====customerValuePrice====',customerValuePrice);
            console.log('====usaListPrice====',usaListPrice);
            console.log('====USAListPricePercentage====',USAListPricePercentage);
            //Added by sravan
            var discOnNonDiscountableOnly = parseFloat(dealModelW.data.ZCRMFM_MARGIN_OVERCAST.DISC_ON_NON_DISC);
            dealModelW.nonDiscountablePrice = parseFloat(dealModelW.nonDiscountablePrice) + discOnNonDiscountableOnly;
            //Adde by sravan
            
            dealModelW.discount = totalNewDiscount;
            dealModelW.orderNetPrice = customerPrice / divisor; //OrderNet Price = Customer price / divisor
            var discamt = (dealModelW.orderNetPrice.toFixed(2))*((1-(Math.pow(1.00750,-leaseTerm)))/0.00750);
            console.log("amt : "+discamt+' : '+dealModelW.orderNetPrice+' non disc : '+dealModelW.nonDiscountablePrice);
            var newBookingPrice;
            if(ordertype === 'purchase')
            	newBookingPrice = bookingPrice - totalNewDiscount;
            else
                newBookingPrice = discamt+dealModelW.nonDiscountablePrice;
            console.log('new booking price : '+newBookingPrice);
            dealModelW.customerValuePrice = customerPrice;
            dealModelW.bookingPrice = newBookingPrice;
            dealModelW.totalMargin = newBookingPrice - cost;
            dealModelW.marginProduct = ((newBookingPrice - cost)/newBookingPrice)*100;
            dealModelW.commissionValue = commissionValue -(newDiscountAmt + convertedNewDiscount);
            dealModelW.gsaPrice = dealModelW.orderNetPrice - gsaNetPrice;
            if(ordertype === 'purchase')
            	dealModelW.discountable = dealModelW.discountable - (newDiscountAmt + convertedNewDiscount); //Discountable Bookings
            else
            	dealModelW.discountable = discamt.toFixed(2); //Discountable Bookings
            
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
            dealModelW.USAListPricePercentage = (totalNewDiscount/usaListPrice)*100;
            dealModelW.ContractListPricePercentage = (totalNewDiscount/contractListPrice)*100;
            
        }
        
        dealModelW.result = dealModelW.gsaPrice > 0 ? 'GSA Test Passed.' : 'GSA Test Failed.';
        component.set('v.dealModelWrapper',dealModelW);
    }
    ,
    
    resetDiscount : function(component, helper){
        var det = [];
        det = component.get("v.Details");
        console.log("details :" + component.get("v.Details"));
        for(var ii=0;ii < det.length;ii++){
            det[ii].discperc = 0;
            det[ii].discnum = 0;
            det[ii].net = det[ii].totalamount;
        }
        component.set('v.Details', det);
    } ,
    
    displayDiscountError : function(component, helper){
       // this.showToast('Given discounted should not be less than Discountable Amount', 'Error!', 'error');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message: 'Given discount should be less than Discountable Amount',
            duration:' 4000',
            key: 'info_alt',
            type: 'info',
            mode: 'dismissible'
        });
        toastEvent.fire();
    }
    
    
    
})