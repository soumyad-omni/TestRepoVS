global class LeanDataCustomInterface extends LeanData.CustomInterface {
	public Id territoryId;
    public Id ownerId;    
    global override Map<String, List<String>> getMapOfCustomInterfaceNodeNamesToEdges(){
        Map<String, List<String>> customInterfaceMap = new Map<String, List<String>>();
        customInterfaceMap.put('Route to ETM Territory', new List<String>{'Next Node','Inactive Owner','No Territory Found'});
        
        return customInterfaceMap;
    }
    
    global override Map<String,Object> additionalParametersMap() {
        Map<String,Object> additionalParameters = new Map<String,Object>();
        
        additionalParameters.put('Route to ETM Territory', new List<String>{'Role'});
        
        return additionalParameters;
    }
    
    global override String customRoutingRule(SObject primary, Map<String, SObject> chosenSObjects, String parameter, Map<String, Object> additionalParameters) {
        Lead primaryLead;
        Contact primaryContact;
        
        if(primary.getSObjectType() == Lead.sObjectType){
            primaryLead = (Lead)primary;
        } else {
            primaryContact = (Contact) primary;
        }
        
        if(parameter == 'Route to ETM Territory'){
            Id primaryAccountId;
            
            //uses L2A match node result for Lead Routing
            if(primaryLead != null && chosenSObjects.get('L2A') != null){
                Account acc = (Account) chosenSObjects.get('L2A');
                primaryAccountId = acc.Id;
            } else {
                if(primaryContact.AccountId != null) {
                   primaryAccountId = primaryContact.AccountId; 
                } else {
                    return 'No Territory Found';
                }
            }
            
            String role;
            Set<String> roleSet = new Set<String>();
            if(additionalParameters.get('Role') != null) role = (String)additionalParameters.get('Role');
            
            
            if(role.contains(',')){
                roleSet.addAll(role.split(','));
            }else{
                roleSet.add(role);
            }
            
            // get active territory2 model
            List<Territory2Model> tmList = [Select Id From Territory2Model Where State = 'Active'];
            
            // get active territory2 model
            List<Territory2> allTerritories = [Select Id From Territory2 Where Territory2ModelId IN :tmList];
            
            // get active territory2 associated with the above model
            List<ObjectTerritory2Association> objectTerritory2AssociationList = [SELECT Id, 
                                                                                 Territory2Id 
                                                                                 FROM ObjectTerritory2Association 
                                                                                 WHERE ObjectId = :primaryAccountId
                                                                                 AND Territory2Id IN :allTerritories
                                                                                 AND Territory2.Territory2Model.State = 'Active'];
            //Query from most recent one. or looping through list to find most recent territory which is active
            List<Id> terrorityIds = new List<Id>();
            
            // get related territories for the given account
            for(ObjectTerritory2Association objTerr2 : objectTerritory2AssociationList){
                terrorityIds.add(objTerr2.Territory2Id);
            }
            
            List<UserTerritory2Association> userTerritoryList = [Select Id, 
                                                                 UserId, 
                                                                 User.IsActive, 
                                                                 RoleInTerritory2 
                                                                 FROM UserTerritory2Association 
                                                                 WHERE Territory2Id IN :terrorityIds 
                                                                 AND RoleInTerritory2 IN :roleSet
                                                                 AND User.IsActive = true];
            
            Boolean hasInactive = FALSE;
            Id foundOwnerId;
            
            for(UserTerritory2Association userTerr : userTerritoryList){
                if(userTerr.User.IsActive){
                    foundOwnerId = userTerr.UserId;
                    ownerId = foundOwnerId;
                    territoryId = userTerr.Id;
                } else {
                    hasInactive = TRUE;
                }
            }
            
            if(foundOwnerId != null){
                
                if(primaryLead != null) {
                    primaryLead.OwnerId = foundOwnerId;
                } else if(primaryContact != null) {
                    //primaryContact.OwnerId = foundOwnerId; //commented as part of IBA-4067 & IBA-3316
                    primaryContact.SDR_ISR_Owner__c = foundOwnerId; // added as part of IBA-4067 & IBA-3316
                } 
                
                return 'Next Node';
            } else if(hasInactive == TRUE){
                return 'Inactive Owner';
            } else {
                return 'No Territory Found';
            }
        }
        
        return 'invalid parameter';
    }
    
    global override Map<String, Map<String, Object>> customInterfaceLogMap() {
        Map<String, Map<String, Object>> logMap = new Map<String, Map<String, Object>>();
        Map<String, Object> valueMap1 = new Map<String, Object>();
        valueMap1.put('Territory', territoryId);
        valueMap1.put('Territory Owner', ownerId);
        logMap.put('Route to ETM Territory', valueMap1);
        return logMap;
	}

}