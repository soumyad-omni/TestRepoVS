/**
 * @Author  :  Jayvardhan Singh
 * @Desc  :  Utility class to run Enterprise Territory Management Assignment rules
 * */
public class RunAccountTerritoryRules implements Queueable, Database.AllowsCallouts  {
    public Set<String> accntIds = null;
    private String sessionId = null;    
    private String accountTag = '<urn:sObjects> '+
                          '<urn1:type>Account</urn1:type>  '+
              '<urn1:Id>{ACCID}</urn1:Id>   '+
                      '</urn:sObjects> ' ;    
    private String requestTemplate = '<soapenv:Envelope '+
        'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'+
        ' xmlns:urn="urn:partner.soap.sforce.com"'+
        ' xmlns:urn1="urn:sobject.partner.soap.sforce.com">'+
                                '<soapenv:Header> '+
                                  '<urn:AssignmentRuleHeader> '+ 
                                     '<urn:useDefaultRule>true</urn:useDefaultRule> '+
                                     '<urn:assignmentRuleId></urn:assignmentRuleId> '+
                                  '</urn:AssignmentRuleHeader>  '+
                                  '<urn:SessionHeader> '+
                '<urn:sessionId>{SESSID}</urn:sessionId> '+
                                  '</urn:SessionHeader> '+
                               '</soapenv:Header> '+
                               '<soapenv:Body> '+
                '<urn:update> '+
                 ' {ACCLISTS}'+ 
                                  '</urn:update> '+
                               '</soapenv:Body> '+
                            '</soapenv:Envelope>';
    
    public void execute(QueueableContext context) {
      sessionId =  UserInfo.getSessionId();     
        List<String> lstAccString = new List<String>();
        List<Account> AccountsToUpdate= new List<Account>();//Added by Sourav for IBA-1129
        if(accntIds != null){
            for(String accId:accntIds){
                lstAccString.add(accountTag.replace('{ACCID}', accId)); 
            }
            AccountsToUpdate = [Select id,IsDeleted__c From Account Where id IN :accntIds];//Added by Sourav for IBA-1129
        }        
        requestTemplate = requestTemplate.replace('{ACCLISTS}', String.join(lstAccString, ' ')) ;
        requestTemplate = requestTemplate.replace('{SESSID}', sessionId) ;        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(System.URL.getSalesforceBaseUrl().toExternalForm()+
          '/services/Soap/u/41.0/'+UserInfo.getOrganizationId());
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', '""');
        request.setBody(requestTemplate);
        String requestBody = '';
        try{
            if(!test.isRunningTest())
          requestBody = String.valueOf(new Http().send(request).getBodyDocument());
        }
        catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        finally {
        //Pls use batch size one if updating bulk account from dataloader
        List<Id> idList = new List<Id>(); 
        List<Opportunity> oppList;
        List<Opportunity> updatedOppList = new List<Opportunity>();
        Map<Id,Id> oppTerritoryMap = new Map<Id,Id>();
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>([SELECT Id, AccountId, Territory2Id FROM Opportunity 
                                                                      WHERE AccountId IN :accntIds and Account.IsDeleted__c = false
                                                                      AND (OppStatus__c ='PO Received - Pending Paperwork' OR 
                                                                      OppStatus__c ='PO Received' OR OppStatus__c ='Open')
                                                                      ]);
        idList.addAll(opportunityMap.keySet());
        oppList = opportunityMap.values();
        OpportunityTerritoryAssign handler = new OpportunityTerritoryAssign();
        oppTerritoryMap = handler.getOpportunityTerritory2Assignments(idList);
        for (Opportunity opp : oppList)
    {
            if(oppTerritoryMap.get(opp.Id) != null)
            {
                opp.Territory2Id = oppTerritoryMap.get(opp.Id);
                updatedOppList.add(opp);
            }          
    }
        if(updatedOppList.size() > 0)
        { update updatedOppList;}
        
        /*IBA-3677 if(!Test.isRunningTest() ){//Adding this condition for Test Class
            	System.enqueuejob(new updateContactQueueableclass(AccountsToUpdate));//Added by Sourav for IBA-1129
        }*/
        // IBA-3677
        if (oppTerritoryMap != null || !oppTerritoryMap.isEmpty()) {
            List<Opportunity> oppFullList = [SELECT Id, AccountId, Territory2Id, OwnerId, Account.Facility_Type__c from Opportunity 
                                         WHERE Id IN :idList and Account.IsDeleted__c = false
                                         AND (OppStatus__c ='PO Received - Pending Paperwork' OR 
                                              OppStatus__c ='PO Received' OR OppStatus__c ='Open')];
            CreateOpportunityTeamMembers job = new CreateOpportunityTeamMembers();
            job.oppFullList = oppFullList; 
            if(!Test.isRunningTest()){
            System.enqueueJob(job);
            }
        }
    }
    }

}