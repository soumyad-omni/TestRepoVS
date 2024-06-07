({
	helperMethod : function(component, event) {
		
        var artId = component.get("v.recordId");
        console.log('Helper called.........' +artId);
        var action = component.get("c.showAccountCreditDetails");
         action.setParams({ AccId : artId});
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseData = response.getReturnValue();
                console.log(JSON.stringify(responseData.ZISM_BAPI_CR_ACC_GETDETAIL));
                console.log('====responseData==='+responseData);
                /*if(responseData.output.RETURN_x.MESSAGE != null && responseData.output.RETURN_x.MESSAGE != '') {
                   var msg = responseData.output.RETURN_x.MESSAGE;
                   this.showToast(msg, 'SAP Credit Status', 'error'); 
                }
                if(responseData.output.PS_CREDIT_ACCOUNT_DETAIL_ALL.NXT_REVIEW == '0000-00-00') {
                    responseData.output.PS_CREDIT_ACCOUNT_DETAIL_ALL.NXT_REVIEW = '';
                }*/
                component.set('v.wrapperList',responseData);
            }
            else {
                var errors = response.getError();
                console.log('error : '+response.getError()+' '+errors[0].Message);
                this.showToast(errors[0], 'Error Message', 'error');
            }
        });
        $A.enqueueAction(action);
	},
    toggleSection : function(component, event){
        var sectionId = event.getSource().get("v.id");
        var iconId1 = sectionId + '-icon-1';
        var iconId2 = sectionId + '-icon-2';
        var iconId3 = sectionId + '-icon-3';
        var iconId4 = sectionId + '-icon-4';
        var iconId5 = sectionId + '-icon-5';
        $A.util.toggleClass(component.find(sectionId), 'slds-is-open');
        $A.util.toggleClass(component.find(iconId1), 'slds-hide');
        $A.util.toggleClass(component.find(iconId2), 'slds-hide');
        $A.util.toggleClass(component.find(iconId3), 'slds-hide');
        $A.util.toggleClass(component.find(iconId4), 'slds-hide');
        $A.util.toggleClass(component.find(iconId5), 'slds-hide');
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
    getAccount: function(component, event){
        
        var action = component.get("c.getAccountDetails");
        action.setParams({ recId : component.get("v.recordId")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.AccountDetails",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    getCSVBody : function(component) {
        var accountDetails = component.get("v.AccountDetails");
        var wrapperDetails = component.get("v.wrapperList");
        console.log('wrapperDetails-->'+JSON.stringify(wrapperDetails));
        
        var csvStringResult,counter,keys,lineDivider,columnDivider;   
        
        lineDivider='\n';
        keys=['Account Name','Approved Not Booked','Booked Not Paid','Primary Liabilities','Total Liabilities'];
        csvStringResult='';
        csvStringResult+=keys.join('\t');
        csvStringResult+=lineDivider;
        csvStringResult += accountDetails.Name + '\t$' + wrapperDetails.ApprovedNotBooked + '\t$' + wrapperDetails.wrapper.ZISM_BAPI_CR_ACC_GETDETAIL.exports.EV_CREDIT_OVERVIEW.BOOKED_NOT_PAID + '\t$' + wrapperDetails.wrapper.ZISM_BAPI_CR_ACC_GETDETAIL.exports.PS_CREDIT_ACCOUNT_DETAIL_ALL.TOTAL_LIABILITIES + '\t$' + wrapperDetails.TotalLiabilities;
        csvStringResult+=lineDivider;
        csvStringResult+=lineDivider;
        csvStringResult+='Booked Not Paid';
        csvStringResult+=lineDivider;
        keys=['Opportunity Number','Customer Name','Quote Number','Sales Order Number','Booked Not Invoiced','Invoiced Not Paid'];
        csvStringResult+=keys.join('\t');
        csvStringResult+=lineDivider;
        var bookNotPaidList = wrapperDetails.BookedNotPaidList;
        for(var i=0;i<bookNotPaidList.length;i++)
        {
            csvStringResult+= bookNotPaidList[i].oppNumber ? bookNotPaidList[i].oppNumber : '';
            csvStringResult+= '\t' + (bookNotPaidList[i].customerName ? bookNotPaidList[i].customerName : '');
            csvStringResult+= '\t' + (bookNotPaidList[i].quoteNumber ? bookNotPaidList[i].quoteNumber : '');
            csvStringResult+= '\t' + (bookNotPaidList[i].SoNumber ? bookNotPaidList[i].SoNumber : '');
            csvStringResult+= '\t$' + (bookNotPaidList[i].amountBooked ? bookNotPaidList[i].amountBooked : 0);
            csvStringResult+= '\t$' + (bookNotPaidList[i].invoicedNotPaid ? bookNotPaidList[i].invoicedNotPaid : 0);
            
            csvStringResult+=lineDivider;
            
        }
        csvStringResult+=lineDivider;
        csvStringResult+='Approved Not Booked';
        csvStringResult+=lineDivider;
        keys=['Opportunity Number','Customer Name','Opportunity Expected Bookings','Credit Approved Date','Quote Number','Quote Net Value'];
        csvStringResult+=keys.join('\t');
        csvStringResult+=lineDivider;
        var oppList = wrapperDetails.ApprovedNotBookedList;
        for(var i=0;i<oppList.length;i++)
        {
            csvStringResult += oppList[i].oppNumber ? oppList[i].oppNumber : '';
            csvStringResult += '\t' + (oppList[i].customerName ? oppList[i].customerName : '');
            csvStringResult += '\t$' + (oppList[i].oppExpectedBookings ? oppList[i].oppExpectedBookings : 0);
            csvStringResult += '\t' + (oppList[i].creditApprovedDate ? oppList[i].creditApprovedDate : '');
            csvStringResult += '\t' + (oppList[i].quoteNumber ? oppList[i].quoteNumber : '');
            csvStringResult += '\t$' + (oppList[i].quoteNetValue ? oppList[i].quoteNetValue : 0);
            
            csvStringResult+=lineDivider;
        }

        return csvStringResult
    }
})