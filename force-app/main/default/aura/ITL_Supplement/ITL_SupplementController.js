({
    doInit : function(component, event, helper){
        component.set("v.isDisabled", true);      
        var recordType = component.get("v.recordTypeId");
        var quoteId = component.get("v.quoteId");
        
        if(recordType == 'International ADC/VBM Supplement' || recordType == 'NAA Budgetary Quote' || recordType == 'NAA Supplement Quote' )
        {
            component.set("v.isDealDeskDiscountingRequested", true); 
            component.set("v.isPricingChangesMade", true);             
        }
        if(recordType == 'Margin Analysis / Other') {
            component.set("v.isDiscountingBoxRequired", false); 
        }
        component.set("v.isDisabled", false);
        if(recordType == 'Small Parts')
        {
            component.set("v.isDisabled", true);
            component.set("v.showHideComponent",false);
            var action = component.get("c.isSmallPartDiscounted");
            action.setParams({
                quoteId : quoteId,
                recordTypeId : recordType            
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('return value : '+response.getReturnValue());
                    component.set("v.isShowSmallPartDiscountError",response.getReturnValue());                 
                    if(response.getReturnValue() == true)
                    {  
                        // alert("Small Part is discounted. So you cannot proceed." );                         
                    }
                    else
                    {
                        component.set("v.isDisabled", false);
                        component.set("v.showHideComponent", true);
                    }
                }
            });
            $A.enqueueAction(action);

            
        }
        helper.getTagPicklist(component, event);
                
    },
    
    handleFilesChange: function(component, event, helper) {
        //component.set("v.isDisabled", true);
        var files='';
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = '';
            for (var i = 0; i < event.getSource().get("v.files").length; i++) 
            {
                files = component.find("fileId").get("v.files")[i]["name"];
                if(i == 0)
                {
                  fileName=files;  
                }
                else
                {
                  fileName=fileName+','+files;
                }
                
            }
        }
        component.set("v.fileName", fileName);
        console.log('File Name ',fileName);
       // component.set("v.isDisabled", false);
    },
    
    handleRadioChange : function(component, event, helper) {
    	var radioGrpValue = component.get("v.radioValue");
        var setTrue = true;
    	if(radioGrpValue == "option1"){
            component.set("v.isSaveSelected",setTrue);
            component.set("v.isSaveSubmitSelected",false);
        } else if(radioGrpValue == "option2"){
            component.set("v.isSaveSubmitSelected",setTrue);
            component.set("v.isSaveSelected",false);
        }
	},
    
    handleNext : function(component, event, helper){
        component.set("v.showLoading", true);
       /* if (component.find("fileId").get("v.files") != null && component.find("fileId").get("v.files").length > 0) {
            helper.saveQuoteApproval(component, event);
            //console.log('inside if');
            //helper.uploadHelper(component, event);
        } else {*/ //Commented for IBA-1297 by Sourav
            console.log('inside else');
            helper.saveQuote(component, event);
        //}				//Commented for IBA-1297 by Sourav
    },
    
    handlePrevious : function(component, event, helper){
        alert('Click Previous button');
        var quoteId = component.get("v.quoteId");
        var url = window.location.origin + '/flow/Create_Quote_Approval_Updated?QuoterecordId='+quoteId+'&retURL='+quoteId;
        console.log('url-->'+url);
        window.open(url,'_top');
    },
	
	handleFinish : function(component, event, helper){
        var quoteId = component.get("v.quoteId");
	    var url = window.location.origin + '/lightning/r/Quote/'+quoteId+'/view';
        window.open(url,'_top');

        //helper.navigateSobject(component);
     },
    handleUploadFinished: function (cmp, event) { ////Added for IBA-1297 by Sourav
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        //alert("Files uploaded : " + uploadedFiles.length);
        var idst = cmp.get("v.idst");
        const uploadedFileList = cmp.get("v.uploadedFileList");
        //IBA-6018
        var filesid = [];
        uploadedFiles.forEach(file => {
            uploadedFileList.push({Name:file.name,Tag__c:'',Id:file.contentVersionId}); 
            //console.log(file)           
            idst = idst+","+file.documentId;
        })
        
        cmp.set("v.idst",idst);
        console.log(uploadedFileList.length);

        if(uploadedFileList.length > 0){
            cmp.set("v.uploadedFileList",uploadedFileList);
            cmp.set("v.filePopup",true);
        }
	},
    submitDetails: function(component, event, helper) {//IBA-6018
        var records = component.get("v.uploadedFileList2");
        const revRecordsToInsert = [];
        records.slice().reverse().forEach(x => revRecordsToInsert.push(x));
        const uniqueArray = revRecordsToInsert.filter((value, index) => {
            const _value = JSON.stringify(value.Id);
            return (
                index ===
                revRecordsToInsert.findIndex((obj) => {
                    return JSON.stringify(obj.Id) === _value;
                })
            );
        });
        console.log(uniqueArray.length);

        const uploadedFileList = component.get("v.uploadedFileList");

        if(uploadedFileList.length === uniqueArray.length){
            var action = component.get("c.processRecords");
            action.setParams({ records : uniqueArray });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("Records sent successfully.");
                    component.set("v.filePopup", false);
                } else {
                    console.log("Error sending records: " + response.getError());
                }
            });
            
            $A.enqueueAction(action);
        }else{
            
            component.set("v.showMessage", true);
            
            window.setTimeout(
                $A.getCallback(function() {
                    component.set("v.showMessage", false);
                }), 
                5000 
            );
            console.log("error");
        }
    },
    handleTagOnChange : function(cmp, event, helper) {//IBA-6018
        var tag = event.getSource().get("v.value");
        var id = event.getSource().get("v.name");
        console.log(tag);
        
        const uploadedFileList2 = cmp.get("v.uploadedFileList2");
        
        uploadedFileList2.push({Tag__c:tag,Id:id});
        console.log(uploadedFileList2.length);
    }
})