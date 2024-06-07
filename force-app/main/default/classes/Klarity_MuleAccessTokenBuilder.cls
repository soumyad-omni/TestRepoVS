/* 
* Class Name       :Klarity_MuleAccessTokenBuilder
* Description      :Base Controller for initiating Mule API callout to get access token
* Created By       :Sahid Hussain
* Created On       :Nov 22,2022

* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date           Story                                 Description
* ----------------------------------------------------------------------------------------------------------------
* Sahid Hussain           11/22/2022
*/
public class Klarity_MuleAccessTokenBuilder {

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
        SCP_Integration_Details__c authMule = SCP_Integration_Details__c.getValues('Klarity_Mulesoft_Authorization');
        
            request.setMethod(authMule.SCP_Method_Type__c);
            request.setHeader('client_id', authMule.SCP_Key_Client_Id__c);
            request.setHeader('client_secret',authMule.SCP_Password_Client_Secret__c);
            request.setHeader('grant_type',authMule.SCP_Grant_Type__c);
            request.setEndpoint(authMule.SCP_End_Point__c);
        if(!Test.isRunningTest()){
        	response = h.send(request);
        }else{
            Klarity_MuleAccessTokenMock kp = new Klarity_MuleAccessTokenMock();
        	response = kp.respond(request);
        }
        
        resp =  (Map<String,Object>)System.JSON.deserializeUntyped(response.getBody());
        system.debug('Authorization response-->'+resp.get('access_token'));
        if(response.getStatusCode() == 200)
            return String.valueof(resp.get('access_token'));
        else
            return '';
    }
}