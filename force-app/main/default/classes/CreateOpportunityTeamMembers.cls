/**
* @Author   :   Jayvardhan Singh
* @Desc :   Create Opp team members
* */
public class CreateOpportunityTeamMembers implements Queueable, Database.AllowsCallouts  {
    public static Boolean skipOpportunityTeamMemberTrigger = false;
    public List<String> oppIds = new List<String>();
    public List<Opportunity> oppList = new List<Opportunity>();
    public List<Opportunity> oppFullList = new List<Opportunity>(); // IBA-3677    
    public Set<Id> accountIds = new Set<Id>();
    private Set<Id> territorySet = new Set<Id>();
    private Map<Id,Set<String>> utMap = new Map<Id,Set<String>>();
    private Map<Id,Set<Id>> accountTerritoryMap = new Map<Id,Set<Id>>();
    private Set<String> roleSet = new Set<String>();
    private Set<String> plroleSet = new Set<String>();
    private Set<String> nacProductRoleSet = new Set<String>();
    private Set<String> productSegmentRoleSet = new Set<String>();
    private String nonAcuteFacilityType = 'Non Acute Care';
    Public String role = ''; //1993
    Public String user = ''; //1993
    private String roleAccountOwner = 'Account Owner';
    private String roleInsideSalesRep = 'Inside Sales Rep';
    private Boolean isNonAcuteFacility = false;
    private Boolean isHavingAccountOwnerRoleWithOwner  = false;
    private Boolean isHavingInsideSalesRep  = false;
    private Boolean isNACSalesRep  = false;
    private Set<String> facilityTypeSet = new Set<String>();
    private Set<String> nacSalesRolesSet = new Set<String>();
    private Set<Id> salesUserIdsToFetchRemovePersons = new Set<Id>();
    @testVisible
    private Id territory2Id;
    public Set<Id> oppOwnerIds = new Set<Id>();
    public Map<id,Boolean> isContainsproductSegmentRoleSet  = new Map<id,Boolean>(); //RJ
    
    public Set<String> getNACSalesRoles(){
        Set<String> salesRoles = new Set<String>();
        salesRoles.add('NAC SD Divisional Manager');
        salesRoles.add('NAC SD Regional Manager');
        salesRoles.add('NAC Business Unit Manager');
        salesRoles.add('NAC Sales Associate');
        salesRoles.add('NAC Sales Consultant');
        return salesRoles;
    }
    
    //start IBA-2359
    static Set<String> consumablesOwnerRoles=new Set<String>{'Consumables Sales Consultant','Consumables Sales Associate',
        'Consumables Strategic Account Director','Market Development and Fortification',
        'Consumables Account Area Representative','Consumables Strategic Account Executive','Consumables - Market Dev'};
    static Set<String> consumablesRoles=new Set<String>{'Consumables Business Unit Manager','Consumables Sales Associate','Consumables Sales Consultant',
                'Consumables Divisional Manager','Consumables Regional Manager','Consumables Strategic Account Director',
                'Market Development and Fortification','Consumables Account Area Representative','Consumables Strategic Account Executive'};
    static Set<String> consumableProducts=new Set<String>{'SingleDose Automation','MultiMed Automation','MA Consumable','Small Machine','MA Consumable'};
    static Set<String> nacFacilityTypes=new Set<String>{'Correctional Facilities','Federally Qualified Health Center','Home Health Hospice',
                            'Other','Pharmacy','Psychiatric Hospital', 'Rehabilitation Hospital', 'Religious Non-Medical Health Care Institution',
                            'Long Term Acute Care Hospital','Renal Dialysis Clinic','Retail Clinic', 'Rural Health Clinic', 'Skilled Nursing Facility',
                            'Urgent Care Clinic','Ambulatory Surgical Center', 'Institutional Pharmacy', 'Oncology Clinic' };
    Map<Id,Boolean> isConsumableFacilityType = new Map<Id,Boolean> ();
    Map<Id,Boolean> isContainsConsumableProdSeg = new Map<Id,Boolean> ();                                                  
    Map<Id,Boolean> isContainsOtherthanConsumableProdSeg = new Map<Id,Boolean> ();//IBA-5966 Sourav
    //end IBA-2359
    
