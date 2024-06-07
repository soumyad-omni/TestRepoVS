public class TerritoryUtility {
    
    public static List<AccountTeamMember> populateAccountTeamMemberList(List<Id> accids)
    {
        List<AccountTeamMember> atmList = new List<AccountTeamMember>();
        Map<Id,UserTerritory2Association> utMap = new Map<Id,UserTerritory2Association>();
		Set<Id> territorySet = new Set<Id>();
        Map<Id,Set<Id>> accountTerritoryMap = new Map<Id,Set<Id>>();
        Set<Id> territoryIds;
         for(ObjectTerritory2Association ota:[Select ObjectId, Territory2Id, Territory2.Territory2Type.Priority 
                                              FROM ObjectTerritory2Association
                                              where objectId IN :accIds ]){
            territoryIds = accountTerritoryMap.get(ota.ObjectId);
            if(!territorySet.contains(ota.Territory2Id))
            {
                territorySet.add(ota.Territory2Id);
            }
            if(territoryIds!= null && territoryIds.size() > 0){
                territoryIds.add(ota.Territory2Id);
            }
            else 
            {
                territoryIds = new  Set<Id>();
                territoryIds.add(ota.Territory2Id);                
            }  
             accountTerritoryMap.put(ota.ObjectId, territoryIds);                                                  
        }
        if(territorySet.size() == 0 )
          return atmList;      
	    territoryIds= new Set<Id>();
     
        for(UserTerritory2Association uta: [Select User.Name,RoleInTerritory2,UserId,Territory2Id,IsActive
                                                             from UserTerritory2Association 
                                                             where Territory2Id in:territorySet and User.IsActive =: true ]){
             for (Id acctId: accids)
             {
                   territoryIds = accountTerritoryMap.get(acctId);
                   if(territoryIds!= null && territoryIds.size()>0 && territoryIds.contains(uta.Territory2Id))
                   {
                       AccountTeamMember atm = new AccountTeamMember();   
                       atm.TeamMemberRole = uta.RoleInTerritory2;
                       atm.AccountId = acctId;
                       atm.UserId = uta.UserId;
                       atmList.add(atm);
                       system.debug('Role'+atm.TeamMemberRole);
                   }
             }
	    } 
        
      return atmList;
    }
	//IBA-3993 Change Start
  /*public static void populateExchangeRate(Opportunity opportunityRecord)
    {
        Date exchangeDate = date.today();
        Map<String, DatedConversionRate> currency2DatedConversionRateMap = new Map<String, DatedConversionRate>();
        Set<String> currencyCodeSet = new Set<String>();
        if(opportunityRecord.CloseDate != null && exchangeDate > opportunityRecord.CloseDate)
        {
           exchangeDate = opportunityRecord.CloseDate; 
        }        
        if(opportunityRecord.CurrencyIsoCode != 'USD')
        {
            currencyCodeSet.add(opportunityRecord.CurrencyIsoCode);           
            List<DatedConversionRate> dcrList = [SELECT ConversionRate,IsoCode,NextStartDate,StartDate FROM DatedConversionRate
                                                  WHERE IsoCode IN :currencyCodeSet 
                                                  AND NextStartDate > :exchangeDate AND StartDate <= :exchangeDate
                                                 LIMIT 1];
            
            if(dcrList.size() > 0)                                    
            {
                opportunityRecord.Exchange_Rate__c = dcrList[0].ConversionRate;
            }
        }
        else
        {
            opportunityRecord.Exchange_Rate__c = 1;
        }        
        
    } */
    public static void updateOpportunityExchangeRate (Opportunity opportunityRecord) {
        Set<String> currencyCodeSet = new Set<String>();
        if (opportunityRecord.CurrencyIsoCode != 'USD') {
            currencyCodeSet.add(opportunityRecord.CurrencyIsoCode);
            List<Currency_Exchange_Rate__c> exchangeRateList = [SELECT M1_Exchange_Rate__c, Status__c
                                                                FROM Currency_Exchange_Rate__c
                                                                WHERE CurrencyIsoCode = :opportunityRecord.CurrencyIsoCode
                                                                AND Status__c = 'Active'
                                                                LIMIT 1];
            if (!exchangeRateList.isEmpty()) {
                opportunityRecord.Exchange_Rate__c = exchangeRateList[0].M1_Exchange_Rate__c;
            }
        } else {
            opportunityRecord.Exchange_Rate__c = 1;
        }
    }
    //IBA-3993 Change End
    //IBA-1774
    public static void populateBookedExchangeRate(Opportunity opportunityRecord)
    	{
        Date exchangeDate = date.today();
        Map<String, DatedConversionRate> currency2DatedConversionRateMap = new Map<String, DatedConversionRate>();
        Set<String> currencyCodeSet = new Set<String>();
              
        if(opportunityRecord.CurrencyIsoCode != 'USD')
        {
            currencyCodeSet.add(opportunityRecord.CurrencyIsoCode);           
            List<DatedConversionRate> dcrList = [SELECT ConversionRate,IsoCode,NextStartDate,StartDate FROM DatedConversionRate
                                                  WHERE IsoCode IN :currencyCodeSet 
                                                  AND NextStartDate > :exchangeDate AND StartDate <= :exchangeDate
                                                 LIMIT 1];
            
            if(dcrList.size() > 0)                                    
            {
                opportunityRecord.Forecast_Booked_Exchange_Rate__c = dcrList[0].ConversionRate;
            }
        }
        else
        {
            opportunityRecord.Forecast_Booked_Exchange_Rate__c = 1;
        }        
        
    }

}