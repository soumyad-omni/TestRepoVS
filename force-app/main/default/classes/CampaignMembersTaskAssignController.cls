// CampaignMembersTaskAssignController
// This is the handler for the Campaign Members Task Assign page for the Campaign
// -----------------------------------------------------------------------------------------------------------
//  Author              Date            Description
//  jszurley            ?               Creation
//  CG team            06/12/2018       Added Task_Assigned__c,Product_Opportunity__c in SOQL query as part of Sprint 1
//  CG team            07/02/2018       Added logic for attachment to task as part of sprint-2,W-000081  
//  Haripriya Maturi   07/11/2018       Added methods for to add values to the Filter dynamically as part of Sprint 3, W-000778
//  Haripriya Maturi   10/05/2018       Implemented W-000521, W-000778 as part of Sprint 6
public class CampaignMembersTaskAssignController {
    
    // Variables
    public Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    public Map <String, Map<String, Schema.SObjectField>> mapSchemaFields {get;set;} 
    
    public List<String> lstFilters {get;set;}
    public Map<Id, Id> mapSelectedCampaignMembers {get;set;}
    
    public Map <Id, Id> mapOwnerIds = new Map<Id, Id>();
    public Map <Id, Id> mapCGroupContactIds = new Map<Id, Id>();
    public Map <Id, Id> mapLGroupLeadIds = new Map<Id, Id>();
    public List<Id> lstLeadIds = new List<Id>();
    public List<Id> lstContactIds = new List<Id>();
    public List<Id> lstCGroupIds = new List<Id>();
    public List<Id> lstLGroupIds = new List<Id>();
    private Integer offsetSize = 0;
    private Integer limitSize = 10;
    private Integer counter = 0;
    private Integer limit60 = 60;
    public Boolean hasNextRecords {get;set;}
    public Boolean hasPrevRecords {get;set;}
    public String countTotal {get;set;}
    public Integer totalSize {get;set;}
    
    public List<AccountTeamMember> atm = new List<AccountTeamMember>();
    Map<Id,List<AccountTeamMember>> ateammap = new Map<Id,List<AccountTeamMember>>();//Added by sravan for SF-BUG-778 23 JAN
    
    public CampaignMembersWrapper cmwrap{get;set;}
    public CampaignMembersWrapper cmwrap_toAddALl{get;set;}
    //
    public List<CampaignMembersWrapper> lstCampaignMembers {get;set;}
    public List<CampaignMembersWrapper> lstAllCampaignMembers {get;set;}
    // 
    public List<CampaignMembersWrapper> selectedCampaignMembers {
        get {
            if (selectedCampaignMembers == null) selectedCampaignMembers = new List<CampaignMembersWrapper>();
            return selectedCampaignMembers;
        }
        set;
    }      
    
    public Map<Id,CampaignMembersWrapper> removeUnSelCampaignMembersMap = new Map<Id,CampaignMembersWrapper>();
    public Map<Id,CampaignMembersWrapper> removeUnSelCampaignMembersMap1 = new Map<Id,CampaignMembersWrapper>();
    //
    public Id checkBoxId {get;set;}
    //
    public List<Task> lstNewTasks = new List<Task>();
    public List<CampaignMember> lstSelCMs = new List<CampaignMember>();
    //
    public Map <Id, Id> mapQueues = new Map<Id, Id>();
    public String selAcctOwnerName {get;set;}
    public String selMemberType {get;set;}
    public String selAssignedTo {get;set;}
    //
    public List<String> filterResults = new List<String>(); 
    
    public Task t = new Task();
    public Task getProxyObject() { return t;}
    
    // For Avail to Select Lists
    
    private Set<String> selectedFields;
    public Integer intSelectedCount;
    
    public Set<String> lstResultFields = new Set<String>();
    
    public Integer cntCMs {get;set;}
    public Id theCampaignId {get;set;}
    public String theCampaignName {get;set;}
    
    public string soql {get;set;}
    
    //Project Aloha - Sprint 3
    public String selectedJobTitle{get;set;}
    public List<String> jobTitleList = new List<String>();
    public String jobTitleCondition = '';
    
    public String selectedLeadClassification{get;set;}
    
    public String selectedProductOpportunity{get;set;}
    public List<String> prodOppList = new List<String>();
    public string condition = '';
    
    public String selMemberstat{get;set;}
    public String selFollowUpField{get;set;}
    public Boolean selFollowUpTask{get;set;}
    
    public Map<Id,CampaignMembersWrapper> campIdMemberMap = new Map<Id,CampaignMembersWrapper>();
    public Boolean isAddAll=false;
    
    public Boolean isFirstLoad=false;
    //public Set<String> memStatusSet = new Set<String>();
    public List<String> memStatusList = new List<String>();
    
    //public Set<String> classificSet = new Set<String>();
    //public List<String> classificList = new List<String>();
    
    // Custom data structures
    /*public class Selected_Results {
// 
public String objectName {get;set;}
public String fieldName {get;set;}
public String displayName {get;set;}
}*/
    
    // =============================================================
    // GETTERS & SETTERS
    // =============================================================
    
    //
    //this method to get values into Member Type Filter 
    public List<SelectOption> getAssignToValues() {
        List<SelectOption> options = new List<SelectOption>();
        Map<String,Acct_Team_Roles_for_Followup_Task__c> teamRoles = Acct_Team_Roles_for_Followup_Task__c.getAll();
        options.add(new SelectOption('','--Select One--'));
        for(String tr: teamRoles.keySet()) { 
            options.add(new SelectOption(tr,tr));
        }
        return options;
    }
    
    //this method to get values into Assign To Filter 
    public List<SelectOption> getMemberStatusValues() {
        List<SelectOption> memStstValues = new List<SelectOption>();
        //List<RecordType> campRecTypes = [select Id,name From RecordType where sobjecttype = 'Campaign' and name in ('Contact','Lead')];
        //Schema.DescribeFieldResult fieldResult = CampaignMember.Status.getDescribe();
        //List<Schema.PicklistEntry> ms = fieldResult.getPicklistValues();
        memStatusList.clear();
        List<CampaignMemberStatus> cmstatus = [SELECT Id, CampaignId, Label FROM CampaignMemberStatus where CampaignId =: theCampaignId];
        if(cmstatus.size()>0){
            for(CampaignMemberStatus cms: cmstatus){
                memStatusList.add(cms.Label);
            }
        }
        
        memStstValues.add(new SelectOption('','--Select One--'));
        if(memStatusList.size()>0){
            // System.Debug('memStatusList : '+memStatusList);
            for(String f : memStatusList) { memStstValues.add(new SelectOption(f,f));
                                          }
        }
        
        return memStstValues;
    }
    
