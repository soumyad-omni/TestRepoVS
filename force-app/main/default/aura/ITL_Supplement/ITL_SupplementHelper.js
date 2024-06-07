({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,     //Chunk Max size 750Kb
    
    
    saveQuoteApproval : function(component, event){
        var newQuoteApp = component.get("v.simpleNewQuoteApproval");
        console.log('newQuoteApp'+ JSON.stringify(component.get("v.simpleNewQuoteApproval")));
        var quoteId = component.get("v.quoteId");
        var recordTypeId = component.get("v.recordTypeId");
        var isSaveSubmitClick = component.get("v.isSaveSubmitSelected");
        var isSaveClick = component.get("v.isSaveSelected");
        component.set("v.isDisabled", true);
        var action = component.get("c.saveQuoteApproval");
		action.setParams({
            quoteApp: newQuoteApp,
            quoteId : quoteId,
            recordTypeId : recordTypeId,
            isSaveSubmitClick : isSaveSubmitClick            
        });
        
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            var quoteAppId = response.getReturnValue();
            component.set("v.quoteApprovalId",quoteAppId);
            var state = response.getState();
            if (state === "SUCCESS") {
                var fileCount=component.find("fileId").get("v.files").length;
                if (fileCount > 0) {
                    for (var i = 0; i < fileCount; i++) 
                    {
                        this.uploadHelper(component, event,component.find("fileId").get("v.files")[i],i);
                    }
                }
           	} // handel the response errors
            else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
              component.set("v.isDisabled", false);
              component.set("v.showLoading", false);
            
        });
        // enqueue the action
        $A.enqueueAction(action);
        
    },
    
    saveQuote : function(component, event){
        var newQuoteApp = component.get("v.simpleNewQuoteApproval");
        console.log('newQuoteApp'+ JSON.stringify(component.get("v.simpleNewQuoteApproval")));
        var quoteId = component.get("v.quoteId");
        var recordTypeId = component.get("v.recordTypeId");
        var isSaveSubmitClick = component.get("v.isSaveSubmitSelected");
        var isSaveClick = component.get("v.isSaveSelected");
        var idsNew = component.get("v.idst");//Added extra variable by Sourav IBA-1297
        component.set("v.isDisabled", true);
        var action = component.get("c.saveQuoteApp");
		action.setParams({
            quoteApp: newQuoteApp,
            quoteId : quoteId,
            recordTypeId : recordTypeId,
            isSaveSubmitClick : isSaveSubmitClick,
            ids: idsNew									//Added extra variable by Sourav IBA-1297
        });
        
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            var quoteAppId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                if(isSaveSubmitClick){
                    this.navigateSobject(component);
                }else{
                	component.set("v.showHideComponent", false);
                	//alert('Quote inserted successfully');
                }
           	} // handel the response errors
            else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
              component.set("v.isDisabled", false);
              component.set("v.showLoading", false);
            
        });
        // enqueue the action
        $A.enqueueAction(action);
        
    },
    
    uploadHelper : function(component, event,f,index) {
		// start/show the loading spinner   
        component.set("v.showLoadingSpinner", true);
        component.set("v.isDisabled", true);
        var file = f;
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        //var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.isDisabled", false);
            component.set("v.showLoading", false);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
        
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
 
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents,index);
        });
 
        objFileReader.readAsDataURL(file);
	},
    uploadProcess: function(component, file, fileContents,index) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
 
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition,index);
    },
    
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition,index) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var newQuoteApp = component.get("v.simpleNewQuoteApproval");
        var quoteId = component.get("v.quoteId");
        var quoteApprovalId = component.get("v.quoteApprovalId");
        var recordTypeId = component.get("v.recordTypeId");
        var isSaveSubmitClick = component.get("v.isSaveSubmitSelected");
        console.log('quoteId-->'+quoteId);
        console.log('recordTypeId-->'+recordTypeId);
        var fileCount=component.find("fileId").get("v.files").length;
        var action = component.get("c.saveChunk");
        action.setParams({
            quoteApp: newQuoteApp,
            quoteApprovalId : quoteApprovalId,
            recordTypeId : recordTypeId,
            isSaveSubmitClick : isSaveSubmitClick,
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            index: index,
            filesCount:fileCount
            
        });
 
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            var index = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert('File uploaded succesfully');
                console.log('isSaveSubmitClick value ',isSaveSubmitClick);
                console.log('isSaveSubmitClick value ',component.get("v.isSaveSubmitSelected"));
                if(index+1 == fileCount)
                {
                    if(isSaveSubmitClick){
                        this.navigateSobject(component);
                    } else{
                        console.log('inside else');
                        component.set("v.showLoadingSpinner", false);
                        component.set("v.showHideComponent", false);
                    }  
                }
               
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.showLoadingSpinner", false);
            component.set("v.showHideComponent", false);
            component.set("v.isDisabled", false);
            component.set("v.showLoading", false);
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    
    navigateSobject : function (component) {
        console.log('navigate method');
		var quoteId = component.get("v.quoteId");
	    var url = window.location.origin + '/lightning/r/Quote/'+quoteId+'/view';
        window.open(url,'_top');
    },
    getTagPicklist: function(component, event) {
        var action = component.get("c.getTagPicklist");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var tagMap = [];
                for(var key in result){
                    tagMap.push({key: key, value: result[key]});
                }
                component.set("v.tagMap", tagMap);
            }
        });
        $A.enqueueAction(action);
    }
})