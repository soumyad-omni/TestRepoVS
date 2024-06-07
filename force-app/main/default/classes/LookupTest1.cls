@isTest(SeeAllData=true) 
private class LookupTest1 {
 static testMethod void validatemethod1() {
     string objectName='Product2';
     String fld_API_Text='ProductCode';
     String          fld_API_Val='Id';
     String    fld_API_Search='ProductCode';
     String     lookupIcon='standard:product'; 
     String     sellItemId='';
     String       fieldId=''    ;                        
     String      placeholder='Enter space after text to search products';
     Product2 prd2 = [Select id,ProductCode,Description,sales_text__c,DW_Product_Line__c  from Product2 LIMIT 1];
     fieldId = prd2.Id;
     Lookup.searchByIdDB(objectName,  fld_API_Text,  fld_API_Val, 
                                   4, fld_API_Search, fieldId);
     Lookup.searchDB(objectName,  fld_API_Text,  fld_API_Val, 
                                   4, fld_API_Search, fieldId);
     
     
 
 }
}