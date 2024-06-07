({
	doInit : function(component, event, helper) {
        
       var action = component.get("c.getCurrentUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set current user information on userInfo attribute
                component.set("v.userId", storeResponse);
                console.log("User Id: "+storeResponse);
                
                //console.log("Campaign owner id : "+ camp.OwnerId);
            }
        });
        $A.enqueueAction(action);
        
         var action = component.get("c.getStatus");
        action.setParams({ campId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.checkUser", storeResponse);
                console.log("Status: "+storeResponse);
            }
        });
        $A.enqueueAction(action);
    },
    navigateToReport : function(component, event, helper) {
        //updated by sravan for SF-BUG-871 on FEB 20 2020 START
        var Url;
        var action = component.get("c.getReportUrl");
        action.setParams({campid : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state : '+state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                Url = storeResponse;
                console.log(storeResponse+'url 1 : '+Url);
                var navToUrlEvt = $A.get("e.force:navigateToURL");
        navToUrlEvt.setParams({
            "url" : Url    
        }); 
        navToUrlEvt.fire(); 
            }
            else{
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
        //updated by sravan for SF-BUG-871 on FEB 20 2020 END
        //commented below code by sravan for SF-BUG-871 on FEB 20 2020
        //var Url = "https://omnicell--sravank.lightning.force.com/lightning/r/Report/00O1N000006DVaQUAW/view?fv0="+component.get("v.recordId");                
        
       /* var navToUrlEvt = $A.get("e.force:navigateToURL");
        navToUrlEvt.setParams({
            "url" : Url    
        }); 
        navToUrlEvt.fire(); */
    },
    section1 : function(component, event, helper) {
       helper.helperFun(component,event,'articleOne');
    },
    section2 : function(component, event, helper) {
       helper.helperFun(component,event,'articleTwo');
    },
 section3 : function(component, event, helper) {
       helper.helperFun(component,event,'articleThree');
    },
section4 : function(component, event, helper) {
       helper.helperFun(component,event,'articleFour');
    },
section5 : function(component, event, helper) {
       helper.helperFun(component,event,'articleFive');
    },
section6 : function(component, event, helper) {
       helper.helperFun(component,event,'articleSix');
    },
section7 : function(component, event, helper) {
       helper.helperFun(component,event,'articleSeven');
    },
    section8 : function(component, event, helper) {
       helper.helperFun(component,event,'articleEight');
    }

})