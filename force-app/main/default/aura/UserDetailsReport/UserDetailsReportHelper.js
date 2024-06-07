({
	getCSVBody : function(component) {
        var UserDetails = component.get("v.UserDetails");
        console.log('UserDetails-->'+JSON.stringify(UserDetails));
        
        var csvStringResult,counter,keys,lineDivider,columnDivider;   
        
        lineDivider='\n';
        keys=['USER','MANAGER','USER PROFILE','ACTIVE','SF STATUS','DATE FROZEN','DAYS FROZEN','OVERRIDE','AD STATUS','TERM DATE','DAYS FROM TERM DATE TO FROZEN DATE'];
        csvStringResult='';
        csvStringResult+=keys.join('\t');
        csvStringResult+=lineDivider;
        for(var i=0;i<UserDetails.length;i++)
        {
            csvStringResult+= UserDetails[i].Name ? UserDetails[i].Name : '';
            csvStringResult+= '\t' + (UserDetails[i].ManagerName ? UserDetails[i].ManagerName : '');
            csvStringResult+= '\t' + (UserDetails[i].ProfileName ? UserDetails[i].ProfileName : '');
            csvStringResult+= '\t' + (UserDetails[i].isActive ? UserDetails[i].isActive : '');
            csvStringResult+= '\t' + (UserDetails[i].isFrozen ? UserDetails[i].isFrozen : 0);
            csvStringResult+= '\t' + (UserDetails[i].dateFrozen ? UserDetails[i].dateFrozen : '');
            csvStringResult+= '\t' + (UserDetails[i].daysFrozen ? UserDetails[i].daysFrozen : 0);
            csvStringResult+= '\t' + (UserDetails[i].doNotDeactivate ? UserDetails[i].doNotDeactivate : '');
            csvStringResult+= '\t' + (UserDetails[i].adstatus ? UserDetails[i].adstatus : '');
            csvStringResult+= '\t' + (UserDetails[i].termDate ? UserDetails[i].termDate : '');
            csvStringResult+= '\t' + (UserDetails[i].termToFrozen ? UserDetails[i].termToFrozen : '');
            
            csvStringResult+=lineDivider;
            
        }
        return csvStringResult
    }
})