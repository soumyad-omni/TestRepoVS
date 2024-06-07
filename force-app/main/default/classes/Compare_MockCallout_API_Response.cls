@isTest(seeAllData=false)
global class Compare_MockCallout_API_Response implements HttpCalloutMock {
    
    public string isMockresponse;
    // public Compare_MockCallout_API_Response(final string isMockresponse){
    //this.isMockresponse=isMockresponse;
    // }
    
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        //if(isMockresponse =='SUCCESS'){
            res.setHeader('Content-Type','application/json');
            res.setBody('{"SAP_Quote_Number_Truncated__c":"5402494","Quote_Revision__c":"6","Conga_Total_Product__c":"291720.00","Conga_Total_Support_Services__c":"13500.00","Conga_Total_Shipping_and_Handling__c":"16927.04","Conga_Grand_Total__c":"322147.04","Conga_total_monthly_product__c":"0.00","Conga_Total_Monthly_Support_Services__c":"0.00","Service_Duration__c":"012 Months/Advantage Plan","Conga_Quote_Line_Discount__c":"0","Item_Count":"1","Quote_Line__c":[{"conga_Product1_c":"CPA-CAR-069","Conga_Quantity__c":"1.000","Conga1_USA_List_Price__c":"332150.00","Conga_List_Price__c":"276250.00","Conga_Unit_Price__c":"276250.00","Conga_Extended_Price_Materials__c":"276250","Conga_Unit_Services__c":"1125.00","Conga_Extended_Services__c":"1125"}]}');
            res.setStatusCode(200);
       // }
        return res;
    }
}