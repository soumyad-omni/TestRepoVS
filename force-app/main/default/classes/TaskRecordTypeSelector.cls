public with sharing class TaskRecordTypeSelector {
    /*
* This function will fetch the RecordTypes of
* provided object and will return a map of
* recordTypeId and recordTypeNames
* it excludes 'master' record type
* */
    public static Map<Id, String> recordtypemap;
  
    @AuraEnabled        
    public static Map<Id, String> fetchRecordTypeValues(String objectName){
        List<Schema.RecordTypeInfo> recordtypes = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfos(); 
        system.debug('recordtypemap'+recordtypemap);
        recordtypemap = new Map<Id, String>();
       
          Id profileid = userInfo.getProfileId();
        
        list<Profile> profilenames = [Select Id,Name from Profile where Id =: profileid ];
        for(RecordTypeInfo rt : recordtypes){
            boolean flag = true;
            if(objectName == 'Task'){ //IBA-4971 - Start
                if(rt.isAvailable() && rt.getName() !='Master'){
                    recordtypemap.put(rt.getRecordTypeId(), rt.getName());
                }
            }									
            else{							//IBA-4971 - End
            for(Profile p:profilenames){
                
              //commented for IBA-3127
                if((p.Name == System.Label.InternationalSalesOps || p.Name == System.Label.InternationalSalesFrance || p.Name == System.Label.InternationalSalesRepresentative) && (rt.getName() !='Customer Experience' && rt.getName() !='Sales-NA' && rt.getName() !='Sales-International' && rt.getName() !='Master' && rt.getName().trim() != '')){   
                    recordtypemap.put(rt.getRecordTypeId(), rt.getName());
                    system.debug('record type : ' + rt.getName() + 'profile name :' + p.Name);
                    flag = false;
                    
                }            
               else if((p.Name == System.Label.BookingTeam || p.Name == System.Label.Consultant  || p.Name == System.Label.CreditsandCollection 
                                                 || p.Name ==  System.Label.DealDeskandLegal || p.Name == System.Label.Revenue
                                                 || p.Name == System.Label.SalesDevelopment || p.Name == System.Label.SalesManager
                                                 || p.Name == System.Label.SalesRepresentative ) && (rt.getName() !='Customer Experience' && rt.getName() !='Sales-International' && rt.getName() !='Sales-International' && rt.getName() !='International Sales Objectives' && rt.getName() !='Master' && rt.getName().trim() != '' ))
                {  
                    recordtypemap.put(rt.getRecordTypeId(), rt.getName());
                    
                }
                
                else if((p.Name == System.Label.CustomerSupportUK || p.Name == System.Label.InternationalSalesUK ) && (rt.getName() !='Customer Experience' && rt.getName() !='Sales-NA' && rt.getName() !='Sales-International' && rt.getName() !='Master' && rt.getName().trim() != ''))
                {
                   
                    recordtypemap.put(rt.getRecordTypeId(), rt.getName());
                    
                }
               else if((p.Name == System.Label.BusinessAdministrator || p.Name == System.Label.SystemAdministrator || p.Name == System.Label.Marketing || p.Name == System.Label.MarketingIntelligence || p.Name == System.Label.MarketingIntelligenceEMEA || p.Name == System.Label.MarketingUser ) && rt.getName() !='Master' && rt.getName().trim() != ''){
                   
                    recordtypemap.put(rt.getRecordTypeId(), rt.getName());
                }
                else if(p.Name == System.Label.TAMS && rt.getName() !='Sales-International' && rt.getName() !='Sales-NA' && rt.getName() !='International Sales Objectives'   && rt.getName() !='Master' && rt.getName().trim() != ''){
                    
                    recordtypemap.put(rt.getRecordTypeId(), rt.getName());
                }
               
                
                }
            }
            
            
        }
          return recordtypemap;
    }
}