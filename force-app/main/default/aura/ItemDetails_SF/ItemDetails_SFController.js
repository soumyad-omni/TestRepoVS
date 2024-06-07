({
	doInit : function(component, event, helper) {
        //Added by sravan for SF-BUG-590
        var action = component.get("c.getOrderType");
        action.setParams({ "qId" : component.get("v.recordid")});
        console.log('record id : '+component.get("v.recordid"));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('return value : '+response.getReturnValue());
               component.set("v.ordertype",response.getReturnValue());           
            }
        });
        $A.enqueueAction(action);
        console.log("order type : "+component.get("v.ordertype"));
		//Added by sravan for SF-BUG-590 END
		helper.doInit(component, event);
	},
    //Added calculateTotalDiscount by sravan for SF-BUG-590 START
    calculateProdDiscount : function(component, event, helper){
        var dealwrappnew = component.get("v.dealModelWrapper");
        var det = [];
        det = component.get("v.Details");
        console.log("details :" + component.get("v.Details"));
        var totdiscount = 0;
        var displayError = false;
        for(var ii=0;ii < det.length;ii++){
            var netbooking = 0;
            console.log(det[ii].name+' : '+det[ii].discperc+det[ii].discnum);
            if((det[ii].discperc > 100)||(det[ii].discperc != 0 && det[ii].discnum != 0)||(det[ii].discnum > det[ii].discamount))
            {displayError = true; break;}
            if(det[ii].discperc != 0){
                netbooking = det[ii].nondiscamount + (det[ii].discamount-(det[ii].discamount * (det[ii].discperc/100)));
            	totdiscount = totdiscount+det[ii].discamount * (det[ii].discperc/100);
            }
            else if(det[ii].discnum != 0){
                netbooking = det[ii].nondiscamount + (det[ii].discamount - det[ii].discnum);
                totdiscount = totdiscount + det[ii].discnum;
            }
            else{
                 netbooking = det[ii].totalamount;   
            }
            det[ii].net = netbooking;
        }
        if(displayError)
        {
            helper.displayDiscountError(component,helper);
        }
        else
        {
            component.set('v.Details', det);
            dealwrappnew.discountAmount = totdiscount;
            component.set("v.dealModelWrapper",dealwrappnew);
            var calculateDiscountEvent = component.getEvent("calculateDiscountEvent");
            calculateDiscountEvent.fire(); 
        }
        
        
       // helper.calculateTotalDiscount(component, helper);
    },
    reset : function(component, event,helper){       
        helper.resetDiscount(component, helper);
        var resetParentEvent = component.getEvent("resetEvent");
        resetParentEvent.fire();
    },
    onKeyUp: function(component, event){
        var inputId = event.getSource().get("v.id");
          if(inputId === 'discPercId'){
            if(parseInt(inputValue) > 100){
                inputValue = inputValue.substring(0,inputValue.length - 1);
            }
           
        }
    },
    callChildReset : function(component, event, helper) {
       helper.resetDiscount(component, helper);
    }
    //Added by sravan for SF-BUG-590 END
})