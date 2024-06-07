/**********************************************************************
Name:  OmnicellAcctContRelationToCastIron_Class
Copyright © 2018
======================================================
======================================================
Purpose: 
Once AccountContactRelation is created/updated,invoke REST api class to connect to CastIron.                                                            
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL                  Description
0.1          Amruta Dhumal            09/24/2018            Developed by CG Team    INITIAL DEVELOPMENT
***********************************************************************/

global class OmnicellAcctContRelationToCastIron_Class{
    
  
    public static void callOutMethod(set<Id> newactconIds){
    
    system.debug('method 1...');
        
        CastIronIntegration__c csValue1 = CastIronIntegration__c.getInstance('CastIronIntegration');
    
        
        String endpoint = csValue1.AcctConRelEndPoint__c; 
        system.debug('endpoint...'+endpoint);
        
        
        String jsonstrinsert ='';
        String contactid ='';
        string actconid ='';
        string errormsg ='';
        List<String> jasonstrings = new List<String>();
        
        AccountContactRelation [] actconList = [SELECT Id,AccountId,Account.SAP_Account_ID__c,ContactId,Contact.SAP_Contact_ID__c,Roles FROM AccountContactRelation WHERE Id IN: newactconIds];
        system.debug('actconList...'+actconList);
        
         if(actconList.size()>0)
         {
          for(AccountContactRelation actcon : actconList) 
           {
            system.debug('actcon...'+actcon);
            actconid = actcon.Id;
            system.debug('actconid...'+actconid);
            contactid = actcon.ContactId;
            string sfdcactconid = actcon.Id;
            string conid = actcon.ContactId;
            string actid = actcon.AccountId;
            string role = actcon.Roles;
            string sapaccountid = actcon.Account.SAP_Account_ID__c;
            string sapcontactid = actcon.Contact.SAP_Contact_ID__c;
           if(role == null)
            {
              role = '';
            }
            
            if(sapcontactid == null)
            {
              sapcontactid = '';
            }
            
            if(sapaccountid == null)
            {
              sapaccountid = '';
            }
             jsonstrinsert ='{"Salesforce AccountContactRelation ID" : "'+sfdcactconid +'","SAP Contact ID" : "'+ sapcontactid +'","Salesforce Contact ID" : "'+conid +'","SAP Account ID" : "'+ sapaccountid +'","Salesforce Account ID" :"'+actid+'"}';

             system.debug('jsonstrinsert...'+jsonstrinsert);
             jasonstrings.add(jsonstrinsert);
        }
            string jsonString = JSON.serialize(jasonstrings);
            
            jsonString = jsonString.replace('\\"', '"');
            jsonString = jsonString.replace('"{', '{');
            jsonString = jsonString.replace('}"', '}');
            
            System.debug('jsonString : '+jsonString);
            try{
                system.debug('in try...');
               /* if(sapcontactid != '' )
                {
                 system.debug('Inside if');
                
                 
                }*/
                Http h= new Http();
                HttpRequest req= new HttpRequest();
                //req.setClientCertificateName('CastIronIntegration');
                req.setHeader('Content-Type','application/json');
                req.setHeader('accept','application/json');
                req.setBody(jsonString);
                req.setMethod('POST');
                req.setEndpoint(endPoint);
                req.setTimeout(120000); 
                HttpResponse res=h.send(req);
                if(res.getstatusCode() == 200){
                System.debug(res+'###123createresp');
                system.debug('res.getBody()..'+res.getBody());
              } 
              
               if(res.getstatusCode() != 200){
                     system.debug('errorbody..'+res.getBody());
                     system.debug('errorstatus..'+res.getStatus());
                    
                       errormsg = res.getStatus();
                       system.debug('errormsg..'+errormsg);
                       if(errormsg!=null){
                        system.debug('callingclass..');
                       ErrorLogging.IntegrationLog(errormsg, 'callOutMethod','App');
                     }
                      
                  }  
               
            }
            catch(Exception e){
              System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
              ErrorLogging.Log(e, 'callOutMethod','App');
              
            }
                
          }
            
        }
     
   }