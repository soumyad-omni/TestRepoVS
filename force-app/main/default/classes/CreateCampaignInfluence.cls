public class CreateCampaignInfluence   {
    
    public List<Id> oppIds = new List<Id>();
    
    
    private static CampaignInfluence setCampaignInfluenceFields(Id campaignId,Id camInfluenceModelId, Id contactId, Id oppId,
                                                         Decimal revenueShare, Integer influence)
    {
        CampaignInfluence ci = new CampaignInfluence();
        ci.CampaignId = campaignId;
        ci.ModelId = camInfluenceModelId;
        ci.ContactId = contactId;
        ci.OpportunityId = oppId;
       // ci.Custom_Revenue_Share__c = revenueShare;
        ci.Influence = influence;
        return ci;
    }
    
     public static Map<String,CampaignInfluence> getCampaignInfluenceMapBasedOnOpportunity(String oppId) {
        Map<String,CampaignInfluence> camInfluenceMap = new Map<String,CampaignInfluence>();
        List<CampaignInfluence> camInfluenceList =  getCampaignInfluenceBasedOnOpportunity(oppId);
        String key = '';
        if(camInfluenceList.size() > 0)
        {
            for (CampaignInfluence ci: camInfluenceList)
            { 
               
              key = ci.CampaignId+'-'+ci.ContactId+'-' +ci.ModelId;
                system.debug('key'+key);
              camInfluenceMap.put(key,ci);
            }            
        }       
        return camInfluenceMap;         
    }

    
    public static List<CampaignInfluence> getCampaignInfluenceBasedOnOpportunity(String oppId) {
        List<CampaignInfluence> camInfluenceList = new List<CampaignInfluence>();
        Id modelId = null;
        List<CampaignInfluenceModel> camInfluenceModelList = [SELECT id, MasterLabel from CampaignInfluenceModel 
                                         WHERE MasterLabel = 'Omnicell Model'];
        CampaignInfluenceModel camInfluenceModel;
        if(camInfluenceModelList.size() > 0)
        {
          camInfluenceModel = camInfluenceModelList[0] ;
          modelId = camInfluenceModel.Id;
          camInfluenceList = [Select Id,CampaignId,ModelId,ContactId from CampaignInfluence WHERE OpportunityId =: OppId and ModelId =:modelId];         
        }
        return camInfluenceList;         
    }
    
    public static void deleteCampaignInfluences(String oppId) {
        List<CampaignInfluence> camInfluenceList = getCampaignInfluenceBasedOnOpportunity(oppId);
        if(camInfluenceList.size() > 0)
        { delete camInfluenceList; }         
    }
    
    public static void addCampaignInfluences(String oppId) {
        List<Opportunity> oppList = new List<Opportunity>(); 
        CampaignInfluenceModel camInfluenceModel;
        Set<Id> oppIds = new Set<Id>();
        Set<String> statusSet = new Set<String>();
        Set<Id> contactIdSet = new Set<Id>();
       // String oppId ='0061N00000gNwygQAC';
        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
        List<CampaignMember> cmList = new List<CampaignMember>();
        Map<Id,Set<Id>> oppContactSet = new Map<Id,Set<Id>>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        List<CampaignInfluenceModel> camInfluenceModelList = new List<CampaignInfluenceModel>();
        List<CampaignInfluence> camInfluenceList = new List<CampaignInfluence>();
        oppList = [SELECT id, Createddate, Expected_Bookings_Real__c, Name FROM Opportunity WHERE Id =: oppId ] ;
        for(Opportunity opp : oppList )
        {
            oppIds.add(opp.Id);
            oppMap.put(opp.Id,opp);
        }
        ocrList = [SELECT id, ContactId, Role, OpportunityId FROM OpportunityContactRole WHERE OpportunityID in: oppIds ];
        for(OpportunityContactRole ocr : ocrList )
        {
            contactIdSet.add(ocr.ContactId);
            Set<Id> oppIdSet = new Set<Id>();
            if(oppContactSet.get(ocr.ContactId)!= null)
            {
               oppIdSet = oppContactSet.get(ocr.ContactId); 
            }            
            oppIdSet.add(ocr.OpportunityId);
            oppContactSet.put(ocr.ContactId,oppIdSet);
        }
        cmList = [Select Id, CampaignId, ContactId, Campaign.Name, Campaign.StartDate FROM CampaignMember 
                         WHERE ContactId in: contactIdSet and Campaign.StartDate != null];        
        camInfluenceModelList = [SELECT id, MasterLabel from CampaignInfluenceModel 
                                         WHERE MasterLabel = 'Omnicell Model'];
        if(camInfluenceModelList.size() > 0)
        {
          camInfluenceModel = camInfluenceModelList[0] ;
        }
        
        Map<String,CampaignInfluence> camInfluenceMap = getCampaignInfluenceMapBasedOnOpportunity(oppId);
        for(CampaignMember cm : cmList )
        {
            Set<Id> oppValueSet = new Set<Id>();
            oppValueSet = oppContactSet.get(cm.ContactId);
            for(Id oppIdValue : oppValueSet )
            {
                Date oppCreatedDate = oppMap.get(oppIdValue).createddate.Date();
                Date campaignStartDate = cm.Campaign.StartDate;
                Integer months = oppCreatedDate.monthsBetween(campaignStartDate);
                Integer influence = 0;
                Decimal revenueShare = 0;
                if(months < 12 && months > -12)
                {
                    if(campaignStartDate <= oppCreatedDate)
                    {
                        influence = 100;
                        if(oppMap.get(oppIdValue).Expected_Bookings_Real__c != null)
                         revenueShare = oppMap.get(oppIdValue).Expected_Bookings_Real__c;
                    }
                    else
                    {
                        influence = 10; 
                        if(oppMap.get(oppIdValue).Expected_Bookings_Real__c != null && oppMap.get(oppIdValue).Expected_Bookings_Real__c > 0)
                         revenueShare = oppMap.get(oppIdValue).Expected_Bookings_Real__c/10;
                    }
                    CampaignInfluence ci = setCampaignInfluenceFields(cm.campaignId,camInfluenceModel.Id,cm.contactId,oppIdValue,
                                                         revenueShare, influence);
                    if(camInfluenceMap.size() == 0 || camInfluenceMap.get(ci.CampaignId+'-'+ci.ContactId+'-' +ci.ModelId) == null)
                    {
                          system.debug('key1'+ci.CampaignId+'-'+ci.ContactId+'-' +ci.ModelId);
                          camInfluenceList.add(ci);
                    } 
                }
               
            }
                   
        }
        system.debug('camInfluenceListSize'+camInfluenceList.size());
        if(camInfluenceList.size() > 0)
        {Database.insert(camInfluenceList);}
      
    }
}