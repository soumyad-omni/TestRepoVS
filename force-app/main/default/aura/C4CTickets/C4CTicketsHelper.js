({
	getData : function(component, event) {
        this.loadCloumn(component, event);
        var action = component.get("c.getTickets");
        action.setParams({recordId: component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isError", false);
                var SAPC4CTickets = response.getReturnValue();;
                if(SAPC4CTickets && SAPC4CTickets.ServiceRequestCollection){
                    var data = SAPC4CTickets.ServiceRequestCollection;
                    var viewAll = component.get("v.viewAll");
                    if(data.length > 200){
                        component.set("v.count", '200+')
                        data.splice(200, 1);
                        component.set("v.data", data);
                    }else{
                        component.set("v.count", data.length)
                        component.set("v.data", data);
                    }
                    if(!viewAll){
                        var newData = [];
                        if(data.length >= 5) {
                            for(var i = 0; i < 5; i++){
                               newData.push(data[i]); 
                            }
                            component.set("v.data", newData);
                        }
                    }
                }
                
            } else if (state === "ERROR") {
                component.set("v.isError", true);
                component.set("v.errorMessage", response.getError()[0].message);
        	}
            component.set("v.isWaiting", false);
        }); 
		$A.enqueueAction(action);
    },
    
    loadCloumn : function(component, event){
        component.set('v.columns', [
           // {label: 'ID', fieldName: 'ID', type: 'text'},
            {label: 'Action Name', fieldName: 'ActionName', type: 'text'},
            {label: 'Assigned To Name', fieldName: 'AssignedToName', type: 'text'},
            //{label: 'Contact ID', fieldName: 'ContactID', type: 'text'},
            {label: 'Contact Name', fieldName: 'ContactName', type: 'text'},
            //{label: 'Customer', fieldName: 'Customer', type: 'text'},
            //{label: 'Customer Status', fieldName: 'CustomerStatus', type: 'text'},
            //{label: 'Customer Status Text', fieldName: 'CustomerStatusText', type: 'text'},
            //{label: 'ETag', fieldName: 'ETag', type: 'date'},
            
            //{label: 'ObjectID', fieldName: 'ObjectID', type: 'text'},
            //{label: 'Par Location', fieldName: 'ParLocation', type: 'text'},
            {label: 'Product ID', fieldName: 'ProductID', type: 'text'},
            {label: 'Reported On Date', fieldName: 'ReportedOnDate', type: 'datetime'},
            //{label: 'Reporter Email', fieldName: 'ReporterEmail', type: 'email'},
            //{label: 'Resolution Code Name', fieldName: 'ResolutionCodeName', type: 'text'},
            {label: 'Serial ID', fieldName: 'SerialID', type: 'text'},
            {label: 'Service Priority Code Text', fieldName: 'ServicePriorityCodeText', type: 'text'},
            //{label: 'Service Request User Life Cycle Status Code', fieldName: 'ServiceRequestUserLifeCycleStatusCode', type: 'text'},
            {label: 'Service Request User Life Cycle Status Code Text', fieldName: 'ServiceRequestUserLifeCycleStatusCodeText', type: 'text'},
           // {label: 'Sub Area Name', fieldName: 'SubAreaName', type: 'text'},
            {label: 'Subject', fieldName: 'Subject', type: 'text'}

        ]);
    },
    navigateToViewAll : function(component, event, helper) {
        console.log('Enter Here');
        var evt = $A.get("e.force:navigateToComponent");
        console.log('evt'+evt);
        evt.setParams({ componentDef: "c:C4CTickets",componentAttributes :{"viewAll":true, recordId : component.get("v.recordId")}});
        evt.fire();
    },
    prepTableMeta : function(cmp, retData) {
    	var tableMeta = JSON.parse(retData.Metadata).ServiceRequestCollection;
		var tableData = retData.ServiceRequestCollection;
		var firstRow, keyField;
		if (tableData) {
			firstRow = tableData[0];
		}
		var columnMeta = [];
		var bodyFont = window.getComputedStyle(document.body,null).getPropertyValue('font');
		var context = document.createElement('canvas').getContext("2d");
		context.font = bodyFont;
		Object.keys(tableMeta.fields).forEach(function(field) {
			var fieldMeta = tableMeta.fields[field];
			var colType;
			var typeAttr = {};
			switch (fieldMeta.apexType) {
				case "INTEGERX":
				case "LONGX":
					colType = "number";
					typeAttr.maximumFractionDigits = 0;
					break;
				case "DECIMALX":
				case "DOUBLEX":
					colType = "number";
					typeAttr.maximumFractionDigits = fieldMeta.scale;
					break;
				case "CURRENCYX":
					colType = "currency";
					if (firstRow && fieldMeta.unitCode) {
						typeAttr.currencyCode = firstRow[fieldMeta.unitCode];
					}
					break;	
				case "PERCENTX":
					colType = "percent";
					typeAttr.maximumFractionDigits = fieldMeta.scale;
					break;
				case "DATEX":
					colType = "date";
					typeAttr.timeZone = "UTC";
					break;
				case "DATETIMEX":
					colType = "date";
					typeAttr.hour = typeAttr.minute = "numeric";
					break;
				case "STRINGX":
				default:
					colType = "text";
			}
			var col = {label: fieldMeta.name, fieldName: fieldMeta.name, type: colType, sortable: true, initialWidth: context.measureText("1".repeat(fieldMeta.length)).width};
			if (typeAttr) {
				col.typeAttributes = typeAttr;
			}
			columnMeta.push(col);
		});
		//if (tableData) {
		//	cmp.set("v.totalRows", tableData.length);
		//}

    	cmp.set("v.tableMeta", columnMeta);
    },
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.returnedData");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.returnedData", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
})