    //this method to get values into Assign To Filter 
    public List<SelectOption> getMemberTypeValues() {
        List<SelectOption> options = new List<SelectOption>();
        List<RecordType> campRecTypes = [select Id,name From RecordType where sobjecttype = 'Campaign' and name in ('Contact','Lead')];
        
        options.add(new SelectOption('','--Select One--'));
        for(RecordType rt: campRecTypes) { options.add(new SelectOption(rt.name,rt.name));
                                         }
        return options;
    }
    
    //this method to get values into Omnicell Job Title     
    public List<SelectOption> getOmnicellJobTitleValues(){
        try{
            List<SelectOption> jobTitles = new List<Selectoption>();
            Schema.DescribeFieldResult fieldResult = Contact.Omnicell_Job_Code__c.getDescribe();
            List<Schema.PicklistEntry> jt = fieldResult.getPicklistValues();
            jobTitles.add(new SelectOption('','--Select One--'));
            for(Schema.PicklistEntry f : jt){
                //   System.Debug('f.getLabel() : '+f.getLabel());
                //   System.Debug('f.getValue() : '+f.getValue());
                jobTitles.add(new SelectOption('\''+f.getLabel()+'\'', f.getLabel()));
            }      
            return jobTitles;
        }catch(Exception e){
            //System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
            ErrorLogging.Log(e, 'CampaignMembersTaskAssignController','App');
            return null;
        }
    }
    
    //this method to get values into Lead Classification     
    public List<SelectOption> getLeadClassificationValues(){
        try{
            List<SelectOption> leadClassification = new List<Selectoption>();
            Schema.DescribeFieldResult fieldResult = CampaignMember.Lead_Classification__c.getDescribe();
            List<Schema.PicklistEntry> lc = fieldResult.getPicklistValues();
            leadClassification.add(new SelectOption('','--Select One--'));
            //System.debug('classificList :'+classificList);
            if(lc.size()>0 || lc != NUll || !lc.isEmpty()){
                for(Schema.PicklistEntry f : lc){
                    leadClassification.add(new SelectOption(f.getLabel(), f.getLabel()));
                }    
            }
            return leadClassification;
        }catch(Exception e){
            //  System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
            ErrorLogging.Log(e, 'CampaignMembersTaskAssignController','App');
            return null;
        }
    }
    
    //this method to get values into Product Opportunity     
    public List<SelectOption> getProductOpportunityValues(){
        try{
            List<SelectOption> prodOpp = new List<Selectoption>();
            Schema.DescribeFieldResult fieldResult = CampaignMember.Product_Opportunity__c.getDescribe();
            List<Schema.PicklistEntry> po = fieldResult.getPicklistValues();
            prodOpp.add(new SelectOption('','--Select One--'));
            for(Schema.PicklistEntry f : po){
                prodOpp.add(new SelectOption(f.getLabel(), f.getValue()));
            }      
            return prodOpp;
        }catch(Exception e){
            //System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
            ErrorLogging.Log(e, 'CampaignMembersTaskAssignController','App');
            return null;
        }
    } 
    
    public void addSelectedMemberToList() {
        List<Id> lstIds = new List<Id>();
        Id theParentId;
        
        try{
            for (CampaignMembersWrapper cmw : lstCampaignMembers) {
                //System.Debug('In selection::: Checked :'+cmw.checked+' cmw acct owner : '+cmw.acctOwner+' '+'cmw cm id : '+cmw.cm.id);
                if (cmw.checked && !campIdMemberMap.containsKey(cmw.cm.id)) {
                    selectedCampaignMembers.add(new CampaignMembersWrapper(cmw.cm));
                    campIdMemberMap.put(cmw.cm.id,cmw);
                    removeUnSelCampaignMembersMap1.put(cmw.cm.id,(new CampaignMembersWrapper(cmw.cm)));
                    lstIds.add(cmw.cm.id);
                    //theParentId = cmw.cm.parentId;
                }if(!cmw.checked && campIdMemberMap.containsKey(cmw.cm.id)){
                    removeUnSelCampaignMembersMap.put(cmw.cm.id,(new CampaignMembersWrapper(cmw.cm)));
                }
            }
            //System.Debug('campIdMemberMap :: '+campIdMemberMap);
            //  System.debug('selectedCampaignMembers are :: '+selectedCampaignMembers);
            //System.debug('unchecked cmp members :: '+removeUnSelCampaignMembersMap);
        }catch(Exception e){
            System.debug('exception e : '+e.getMessage());
            //  System.debug('at Line No. : '+e.getLineNumber());
        }
    }
    
