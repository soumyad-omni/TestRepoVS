global class RunAccountTerritoryController {
   
    @AuraEnabled
    global static Boolean updateTerritory(string accountId){
        Boolean retVal = true;
        List<Profile> assignedProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        system.debug(assignedProfile[0].Name);
        system.debug(assignedProfile[0].Id);
        if(!Test.isRunningTest() && assignedProfile.size()> 0 && assignedProfile[0].Name != 'System Administrator' 
           && assignedProfile[0].Name != 'Business Administrator' && assignedProfile[0].Name != 'International Sales Ops' && assignedProfile[0].Name != 'Booking Team')
        {  return retVal;}
        
        retVal = false;   
        RunAccountTerritoryRules job = new RunAccountTerritoryRules() ;
        job.accntIds = new Set<String>{accountId}; 
        System.enqueueJob(job);
        return retVal;
    }
}