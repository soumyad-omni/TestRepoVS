({
    doinit : function(component,event,helper){
        helper.higherleveiItem_helper(component,event,helper);
        helper.BaseURL_helper(component,event,helper);
        helper.legacycreateddate(component,event,helper);
    },
  
	buttonAction : function(component, event, helper) {
        
        var action = component.get('c.getNextAvailableQuoteLineSAPNumber');
        action.setParams({quoteId : component.get("v.recordId") });
        //debugger; 
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var nextquoteId = response.getReturnValue();
                //debugger; 
                let button = component.find('enablebuttonid');	
                button.set("v.disabled",false); 
                var quoteno = component.get("v.qte.Quote_Number__c");
                quoteno = quoteno.replace(/^0+/, '');
				                
                var obj = 'BUS2000115';
                var ordertype = component.get("v.qte.Order_Type__c");
                // var createdate = component.get("v.qte.Legacy_SAP_Created_Date__c");
                var createdate = component.get("v.legCrDate");
                var postdt = component.get("v.qte.Posting_Date__c")
                console.log('create date after helper add'+createdate);
                var cr = $A.localizationService.formatDate(createdate, "MM/DD/YYYY hh:mm:ss");
                console.log('create date '+cr);  
                var postdate = component.get("v.qte.CreatedDate");
                
                var postdte = $A.localizationService.formatDate(postdt, "MM/DD/YYYY");
                var hightitem = component.get("v.HigherLevel");
                
                //New Logic Added for DDMMYY as per USER ZONE - SF-BUG-710 Rajesh
                
                var timezone = $A.get("$Locale.timezone");                
                var ul = $A.get("$Locale.userLocaleLang");
                var ulc = $A.get("$Locale.userLocaleCountry");
                var localsidkey=ul + "-"+ulc;                
                
                var currentdate = new Date(component.get("v.legCrDate"));
                var datetobeformated =currentdate.toLocaleString(localsidkey, {timeZone: timezone});
                var format =datetobeformated.substring(0, 10).replace(/\,/g,"");
                var datetime =format;
                 console.log('LENGTH:      '+datetime.toString().length);

                if(datetime.toString().length <= 9){ 
                    var dti= datetime.toString().indexOf("/");
                    if(dti == 1) {
                        datetime = '0'+datetime;
                    }
                    var dtio= datetime.toString().indexOf("/20");
                    if(dtio == 4) {
                        var conc= datetime.toString().replace("/", "/0");
                        datetime =conc;
                    }
                    console.log('12321: '+dti +' dtio: '+dtio + 'conc:  '+conc);                    
                }
                console.log('datetime:      '+datetime+'   datetobeformated:   '+datetobeformated);		     
                // END SF-BUG-710
                
                var desc;
                if(component.get("v.qte.Description") === null){
                    desc = "\"\"";
                }else{
                    desc= component.get("v.qte.Description");
                    desc = desc.replace('#', '%23');
                    desc = desc.replace('$', '%24');
                    desc = desc.replace('@', '%40');
                    desc = desc.replace('/', '%2F');
                    desc = desc.replace(':', '%3A'); 
                    desc = desc.replace(';', '%3B');
                    desc = desc.replace('<', '%3C');
                    desc = desc.replace('=', '%3D');
                    desc = desc.replace('>', '%3E');
                    desc = desc.replace('?', '%3F');
                    desc = desc.replace('[', '%5B');
                    desc = desc.replace(']', '%5D');
                    desc = desc.replace('^', '%5E');
                    desc = desc.replace('{', '%7B');
                    desc = desc.replace('}', '%5D');
                    desc = desc.replace('|', '%5C');
                    //desc = desc.replace('\', '%5C');
                    desc = desc.replace('~', '%7E');
                }
                
                var status = component.get("v.qte.Status");
                
                var sts;
                /*if(status == 'E0013' || status == 'E0014' || status == 'E0017' || status == 'E0019' || status == 'E0018' || status == 'E0004' || status == 'E0007' || status == 'E0009' || status == 'E0003' )
                {
                    sts = 'X';             
                }
                else{
                    sts = "\"\""; 
                }*/
                //soumyad sf-bug-384 start
                var a1 = component.get("c.qstat");
        		a1.setParams({ qid : component.get("v.recordId") });
                a1.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var res1 = response.getReturnValue();
                        console.log('t1..........................' +res1);
                        if (res1 === true){
                        var a2 = component.get("c.getUser123");
                        a2.setCallback(this, function(response) {
                            var res2 = response.getState();
                            if (res2 === "SUCCESS") {
                                var res3 = response.getReturnValue();
                                console.log('t2..........................' +res3);
                                if (res3 === true) {
                            		sts = "\"\""; 
                                    console.log('edit..........................' +res3);
                                    var cincombaseurl = component.get("v.BaseURL");
                                    console.log('sts..........................' +sts);
                                    var navToUrlEvt = $A.get("e.force:navigateToURL");
                                    navToUrlEvt.setParams({"url" : cincombaseurl+'QuoteNumber='+quoteno+'&ObjectType='+obj+'&QuoteType='+ordertype+'&NextItemno='+nextquoteId+'&CreateDate='+datetime+'&Description='+desc+'&PostDate='+postdte+'&AllowChange='+sts});  
                                    navToUrlEvt.fire();
                                }
                                else{
                                    console.log('read..........................' +res3);
                                    sts = "X";
                                    var cincombaseurl = component.get("v.BaseURL");
                                    console.log('sts..........................' +sts);
                                    var navToUrlEvt = $A.get("e.force:navigateToURL");
                                    navToUrlEvt.setParams({"url" : cincombaseurl+'QuoteNumber='+quoteno+'&ObjectType='+obj+'&QuoteType='+ordertype+'&NextItemno='+nextquoteId+'&CreateDate='+datetime+'&Description='+desc+'&PostDate='+postdte+'&AllowChange='+sts});  
                                    navToUrlEvt.fire();
                                }
                                
                            }
                            });
                        $A.enqueueAction(a2);
                                                  
                        }
                        else{
                                if(status == 'E0013' || status == 'E0014' || status == 'E0017' || status == 'E0019' || status == 'E0023' || status == 'E0024')
                                {
                                    sts = 'X';             
                                }
                                else{
                                    sts = "\"\""; 
                                }
                                var cincombaseurl = component.get("v.BaseURL");
                                console.log('sts..........................' +sts);
                                var navToUrlEvt = $A.get("e.force:navigateToURL");
                                navToUrlEvt.setParams({"url" : cincombaseurl+'QuoteNumber='+quoteno+'&ObjectType='+obj+'&QuoteType='+ordertype+'&NextItemno='+nextquoteId+'&CreateDate='+datetime+'&Description='+desc+'&PostDate='+postdte+'&AllowChange='+sts});  
                                navToUrlEvt.fire();
                            }
                    }
                    
                });
                $A.enqueueAction(a1);
                                
                //soumyad sf-bug-384 end
                
                /*var cincombaseurl = component.get("v.BaseURL");
                console.log('sts..........................' +sts);
                var navToUrlEvt = $A.get("e.force:navigateToURL");
                //navToUrlEvt.setParams({"url" : 'HTTP://CINCOM-DEV.OMNICELL.COM/CINCOMCONFIGURATORCR1/CONFIGURATIONTOOL.ASPX?'+'QuoteNumber='+quoteno+'&ObjectType='+obj+'&QuoteType='+ordertype+'&NextItemno='+hightitem+'&CreateDate='+cr+'&Description='+desc+'&PostDate='+postdte+'&AllowChange='+sts});  
                navToUrlEvt.setParams({"url" : cincombaseurl+'QuoteNumber='+quoteno+'&ObjectType='+obj+'&QuoteType='+ordertype+'&NextItemno='+nextquoteId+'&CreateDate='+cr+'&Description='+desc+'&PostDate='+postdte+'&AllowChange='+sts});  
                navToUrlEvt.fire();*/
                //helper.updatelockedcheckbox_helper(component,event,helper);
            }
            
        }); 
        $A.enqueueAction(action);
    }
})