    public List<CampaignMembersWrapper> getDisplayList() {
        if(!isAddAll){
            //lstNewTasks.clear();
            if(removeUnSelCampaignMembersMap.size()>0){
                //selectedCampaignMembers.removeAll(removeSelectedCampaignMembers);
                for(Id wrapId : removeUnSelCampaignMembersMap.keySet()){
                    removeUnSelCampaignMembersMap1.remove(wrapId);
                }
            }
            //System.Debug('before clearing'+selectedCampaignMembers);
            selectedCampaignMembers.clear();
            //System.Debug('after clearing'+selectedCampaignMembers);
            selectedCampaignMembers.addAll(removeUnSelCampaignMembersMap1.values());
            //System.Debug('after removing unchecked'+selectedCampaignMembers);
        }
        if (selectedCampaignMembers.size() > 0) {
            
            return selectedCampaignMembers;
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.No_Campaign_Member_Selected));
            return null;
        }
    }
    
    //
    public List<SelectOption> getResponseStatus() {
        //
        List<SelectOption> options = new List<SelectOption>();
        //
        options.add(new SelectOption('','--Select One--'));
        //
        List<CampaignMemberStatus> lstCMS = [select Label from CampaignMemberStatus where CampaignId = :theCampaignId];
        //
        for (CampaignMemberStatus cms : lstCMS) {
            options.add(new SelectOption(cms.label, cms.label));
        }
        return options;   
    }  
    
    
    // =============================================================
    // Initialization Calls
    // =============================================================
    
    public CampaignMembersTaskAssignController() {
        //
        //Selected_Results tempResults = new Selected_Results();
        String sTemp='';
        //
        theCampaignId = apexpages.currentpage().getparameters().get('CampaignId');
        theCampaignName = apexpages.currentpage().getparameters().get('CampaignName');
        theCampaignName = theCampaignName.replaceAll('[+]', ' ');
        //
        /////////////////////////////////sravan change 5 dec - SF-BUG-778
        
        List<campaignMember> campmem = [select id,leadid,Contact.Account.Id,Lead.Account__r.Id,contactid from campaignmember where campaignid=:theCampaignId];
        List<Id> accids = new List<Id>();
        for(campaignMember cm : campmem){
            if(cm.leadid != null){
                if(cm.lead.account__c != null)
                	accids.add(cm.Lead.Account__r.Id);
            }
            if(cm.ContactId != null){
                if(cm.Contact.Account.Id != null)
                	accids.add(cm.Contact.Account.Id);
            }  	
        }
        Map<String,Acct_Team_Roles_for_Followup_Task__c> teamRoles = Acct_Team_Roles_for_Followup_Task__c.getAll();
        			Set<String> ActTeamRoleList = teamRoles.keySet();
         //SF-BUG -592           
         atm = TerritoryUtility.populateAccountTeamMemberList(accids);
           //  [select TeamMemberRole,AccountId, User.Id, User.Name from AccountTeamMember where AccountId =: accids 
               // and TeamMemberRole in: ActTeamRoleList];
        //Added by sravan for SF-BUG-778 23 JAN START
        system.debug('ATMSIZE'+atm.size());
        for(AccountTeamMember at : atm){
            if(ateammap.containsKey(at.AccountId)){
                List<AccountTeamMember>teamList=ateammap.get(at.AccountId);
                teamList.add(at);
                ateammap.put(at.AccountId, teamList);
            }
            else{
                ateammap.put(at.AccountId, new List<AccountTeamMember>{at});
            }
        }
        //Added by sravan for SF-BUG-778 23 JAN END
        //CampaignMembersWrapper.atm1 = atm;
        ///////////////////////////////// - SF-BUG-778
                
        mapSchemaFields = new Map<String,Map<String, Schema.SObjectField>>();
        mapSelectedCampaignMembers = new Map<Id,Id>();
        selectedFields = new Set<String>();
        lstFilters = new List<String>();
        
        isFirstLoad = true;
        //
        runSearch();
        //
    }
    
    // =============================================================
    // Methods below are for display of results
    // =============================================================
    
    // runs the search with parameters passed via Javascript
    public void runSearch() {
        //
        String sWhere = '';
        String sTemp = '';
        //
        
        soql = 'SELECT Id, SelectedForClone__c, Campaign_Notes__c,Lead.Interested_Productslje__c,lead.ownerId,Status,HasResponded, Campaign.ParentId,Task_Assigned__c,Lead_Classification__c, Product_Opportunity__c, Follow_up_Field_Filter__c, CreatedDate, LastModifiedDate, Follow_up_Task_Assigned__c,';
        //soql = soql + '  Contact.LastName, Contact.FirstName, Contact.Title, Contact.Owner.Name, Contact.Owner.Title,';
        //soql = soql + '  Lead.LastName, Lead.FirstName, Lead.Title, Lead.Owner.Name, Lead.Owner.Title, Lead.Company,';
        soql = soql + ' Contact.Title, toLabel(Contact.Omnicell_Job_Code__c), Contact.Account.BillingCountry, Contact.Account.Region__c, Contact.Account.Account_Territory__c, Contact.Account.Account_Status__c, Contact.Account.Facility_Type__c, toLabel(Contact.Account.Partner_Type__c),';  //IBA-4149
        soql = soql + ' Lead.Company, Lead.Title, toLabel(Lead.Omnicell_Job_Title__c), Lead.Owner.Name, Lead.Account__r.BillingCountry, Lead.Account__r.Region__c, Lead.Account__r.Account_Territory__c, Lead.Account__r.Account_Status__c, Lead.Account__r.Facility_Type__c, toLabel(Lead.Account__r.Partner_Type__c),';  //IBA-4149
        soql = soql + ' Contact.Account.Name, Contact.Account.Owner.Name, Contact.Account.BillingState, Lead.Account__r.Owner.Name, Lead.Account__r.BillingState,';
        soql = soql + ' Contact.Account.Owner.Title, Lead.Account__r.Owner.Title,Interviewer__c,Lead.Account__r.Division_Account__c,';
       // soql = soql + ' Contact.Account.MAI_Customer_Classification__c, Lead.Account__r.Name, Lead.Account__r.MAI_Customer_Classification__c,';
        soql = soql + ' Contact.Account.of_Active_Commit_Opportunities__c, Lead.Account__r.of_Active_Commit_Opportunities__c,';
        soql = soql + ' Contact.Account.of_Active_Pipeline_Opportunities__c, Lead.Account__r.of_Active_Pipeline_Opportunities__c,';
        soql = soql + ' Contact.Account.of_Active_Strong_Upside_Opportunities__c, Lead.Account__r.of_Active_Strong_Upside_Opportunities__c,';
        soql = soql + ' Contact.Account.of_Active_Upside_Opportunities__c, Lead.Account__r.of_Active_Upside_Opportunities__c,';
        soql = soql + ' Contact.Account.Country_Cluster__c, Lead.Account__r.Country_Cluster__c,Contact.FirstName, Contact.LastName,Lead.FirstName,Lead.LastName, ';
        soql = soql + ' Contact.Account.Num_of_Active_Opportunities__c, Lead.Account__r.Num_of_Active_Opportunities__c, Contact.Account.Division_Account__c';
        soql = soql + ' FROM CampaignMember WHERE IsDeleted = false';
        soql = soql + ' AND CampaignMember.CampaignId = \'' + theCampaignId + '\'';
        
        countTotal = 'SELECT COUNT() FROM CampaignMember WHERE IsDeleted = false AND CampaignMember.CampaignId = \''+ theCampaignId + '\'';
        
        for (String fr : filterResults) {
            System.Debug('filter results : '+fr);
            soql = soql + ' AND ' + fr;
            countTotal = countTotal + ' AND ' + fr;
        }
        // System.Debug('soql : '+soql);
        //
        filterResults.clear();
        
        // run the query again
        populateCampaignList();
        //addMembersToAssignTaskTab();
    }
    
    // Get the selected checked Members
    //commented the below method by sravan for SF-BUG-778
    /*public void addAll() {
isAddAll = true;
//
selectedCampaignMembers.clear();
//
for(CampaignMembersWrapper cmw: lstCampaignMembers) { 
System.debug('cmw : '+cmw.memberType+'lead owner : '+cmw.leadOwner);
cmw.checked = true;
selectedCampaignMembers.add(cmw);
}
//
intSelectedCount = selectedCampaignMembers.size();
//
//doNothing();
getDisplayList();
//
}*/
    //Added the below method by sravan for SF-BUG-778
    public void addAll() {
        isAddAll = true;
        //
        selectedCampaignMembers.clear();
        //
        String qryaddall = soql + ' order by Contact.LastName, Lead.LastName LIMIT 500';
        /*totalSize = (Integer)Database.countQuery(qryaddall.size());

tooManyCampaignMembers();*/
        List<CampaignMembersWrapper> lstCampaignMembers1 = new List<CampaignMembersWrapper>();
        // may need to modify for governor limits??
        System.debug('query : '+qryaddall);
        for(CampaignMember c : Database.query(qryaddall)) {
            // create a new wrapper by passing it the category in the constructor
            cmwrap = new CampaignMembersWrapper(c);
            // add the wrapper to the results
            lstCampaignMembers1.add(cmwrap);
        }
        for(CampaignMembersWrapper cmw: lstCampaignMembers1) { 
            System.debug('cmw : '+cmw.memberType+'lead owner : '+cmw.leadOwner);
            cmw.checked = true;
            selectedCampaignMembers.add(cmw);
        }
        //
        intSelectedCount = selectedCampaignMembers.size();
        //
        //doNothing();
        getDisplayList();
        //
    }
    
    
    // Get all Members
    //
    public void addAllMembers() {
        isAddAll = true;
        //
        selectedCampaignMembers.clear();
        //
        for(CampaignMembersWrapper cmw: lstAllCampaignMembers) { 
            cmw.checked = true;
            selectedCampaignMembers.add(cmw);
        }
        //
        intSelectedCount = selectedCampaignMembers.size();
        //
        //doNothing();
        getDisplayList();
        //
    }
    
    //Removes the selected checked Members
    public void removeAll() {
        selectedCampaignMembers.clear();
    }
    
    // Get the selected checked Members
    //
    public void checkBoxSelected() {
        //
        //selectedCampaignMembers.clear();
        //
        if (mapSelectedCampaignMembers.containsKey(checkBoxId)) {
            //
            mapSelectedCampaignMembers.remove(checkBoxId);
            //          
        } else {
            //
            mapSelectedCampaignMembers.put(checkBoxId, checkBoxId);
            //
        }
        //
        intSelectedCount = mapSelectedCampaignMembers.size();
        //
        //return null;
    }
    
    
    // Populate Campaign Member List
    public void populateCampaignList(){
        //
        if (lstCampaignMembers == null) {
            lstCampaignMembers = new List<CampaignMembersWrapper>(); // init the list if it is null
        } else {
            lstCampaignMembers.clear(); // clear out the current results if they exist
        }
        //
        //lstContactTMs = Database.query(soql + ' and ContactId != null order by Contact.LastName, Lead.LastName'); 
        //lstLeadTMs = Database.query(soql + ' and LeadId != null order by Contact.LastName, Lead.LastName'); 
        // dynamic soql for fun
        String qry = soql + ' order by Contact.LastName, Lead.LastName LIMIT :limitSize offset :offsetsize';
        
        totalSize = (Integer)Database.countQuery(countTotal);
        
        tooManyCampaignMembers();
        
        // may need to modify for governor limits??
        System.debug('query : '+qry);
        for(CampaignMember c : Database.query(qry)) {
            // create a new wrapper by passing it the category in the constructor
            cmwrap = new CampaignMembersWrapper(c);
            // add the wrapper to the results
            lstCampaignMembers.add(cmwrap);
            //System.debug('cmwrap.checked : '+cmwrap.checked);
            /*System.debug('lead classification : '+cmwrap.leadClassification);
if(cmwrap.memberStatus != null && cmwrap.memberStatus != ''){
memStatusSet.add(cmwrap.memberStatus);                
}
if(cmwrap.leadClassification != null && cmwrap.leadClassification != ''){
classificSet.add(cmwrap.leadClassification);                
}*/
        }
        /*if(isFirstLoad){
isFirstLoad = false;
if(!memStatusSet.isEmpty())
memStatusList.addAll(memStatusSet);
if(!classificSet.isEmpty())
classificList.addAll(classificSet);
}
System.debug('classificList : '+classificList);*/
        //System.Debug('lstCampaignMembers :: '+lstCampaignMembers);
        //
        hasNextRecords = hasNext();
        hasPrevRecords = hasPrevious();
        cntCMs = lstCampaignMembers.size();
        //
        
    }
    
    // Populate All Campaign Members to Assign Task Tab List
    public void addMembersToAssignTaskTab(){
        //
        if (lstAllCampaignMembers == null) {
            lstAllCampaignMembers = new List<CampaignMembersWrapper>(); // init the list if it is null
        } else {
            lstAllCampaignMembers.clear(); // clear out the current results if they exist
        }
        
        String qry1 = soql + ' order by Contact.LastName, Lead.LastName LIMIT :limit60';
        
        
        // may need to modify for governor limits??
        for(CampaignMember c : Database.query(qry1)) {
            // create a new wrapper by passing it the category in the constructor
            cmwrap_toAddALl = new CampaignMembersWrapper(c);
            // add the wrapper to the results
            lstAllCampaignMembers.add(cmwrap_toAddALl);
        }
    }
    
    public PageReference tooManyCampaignMembers(){
        if(totalSize > 500){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.SEVERITY.Warning, System.Label.Too_many_Campaign_Members));
        }
        
        return null;
    }
    
    /* =================== Pagination Controls ===================*/
    
    public Boolean hasNext(){
        if((offsetSize + limitSize) > totalSize){
            return true;
        }
        else{
            return false;
        }
    }
    
    public Boolean hasPrevious(){
        if(offsetSize == 0){
            return true;
        }
        else{
            return false;
        }
    }
    
    public void next(){
        offsetSize = offsetSize + limitSize;
        populateCampaignList();
    }
    
    public void previous(){
        offsetSize = offsetSize - limitSize;
        populateCampaignList();
    }
    
    public Integer getTotalPages(){
        if(Math.mod(totalSize, limitSize) > 0){
            return totalSize/limitSize + 1;
        }
        else{
            return (totalSize/limitSize);
        }
    }
    
    public List<Integer> getPageIndexes(){
        List<Integer> pages = new List<Integer>();
        for(Integer i = getPageNumber(); i<=getPageNumber()+4; i++){
            if(i < getTotalPages() - 4){
                pages.add(i);
            }
        }
        return pages;
    }
    
    public Integer getPageNumber(){
        return offsetSize/limitSize + 1;
    }
    
    // Populate Campaign Member List
    public void assignTaskToCampaignMembers(){
        try {
            //
            Id theContOwnerid;
            Id theLeadOwnerid;
            Id theWhoId;
            //
            MAP<String, ID> mapStateDataLQ = new MAP<String, ID>();
            MAP<String, ID> mapStateDataIS = new MAP<String, ID>();
            //
            List<StateData__c> lstSD = [select Name, Lead_Qualification_Team_Owner__c, Inside_Sales_Rep_Owner__c from StateData__c];
            //
            for (StateData__c sd : lstSD) {
                // add to map
                if (sd.Lead_Qualification_Team_Owner__c != null) mapStateDataLQ.put(sd.name, sd.Lead_Qualification_Team_Owner__c);
                if (sd.Inside_Sales_Rep_Owner__c != null) mapStateDataIS.put(sd.name, sd.Inside_Sales_Rep_Owner__c);            
            }
            //
            //System.Debug('selectedCampaignMembers : '+selectedCampaignMembers.size());
            List<CampaignMember> updatecampmemlist = new List<CampaignMember>(); //SF-BUG-778 changes 23 JAN
            for (CampaignMembersWrapper cmw: selectedCampaignMembers) {
                //
                //Added by sravan for SF-BUG-778 START
                boolean taskassigned = false;
                String prdopp;
                if(cmw.prodOpportunity != null)
                 prdopp = cmw.prodOpportunity;
                else
                    prdopp = null;
                String campmemnotes;
                if(cmw.campaignnotes != null)
                   campmemnotes = cmw.campaignnotes;
                else
                    campmemnotes = null;
                String interprdcts;
                if(cmw.intrestedprd != null)
                    interprdcts = cmw.intrestedprd;
                else
                    interprdcts = null;
                //Added by sravan for SF-BUG-778 END
                theContOwnerId = null;
                theLeadOwnerId = null;
                // Add Task
                if (selAssignedTo == System.Label.Account_Owner) {
                    if (cmw.cm.ContactId!=null) {
                        theWhoId = cmw.cm.ContactId;
                        theContOwnerId = cmw.cm.Contact.Account.ownerid;
                        //System.debug('theContOwnerId : '+theContOwnerId);
                    } else {
                        theWhoId = cmw.cm.LeadId;
                        theLeadOwnerId = cmw.cm.Lead.Account__r.ownerid;
                    }
                    System.debug('Member Type : '+cmw.memberType);
                    System.debug('Lead Id : '+cmw.cm.LeadId+' Lead Owner : '+theLeadOwnerId);
                    //
                    if (cmw.cm.ContactId != null && theContOwnerId == null && cmw.memberType == 'Contact'){
                        //
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, cmw.cm.Lead.FirstName + ' ' + cmw.cm.Lead.LastName + ' does not have an owner.'));
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Contact_With_Out_Owner));
                        //
                    }else if(cmw.cm.LeadId != null && theLeadOwnerId == null && cmw.memberType == 'Lead'){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Lead_With_Out_Owner));
                    }else{
                        taskassigned = true; //SF-BUG-778 changes 23 JAN
                        if (cmw.cm.ContactId!=null) {
                            addTasksToList( theWhoId, theCampaignId, theContOwnerId, cmw.cm.Id,cmw.worldRegion,prdopp,campmemnotes,interprdcts);//Added countrycluster,prdopp,campmemnotes for SF-BUG-778 by Sravan
                        } else {
                            // Lead Task can't be assigned to a campaign
                            addTasksToList( theWhoId, null, theLeadOwnerId, cmw.cm.Id,cmw.worldRegion,prdopp,campmemnotes,interprdcts);//Added countrycluster,prdopp,campmemnotes for SF-BUG-778 by Sravan
                        }
                    }
                    //
                }
                
                //added 5/19/17 LJN for Assign to Lead Owner
                if (selAssignedTo == 'Lead Owner') {
                    if (cmw.cm.ContactId!=null) {
                        theWhoId = cmw.cm.ContactId;
                        theContOwnerId = cmw.cm.Contact.Account.ownerid;
                    } else {
                        theWhoId = cmw.cm.LeadId;
                        theLeadOwnerId = cmw.cm.Lead.Ownerid;
                        //System.Debug('theLeadOwnerId : '+theLeadOwnerId);
                    }
                    //System.debug('cmw :- '+cmw);
                    //System.debug('cmw.isLeadOwnerIsQueue :- ' +cmw.isLeadOwnerIsQueue);
                    //
                    if(cmw.isLeadOwnerIsQueue){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.CampMem_LeadOwner_Marketing_Queue));
                    }else if (cmw.cm.ContactId != null && theContOwnerId == null && cmw.memberType == 'Contact') {
                        //
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, cmw.cm.Lead.FirstName + ' ' + cmw.cm.Lead.LastName + ' does not have an owner.'));
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Contact_With_Out_Owner));
                        //
                    }else if(cmw.cm.LeadId != null && theLeadOwnerId == null && cmw.memberType == 'Lead'){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Lead_With_Out_Owner));
                    }else {
                        taskassigned = true; //SF-BUG-778 changes 23 JAN
                        if (cmw.cm.ContactId!=null) {
                            //   addTasktoList( theWhoId, theCampaignId, theContOwnerId);
                            addTasksToList( theWhoId, theCampaignId, theContOwnerId, cmw.cm.Id,cmw.worldRegion,prdopp,campmemnotes,interprdcts);//Added countrycluster,prdopp,campmemnotes for SF-BUG-778 by Sravan
                        } else {
                            // Lead Task can't be assigned to a campaign
                            //   addTasktoList( theWhoId, null, theLeadOwnerId);
                            // added by Asha
                            addTasksToList( theWhoId, null, theLeadOwnerId, cmw.cm.Id,cmw.worldRegion,prdopp,campmemnotes,interprdcts);//Added countrycluster,prdopp,campmemnotes for SF-BUG-778 by Sravan
                        }
                    }
                    //
                }
                
                //Below code for (Direct Manager, Key Account Manager, Regional Manager, Director, Sales Development Consultant, IV Rep, Performance Center Rep)added 10/07/2018 - As part of Sprint 6
                /* if (selAssignedTo == 'Direct Manager') {                
theWhoId = cmw.cm.ContactId;
//System.Debug('cmw.directManagerId : '+cmw.directManagerId);
theContOwnerId = cmw.directManagerId;//cmw.cm.Contact.Account.ownerid;

//
if (theContOwnerId == null) {
//
//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, cmw.cm.Lead.FirstName + ' ' + cmw.cm.Lead.LastName + ' does not have an owner.'));
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Camp_mem_does_not_have_Direct_Mngr));
//
} else {
if (cmw.cm.ContactId!=null) {
addTasktoList( theWhoId, theCampaignId, theContOwnerId);
} else {
// Lead Task can't be assigned to a campaign
addTasktoList( theWhoId, null, theContOwnerId);
}
}
//
}*/
                if (selAssignedTo == System.Label.Key_Account_Manager) {   
                    theWhoId = cmw.cm.ContactId;
                    theContOwnerId = cmw.keyAcctManagerId;//cmw.cm.Contact.Account.ownerid;
                    
                    //
                    if (theContOwnerId == null) {
                        //
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, cmw.cm.Lead.FirstName + ' ' + cmw.cm.Lead.LastName + ' does not have an owner.'));
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Camp_mem_does_not_have_Key_Acct_Mngr));
                        //
                    } else {
                        taskassigned = true; //SF-BUG-778 changes 23 JAN
                        if (cmw.cm.ContactId!=null) {
                            addTasksToList( theWhoId, theCampaignId, theContOwnerId, cmw.cm.Id,cmw.worldRegion,prdopp,campmemnotes,interprdcts);//Added countrycluster,prdopp,campmemnotes for SF-BUG-778 by Sravan
                        } else {
                            // Lead Task can't be assigned to a campaign
                            addTasksToList( theWhoId, null, theContOwnerId, cmw.cm.Id,cmw.worldRegion,prdopp,campmemnotes,interprdcts);//Added countrycluster,prdopp,campmemnotes for SF-BUG-778 by Sravan
                        }
                    }
                    //
                }
                /*if (selAssignedTo == 'Regional Manager') {                
theWhoId = cmw.cm.ContactId;
//System.debug('cmw.regionalManagerId : '+cmw.regionalManagerId);
theContOwnerId = cmw.regionalManagerId;//cmw.cm.Contact.Account.ownerid;
//System.debug('theContOwnerId ==>'+theContOwnerId);
//
if (theContOwnerId == null) {
//
//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, cmw.cm.Lead.FirstName + ' ' + cmw.cm.Lead.LastName + ' does not have an owner.'));
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Camp_mem_does_not_have_Reg_Mngr));
//
} else {
if (cmw.cm.ContactId!=null) {
addTasktoList( theWhoId, theCampaignId, theContOwnerId);
} else {
// Lead Task can't be assigned to a campaign
addTasktoList( theWhoId, null, theContOwnerId);
}
}
//
}
if (selAssignedTo == 'Director') {                
theWhoId = cmw.cm.ContactId;
theContOwnerId = cmw.directorId;//cmw.cm.Contact.Account.ownerid;

//
if (theContOwnerId == null) {
//
//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, cmw.cm.Lead.FirstName + ' ' + cmw.cm.Lead.LastName + ' does not have an owner.'));
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Camp_mem_does_not_have_director));
//
} else {
if (cmw.cm.ContactId!=null) {
addTasktoList( theWhoId, theCampaignId, theContOwnerId);
} else {
// Lead Task can't be assigned to a campaign
addTasktoList( theWhoId, null, theContOwnerId);
}
}
//
}
if (selAssignedTo == 'Sales Development Consultant') {                
theWhoId = cmw.cm.ContactId;
theContOwnerId = cmw.salesDevConId;//cmw.cm.Contact.Account.ownerid;

//
if (theContOwnerId == null) {
//
//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, cmw.cm.Lead.FirstName + ' ' + cmw.cm.Lead.LastName + ' does not have an owner.'));
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Camp_mem_does_not_have_Sales_Dev_Const));
//
} else {
if (cmw.cm.ContactId!=null) {
addTasktoList( theWhoId, theCampaignId, theContOwnerId);
} else {
// Lead Task can't be assigned to a campaign
addTasktoList( theWhoId, null, theContOwnerId);
}
}
//
}*/
                if (selAssignedTo == System.Label.IV_Sales_Consultant) {  
                    theWhoId = cmw.cm.ContactId;
                    theContOwnerId = cmw.IVRepId;//cmw.cm.Contact.Account.ownerid;
                    
                    //
                    if (theContOwnerId == null) {
                        //
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, cmw.cm.Lead.FirstName + ' ' + cmw.cm.Lead.LastName + ' does not have an owner.'));
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Camp_mem_does_not_have_IV_Rep));
                        //
                    } else {
                        taskassigned = true; //SF-BUG-778 changes 23 JAN
                        if (cmw.cm.ContactId!=null) {
                            addTasksToList( theWhoId, theCampaignId, theContOwnerId, cmw.cm.Id,cmw.worldRegion,prdopp,campmemnotes,interprdcts);//Added countrycluster,prdopp,campmemnotes for SF-BUG-778 by Sravan
                        } else {
                            // Lead Task can't be assigned to a campaign
                            addTasksToList( theWhoId, null, theContOwnerId, cmw.cm.Id,cmw.worldRegion,prdopp,campmemnotes,interprdcts);//Added countrycluster,prdopp,campmemnotes for SF-BUG-778 by Sravan
                        }
                    }
                    //
                }
                /*if (selAssignedTo == 'Performance Center Rep') {                
theWhoId = cmw.cm.ContactId;
theContOwnerId = cmw.perfCenterRepId;//cmw.cm.Contact.Account.ownerid;

//
if (theContOwnerId == null) {
//
//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, cmw.cm.Lead.FirstName + ' ' + cmw.cm.Lead.LastName + ' does not have an owner.'));
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Camp_mem_does_not_have_Perf_Center_Rep));
//
} else {
if (cmw.cm.ContactId!=null) {
addTasktoList( theWhoId, theCampaignId, theContOwnerId);
} else {
// Lead Task can't be assigned to a campaign
addTasktoList( theWhoId, null, theContOwnerId);
}
}
//
}*/            
                if (selAssignedTo == System.Label.Inside_Sales_Rep) {
                    //
                    // Get Owner by State
                    //
                    /*if (cmw.cm.ContactId!=null) {
// find Lead Qual from state
if (mapStateDataIS.containskey(cmw.cm.Contact.Account.BillingState)) {
//
theWhoId = cmw.cm.ContactId;
theContOwnerId = mapStateDataIS.get(cmw.cm.Contact.Account.BillingState);
//
}
} else {
// find state
if (mapStateDataLQ.containskey(cmw.cm.Lead.Account__r.BillingState)) {
//
theWhoId = cmw.cm.LeadId;
theContOwnerId = mapStateDataIS.get(cmw.cm.Lead.Account__r.Billingstate);
//
}
}*/
                    ////Sravan change Dec 5 SF-BUG-778
        			String accid;
                    if (cmw.cm.ContactId!=null) {
                        if(cmw.cm.Contact.Accountid != null)
                        	accid = cmw.cm.Contact.Accountid;
                        theWhoId = cmw.cm.ContactId;
                    } else {
                        if(cmw.cm.Lead.Account__c != null)
                        	accid = cmw.cm.Lead.Account__c;
                        theWhoId = cmw.cm.LeadId;
                        //System.Debug('theLeadOwnerId : '+theLeadOwnerId);
                    }
                    System.debug('atm : '+atm.size());
			//added by sravan for SF-BUG-778 JAN 23 START
                    if(accid != null){
                        if(ateammap.get(accid) != null){
                    		List<AccountTeamMember> atlist = ateammap.get(accid);
                    		for(AccountTeamMember tMem : atlist){
                    			if(tMem.AccountId == accid){
                					if(tMem.TeamMemberRole == System.Label.Inside_Sales_Rep){
                    					theContOwnerId = tMem.UserId;
                					}
                    			}
                        	}
                        }
                    }
			//added by sravan for SF-BUG-778 JAN 23 END
                    //theWhoId = cmw.cm.ContactId;
                    //theContOwnerId = cmw.insideSalesRepId;//cmw.cm.Contact.Account.ownerid;
                    ////Sravan change Dec 5 SF-BUG-778
                    if (theContOwnerId != null) {
                        taskassigned = true; //SF-BUG-778 changes 23 JAN      
                        if (cmw.cm.ContactId!=null) {
                            addTasksToList( theWhoId, theCampaignId, theContOwnerId, cmw.cm.Id,cmw.worldRegion,prdopp,campmemnotes,interprdcts);//Added countrycluster,prdopp,campmemnotes for SF-BUG-778 by Sravan
                        } else {
                            // Lead Task can't be assigned to a campaign
                            addTasksToList( theWhoId, null, theContOwnerId, cmw.cm.Id,cmw.worldRegion,prdopp,campmemnotes,interprdcts);//Added countrycluster,prdopp,campmemnotes for SF-BUG-778 by Sravan
                        }                    
                    } else {
                        //
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, cmw.cm.Lead.FirstName + ' ' + cmw.cm.Lead.LastName + ' does not have an owner.'));
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.Camp_mem_does_not_have_Inside_Sales_Team));
                        //
                    }
                }
		    //added by sravan for SF-BUG-778 JAN 23 START
                if(taskassigned == true){
                    cmw.cm.Task_Assigned__c = true;
                    cmw.cm.Follow_up_Task_Assigned__c = true;//SF-BUG-983 Added by Sourav
                    System.debug('*********'+System.now());
                    cmw.cm.Follow_up_Task_Assigned_Date__c = System.now();//SF-BUG-983 Added by Sourav
                    updatecampmemlist.add(cmw.cm);
                }
                else{
                    cmw.cm.Task_Assigned__c = false;
                }
		   //added by sravan for SF-BUG-778 JAN 23 END 
            }
            //
            CampaignMemberTriggerHandler.fromtaskassigncontroller = true;//added by sravan for SF-BUG-778 JAN 23
            update updatecampmemlist;//added by sravan for SF-BUG-778 JAN 23
            System.debug('New Tasks---------------- : '+lstNewTasks);
            if (lstNewTasks.size()>0) {upsert lstNewTasks;} //added upsert for SF-BUG-778 CAPGEMINI 14 NOV
            //
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, lstNewTasks.size() + ' '+System.Label.Tasks_Added));
            
            //
            // Clear all
            //
            intSelectedCount = 0;
            clearFilter();
            
            //                    
        }catch(DMLException e) {
            //
            system.debug('error'+ e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + e));
            ErrorLogging.Log(e, 'assignTaskToCampaignMembers','App');
        }catch(Exception e){
            system.debug('error'+ e);
            //System.debug('exception :'+e.getMessage()+'at Line no. : '+e.getLineNumber());
            ErrorLogging.Log(e, 'assignTaskToCampaignMembers','App');
            /*String exmsg = e.getMessage();
if(exmsg.equals('Invalid id:')){
System.Debug('Ok');
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, lstNewTasks.size() + 'Selected Owner is Inactive'));
}*/
        } 
    }
    
    //dummy method to avoid deployment issues, can be get deleted later - Haripriya
    public void addTaskToList(Id idWho, Id idWhat, ID idOwner){
    }
    
    
    // Add Task to List
    public void addTasksToList(Id idWho, Id idWhat, ID idOwner, Id idCampaignMember, String countrycluster,String prdopp,String campmemnotes,String interprdcts) {//Added countrycluster,prdopp,campmemnotes for SF-BUG-778 by Sravan
        //
        try{
            Task newTask = new Task();
            newTask.ActivityDate = t.ActivityDate;
            /* commented below line and added 3 fields - Follow_up_Tasks_Notes__c,Activity_Type__c,Activity_SubType__c by Asha */
            //  newTask.Description = t.Description;
            newTask.Follow_up_Tasks_Notes__c = t.Description;
            newTask.Priority = t.Priority;
            newTask.Subject = t.Subject;
            newTask.Status = t.Status;
            newTask.WhoId = idWho;
            newTask.WhatId = idWhat;
            //Added by sravan for SF-BUG-778 START
            Id usid = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales-NA').getRecordTypeId();
            //Id ukid = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales-UK').getRecordTypeId();
            Id international = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales-International').getRecordTypeId();
            if(idWho != null){
                //list<Contact> cont = [select id,Account_Country_Cluster__c from Contact where id =:idWho];
                if(countrycluster != null){
                    if(countrycluster == 'US&CA')
                        newTask.RecordTypeId = usid;
                    else if(countrycluster == 'UK&I')
                        //  newTask.RecordTypeId = ukid; //Comment for IBA-3127
                     	newTask.RecordTypeId = international;       
                    else
                        newTask.RecordTypeId = international;
                }
            }
            System.debug('record type : '+newtask.RecordTypeId);
            //Added by sravan for SF-BUG-778 END   
            newTask.OwnerId = idOwner;
           //IBA-4524 newTask.Campaign_Task_Type__c = 'Follow Up';
            newTask.Campaign_Id__c = theCampaignId;
            newTask.Campaign__c =theCampaignId;  
          //IBA-4524  newTask.CampaignMember_Id__c = idCampaignMember;
            newTask.Interested_Products__c = interprdcts;
            //list<lead> ld = [select id,Account__r.Country_Cluster__c,Interested_Productslje__c from Lead where id =:idWho];//Added Country_Cluster__c by sravan for SF-BUG-778 START
            //if(ld!=null && ld.size()>0){
                //newTask.Interested_Products__c = ld[0].Interested_Productslje__c;
                /*below lines are added by Asha*/
                
                //Added by sravan for SF-BUG-778 START
                /*if(ld[0].Account__r.Country_Cluster__c != null){
                    if(ld[0].Account__r.Country_Cluster__c == 'US&CA')
                        newTask.RecordTypeId = usid;
                    else if(ld[0].Account__r.Country_Cluster__c == 'UK&I')
                        newTask.RecordTypeId = ukid;
                    else
                        newTask.RecordTypeId = international;
                }*/
                //Added by sravan for SF-BUG-778 END
                
            //}
            //moved the below two lines from the if condition above by SRAVAN for SF-BUG-778
            newTask.Activity_Type__c = 'Account';
            newTask.Activity_SubType__c = 'Follow-up on Marketing Campaign Contact/Lead';
            //list<CampaignMember> cm=[select Product_Opportunity__c,Campaign_Notes__c from campaignmember where (leadid = :idWho OR contactid =:idWho)and CampaignId=:newTask.Campaign__c];
            //if(String.ValueOf(idWho).Substring(0,3) == '00Q')     
            newTask.Interested_Products__c= prdopp; 
            /* commented below line and added Description by Asha */
            //newTask.Campaign_Notes__c =cm[0].Campaign_Notes__c;  
            newTask.Description = campmemnotes; 
            lstNewTasks.add(newTask); 
        }catch(Exception e){
            ErrorLogging.Log(e, 'addTaskToList','App');
        }
    }
    
    // Return to Original Campaign
    public PageReference returnToCampaign() {
        //
        PageReference pref = new PageReference('/'+theCampaignId);
        //
        pref.setRedirect(true);
        //
        return pref;
    } 
    
    // Filter List
    //   
    public void addFilter() {
        System.debug('Product Opportunity New----------------------: '+selectedProductOpportunity);
        System.debug('selectedLeadClassification : '+selectedLeadClassification);
        //System.Debug('selMemberType : '+selMemberType);
        
        if (selMemberstat != null) {
            lstFilters.add('Campaign Member Status = ' + selMemberstat);
            //
            filterResults.add('status = \'' + selMemberstat + '\'');
        }
        if (selMemberType != null && selMemberType != '') {
            lstFilters.add('Contact or Lead = ' + selMemberType);
            //
            if (selMemberType == 'Contact') {
                filterResults.add('Contact.LastName != null');
            } else {
                filterResults.add('Lead.LastName != null AND Lead.isConverted = false');//Added isconverted for SF-BUG-778 by Sravan
            }
            //
        }
        if (selAcctOwnerName != null && selAcctOwnerName != '') {
            lstFilters.add('Account Owner Name = ' + selAcctOwnerName);
            //
            filterResults.add('(Contact.Account.Owner.Name like \'%' + selAcctOwnerName + '%\' OR Lead.Account__r.Owner.Name like \'%' + selAcctOwnerName + '%\')');
            //
        }
        if (selectedJobTitle != null && selectedJobTitle != '' && selectedJobTitle != ' ' && selectedJobTitle != '[]') {
            lstFilters.add('Omnicell Job Title = ' + selectedJobTitle);
            //
            System.Debug('selectedJobTitle : '+selectedJobTitle);
            String firstVal;
            String str = selectedJobTitle.remove('[');
            str = str.remove(']');
            System.debug('str :: '+str);
            jobTitleList.clear();
            jobTitleCondition = '';
            jobTitleList = str.split(',(?=(?:[^\']*\'[^\']*\')*[^\']*$)');
            
            System.debug('jobTitleList :: '+jobTitleList+' size is : '+jobTitleList.size());
            
            if(jobTitleList.size()>0){
                if(jobTitleList.size()>1){ 
                    for(string val : jobTitleList) {
                        firstVal = val;
                        break;
                    }
                    System.Debug('firstVal : '+firstVal);
                    jobTitleList.remove(0);   
                    for(string val : jobTitleList) {
                        val = val.trim();
                        System.Debug('val : '+val);
                        jobTitleCondition += ',' + val;
                    }
                    System.Debug('jobTitleCondition : '+jobTitleCondition);
                    jobTitleCondition = firstVal+jobTitleCondition;
                }else{
                    jobTitleCondition = str;
                }
                System.Debug('jobTitleCondition : '+jobTitleCondition);
            }
            
            if (selMemberType == 'Contact' && jobTitleCondition != '' && jobTitleCondition != ' ') {
                filterResults.add('toLabel(Contact.Omnicell_Job_Code__c) in('+jobTitleCondition+')');
            }else if (selMemberType == 'Lead' && jobTitleCondition != '' && jobTitleCondition != ' ') {
                filterResults.add('toLabel(Lead.Omnicell_Job_Title__c) in('+jobTitleCondition+')');
            }else if(jobTitleCondition != '' && jobTitleCondition != ' '){
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Error_on_Omnicell_Job_Title_picklist));
                filterResults.add('(toLabel(Contact.Omnicell_Job_Code__c) in('+jobTitleCondition+') or toLabel(Lead.Omnicell_Job_Title__c) in('+jobTitleCondition+'))');
            }
        }
        if (selectedLeadClassification != null) {
            lstFilters.add('Lead Classification = ' + selectedLeadClassification);
            //
            //if (selMemberType == 'Lead') {
            filterResults.add('Lead_Classification__c = \'' + selectedLeadClassification + '\'');
            //}
        }
        if (selectedProductOpportunity != null && selectedProductOpportunity != '' && selectedProductOpportunity != ' ' && selectedProductOpportunity != '[]') {
            lstFilters.add('Product Opportunity = ' + selectedProductOpportunity);
            //
            System.debug('selectedProductOpportunity :: '+selectedProductOpportunity);
            String firstVal;
            String str = selectedProductOpportunity.remove('[');
            str = str.remove(']');
            System.debug('str :: '+str);            
            prodOppList.clear();
            condition = '';
            prodOppList = str.split(',');
            System.debug('prodOppList :: '+prodOppList);
            if(prodOppList.size()>0){
                if(prodOppList.size()>1){ 
                    for(string val : prodOppList) {
                        firstVal = val;
                        break;
                    }
                    System.Debug('firstVal : '+firstVal);
                    prodOppList.remove(0);   
                    for(string val : prodOppList) {
                        val = val.trim();
                        System.Debug('val : '+val);
                        condition += ',\'' + val + '\'';
                    }
                    System.Debug('condition : '+condition);
                    condition = condition+'\'';
                    System.Debug('condition : '+condition);
                    condition = condition.substring(1, condition.length() - 1);
                    condition = '\''+firstVal+'\','+condition;
                }else{
                    condition = '\''+str+'\'';
                }
                System.Debug('condition : '+condition);
            }
            if(condition != '' && condition != ' '){
                filterResults.add('Product_Opportunity__c includes('+condition+')');
            }
        }
        if (selFollowUpField != null && selFollowUpField != '') {
            lstFilters.add('FollowUp Field Filter = ' + selFollowUpField);
            //
            filterResults.add('Follow_up_Field_Filter__c = \'' + selFollowUpField + '\'');
        }
        //if (selFollowUpTask) {
        lstFilters.add('FollowUp Task = ' + selFollowUpTask);
        //
        filterResults.add('Task_Assigned__c = ' + selFollowUpTask );
        //}
        
        offsetSize = 0;
        System.Debug('filterResults :- '+filterResults);
        runSearch();
        //
    }
    
    // Clear Filter List
    //   
    public void clearFilter() {
        selMemberType = '--Select One--';
        selMemberstat = '--Select One--';
        selAcctOwnerName = '';
        selectedJobTitle = '--Select One--';
        selectedLeadClassification = '--Select One--';
        selectedProductOpportunity = '--Select One--';
        selFollowUpField = '';
        selFollowUpTask = false;
        //
        runSearch();
        //
    }
    
    // function used to do nothing, but rerender tab
    //
    public void doNothing() {
        //
        isAddAll = false;
        getDisplayList();
        campIdMemberMap.clear();
        removeUnSelCampaignMembersMap.clear();
        //
    }
    

}