    public void execute(QueueableContext context) {        
        // IBA-3677       
        if(oppFullList.size()>0){
            oppList.add(oppFullList[0]);
            oppexecute();
            oppFullList.remove(0); 
            if(oppFullList.size()>0 || Test.isRunningTest()){
                CreateOpportunityTeamMembers job = new CreateOpportunityTeamMembers();
                job.oppFullList = oppFullList; 
                if(!Test.isRunningTest()){
                    System.enqueueJob(job);
                }
            }
        }
    }
    
    public void oppexecute() { // IBA-3677
        nacSalesRolesSet = getNACSalesRoles();
        productSegmentRoleSet.add('SingleDose Automation');
        productSegmentRoleSet.add('MultiMed Automation');
        productSegmentRoleSet.add('MA Consumable');
        productSegmentRoleSet.add('Core Machine');//Core Machine, SingleDose Automation, MultiMed Automation, MA Consumable
        
        List<NonAcuteCareFacilityType__c> facilityTypeList = NonAcuteCareFacilityType__c.getall().values();
        for(NonAcuteCareFacilityType__c objFacilityType  :facilityTypeList) {
            facilityTypeSet.add(objFacilityType.FacilityType__c);
        }
        Map<String,List<Product_Based_Team_Role__c>> pbRoleSet = new Map<String,List<Product_Based_Team_Role__c>>();
        for(Opportunity opp:oppList){
            oppOwnerIds.add(opp.OwnerId);
            if(opp.AccountId != null && !accountIds.contains(opp.AccountId)){
                accountIds.add(opp.AccountId);
                oppIds.add(opp.Id);
            }
            if(facilityTypeSet.contains(opp.Account.Facility_Type__c)){
                isNonAcuteFacility = true;
            }
            if(nacFacilityTypes.contains(opp.Account.Facility_Type__c)){ //IBA-2359
                isConsumableFacilityType.put(opp.Id,true);
            }
        }
        
        List<OpportunityTeamMember> oppTeamList = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> assoOppTeamList = new List<OpportunityTeamMember>();
        
        List<Profile> assignedProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        for(Quota_Carrying_Team_Role__c role:[Select Id, Name from Quota_Carrying_Team_Role__c ]){
            if(!roleSet.contains(role.Name)){
                roleSet.add(role.Name); 
            }
        }
        
        List<Product_Based_Team_Role__c> pbList;
        for(Product_Based_Team_Role__c pbRole:[Select Id, Name, Portfolio_Segment1__c,Team_Role__c from Product_Based_Team_Role__c LIMIT 5000 ]){
            if(!pbRoleSet.keyset().contains(pbRole.Portfolio_Segment1__c)){
                pbList = new List<Product_Based_Team_Role__c>(); 
                pbList.add(pbRole);
                pbRoleSet.put(pbRole.Portfolio_Segment1__c,pbList);
            }
            else
            {
                pbList = pbRoleSet.get(pbRole.Portfolio_Segment1__c);
                pbList.add(pbRole);
                pbRoleSet.put(pbRole.Portfolio_Segment1__c,pbList);
            }
        } 
        for(Product_Line__c pl:[Select Id,Portfolio_Segment__c,Product_Line_Picklist2__c,Opportunity__c from Product_Line__c
                                where Portfolio_Segment__c!= null and Opportunity__c =:oppIds LIMIT 10000 ]){
                                    //RJ START
                                    if(productSegmentRoleSet.contains(pl.Portfolio_Segment__c) && !(isContainsproductSegmentRoleSet.containsKey(pl.Opportunity__c))) {
                                        isContainsproductSegmentRoleSet.put(pl.Opportunity__c,true);
                                    }
                                    //RJ END
                                    if(pbRoleSet.keyset().contains(pl.Portfolio_Segment__c)){
                                        pbList = pbRoleSet.get(pl.Portfolio_Segment__c);
                                        for (Product_Based_Team_Role__c pbtr : pbList)
                                        {
                                            plroleSet.add(pbtr.Team_Role__c+',-,'+pl.Opportunity__c); 
                                            if(nacProductRoleSet.isEmpty() && productSegmentRoleSet.contains(pl.Portfolio_Segment__c) && isNonAcuteFacility)
                                            {
                                                nacProductRoleSet.addAll(nacSalesRolesSet);
                                            }
                                        }
                                    }
                                    //IBA-2359
                                    if(consumableProducts.contains(pl.Portfolio_Segment__c) && !(isContainsConsumableProdSeg.containsKey(pl.Opportunity__c)))  {
                                        isContainsConsumableProdSeg.put(pl.Opportunity__c,true);
                                    } //end IBA-2359
                                    
                                    if(!consumableProducts.contains(pl.Portfolio_Segment__c) && !(isContainsOtherthanConsumableProdSeg.containsKey(pl.Opportunity__c)))  { //IBA-5966 Sourav
                                        isContainsOtherthanConsumableProdSeg.put(pl.Opportunity__c,true);
                                    } 
                                    
                                }
        
        //populate accountTerritoryMap and territorySet
        getAccountTerritoryMap(accountIds);
        if(territorySet.size() == 0 && !Test.isRunningTest()){ 
            updateFailureReasonOpportunity('No territories on account');
            return;
        }
        if(Test.isRunningTest()){
            territorySet.add(territory2Id);
        }
        List<UserTerritory2Association> userTerrAssList = new List<UserTerritory2Association>();
        //1993
        If((role == null && user == '')||(role == '' && user == '')){
            userTerrAssList = [select User.Name,RoleInTerritory2,UserId,Territory2Id,IsActive
                               from UserTerritory2Association 
                               where Territory2Id in:territorySet and User.IsActive =: true ];            
        }
        else if(role != null && user == '' && role != ''){
            userTerrAssList = [select User.Name,RoleInTerritory2,UserId,Territory2Id,IsActive
                               from UserTerritory2Association 
                               where Territory2Id in:territorySet and User.IsActive =: true and RoleInTerritory2 =: role];              
        } 
        else if((role == null && user != '')||(role == '' && user != '')){
            userTerrAssList = [select User.Name,RoleInTerritory2,UserId,Territory2Id,IsActive
                               from UserTerritory2Association 
                               where Territory2Id in:territorySet and User.IsActive =: true and User.Name =: user];              
        }
        else{
            userTerrAssList = [select User.Name,RoleInTerritory2,UserId,Territory2Id,IsActive
                               from UserTerritory2Association 
                               where Territory2Id in:territorySet and User.IsActive =: true and (RoleInTerritory2 =: role or User.Name =: user)];              
        }
        //1993
        for(UserTerritory2Association uta:userTerrAssList){
            Set<String> userIds = utMap.get(uta.Territory2Id);
            if(userIds!= null && userIds.size() > 0){
                userIds.add(uta.UserId+',-,'+uta.RoleInTerritory2);
            }
            else 
            {
                userIds = new  Set<String>();
                userIds.add(uta.UserId+',-,'+uta.RoleInTerritory2);               
            }            
            utMap.put(uta.Territory2Id, userIds);
        } 
        if(utMap== null || utMap.size() == 0 ){
            updateFailureReasonOpportunity('No user or role assigned in territories');
            return;
        }
        
        Map<String, Opportunity_Team_Members_History__c> oppTeamMembersHistoryRec2InsertMap = new Map<String, Opportunity_Team_Members_History__c>();
        String key = '';
        Boolean skipReturn = false;
        //1993
        if((user == '' && role == null)||(user == '' && role == '')){
            oppTeamList =[Select Id, OpportunityId, UserId, TeamMemberRole,OpportunityAccessLevel,Compensation__c from OpportunityTeamMember where OpportunityId in: oppIds];
        }
        else if((user != '' && role == null)||(user != '' && role == '')){
            oppTeamList =[Select Id, OpportunityId, UserId, TeamMemberRole,OpportunityAccessLevel,Compensation__c from OpportunityTeamMember where OpportunityId in: oppIds and User.name =: user];
        }
        else if(user == '' && role != null && role != ''){
            oppTeamList =[Select Id, OpportunityId, UserId, TeamMemberRole,OpportunityAccessLevel,Compensation__c from OpportunityTeamMember where OpportunityId in: oppIds and TeamMemberRole =: role];
        }
        else{
            oppTeamList =[Select Id, OpportunityId, UserId, TeamMemberRole,OpportunityAccessLevel,Compensation__c from OpportunityTeamMember where OpportunityId in: oppIds and (User.name =: user or TeamMemberRole =: role)];
        }
        //1993
        if(oppTeamList.size() > 0){
            for(OpportunityTeamMember var: oppTeamList){
                key = var.OpportunityId + '~' + var.UserId + '~' + var.TeamMemberRole;
                if(!oppTeamMembersHistoryRec2InsertMap.containsKey(key)){
                    oppTeamMembersHistoryRec2InsertMap.put(key, new Opportunity_Team_Members_History__c(Opportunity__c = var.OpportunityId,
                                                                                                        User__c = var.UserId,
                                                                                                        Team_Role__c = var.TeamMemberRole,
                                                                                                        ParentId__c = var.Id,
                                                                                                        OpportunityAccessLevel__c = var.OpportunityAccessLevel,
                                                                                                        Compensation__c = var.Compensation__c,
                                                                                                        Deleted_Record__c = true));
                }
            }
            try{
                CreateOpportunityTeamMembers.skipOpportunityTeamMemberTrigger = true;
                delete oppTeamList;
                CreateOpportunityTeamMembers.skipOpportunityTeamMemberTrigger = false;
            }
            catch(Exception ex){
                CreateOpportunityTeamMembers.skipOpportunityTeamMemberTrigger = false;
                updateFailureReasonOpportunity('Technical Exception: '+ex.getMessage());
                skipReturn = true;
            }
            
        }
        if(skipReturn){return;} 
        oppTeamList = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> oppTeamMemberList;
        for(Opportunity opp:oppList){
            if(opp.AccountId != null){
                if((user == '' && role == null)||(user == '' && role == '')){  //1993 
                    oppTeamMemberList  = getListofOppTeamMember(opp.AccountId,opp.Id,opp.OwnerId);
                    if(oppTeamMemberList.size() > 0){
                        for(OpportunityTeamMember var: oppTeamMemberList){
                            key = var.OpportunityId + '~' + var.UserId + '~' + var.TeamMemberRole;
                            if(oppTeamMembersHistoryRec2InsertMap.containsKey(key)){
                                oppTeamMembersHistoryRec2InsertMap.remove(key);
                            }
                        }
                        oppTeamList.addAll(oppTeamMemberList);
                    }
                }else{
                    //1993 
                    oppTeamMemberList  = getFilterOppTeamMember(opp.AccountId,opp.Id,opp.OwnerId, userTerrAssList);
                    if(oppTeamMemberList.size() > 0){
                        for(OpportunityTeamMember var: oppTeamMemberList){
                            key = var.OpportunityId + '~' + var.UserId + '~' + var.TeamMemberRole;
                            if(oppTeamMembersHistoryRec2InsertMap.containsKey(key)){
                                oppTeamMembersHistoryRec2InsertMap.remove(key);
                            }
                        }
                        oppTeamList.addAll(oppTeamMemberList);
                    }
                }
            }
        }
        
        if(oppTeamList.size() > 0){
            Database.insert(oppTeamList,false);
            for(Opportunity opp:oppList){
                opp.Update_Opportunity_Team_Status__c = 'Closed';
            }
            OpportunityTriggerHandler.TriggerDisabled = true; //IBA-3471
            update oppList;
        }
        
        List<Opportunity_Team_Members_History__c> oppTeamMemberHistoryList =  [Select Id, Opportunity__c, User__c,Team_Role__c FROM Opportunity_Team_Members_History__c
                                                                               Where Opportunity__c in: oppIds and New_Record__c = false limit 50000];
        if(oppTeamMemberHistoryList.size() > 0){
            for(Opportunity_Team_Members_History__c oppTeamHistory: oppTeamMemberHistoryList){
                key = oppTeamHistory.Opportunity__c + '~' + oppTeamHistory.User__c + '~' + oppTeamHistory.Team_Role__c;
                if(oppTeamMembersHistoryRec2InsertMap.containsKey(key)){
                    oppTeamMembersHistoryRec2InsertMap.remove(key);
                }
            }
            oppTeamList.addAll(oppTeamMemberList);
        }
        
        if(oppTeamMembersHistoryRec2InsertMap.values().size() > 0){
            insert oppTeamMembersHistoryRec2InsertMap.values();
        }
    }
    
