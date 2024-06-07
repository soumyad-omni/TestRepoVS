({
    doInit : function(component, event, helper) {
        component.set('v.myText',"Please Select a CSV File...");
        var recordId = component.get('v.recordId');
    },
    showfiledata : function(component, event, helper) {
        component.set('v.disableUploadBtn',false);
    },
    CreateRecord : function(component, event, helper) {
        component.set('v.disableUploadBtn',true);
        var msg = "Please wait While uploading...";
        component.set('v.myText',"Please wait While uploading...");
        helper.showToast(msg, 'Upload', 'info');
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        if (file){
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                var csv = evt.target.result;
                var result = helper.CSV2JSON(component,csv);
                console.log('result = ' + result);
                console.log('Result = '+JSON.parse(result));
                helper.CreateData(component,result);
            }
            reader.onerror = function (evt) {
            }
        }
    },
    downloadCsv : function(component, event, helper) {
        // get the Records [contact] list from 'ListOfContact' attribute 
        var stockData = component.get("v.myWrapper");
        
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData);   
        if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'Export_Result.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    }
})