({
	CSV2JSON: function (component,csv) {
        //  console.log('Incoming csv = ' + csv);
        //var array = [];
        var arr = []; 
        arr =  csv.split('\n');
        //console.log('Array  = '+array);
        // console.log('arr = '+arr);
        arr.pop();
        var jsonObj = [];
        var headers = arr[0].split(',');
        for(var i = 1; i < arr.length; i++) {
            var data = arr[i].split(',');
            var obj = {};
            for(var j = 0; j < data.length; j++) {
                obj[headers[j].trim()] = data[j].trim();
                //console.log('obj headers = ' + obj[headers[j].trim()]);
            }
            jsonObj.push(obj);
        }
        var json = JSON.stringify(jsonObj);
        //console.log('json = '+ json);
        return json;
    },
     CreateData : function (component,jsonstr){
        var action = component.get('c.insertData');
          var recordId = component.get('v.recordId');    
        action.setParams({
            qlId : recordId,
            jsonData : jsonstr,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                var result=response.getReturnValue();
                component.set('v.myWrapper', response.getReturnValue());
                var msg = "File Uploaded..."
                this.showToast(msg, 'Success', 'Success');
                 component.set('v.myText',"File Uploaded...");
                 component.set('v.disableDownloadBtn',false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast(errors[0].message, 'Success', 'Error');
                        component.set('v.myText',errors[0].message);
                    }
                } else {
                    this.showToast("Unknown error", 'Success', 'Error');
                    component.set('v.myText',"Unknown error");
                }
            }
        }); 
        
        $A.enqueueAction(action);    
        
    },
     showToast : function(errorMsg, title, toastType) {

        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams({
                title : title,
                message: errorMsg,
                type: toastType,
                mode: 'pester',
            });
            toastEvent.fire();
        }else{
            alert(errorMsg);
        }
    },
        convertArrayOfObjectsToCSV : function(component,objectRecords){
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
        // in the keys variable store fields API Names as a key 
        // this labels use in CSV file header  
        keys = ['uniqueValue','status'];
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;            
            for(var sTempkey in keys) {
                var skey = keys[sTempkey]; 
                // add , [comma] after every String value,. [except first]
                if(counter > 0){ 
                    csvStringResult += columnDivider; 
                } 
                // if condition for blank column display if value is empty
                if(objectRecords[i][skey] != undefined){
                    csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                }else{
                    csvStringResult += '"'+ '' +'"';
                }
                counter++;  
            } // inner for loop close 
            csvStringResult += lineDivider;
        }// outer main for loop close 
        
        // return the CSV formate String 
        return csvStringResult;        
    }
})