    public void updateFailureReasonOpportunity(String failureReason){
        //Since batch size = 1 , only one opportunity will be executed here
        for(Opportunity opp:oppList){
            opp.Update_Opportunity_Team_Failure_Reason__c = failureReason;
        }
        
        update oppList;
    }
    
    private List<OpportunityTeamMember> getListofOppTeamMember(Id accountId, Id oppId, Id ownerId){
        //IBA-4942 - Sourav Start
       Account acc = [Select Id,Territory_Assignment_Criteria__c From Account Where Id = :accountId];
        List<NAC_Health_System_Owned_Opp_Team__c>  allNACOppTeamRole = NAC_Health_System_Owned_Opp_Team__c.getAll().values();
        Set<String> nacOppRole = new Set<String>();
        for(NAC_Health_System_Owned_Opp_Team__c nacOpp: allNACOppTeamRole){
            nacOppRole.add(nacOpp.Role__c);
        }
        Set<String> nacHealthSysOwnerOppUserIds = new Set<String>();
        //IBA-4942 - Sourav End
        Boolean isContainProductSeg = isContainsproductSegmentRoleSet.get(oppId);
        Set<Id> territoryIds = new Set<Id>();
        Set<String> userIdsToRemoveBasedOnOwner = new Set<String>();
        Set<String> userIdsToRemove = new Set<String>();
        Set<String> userIds = new Set<String>();
        Set<String> salesUserIds = new Set<String>();
        Set<String> terrUserIds = new Set<String>();
        Boolean isNACOwner = false;
        String userSFId ='';
        String roleSFId = '';
        String salesRepUserId = '';
        //start IBA-2359
        Boolean isConsumableOpprOwner = false; 
        Set<String> consumablesUserIds = new Set<String>();
        Boolean isOpprAcctOwnerSameUser = false;
        Boolean isConsumablesUser = false;
        Boolean isConsumableProductSeg = false;
        Boolean isConsumableOtherthanProductSeg = false;//IBA-5966 Sourav
        Boolean isConsumableFacility =false;
        Boolean isConsumableAcctAreaRep=false;//IBA-4137
        String consumableAcctAreaOwner='Consumables Account Area Representative';//IBA-4137
        String acctOwnerUserRoleId;
        //end IBA-2359
        if(accountTerritoryMap.get(AccountId) != null){ 
            territoryIds = accountTerritoryMap.get(AccountId);
        }
        List<OpportunityTeamMember> oppTeamList = new List<OpportunityTeamMember>();
        for(Id tId: territoryIds){             
            if(utMap.get(tId) == null){ continue;}
            terrUserIds = utMap.get(tId);  
            if(terrUserIds != null && terrUserIds.size() > 0){
                for(String userandRoleId: terrUserIds){
                    List<String> filterLogicSplittedbyComma = userandRoleId.split(',-,');
                    userSFId = filterLogicSplittedbyComma[0];
                    roleSFId = filterLogicSplittedbyComma[1]; 
                    if(nacSalesRolesSet.contains(roleSFId)){ 
                        salesUserIdsToFetchRemovePersons.add(userSFId);
                        isNACSalesRep = true;
                    } 
                    if(roleSFId == roleInsideSalesRep){
                        isHavingInsideSalesRep = true;
                        salesUserIdsToFetchRemovePersons.add(userSFId);
                        isNACSalesRep = false;
                    } 
                    if(nacSalesRolesSet.contains(roleSFId)){
                        salesUserIds.add(userandRoleId);                    
                    }
                    if(userSFId == ownerId && (nacSalesRolesSet.contains(roleSFId))){
                        isNACOwner = true;
                    }
                    if(userSFId == ownerId && roleSFId == roleAccountOwner){
                        isHavingAccountOwnerRoleWithOwner = true;
                    }                     
                    if(userSFId == ownerId && consumablesOwnerRoles.contains(roleSFId)){ //IBA-2359
                        isConsumableOpprOwner=true;
                    }
                    if(userSFId == ownerId && roleSFId == roleAccountOwner){//IBA-2359
                        isOpprAcctOwnerSameUser=true;
                    }
                    if(consumablesRoles.contains(roleSFId)){//IBA-2359
                        consumablesUserIds.add(userandRoleId);
                        if(roleSFId==consumableAcctAreaOwner){ //IBA-4137
                            isConsumableAcctAreaRep=true;//IBA-4137
                        }
                    }
                    if(roleSFId == roleAccountOwner){//IBA-4137
                        acctOwnerUserRoleId = userandRoleId;
                    }
                    if(nacOppRole.contains(roleSFId)){//IBA-4942 Sourav
                        nacHealthSysOwnerOppUserIds.add(userandRoleId);
                    }
                    userIds.add(userandRoleId);
                }
            }
        }
        //IBA-2359
        if(isConsumableFacilityType.get(oppId)!=null){
            isConsumableFacility =isConsumableFacilityType.get(oppId);
        }
        if(isContainsConsumableProdSeg.get(oppId)!=null){
            isConsumableProductSeg = isContainsConsumableProdSeg.get(oppId);
        }
        if(isContainsOtherthanConsumableProdSeg.get(oppId)!=null){//IBA-5966 Sourav
            isConsumableOtherthanProductSeg = isContainsOtherthanConsumableProdSeg.get(oppId);
        } 
        if(consumablesUserIds.size()>0 && (isConsumableOpprOwner || (isOpprAcctOwnerSameUser && isConsumableFacility 
                && isConsumableProductSeg && !isConsumableOtherthanProductSeg)) ){//IBA-5966 Sourav
            userIds = consumablesUserIds;
            if(isConsumableAcctAreaRep==false){ //IBA-4137
                userIds.add(acctOwnerUserRoleId);//IBA-4137
            }
            isConsumablesUser = true;          
        } //end IBA-2359
        if(salesUserIds.size() > 0 && (isNACOwner == true || (isHavingAccountOwnerRoleWithOwner == true && isContainProductSeg == true)) && nacProductRoleSet.isEmpty()){ //RJ
            userIds = salesUserIds;
        }
        if(oppOwnerIds.size() > 0){
            List<OpportunityTeamExclude__c> oppTeamExcludeBasedOnOwnerList = [select Person_Removed1__c,Person_Removed2__c,Person_Removed3__c,Person_Removed4__c
                                                                              from OpportunityTeamExclude__c 
                                                                              where OpportunityOwner__c in: oppOwnerIds ];
            if(oppTeamExcludeBasedOnOwnerList.size() > 0){
                OpportunityTeamExclude__c oppTeamToRemoveBasedOnOwner  = oppTeamExcludeBasedOnOwnerList[0];
                //userIdsToRemove.add(); 
                if(oppTeamToRemoveBasedOnOwner.Person_Removed1__c != null){
                    userIdsToRemoveBasedOnOwner.add(oppTeamToRemoveBasedOnOwner.Person_Removed1__c);
                }
                if(oppTeamToRemoveBasedOnOwner.Person_Removed2__c != null){
                    userIdsToRemoveBasedOnOwner.add(oppTeamToRemoveBasedOnOwner.Person_Removed2__c);
                }
                if(oppTeamToRemoveBasedOnOwner.Person_Removed3__c != null){
                    userIdsToRemoveBasedOnOwner.add(oppTeamToRemoveBasedOnOwner.Person_Removed3__c);
                }
                if(oppTeamToRemoveBasedOnOwner.Person_Removed4__c != null){
                    userIdsToRemoveBasedOnOwner.add(oppTeamToRemoveBasedOnOwner.Person_Removed4__c);
                }
            }
        }
        if(isHavingInsideSalesRep || isNACSalesRep || Test.isRunningTest()){
            if(Test.isRunningTest()){
                salesUserIdsToFetchRemovePersons.addall(oppOwnerIds);
            }
            List<OpportunityTeamExclude__c> oppTeamExcludeList = [select Person_Removed1__c,Person_Removed2__c,Person_Removed3__c,Person_Removed4__c
                                                                  from OpportunityTeamExclude__c 
                                                                  where Person_Removed__c in: salesUserIdsToFetchRemovePersons ];
            if(oppTeamExcludeList.size() > 0){
                OpportunityTeamExclude__c oppTeamToRemove = oppTeamExcludeList[0];
                if(oppTeamToRemove.Person_Removed1__c != null){
                    userIdsToRemove.add(oppTeamToRemove.Person_Removed1__c);
                }
                if(oppTeamToRemove.Person_Removed2__c != null){
                    userIdsToRemove.add(oppTeamToRemove.Person_Removed2__c);
                }
                if(oppTeamToRemove.Person_Removed3__c != null){
                    userIdsToRemove.add(oppTeamToRemove.Person_Removed3__c);
                }
                if(oppTeamToRemove.Person_Removed4__c != null){
                    userIdsToRemove.add(oppTeamToRemove.Person_Removed4__c);
                }
            }
            
            
        }
        System.debug('***'+userIds);
        //IBA-2359
        if(acc.Territory_Assignment_Criteria__c == 'NAC Health System Owned'){//IBA-4942 - Sourav Start
            for(String userandRoleId: nacHealthSysOwnerOppUserIds){
                if(userandRoleId == null) continue;
                List<String> filterLogicSplittedbyComma = userandRoleId.split(',-,');
                userSFId = filterLogicSplittedbyComma[0];
                roleSFId = filterLogicSplittedbyComma[1];                
                oppTeamList.add(new OpportunityTeamMember(userId = userSFId,opportunityId = oppId,TeamMemberRole = roleSFId));
            }
        }
        else{   //IBA-4942 - Sourav - End
            if (isConsumablesUser && !isConsumableOtherthanProductSeg){ //IBA-5966 Sourav
                for(String userandRoleId: userIds){
                    if(userandRoleId == null) continue;
                    List<String> filterLogicSplittedbyComma = userandRoleId.split(',-,');
                    userSFId = filterLogicSplittedbyComma[0];
                    roleSFId = filterLogicSplittedbyComma[1]; 
                    
                    oppTeamList.add(new OpportunityTeamMember(userId = userSFId,opportunityId = oppId,TeamMemberRole = roleSFId));
                }
            } //end IBA-2359
            else{
                for(String userandRoleId: userIds){
                    system.debug('COUNTUSER-'+userandRoleId);
                    if(userandRoleId == null) continue;
                    List<String> filterLogicSplittedbyComma = userandRoleId.split(',-,');
                    userSFId = filterLogicSplittedbyComma[0];
                    roleSFId = filterLogicSplittedbyComma[1]; 
                    system.debug('ROLE-'+roleSFId);
                    system.debug('USER-'+userSFId);
                    if(nacSalesRolesSet.contains(roleSFId) && !(nacSalesRolesSet.contains(roleSFId) && isNACOwner && isHavingAccountOwnerRoleWithOwner && nacProductRoleSet.contains(roleSFId) && isNonAcuteFacility))
                    {
                        system.debug('rj...inside');
                        if(!(nacSalesRolesSet.contains(roleSFId) && (isNACOwner == true || (isHavingAccountOwnerRoleWithOwner == true && isContainProductSeg == true) ))) 
                        {
                            system.debug('Removed');
                            continue;   
                        }
                        
                    }
                    if(userIdsToRemoveBasedOnOwner.contains(userSFId))
                    {
                        system.debug('Removed');
                        continue; 
                    }
                    if(userIdsToRemove.contains(userSFId)&& (isHavingInsideSalesRep || isNACSalesRep) && isHavingAccountOwnerRoleWithOwner && isNonAcuteFacility)
                    {
                        system.debug('Removed');
                        continue; 
                    }
                    if(roleSet.contains(roleSFId)){
                        system.debug('added');
                        oppTeamList.add(new OpportunityTeamMember(userId = userSFId,opportunityId = oppId,TeamMemberRole = roleSFId)); 
                    }
                    else if(plRoleSet.contains(roleSFId+',-,'+oppId))
                    {
                        system.debug('added');
                        oppTeamList.add(new OpportunityTeamMember(userId = userSFId,opportunityId = oppId,TeamMemberRole = roleSFId));
                    }              
                }
            }
        }
        //Below code to remove opportunity team members
        //IBA-5966 - Sourav Start
        List<OpportunityTeamMember> itemsToKeep = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> itemsToRemove = new List<OpportunityTeamMember>();
        if((acc.Territory_Assignment_Criteria__c != 'NAC Health System Owned' && !isConsumableProductSeg) || (isConsumableProductSeg && isConsumableOtherthanProductSeg)){
            for(OpportunityTeamMember oppTeam :oppTeamList){
                if(!(consumablesRoles.contains(oppTeam.TeamMemberRole))){
                    itemsToKeep.add(oppTeam);
                }
                else{
                    itemsToRemove.add(oppTeam);
                }
            }
        }
        if(!itemsToKeep.isEmpty() || !itemsToRemove.isEmpty()){
            oppTeamList.clear();
            oppTeamList.addAll(itemsToKeep);
        }
        //IBA-5966 - Sourav End
        return oppTeamList;
    }
    @testVisible
    private static List<ObjectTerritory2Association> otaTestList = new List<ObjectTerritory2Association>();
    @testVisible
    private Map<Id,Set<Id>> getAccountTerritoryMap( Set<Id> accountIds){
        territorySet = new Set<Id>();
        accountTerritoryMap = new Map<Id,Set<Id>>();
        Map<Id,Territory2Model> modelMap = new Map<Id,Territory2Model>([Select Id from Territory2Model where State = 'Active']);
        List<ObjectTerritory2Association> otaList = [Select ObjectId, Territory2Id, Territory2.Territory2Type.Priority from ObjectTerritory2Association
                                                     where objectId IN :accountIds and Territory2.Territory2ModelId = :modelMap.keySet()];
        if(Test.isRunningTest()){
            modelMap = new Map<Id,Territory2Model>([Select Id from Territory2Model LIMIT 1]);
            otaList = otaTestList;
        }
        Set<Id> territoryIds ;
        for(ObjectTerritory2Association ota: otaList){                                                  
            territoryIds = accountTerritoryMap.get(ota.ObjectId);
            if(!territorySet.contains(ota.Territory2Id)){
                territorySet.add(ota.Territory2Id);
            }
            if(territoryIds!= null && territoryIds.size() > 0){
                territoryIds.add(ota.Territory2Id);
            }
            else {
                territoryIds = new  Set<Id>();
                territoryIds.add(ota.Territory2Id);                
            }            
            accountTerritoryMap.put(ota.ObjectId, territoryIds);
        }
        return accountTerritoryMap;
    }
    
    private List<OpportunityTeamMember> getFilterOppTeamMember(Id accountId, Id oppId, Id ownerId, List<UserTerritory2Association> territoryUser){
        List<OpportunityTeamMember> opportunityTeamToUpdate = new List<OpportunityTeamMember>();
        
        for(UserTerritory2Association tUser: territoryUser){
            opportunityTeamToUpdate.add(new OpportunityTeamMember(userId = tUser.UserId,opportunityId = oppId,TeamMemberRole = tUser.RoleInTerritory2));
        }
        return opportunityTeamToUpdate;
    }
    
}