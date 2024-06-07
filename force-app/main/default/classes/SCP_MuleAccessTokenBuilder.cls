/* 
* Class Name       :SCP_MuleAccessTokenBuilder
* Description      :Base Controller for initiating Mule API callout to get access token
* Created By       :Sanjana K.R
* Created On       :Apr 20,2021

* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date           Story                                 Description
* ----------------------------------------------------------------------------------------------------------------
* Sanjana K.R             20/4/2021
*/

public without sharing class SCP_MuleAccessTokenBuilder{

/******************************************************************************************************************
* Method Name      :     authenticateMuleSystem
* Return           :     String 
* Description      :     Base Method to fetch Accesstoken from Mulesoft
********************************************************************************************************************/
    public static string authenticateMuleSystem(){
        Map<String,Object> resp = new Map<String,Object>();
        Http h = new Http();    
        HttpRequest  request = new HttpRequest();
        HttpResponse response= new HttpResponse();
        SCP_Integration_Details__c authMule = SCP_Integration_Details__c.getValues('SCP_Mulesoft_Authorization');
        
        request.setMethod(authMule.SCP_Method_Type__c);
        request.setHeader('client_id', authMule.SCP_Key_Client_Id__c);
        request.setHeader('client_secret',authMule.SCP_Password_Client_Secret__c);
        request.setHeader('grant_type',authMule.SCP_Grant_Type__c);
        request.setEndpoint(authMule.SCP_End_Point__c);
        if(!Test.isRunningTest()){
        	response = h.send(request);
        }else{
            SCP_MuleAccessTokenMock scp = new SCP_MuleAccessTokenMock(1);
        	response = scp.respond(request);
        }
        
        resp =  (Map<String,Object>)System.JSON.deserializeUntyped(response.getBody());
        system.debug('Authorization response-->'+resp.get('access_token'));
        if(response.getStatusCode() == 200)
            return String.valueof(resp.get('access_token'));
        else
            return '';
    }
}