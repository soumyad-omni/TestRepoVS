/**********************************************************************
Name:  OpportunityTriggerHandler
Copyright Â© 2018
======================================================
======================================================
Purpose: Handler contains method for OpportunityTrigger Events 
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1          ?                          ?          INITIAL DEVELOPMENT
***********************************************************************/
public class OpportunityTriggerHandler implements ITriggerHandler{
    // Allows unit test (or other code) to disable this trigger for the transaction
    public static boolean TriggerDisabled= false;
    public static boolean isFirstRun = True;
    public boolean isDisabled;
    //Trigger execution check 
    public static Boolean runBeforeTriggerOnce = true;
    public static Boolean opportunityChanged = false;
    //public static boolean isperfoptyupdate = false; //Added by sravan on DEC 3 for performance center error
    //Decimal amount;
    Map<id,Decimal> amountMap = new Map<id,Decimal>();
    // Check to see if the trigger has been disabled by either custom setting or code
    public boolean IsDisabled(){
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('OpportunityTriggerDisabled');
        if(tc != null) isDisabled= tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
    }
    
    //=============================================================================
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems){
        opportunityChanged = true;
        //isperfoptyupdate = true; //Added by sravan on DEC 3 for performance center error
        List<Opportunity> oppList=newItems;
        AccountTriggerHandler.isOppInsert = true;//added by sravan for SF-BUG-518
        /*IBA-1312*/
        if(oppList != null && !oppList.isEmpty()) {
            defineCustomerTypeForOpp(oppList);//IBA-4781
            setOppValues(oppList); //IBA-1988
        }
        if(oppList.size() == 1)
        {
            //TerritoryUtility.populateExchangeRate(oppList[0]);
            TerritoryUtility.updateOpportunityExchangeRate(oppList[0]); //IBA-3993 change
        }
        
        /*IBA-1956 Starts*/
        Set<Id> AssociatedOppId = New Set<Id>();
        Set<Id> AccountIds = New Set<Id>();
        for(Opportunity o : oppList){
            //IBA-3846
            if(o.Health_System_Grouping__c == NULL || o.Health_System_Grouping__c == '') //IBA-5820
               o.Health_System_Grouping__c = o.Health_System_Grouping_Id__c;//IBA-5820
            
            //IBA-4197 Starts
            
            if(o.Professional_Services_Intake_Status__c=='Backwards Timeline Created'){
                o.Backwards_Timeline_Created_Status__c=System.now();
            }
            // IBA-4197 Ends
            
            if(o.Associated_Opportunity__c != null){
                AssociatedOppId.add(o.Associated_Opportunity__c);
            }
            if(o.accountId <> NULL)
            {       
                AccountIds.add(o.accountId);
            }
            //IBA-3846
            if(o.Pre_sale_Timeline_Expired_Date__c< o.CloseDate){
                o.Pre_Sale_Timeline_Expired__c='Yes';
            }
            else{
                o.Pre_Sale_Timeline_Expired__c='No';
            }
            //IBA-5809 Start Saptarsha Panthi
            o.Opportunity_Pull_Counter__c=0;
            o.Opportunity_Push_Counter__c=0;
            //IBA-5809 End Saptarha Panthi
        }
        MAP<Id,Opportunity> orgOpp = new MAP<Id,Opportunity>([Select OpportunityGroup__c from Opportunity where id IN: AssociatedOppId]);
        Map<id, Id> accountCreditForMap = new Map<id, Id>();
        map<id,string> accDiv = new map<id,string>();//IBA-3781
        for(Account acc : [SELECT id, Credit_Approved_For__c, Own_Guarantor__c FROM account WHERE id IN :AccountIds AND (Credit_Approved_For__c <> NULL OR Own_Guarantor__c = TRUE)]) 
        {
            
            if(acc.Credit_Approved_For__c == NULL && acc.Own_Guarantor__c)
                accountCreditForMap.put(acc.id,acc.id);
            else
                accountCreditForMap.put(acc.id,acc.Credit_Approved_For__c);
        }
        for(Account acc : [SELECT id, Division_Account__c FROM account WHERE id IN :AccountIds]) //IBA-3781
        {
            accDiv.put(acc.id,acc.Division_Account__c); //IBA-3781
            
        }
        
        for(Opportunity o : oppList){
            if(accountCreditForMap.containsKey(o.accountId))
            {
                o.Credit_Approved_For__c = accountCreditForMap.get(o.accountId);    
            }
            if(accDiv.containsKey(o.accountId)){//IBA-3781
                o.AccountDivision__c = accDiv.get(o.accountId);
            }
            
            if(o.Credit_Approved_For__c <> NULL && o.Credit_Approved_For__c <> o.AccountId)
            {
                o.Credit_Approval_Date__c = system.today();
                o.Credit_Expiry_Date__c = o.Credit_Approval_Date__c.addyears(2);
            }
            
            Opportunity opp = orgOpp.get(o.Associated_Opportunity__c);
            if(opp != null){
                if(opp.OpportunityGroup__c != o.OpportunityGroup__c){
                    o.OpportunityGroup__c = opp.OpportunityGroup__c;
                }
            }
            if(o.RecordTypeId != opptyRecordTypeNameId('International_Opportunity','Id')){ //IBA-5024 Sourav
                o.ForecastCategoryName = o.Pipeline_Category__c;
            }
        }
        /*IBA-1956 Ends*/    
    }
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
        opportunityChanged = true;
        //isperfoptyupdate = true; //Added by sravan on DEC 3 for performance center error
        //Added by Praneeth for Sf Bug 312
        cannotDeleteOpp(oldItems);
        
    }
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        //soumyad sf-bug-968 start
        List<opportunity> oldValues =  new List<opportunity>();
        oldValues = oldItems.values();
        List<opportunity> newValues =  new List<opportunity>();
        newValues = newItems.values();
        Map<Id, opportunity> oldMap = new Map<Id, opportunity>(oldValues);
        Map<Id, opportunity> newMap = new Map<Id, opportunity>(newValues); //IBA-3397
        List<String> changeFields = new List<String>();
        User us = new User();
        us =  [select id,User_ID__c,profile.Name from User where profileid =: UserInfo.getProfileId() AND id =: UserInfo.getUserId() limit 1]; // Added and id =: UserInfo.getUserId() as part of IBA-4984
        set<id> opId = newItems.keyset();//IBA-3846
        //Map<Integer,String> monthMap = new Map<Integer,String>{1 => 'Q1',2 => 'Q1',3 => 'Q1',4 => 'Q2',5 => 'Q2',6 => 'Q2',7 => 'Q3',8 => 'Q3',9 => 'Q3',10 => 'Q4',11 => 'Q4',12 => 'Q4'}; //commented this for IBA-5820 AMAN
        map<id,Opportunity> oppMap = new Map<Id, opportunity>([Select Id, Account.Top_Level_Parent_CSN_Number__c From Opportunity Where id =: opId and //RecordType.Name='U.S & Canada Opportunity']);//IBA-4844 soumyad //removed ,account.SAP_Customer_Number__c this part for IBA-5820
                                                               RecordType.Name IN (:opptyRecordTypeNameId('NAA_Opportunity','Name'), 
                                                                                   :opptyRecordTypeNameId('US_Canada_Advanced_Services','Name'), 
                                                                                   :opptyRecordTypeNameId('US_Canada_Specialty','Name')) ]); //IBA-5992
        /*IBA-1312*/
        /*IBA-2555*/
        /*Below three Lines were commented earlier which I enabled.*/
        if(newValues != null && !newValues.isEmpty()) {
            defineCustomerTypeForOpp(newValues);//IBA-4781
        }
        map<id,string> oppMapNeg = new map<id,string>(); //IBA-3602
        list<id> oppid = new list<id> (); //IBA-3602
        for(opportunity opp : newValues)
        {
            if(opp.RecordTypeId != opptyRecordTypeNameId('International_Opportunity','Id')){ //IBA-5024 Sourav
                opp.ForecastCategoryName = opp.Pipeline_Category__c;
            }
            if((opp.StageName == '7 Closed Lost' || opp.StageName == '6 Closed Won') && (opp.StageName != oldMap.get(opp.Id).StageName))//Added 6 Closed Won to the if condition IBA-6135 Saptarsha Panthi
            {
                opp.CloseDate = system.today();
            }
            if(opp.Credit_Approved_For__c <> oldMap.get(opp.Id).Credit_Approved_For__c)
            {
                Set<String> bookedStatusSet = new Set<String>();
                bookedStatusSet.add('Non Comissionable Booking');
                bookedStatusSet.add('Fully Booked');
                bookedStatusSet.add('Commissionable - No Service PO');
                bookedStatusSet.add('Non Comm. Book - No Service PO');
                // IBA-4182 Starts   bookedStatusSet.add('Non Comm. Book - No Proj. Plan');
                bookedStatusSet.add('Booked with No PO');
                bookedStatusSet.add('Booked with No Service PO');
                bookedStatusSet.add('Booked with No Product PO');  // IBA-4182 Ends
                if(bookedStatusSet.contains(opp.OppStatus__c)){
                    opp.addError('Cannot change guarantor for booked opportunity');
                }
                
                if(opp.Credit_Approved_For__c == NULL)
                {
                    opp.Credit_Approval_Date__c = null;
                    opp.Credit_Expiry_Date__c = null;
                }
                else
                {
                    opp.Credit_Approval_Date__c = system.today();
                    opp.Credit_Expiry_Date__c = opp.Credit_Approval_Date__c.addyears(2);
                }
            }
            //IBA-3602 start
            if(opp.Opportunity__c != oldMap.get(opp.Id).Opportunity__c){
                oppid.add(opp.id);
                if(opp.Opportunity__c == 'Change Order - Credit'){
                    oppMapNeg.put(opp.id,'new credit');
                }else if(oldMap.get(opp.Id).Opportunity__c == 'Change Order - Credit'){
                    oppMapNeg.put(opp.id,'old credit');
                }
            }//IBA-3602 end
            /*IBA-3448 Changes Start: AC*/
            if(opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('International Opportunity').getRecordTypeId()){
                Id currentUserId = UserInfo.getUserId();
                
                if(opp.Credit_Check_Required__c // Removed Requested_Term__c IBA-5934 
                   && opp.Requested_Credit_Value__c != null 
                   && opp.Approved_Credit_Value__c == null){
                       opp.Date_Request_Created__c = Date.today();
                       opp.Requestor_Name__c = currentUserId;
                   }
                If(opp.Credit_Check_Required__c){
                    if (opp.Approved_Credit_Value__c != null && (opp.Approved_Credit_Value__c != oldMap.get(opp.Id).Approved_Credit_Value__c)) {// Removed Approved_Terms__c as part of IBA-5934
                            Set<String> allowedProfiles = new Set<String>{'Business Administrator', 'System Administrator'};
                                Boolean isUserAllowed = allowedProfiles.contains(us.Profile.Name);
                            if (!isUserAllowed) {
                                List<GroupMember> groupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'AR_Team' AND UserOrGroupId = :us.Id LIMIT 1];
                                if (groupMembers.isEmpty()) {
                                    opp.addError('You do not have the required profile or queue membership to update this Opportunity.');
                                }
                            }
                        }
                }
                
                if(opp.Approved_Credit_Value__c != Null  && (opp.Approved_Credit_Value__c != oldMap.get(opp.Id).Approved_Credit_Value__c)){
                                                                                                 opp.Date_Approved__c = Date.today();
                                                                                             }// Removed Approved_Terms__c as part of IBA-5934
                if (((opp.StageName == '6 Closed Won' && oldMap.get(opp.Id).StageName != '6 Closed Won') || (opp.StageName == '4 Negotiate' && oldMap.get(opp.Id).StageName != '4 Negotiate') || (opp.StageName == '5 Finalize' && oldMap.get(opp.Id).StageName != '5 Finalize')) && opp.Credit_Check_Required__c && !opp.Credit_Approval_Check__c) {
                    opp.addError('Completion of Approval steps is mandatory before advancing Opportunity to Stages 4 Negotiate, 5 Finalize or 6-Closed Won.');
                }
            }
            //if(opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('U.S & Canada Opportunity').getRecordTypeId()
            if((opp.RecordTypeId == opptyRecordTypeNameId('NAA_Opportunity','Id') || opp.RecordTypeId == opptyRecordTypeNameId('US_Canada_Advanced_Services','Id') || opp.RecordTypeId == opptyRecordTypeNameId('US_Canada_Specialty','Id'))    //IBA-5992
               && opp.Credit_Check_Required__c == true){
                   opp.Credit_Check_Required__c = false;
               }
            /*IBA-3448 Changes End: AC*/
            
            //if(opp.RecordTypeId==Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('U.S & Canada Opportunity').getRecordTypeId()){//IBA-5992
            if(opp.RecordTypeId==opptyRecordTypeNameId('NAA_Opportunity','Id') || opp.RecordTypeId==opptyRecordTypeNameId('US_Canada_Advanced_Services','Id') || opp.RecordTypeId==opptyRecordTypeNameId('US_Canada_Specialty','Id') ){//IBA-5992
                if(opp.OppStatus__c != oldMap.get(opp.Id).OppStatus__c){//IBA-4600
                    // IBA-4182 Starts
                    if(opp.OppStatus__c=='Booked with No PO' || opp.OppStatus__c=='Booked with No Service PO'|| opp.OppStatus__c=='Booked with No Product PO'){
                        opp.X30_70_Split_Opp__c=True;
                    }
                    if((opp.OppStatus__c=='Non Comissionable Booking' || opp.OppStatus__c=='Fully Booked'|| opp.OppStatus__c=='Commissionable - No Service PO'|| opp.OppStatus__c=='Non Comm. Book - No Service PO') &&
                       (oldMap.get(opp.Id).OppStatus__c=='Booked with No PO' ||oldMap.get(opp.Id).OppStatus__c=='Booked with No Service PO' || oldMap.get(opp.Id).OppStatus__c=='Booked with No Product PO')){
                           opp.Applicable_Comp_Date__c=date.today();
                       }else{
                           opp.Applicable_Comp_Date__c=Null;
                       }
                    // IBA-4182 Ends
                    
                    // IBA-4417 Starts
                    if(opp.OppStatus__c=='Non Comissionable Booking' || opp.OppStatus__c=='Fully Booked'|| opp.OppStatus__c=='Commissionable - No Service PO'|| opp.OppStatus__c=='Non Comm. Book - No Service PO'
                       || opp.OppStatus__c=='Booked with No PO' || opp.OppStatus__c=='Booked with No Service PO'|| opp.OppStatus__c=='Booked with No Product PO'){
                           opp.Professional_Services_Intake_Status__c='Project Scope Handoff';
                           //System.debug('Saptarsha'+datetime.now());
                       }
                }
                
                // IBA-4417 Ends
                if(opp.Professional_Services_Intake_Status__c != oldMap.get(opp.Id).Professional_Services_Intake_Status__c){//IBA-4598
                   
                  
                    if(opp.Professional_Services_Intake_Status__c=='Backwards Timeline Created'){
                        opp.Backwards_Timeline_Created_Status__c=System.now();
                    }
                }
            }
            
            //IBA-3846
            if(opp.Pre_sale_Timeline_Expired_Date__c<opp.CloseDate){
                opp.Pre_Sale_Timeline_Expired__c='Yes';
            }
            else{
                opp.Pre_Sale_Timeline_Expired__c='No';
            }
                /*if(oppMap.containsKey(opp.id)){ 
                if((opp.CloseDate != oldMap.get(opp.Id).CloseDate || opp.X0DUMMY0__c != oldMap.get(opp.Id).X0DUMMY0__c) && 
                   (opp.StageName != '6 Closed Won' && opp.StageName != '7 Closed Lost')){ //IBA-4878 soumyad
                       opportunity op = oppMap.get(opp.Id);
                       string topCsn = op.account.Top_Level_Parent_CSN_Number__c;
                       
                       //removed this part for IBA-5820
                       opp.Health_System_Grouping__c = topCsn + ' - ' + 'NEW'; //IBA-5820 AMAN
                   }
            }IBA-5820 AMAN*/
            //IBA-5809 Start Saptarsha Panthi
            //if((opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('U.S & Canada Opportunity').getRecordTypeId())&&
            if((opp.RecordTypeId==opptyRecordTypeNameId('NAA_Opportunity','Id') || opp.RecordTypeId==opptyRecordTypeNameId('US_Canada_Advanced_Services','Id') || opp.RecordTypeId==opptyRecordTypeNameId('US_Canada_Specialty','Id')) &&   //IBA-4641
               (opp.CloseDate != oldMap.get(opp.Id).CloseDate)){
                   integer newcloseddatemonth = opp.CloseDate.month();
                   integer oldcloseddatemonth = oldMap.get(opp.Id).CloseDate.month();
                   integer newquarter = getQuarter(newcloseddatemonth);
                   integer oldquarter = getQuarter(oldcloseddatemonth);
                   integer newcloseddateyear = opp.CloseDate.year();
                   integer oldcloseddateyear = oldMap.get(opp.Id).CloseDate.year();
                   
                   if(opp.CloseDate > oldMap.get(opp.Id).CloseDate){
                       if((newquarter>oldquarter)||(newcloseddateyear>oldcloseddateyear)){
                           if(oldMap.get(opp.Id).Opportunity_Push_Counter__c==null){
                               opp.Opportunity_Push_Counter__c=1;
                           }
                           else{
                               opp.Opportunity_Push_Counter__c=opp.Opportunity_Push_Counter__c+1;
                           }
                       }
                       
                   }
                   else{
                       if((newquarter<oldquarter)||(newcloseddateyear<oldcloseddateyear)){
                           if(oldMap.get(opp.Id).Opportunity_Pull_Counter__c==null){
                               opp.Opportunity_Pull_Counter__c=1;
                           }
                           else{
                               opp.Opportunity_Pull_Counter__c=opp.Opportunity_Pull_Counter__c+1;
                           }
                           
                       }
                   }
                   //IBA-6135 Start Saptarsha Panthi
                   If((oldMap.get(opp.Id).Opportunity_Pull_Counter__c + 1 < opp.Opportunity_Pull_Counter__c)&& (opp.StageName =='6 CLosed Won' && opp.StageName!=oldMap.get(opp.Id).StageName)){
                       opp.Opportunity_Pull_Counter__c = opp.Opportunity_Pull_Counter__c - 1;
                   }
                   If((oldMap.get(opp.Id).Opportunity_Push_Counter__c + 1 < opp.Opportunity_Push_Counter__c)&& (opp.StageName =='6 CLosed Won' && opp.StageName!=oldMap.get(opp.Id).StageName)){
                       opp.Opportunity_Push_Counter__c = opp.Opportunity_Push_Counter__c - 1;
                   }
                   //IBA-6135 End Saptarsha Panthi
               }
            //IBA-5809 End Saptarsha Panthi
	    //IBA-6135 Start Saptarsha Panthi
            If((oldMap.get(opp.Id).Opportunity_Pull_Counter__c + 1 < opp.Opportunity_Pull_Counter__c)&& (opp.StageName =='6 CLosed Won' && opp.StageName!=oldMap.get(opp.Id).StageName)){
                opp.Opportunity_Pull_Counter__c = opp.Opportunity_Pull_Counter__c - 1;
            }
            //IBA-6135 End Saptarsha Panthi
        }   //IBA-3846 - End
        
        if(newValues.size() == 1 && runBeforeTriggerOnce)
        {
            if((us.profile.Name != 'System Administrator'
                && us.profile.Name != 'Business Administrator' 
                && us.profile.Name != 'International Sales Ops')
               && (oldValues[0].Exchange_Rate_Override__c != newValues[0].Exchange_Rate_Override__c)
               && (oldValues[0].Exchange_Rate__c != newValues[0].Exchange_Rate__c))
            {
                newValues[0].addError('Only Admins and International Sales Ops can change exchange rate') ;
            }
            else if((oldValues[0].oppstatus__c!=Label.Non_Comissionable_Booking
                     ||oldValues[0].oppstatus__c!=Label.Commissionable_Book_No_Service_PO
                     ||oldValues[0].oppstatus__c!=Label.Non_Comm_Book_No_Service_PO
                     // ||oldValues[0].oppstatus__c!=Label.Non_Comm_Book_No_Proj_Plan  IBA-4182 Starts
                     ||oldValues[0].oppstatus__c!=Label.Booked_with_No_PO
                     ||oldValues[0].oppstatus__c!=Label.Booked_with_No_Service_PO
                     ||oldValues[0].oppstatus__c!=Label.Booked_with_No_Product_PO  //IBA-4182 Ends
                     ||oldValues[0].oppstatus__c!=Label.Fully_Booked
                     ||oldValues[0].oppstatus__c!=Label.PO_Received
                     ||oldValues[0].oppstatus__c!=Label.PO_Received_Pending_Paperwork) &&
                    (newValues[0].oppstatus__c==Label.Non_Comissionable_Booking
                     ||newValues[0].oppstatus__c==Label.Commissionable_Book_No_Service_PO
                     ||newValues[0].oppstatus__c==Label.Non_Comm_Book_No_Service_PO
                     // ||newValues[0].oppstatus__c==Label.Non_Comm_Book_No_Proj_Plan IBA-4182 Starts
                     ||newValues[0].oppstatus__c==Label.Booked_with_No_PO
                     ||newValues[0].oppstatus__c==Label.Booked_with_No_Service_PO
                     ||newValues[0].oppstatus__c==Label.Booked_with_No_Product_PO //IBA-4182 Ends
                     ||newValues[0].oppstatus__c==Label.Fully_Booked
                     ||newValues[0].oppstatus__c==Label.PO_Received
                     ||newValues[0].oppstatus__c==Label.PO_Received_Pending_Paperwork))
            {
                //if(newValues[0].Exchange_Rate_Override__c == false)//IBA-3993 method commented out
                //{TerritoryUtility.populateExchangeRate(newValues[0]);} //IBA-3993 method commented out
                if (!newValues[0].Exchange_Rate_Override__c && newValues[0].Pipeline_Category__c != 'Booked' && newValues[0].StageName != '6 Closed Won') //IBA-3993 change
                {TerritoryUtility.updateOpportunityExchangeRate(newValues[0]);} //IBA-3993 change
            }
        }
        //IBA-3993 Start
        if(((newValues[0].RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('International Opportunity').getRecordTypeId())) &&
           ((oldValues[0].Pipeline_Category__c!=newValues[0].Pipeline_Category__c) &&(newValues[0].Pipeline_Category__c=='Booked' && !newValues[0].Exchange_Rate_Override__c))){
               TerritoryUtility.updateOpportunityExchangeRate(newValues[0]);
           }
        //IBA-3993 Start
        //Pabitra IBA-1774
        /*if(((newValues[0].RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('International Opportunity').getRecordTypeId())||
(newValues[0].RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('UK&I and NWE').getRecordTypeId())) &&
((oldValues[0].Pipeline_Category__c!=newValues[0].Pipeline_Category__c) &&(newValues[0].Pipeline_Category__c=='Booked')))*/ 
        if(((newValues[0].RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('International Opportunity').getRecordTypeId())) &&
           ((oldValues[0].Pipeline_Category__c!=newValues[0].Pipeline_Category__c) &&(newValues[0].Pipeline_Category__c=='Booked'))){ //IBA-2711 removed "UK&I and NWE" record type check
               newValues[0].ForecastBookedDate__c=date.today();
               TerritoryUtility.populateBookedExchangeRate(newValues[0]);
           }//End Pabitra IBA-1774
        //IBA-1919 Start Abhrajit  
        if(us.profile.Name != 'System Administrator' && us.profile.Name != 'Business Administrator') {
            //if(((newValues[0].RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('U.S & Canada Opportunity').getRecordTypeId()) &&
            if(((newValues[0].RecordTypeId==opptyRecordTypeNameId('NAA_Opportunity','Id') || newValues[0].RecordTypeId==opptyRecordTypeNameId('US_Canada_Advanced_Services','Id') || newValues[0].RecordTypeId==opptyRecordTypeNameId('US_Canada_Specialty','Id')) &&   //IBA-5992
                ((oldValues[0].Pipeline_Category__c!=newValues[0].Pipeline_Category__c) &&(newValues[0].Pipeline_Category__c != null)))){
                    newValues[0].ForecastUpdate_Date__c=date.today();
                }
            //if((newValues[0].RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('U.S & Canada Opportunity').getRecordTypeId()) &&
            if((newValues[0].RecordTypeId==opptyRecordTypeNameId('NAA_Opportunity','Id') || newValues[0].RecordTypeId==opptyRecordTypeNameId('US_Canada_Advanced_Services','Id') || newValues[0].RecordTypeId==opptyRecordTypeNameId('US_Canada_Specialty','Id')) &&    //IBA-5992
               (oldValues[0].Expected_Bookings__c != newValues[0].Expected_Bookings__c)){
                   newValues[0].Expected_Booking_Updated_Date__c=date.today();
               }
            //if((newValues[0].RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('U.S & Canada Opportunity').getRecordTypeId()) &&
            if((newValues[0].RecordTypeId==opptyRecordTypeNameId('NAA_Opportunity','Id') || newValues[0].RecordTypeId==opptyRecordTypeNameId('US_Canada_Advanced_Services','Id') || newValues[0].RecordTypeId==opptyRecordTypeNameId('US_Canada_Specialty','Id')) &&    //IBA-5992
               (oldValues[0].CloseDate != newValues[0].CloseDate)) {
                   newValues[0].Last_Update_on_Expected_Close_Date__c=date.today();
               }
            //if((newValues[0].RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('U.S & Canada Opportunity').getRecordTypeId()) &&
            if((newValues[0].RecordTypeId==opptyRecordTypeNameId('NAA_Opportunity','Id') || newValues[0].RecordTypeId==opptyRecordTypeNameId('US_Canada_Advanced_Services','Id') || newValues[0].RecordTypeId==opptyRecordTypeNameId('US_Canada_Specialty','Id')) &&    //IBA-5992
               (oldValues[0].ExpectedInstallDate__c != newValues[0].ExpectedInstallDate__c)){
                   newValues[0].Last_Update_on_Expected_Install_Date__c=date.today();
               }
            //if(((newValues[0].RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('U.S & Canada Opportunity').getRecordTypeId()) &&
            if(((newValues[0].RecordTypeId==opptyRecordTypeNameId('NAA_Opportunity','Id') || newValues[0].RecordTypeId==opptyRecordTypeNameId('US_Canada_Advanced_Services','Id') || newValues[0].RecordTypeId==opptyRecordTypeNameId('US_Canada_Specialty','Id')) &&   //IBA-5992
                ((oldValues[0].StageName!=newValues[0].StageName) &&(newValues[0].StageName != null)))){
                    newValues[0].Last_Update_on_Opportunity_Stage__c=date.today();
                }
        } //IBA-1919 End Abhrajit
        //IBA-4546 Start
        List<PermissionSetAssignment> rfpPS = new List<PermissionSetAssignment>();
        String RFPpermissionSetId=null;
        List<RequestforProposalPermissionSetId__c> RfpCustomSetting = RequestforProposalPermissionSetId__c.getall().values();
        if(RfpCustomSetting.size()>0){
            RFPpermissionSetId = RfpCustomSetting[0].PermissionSet_Id__c;
            rfpPS = [ select Id from PermissionSetAssignment where PermissionSetId= :RFPpermissionSetId and AssigneeId =:UserInfo.getUserId()];
        }
        
        //IBA-4546 End
        List<PermissionSetAssignment> psas = [ select Id from PermissionSetAssignment where PermissionSetId IN ( select Id from PermissionSet where Name = 'Professional_Services_Intake') and AssigneeId =: us.id ];//IBA-3846
        
        if ( us.profile.name == 'Sales Representative' || us.profile.name == 'Read Only (Omnicell)' || us.profile.Name == 'Sales Development' || psas.size() > 0 || rfpPS.size() > 0) //Updated if condition for IBA-4546
        {
            for(opportunity opp1 : oldValues){
                if(opp1.OppStatus__c == 'Fully Booked'
                   || opp1.OppStatus__c == Label.Non_Comissionable_Booking
                   || opp1.OppStatus__c == Label.Commissionable_Book_No_Service_PO
                   || opp1.OppStatus__c == Label.Non_Comm_Book_No_Service_PO
                   // || opp1.OppStatus__c == Label.Non_Comm_Book_No_Proj_Plan  IBA-4182 Starts
                   ||opp1.OppStatus__c==Label.Booked_with_No_PO
                   ||opp1.OppStatus__c==Label.Booked_with_No_Service_PO
                   ||opp1.OppStatus__c==Label.Booked_with_No_Product_PO //IBA-4182 Ends 
                  ){
                      //for(opportunity opp : newValues){ IBA-3397
                      if(newMap.containskey(opp1.id)){ //IBA-3397
                          opportunity Opp = newMap.get(opp1.id); //IBA-3397
                          Boolean flag = false;
                          Schema.DescribeSObjectResult objSchema = Opportunity.sObjectType.getDescribe();
                          Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getMap();
                          for (String fieldName : fieldMap.keySet()) {
                              
                              if((oldValues[0].get(fieldName))!=(newValues[0].get(fieldName))) {
                                  changeFields.add(fieldName);
                              }
                          }
                          list<string> passval = new list<String>{'leadsource' ,'priority_opportunity__c' ,'operational_risk_to_customer__c' ,/*'delay_reason__c',*/ 'Professional_Services_Intake__c'}; //Added Professional_Services_Intake__c as part of IBA-2997
						  //delay_reason__c commented as part of IBA-5992 for field deletion
                              list<string> newval = new list<String>();
                          list<string> passvalnew = new list<String>{'Lease_Expiration_Date__c','Self_Install_Desired__c',
                              'cad_drawings_obtained_if_carousel_xr2__c','Turn_Opportunity__c','Training__c','Pre_Sale_Timeline_Expired__c',
                              'Project_Start_Date__c','Staging_Area_Space__c','Anticipated_CAD_Completion_Date__c',/*'First_Requested_Land_Date__c',*/ //Commented as part of IBA-5992 for field deletion
                              'Seismic_Restraint_Required__c','Pre_sale_Timeline_Expired_Date__c','Project_Lead__c','Services_Enablement_Owner__c',
                              'Health_System_Grouping__c','Professional_Services_Intake_Status__c','Status_Reason__c','backwards_timeline_created_status__c',
                              'ExpectedInstallDate__c','Professional_Services_Notes__c',
                              'Last_Update_on_Expected_Install_Date__c'}; //IBA-3846// IBA-4197 //IBA-5334 Saptarsha Panthi
                                  list<string> newval2 = new list<String>(); //IBA-3846
                          
                          Boolean flag2 = false;//IBA-3846
                          Boolean rfppermissionsetflag = false;//IBA-4546
                          for(String str1 : changeFields){                
                              for(String str2 : passval){
                                  if(str1 == str2){
                                      newval.add(str2);
                                  }
                              }
                              //IBA-3846
                              for(String str2 : passvalnew){
                                  if(str1 == str2){
                                      newval2.add(str2);
                                  }
                              }
                          }
                          if(changeFields.size() != newval.size()){
                              flag = true;
                          }
                          if(changeFields.size() != newval2.size()){//IBA-3846
                              flag2 = true;
                          }
                          if(changeFields.contains('request_for_proposal_id__c') && changeFields.size()==1 && rfpPS.size() > 0){//IBA-4546 (Saptarsha) Start
                              rfppermissionsetflag=true; 
                          }//IBA-4546 (Saptarsha) End
                          id actualRecord = opp.Id;
                          system.debug('changeFields '+changeFields);
                          if((flag == true && flag2 == true) && us.profile.name == 'Read Only (Omnicell)' && psas.size() <= 0 && rfppermissionsetflag==false){//IBA-3846 //IBA-4197 //Updated if condition for IBA-4546, As part of IBA-5743 && psas.size() <= 0
                              
                              opp.adderror('For Booked Opportunties Sales Users can only change these fields: Source, Covid19 Priority?, Operational Risk to Customer, Professional Services Intake, Delay Reason, Customer Requested Project Kickoff Date and Professional Services Notes');
                          }
                          if((flag == true && flag2 == true) && us.profile.name == 'Sales Representative' && psas.size() <= 0 && rfppermissionsetflag==false){//IBA-3846 //Updated if condition for IBA-4546, As part of IBA-5743 && psas.size() <= 0
                              opp.adderror('You cannot edit some of the fields due for booked Opportunities');
                          }
                          if( flag2 == true && us.profile.name == 'Sales Development' && psas.size() <= 0 && rfppermissionsetflag==false){//IBA-3846 //Updated if condition for IBA-4546, As part of IBA-5743 psas.size() <= 0 and replaced || with &&
                              opp.adderror('You cannot edit some of the fields due for booked Opportunities');
                          }
                          
                      }
                  }/*else if(opp1.OppStatus__c != 'Open'){ IBA-3397
for(opportunity opp : newValues){
system.debug('changeFields '+opp1.OppStatus__c);
//opp.adderror('Sales Users do not have permission to edit '+opp1.OppStatus__c+' Opportunity');
}
}*/
            }
        }else if((oldValues[0].oppstatus__c==Label.Non_Comissionable_Booking
                  || oldValues[0].oppstatus__c==Label.Commissionable_Book_No_Service_PO
                  ||oldValues[0].oppstatus__c==Label.Non_Comm_Book_No_Service_PO
                  //  ||oldValues[0].oppstatus__c==Label.Non_Comm_Book_No_Proj_Plan IBA-4182 Starts
                  ||oldValues[0].oppstatus__c==Label.Booked_with_No_PO
                  ||oldValues[0].oppstatus__c==Label.Booked_with_No_Service_PO
                  ||oldValues[0].oppstatus__c==Label.Booked_with_No_Product_PO  //IBA-4182 Ends
                  || oldValues[0].oppstatus__c==Label.Fully_Booked) 
                 && (/*us.profile.Name == 'Sales Development'
||*/us.profile.Name == 'Sales Manager'
                     ||us.profile.Name == 'Inside Sales - MA'
                     ||us.profile.Name == 'International Sales France'
                     ||us.profile.Name == 'International Sales Representative'
                     ||us.profile.Name == 'International Sales UK'
                 )){//IBA-3846
                     newValues[0].addError('Sales users cannot edit booked Opportunities') ;
                 }
        /*if(oldValues[0].oppstatus__c==Label.Fully_Booked){ IBA-3846
if((us.profile.Name == 'Sales Development'
||us.profile.Name == 'Sales Manager'
||us.profile.Name == 'Inside Sales - MA'
||us.profile.Name == 'International Sales France'
||us.profile.Name == 'International Sales Representative'
||us.profile.Name == 'International Sales UK')){
newValues[0].addError('Sales users cannot edit booked Opportunities') ;
}
}*///IBA-2611 End Abhrajitc
        opportunityChanged = true;
        //isperfoptyupdate = true; //Added by sravan on DEC 3 for performance center error
        Boolean checkFlag;
        checkFlag = false;
        if(checkFlag == false)
            checkFlag = true;
        if(checkFlag == true){
            checkFlag= false;
            List<Opportunity> oppList1=newItems.values();
            oppList1 = newItems.values();
            if(oppList1.size()>0)
                checkFlag = true;
        }
        if(runBeforeTriggerOnce){
            List<Opportunity> oppList=newItems.values();
            //updateAnnuityCount(oldItems, oppList);
            getIVProductLine(oppList);
            //updateIVPC(oppList);
            //checkStage(oppList); 
            runBeforeTriggerOnce = false;
            
            //For all Primary Quotes, update the Expected Booking field on Opportunity with SAP Expected Booking value for specific status values of Quote Added by Sravan on 06/17
            
            List<opportunity> oldopp = oldItems.values();
            List<Opportunity> newopp = newItems.values();
            Boolean checkStat = false;
            Boolean setFlag = false;//IBA-2111
            List<Quote> quotesprimary = [select id,sap_expected_bookings__c,opportunityid,Booking_Date__c,Primary_Quote__c from quote where opportunityid =:newItems.keyset() and Primary_Quote__c = true];
            //Added isdelete__c,Quote__c in the query for SF-BUG-744 by Sravan /*isdelete__c*/
            List<Product_Line__c> prdlines = [select id,Quote__c,Amount__c,opportunity__c from Product_Line__c where opportunity__c=:newItems.keyset() and quote__c = null];
            //List<Product_Line__c> prdlinestoDelete = new List<Product_Line__c>();
            for(integer i=0;i<newopp.size();i=i+1){
                System.debug('opp Status : '+newopp[i].oppstatus__c);
                /*for(Product_Line__c pl : prdlines){//Added by sravan to delete product lines if isdelete is true for SF-BUG-744 START
if(pl.isdelete__c == true && pl.Quote__c == null){
prdlinestoDelete.add(pl);
}
}//Added by sravan to delete product lines if isdelete is true for SF-BUG-744 END*/
                ////Added by Sravan on 27 AUG for SF-BUG-566
                if(newopp[i].CurrencyIsoCode != oldopp[i].CurrencyIsoCode){
                    for(Product_Line__c pl : prdlines){
                        System.debug('amount : '+pl.Amount__c);
                        pl.CurrencyIsoCode = newopp[i].CurrencyIsoCode;
                    }
                    ProductLineTriggerHandler.isFromOppcurrupdate = true;
                    update prdlines;
                }///Added by Sravan on 27 AUG for SF-BUG-566
                if(newopp[i].StageName != oldopp[i].StageName){ //Added by Sourav for IBA-1347
                    // Added if statement and RecordtypeId check in Else if as part of IBA-5036 for International SH
                    if(((oldopp[i].StageName == '6 Closed Won')||(oldopp[i].StageName == '7 Closed Lost')) && newopp[i].RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('International Opportunity').getRecordTypeId()){
                        if((newopp[i].StageName != '6 Closed Won')&&(newopp[i].StageName != '7 Closed Lost')){
                            newopp[i].Pipeline_Category__c = 'Committed';
                        }
                    }else if(((oldopp[i].StageName == '6 Closed Won')||(oldopp[i].StageName == '7 Closed Lost')) && newopp[i].RecordTypeId != Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('International Opportunity').getRecordTypeId()){
                        if((newopp[i].StageName != '6 Closed Won')&&(newopp[i].StageName != '7 Closed Lost')){
                            newopp[i].Pipeline_Category__c = 'Development';
                        }
                    }
                }
                //IBA-2111
                if(oldopp[i].oppstatus__c != newopp[i].oppstatus__c ) {
                    setFlag = true;
                }
                if(newopp[i].oppstatus__c != oldopp[i].oppstatus__c && (newopp[i].oppstatus__c==Label.Non_Comissionable_Booking
                                                                        ||newopp[i].oppstatus__c==Label.Commissionable_Book_No_Service_PO
                                                                        ||newopp[i].oppstatus__c==Label.Non_Comm_Book_No_Service_PO
                                                                        //     ||newopp[i].oppstatus__c==Label.Non_Comm_Book_No_Proj_Plan IBA-4182 Starts
                                                                        ||newopp[i].oppstatus__c==Label.Booked_with_No_PO
                                                                        ||newopp[i].oppstatus__c==Label.Booked_with_No_Service_PO
                                                                        ||newopp[i].oppstatus__c==Label.Booked_with_No_Product_PO  //IBA-4182 Ends
                                                                        ||newopp[i].oppstatus__c==Label.Fully_Booked
                                                                        || newopp[i].oppstatus__c == Label.PO_Received_Pending_Paperwork
                                                                        || newopp[i].oppstatus__c == Label.PO_Received
                                                                        //IBA-2010 && IBA-2095
                                                                       )){
                                                                           checkStat = true;
                                                                           System.debug('checkStat : inside loop'+checkStat);
                                                                           boolean hasprimary = false;
                                                                           for(integer j=0;j<quotesprimary.size();j=j+1){
                                                                               if(quotesprimary[j].opportunityid == newopp[i].id){
                                                                                   newopp[i].expected_bookings__c = quotesprimary[j].sap_expected_bookings__c;
                                                                                   hasprimary = true;
                                                                               } 
                                                                           }
                                                                           /*if(!hasprimary){
newopp[i].expected_bookings__c = 0;
}*/                                                                         //commenting the code as Productline deletion is handled by ProdLineSegBSegForPriQuote_Class        
                                                                           /*  if(hasprimary && newopp[i].oppstatus__c != Label.PO_Received_Pending_Paperwork && newopp[i].oppstatus__c != Label.PO_Received){ //IBA-2095
for(Integer k=0;k<prdlines.size();k=k+1){
if(prdlines[k].opportunity__c == newopp[i].id)
prdlinestoDelete.add(prdlines[k]);
}
}*/
                                                                       }
            }
            //IBA-2111
            if(setFlag == true) {
                setRecalculateTeamValue(oldopp,newopp);
            }
            /*if(prdlinestoDelete.size()>0)
System.debug('checkStat : '+checkStat);
ProductLineTriggerHandler.isFromOppUpdate = true;
delete prdlinestoDelete;
*/
        }
        if(oppid.size() > 0)//IBA-3602
            udpatePLamount(oppid,oppMapNeg); //IBA-3602
    }
    
    //=============================================================================
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){
        //IBA-4546 Starts (Saptarsha)
        Boolean runRFPupdateafterdelete=false;
        Set<Id>rfpidstage = new Set<Id>();
        Set<Id>rfpidexpectedbook = new Set<Id>();
        List<Opportunity> oppList=oldItems.values(); 
        for(Opportunity o: oppList)
        {
            if(o.Request_for_Proposal_Id__c!=null)
            {
                runRFPupdateafterdelete=true;
                if(o.Expected_Bookings__c!=null){
                    rfpidexpectedbook.add(o.Request_for_Proposal_Id__c);
                }
                
                if(o.StageName=='6 Closed Won'){
                    rfpidstage.add(o.Request_for_Proposal_Id__c);
                }
            }  
        }
        if(runRFPupdateafterdelete==true){
            UpdateRFPforOpportunities deleterfp =new UpdateRFPforOpportunities();
            deleterfp.RFPupdateafteroppsdelete(rfpidstage, rfpidexpectedbook, oppList);
        }
        //IBA-4546 Ends (Saptarsha)
    }
    //=============================================================================
    // AFTER UNDELETE
    //=============================================================================
    public void afterUndelete(Map<Id, SObject> oldItems){
        //isperfoptyupdate = true; //Added by sravan on DEC 3 for performance center error
        
    }
    //=============================================================================
    // AFTER INSERT
    //=============================================================================
    public void afterInsert(Map<Id, SObject> newItems){
        Boolean runRFPupdateafterInsert=false;
        Set<Id>rfpidstage = new Set<Id>();//IBA-4546
        
        //IBA-3937 starts SH
        Boolean COTMisDisabled; 
        Class_Configuration__c cc = Class_Configuration__c.getInstance('CreateOpportunityTeamMembers');
        if(cc != null) COTMisDisabled = cc.isDisabled__c;
        //IBA-3937 ends
        
        //isperfoptyupdate = true; //Added by sravan on DEC 3 for performance center error
        Boolean checkFlag;
        checkFlag = false;
        if(checkFlag == false)
            checkFlag = true;
        if(checkFlag == true){
            checkFlag= false;
            List<Opportunity> oppList1=newItems.values();
            oppList1 = newItems.values();
            if(oppList1.size()>0)
                checkFlag = true;
        }
        //IBA-2917 starts 
        List<Opportunity> oppListToAdd= new List<Opportunity>();
        oppListToAdd=  newItems.values();
        for(Opportunity o : oppListToAdd){
            //IBA-4546 Start --Saptarsha
            if(o.Request_for_Proposal_Id__c!=null)
            {
                runRFPupdateafterInsert=true;
                if(o.StageName=='6 Closed Won'||o.StageName=='7 closed Lost'){
                    rfpidstage.add(o.Request_for_Proposal_Id__c);
                }            
            }
            //IBA-4546 End --Saptarsha
            OpportunityTriggerHandler.isFirstRun = false;
            Opportunity_Field_History__c oppHistory = new Opportunity_Field_History__c();
            oppHistory.Opportunity__c = o.Id;
            oppHistory.Field__c = 'Created';
            oppHistory.User__c = UserInfo.getUserId();
            oppHistory.Date__c = DateTime.now();
            insert oppHistory;
        }
        //IBA-2917 ends 
        if(AvoidRecursion.isFirstRun()){
            // SF-BUG-592 Start
            //List<Opportunity> oppList=newItems.values();
            //populateOpportunityTeam(newItems.values()); 
            Set<Id> accountIds = new Set<Id>();
            if(!(System.IsBatch()|| System.isQueueable() || System.isScheduled()|| System.isFuture()) &&  !QuoteTriggerHandler.quoteUpdated)
            {
                List<Opportunity> oppUpdatedList= new List<Opportunity>();
                oppUpdatedList = newItems.values();
                for(Opportunity opp:oppUpdatedList){
                    if(opp.AccountId != null && !accountIds.contains(opp.AccountId)){
                        accountIds.add(opp.AccountId);
                    }
                } 
                List<Id> idList = new List<Id>();        
                Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>([Select Id, AccountId, Territory2Id from Opportunity 
                                                                              where AccountId IN :accountIds 
                                                                              and Account.IsDeleted__c = false Limit 50000 ]);
                idList.addAll(opportunityMap.keySet());
                OpportunityTerritoryAssign handler = new OpportunityTerritoryAssign();
                handler.getOpportunityTerritory2Assignments(idList);  
                List<Opportunity> oppFullList = [SELECT Id, AccountId, Territory2Id, OwnerId, Account.Facility_Type__c from Opportunity 
                                                 WHERE Id IN :idList and Account.IsDeleted__c = false
                                                 AND (OppStatus__c ='PO Received - Pending Paperwork' OR 
                                                      OppStatus__c ='PO Received' OR OppStatus__c ='Open')];
                
                if(COTMisDisabled == false){ //IBA-3937 if starts
                    CreateOpportunityTeamMembers job = new CreateOpportunityTeamMembers();
                    job.oppFullList = oppFullList; 
                    if(!Test.isRunningTest()){
                        System.enqueueJob(job);
                    }
                } //IBA-3937 if ends             
            }
            // SF-BUG-592 End
            //IBA-3397 createForecastAndCogsDimension(newItems.values());
        } 
        //IBA-4546 Start --Saptarsha
        if(runRFPupdateafterInsert==true){
            UpdateRFPforOpportunities insertrfp =new UpdateRFPforOpportunities();
            insertrfp.RFPupdateafteroppsinsert(rfpidstage, oppListToAdd);
        }
        //IBA-4546 Start --Saptarsha
    } 
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        //IBA-4546 Starts (Saptarsha)
        Map<Id,Id> newopprfpmap = new Map<Id,Id>();//IBA-4546
        Set<Id>rfpidstage = new Set<Id>();//IBA-4546
        Set<Id>rfpidexpectedbook = new Set<Id>();//IBA-4546
        Set<Id>oldrfpid = new Set<Id>();//IBA-4546
        Set<Id>newrfpid = new Set<Id>();//IBA-4546
        Set<Id>oppidsPLtoadd = new Set<Id>();//IBA-4546     
        Boolean runRFPupdate=false;//IBA-4546
        List<opportunity> oldvalues = oldItems.values();//IBA-4546
        List<opportunity> newvalues = newItems.values();//IBA-4546
        Map<Id, opportunity> oldMap = new Map<Id, opportunity>(oldvalues);//IBA-4546
        list<Opportunity_Field_History__c> opphistoriesToInsert = new list<Opportunity_Field_History__c>();//Moved this line ahead for IBA-5809 Saptarsha Panthi
        //IBA-5809 Start Saptarsha Panthi
        Schema.DescribeFieldResult PushReasonPickist =Opportunity.Opportunity_Push_Reason__c.getDescribe();
        Map<String,String> PushReasonPickistMap = getPickListMap(PushReasonPickist);
        System.debug(PushReasonPickistMap);
        Schema.DescribeFieldResult PullReasonPickist =Opportunity.Opportunity_Pull_Reason__c.getDescribe();
        Map<String,String> PullReasonPickistMap = getPickListMap(PullReasonPickist);
        System.debug(PullReasonPickistMap);
        //IBA-5809 End Saptarsha Panthi
        //IBA-5024 Start Sourav
        Schema.DescribeFieldResult pickListToGetMap1=Opportunity.Funding_Approved_for_Release__c.getDescribe();
        Schema.DescribeFieldResult pickListToGetMap2=Opportunity.Budget_Approved__c.getDescribe();
        Schema.DescribeFieldResult pickListToGetMap3=Opportunity.Walkthrough_Guides_Complete__c.getDescribe();
        //Schema.DescribeFieldResult pickListToGetMap4=Opportunity.Walkthrough_Guide_Complete_Date__c.getDescribe();
        Schema.DescribeFieldResult pickListToGetMap5=Opportunity.Final_Approval_Process__c.getDescribe();
        Schema.DescribeFieldResult pickListToGetMap6=Opportunity.Known_Procurement_Process__c.getDescribe();
        Schema.DescribeFieldResult pickListToGetMap7=Opportunity.Key_Stakeholder_Alignment__c.getDescribe();
        Schema.DescribeFieldResult pickListToGetMap8=Opportunity.Final_Approval_Acquired__c.getDescribe();
        Schema.DescribeFieldResult pickListToGetMap9=Opportunity.Configurations_Confirmed__c.getDescribe();
        Schema.DescribeFieldResult pickListToGetMap10=Opportunity.Risk_to_Current_Quarter__c.getDescribe();
        Schema.DescribeFieldResult pickListToGetMap11=Opportunity.Sales_Process_Kickoff_Meeting__c.getDescribe();
        Schema.DescribeFieldResult pickListToGetMap12=Opportunity.Step_10_IT_Engagement__c.getDescribe();
        Schema.DescribeFieldResult pickListToGetMap13=Opportunity.Step_11_Implementation_Review__c.getDescribe();
        Schema.DescribeFieldResult pickListToGetMap14=Opportunity.EBC_Site_Visit_and_or_Ref_Call__c.getDescribe();
        Schema.DescribeFieldResult pickListToGetMap15=Opportunity.Step_2_Workflow_Business_Analysis__c.getDescribe();
        Schema.DescribeFieldResult pickListToGetMap16=Opportunity.GAP_Analysis_and_Tech_Comparisons__c.getDescribe();
        Schema.DescribeFieldResult pickListToGetMap17=Opportunity.Data_Collection_and_Validation__c.getDescribe();
        Schema.DescribeFieldResult pickListToGetMap18=Opportunity.Step_5_Finance_Review__c.getDescribe();
        Schema.DescribeFieldResult pickListToGetMap19=Opportunity.Step_6_ROI_or_Proforma_Review__c.getDescribe();
        Schema.DescribeFieldResult pickListToGetMap20=Opportunity.Step_7_Validate_Procurement_Process__c.getDescribe();
        Schema.DescribeFieldResult pickListToGetMap21=Opportunity.Blueprinting_documents_on_QAP__c.getDescribe();
        Schema.DescribeFieldResult pickListToGetMap22=Opportunity.Step_9_Customer_Success_Engagement__c.getDescribe();


        Map<String,String> PickistMap1 = getPickListMap(pickListToGetMap1);
        Map<String,String> PickistMap2 = getPickListMap(pickListToGetMap2);
        Map<String,String> PickistMap3 = getPickListMap(pickListToGetMap3);
        //Map<String,String> PickistMap4 = getPickListMap(pickListToGetMap4);
        Map<String,String> PickistMap5 = getPickListMap(pickListToGetMap5);
        Map<String,String> PickistMap6 = getPickListMap(pickListToGetMap6);
        Map<String,String> PickistMap7 = getPickListMap(pickListToGetMap7);
        Map<String,String> PickistMap8 = getPickListMap(pickListToGetMap8);
        Map<String,String> PickistMap9 = getPickListMap(pickListToGetMap9);
        Map<String,String> PickistMap10 = getPickListMap(pickListToGetMap10);
        Map<String,String> PickistMap11 = getPickListMap(pickListToGetMap11);
        Map<String,String> PickistMap12 = getPickListMap(pickListToGetMap12);
        Map<String,String> PickistMap13 = getPickListMap(pickListToGetMap13);
        Map<String,String> PickistMap14 = getPickListMap(pickListToGetMap14);
        Map<String,String> PickistMap15 = getPickListMap(pickListToGetMap15);
        Map<String,String> PickistMap16 = getPickListMap(pickListToGetMap16);
        Map<String,String> PickistMap17 = getPickListMap(pickListToGetMap17);
        Map<String,String> PickistMap18 = getPickListMap(pickListToGetMap18);
        Map<String,String> PickistMap19 = getPickListMap(pickListToGetMap19);
        Map<String,String> PickistMap20 = getPickListMap(pickListToGetMap20);
        Map<String,String> PickistMap21 = getPickListMap(pickListToGetMap21);
        Map<String,String> PickistMap22 = getPickListMap(pickListToGetMap22);
        //IBA-5024 End Sourav
        for(Opportunity opp: newvalues){
            if(opp.Request_for_Proposal_Id__c!=Null){
                if(opp.StageName != oldMap.get(opp.Id).StageName && (opp.StageName=='6 Closed Won' || opp.StageName=='7 Closed Lost'||oldMap.get(opp.Id).StageName=='6 Closed Won') ){
                    runRFPupdate=true;
                    rfpidstage.add(opp.Request_for_Proposal_Id__c);
                }
                if(opp.Expected_Bookings__c!=oldMap.get(opp.Id).Expected_Bookings__c){
                    runRFPupdate=true;
                    rfpidexpectedbook.add(opp.Request_for_Proposal_Id__c); 
                }
            } 
            if(opp.Request_for_Proposal_Id__c!=oldMap.get(opp.Id).Request_for_Proposal_Id__c){
                runRFPupdate=true;
                if(oldMap.get(opp.Id).Request_for_Proposal_Id__c!=null){
                    oldrfpid.add(oldMap.get(opp.Id).Request_for_Proposal_Id__c);
                }
                newopprfpmap.put(opp.Id,opp.Request_for_Proposal_Id__c);
                if(opp.Request_for_Proposal_Id__c!=null){
                    newrfpid.add(opp.Request_for_Proposal_Id__c);
                }
                oppidsPLtoadd.add(opp.Id);
            }
            //IBA-5809 Start Saptarsha Panthi
            if((opp.Opportunity_Push_Counter__c!=oldMap.get(opp.Id).Opportunity_Push_Counter__c)&&
               (opp.Opportunity_Push_Reason__c==oldMap.get(opp.Id).Opportunity_Push_Reason__c)&& (opp.Opportunity_Push_Reason__c!=null)){//IBA-6135 Saptarsha Panthi Updated if condition.
                   Opportunity_Field_History__c oppHistory = new Opportunity_Field_History__c();
                   oppHistory.Opportunity__c = opp.Id;
                   oppHistory.Field__c = 'Opportunity Push Reason';
                   oppHistory.User__c = UserInfo.getUserId(); 
                   oppHistory.Date__c = Datetime.now();
                   if (oldMap.get(opp.Id).Opportunity_Push_Reason__c != null) {
                       oppHistory.ORIGINAL_VALUE__c = PushReasonPickistMap.get(oldMap.get(opp.Id).Opportunity_Push_Reason__c);
                   }
                   System.debug('1:'+oppHistory.ORIGINAL_VALUE__c);
                       if (opp.Opportunity_Push_Reason__c != null) {
                           oppHistory.NEW_VALUE__c = PushReasonPickistMap.get(opp.Opportunity_Push_Reason__c);
                       }
                   System.debug('2:'+oppHistory.ORIGINAL_VALUE__c);
                   opphistoriesToInsert.add(oppHistory);
               }
            if((opp.Opportunity_Pull_Counter__c!=oldMap.get(opp.Id).Opportunity_Pull_Counter__c)&&
               (opp.Opportunity_Pull_Reason__c==oldMap.get(opp.Id).Opportunity_Pull_Reason__c) && (opp.Opportunity_Pull_Reason__c!=null)){//IBA-6135 Saptarsha Panthi Updated if condition.
                   Opportunity_Field_History__c oppHistory = new Opportunity_Field_History__c();
                   oppHistory.Opportunity__c = opp.Id;
                   oppHistory.Field__c = 'Opportunity Pull Reason';
                   oppHistory.User__c = UserInfo.getUserId(); 
                   oppHistory.Date__c = Datetime.now();
                   if (oldMap.get(opp.Id).Opportunity_Pull_Reason__c != null) oppHistory.ORIGINAL_VALUE__c = PullReasonPickistMap.get(oldMap.get(opp.Id).Opportunity_Pull_Reason__c);
                   if (opp.Opportunity_Pull_Reason__c != null) oppHistory.NEW_VALUE__c = PullReasonPickistMap.get(opp.Opportunity_Pull_Reason__c);
                   opphistoriesToInsert.add(oppHistory);
               }
            //IBA-5809 End Saptarsha Panthi
        }
        //IBA-4546 Ends (Saptarsha)
        
        //IBA-3937 starts
        Boolean COTMisDisabled; 
        Class_Configuration__c cc = Class_Configuration__c.getInstance('CreateOpportunityTeamMembers');
        if(cc != null) COTMisDisabled = cc.isDisabled__c;
        //IBA-3937 ends
        
        //isperfoptyupdate = true; //Added by sravan on DEC 3 for performance center error
        Profile p = [Select id,Name from Profile Where id=: userInfo.getProfileId()];
        Boolean isStatusBooked = false;
        Boolean poFlag=false;
        Boolean isOppoOwnerUpdate = false; //Adding new flag for IBA-2933
        Boolean updateTotalContractval = false; //Adding new flag for IBA-3640
        System.debug('inside afterupdate...............');
        if(AvoidRecursion.isFirstRun()){
            
            List<opportunity> oldoptys = oldItems.values();
            List<Opportunity> newoptys = newItems.values();
            Boolean checkStat = false;
            Boolean checkRecalculateFlag = false; //IBA-2111
            Boolean sendEmailFlag = false; /*Adding new email sending flag: AC:IBA-3448*/
            List<Quote> quotesprimary = [select Id,Primary_Quote__c,Status,OpportunityId from quote where opportunityid =:newItems.keyset() and Primary_Quote__c = true];
            List<Opportunity> oppData = new List<Opportunity>();//3356 by Salman.
            for(integer i=0;i<newoptys.size();i=i+1){
                //Added by Salman for IBA-3556
                if((newoptys[i].Pipeline_Category__c!=oldoptys[i].Pipeline_Category__c) || (newoptys[i].stagename != oldoptys[i].stagename && newoptys[i].stagename == '6 Closed Won') || (newoptys[i].stagename != oldoptys[i].stagename && newoptys[i].stagename == '7 Closed Lost')){
                    oppData.add(newoptys[i]);
                }
                System.debug('opp Status : '+newoptys[i].oppstatus__c);
                if((newoptys[i].oppstatus__c!=oldoptys[i].oppstatus__c)
                   &&(newoptys[i].oppstatus__c==Label.Non_Comissionable_Booking
                      ||newoptys[i].oppstatus__c==Label.Commissionable_Book_No_Service_PO
                      ||newoptys[i].oppstatus__c==Label.Non_Comm_Book_No_Service_PO
                      ||newoptys[i].oppstatus__c==Label.Non_Comm_Book_No_Proj_Plan
                      ||newoptys[i].oppstatus__c==Label.Fully_Booked
                      //|| newoptys[i].oppstatus__c == Label.PO_Received_Pending_Paperwork
                      //|| newoptys[i].oppstatus__c == Label.PO_Received
                      //IBA-2010
                     ) && (newoptys[i].X30_70_Split_Opp__c==false)){  
                         isStatusBooked = true;
                         if(newoptys[i].OwnerId==oldoptys[i].OwnerId) //Added by Sourav Das SF-BUG-943
                         {
                             System.debug('************'+oldoptys[0].OwnerId+'++++++++'+newoptys[0].OwnerId);
                             checkStat = true;
                         }
                     }
                //IBA-2111
                if(oldoptys[i].Recalculate_Team__c != newoptys[i].Recalculate_Team__c  && newoptys[i].Recalculate_Team__c == true){
                    checkRecalculateFlag = true;
                }
                if(newoptys[i].Expected_Bookings__c != oldoptys[i].Expected_Bookings__c && newoptys[i].Expected_Bookings__c != null && newoptys[i].Opportunity__c =='Specialty'){ // adding logic for IBA-3640
                    updateTotalContractval = true;
                }
                // IBA-4182
                if((newoptys[i].oppstatus__c!=oldoptys[i].oppstatus__c) && ( newoptys[i].oppstatus__c==Label.Booked_with_No_PO || newoptys[i].oppstatus__c==Label.Booked_with_No_Product_PO
                                                                            ||newoptys[i].oppstatus__c==Label.Booked_with_No_Service_PO)){
                                                                                poFlag=true;
                                                                            } //IBA-4182
                /*IBA-3448 AC: Change Start*/
                if (newoptys[i].Credit_Check_Required__c == true
                    && newoptys[i].Credit_Check_Required__c != oldoptys[i].Credit_Check_Required__c
                    && newoptys[i].Requested_Credit_Value__c != null
                    // && !String.isBlank(newoptys[i].Requested_Term__c) IBA-5934
                    // && String.isBlank(newoptys[i].Approved_Terms__c) IBA-5934 
                    && newoptys[i].RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('International Opportunity').getRecordTypeId()) {
                        sendEmailFlag = true;
                    }
                /*IBA-3448 AC: Change Ends*/
            }
            /*IBA-3448 AC: Change Start*/
            if (sendEmailFlag) {
                Opportunity_SendEmail__c emailFlag = [Select Send_Email__c From Opportunity_SendEmail__c Where Name = 'Opportunity SendEmail' Limit 1];
                if (emailFlag != null && emailFlag.Send_Email__c) {
                    for (Opportunity opp : newoptys) {
                        sendOpportunityEmail(opp.Id);
                    }
                }
            }
            /*IBA-3448 AC: Change Ends*/
            if( poFlag== true){   // IBA-4182
                
                ProdLineSegBSegForPriQuote_Class obj = new ProdLineSegBSegForPriQuote_Class();
                obj.initiateProductUpdates(quotesprimary,quotesprimary);
            } 
            // IBA-4182 
            if( isStatusBooked== true){      
                
                ProdLineSegBSegForPriQuote_Class obj = new ProdLineSegBSegForPriQuote_Class();
                obj.initiateProductUpdates(quotesprimary,quotesprimary);
            }
            Set<Id> optyIds = new Set<Id>();
            Set<id> OppIdsWithCreditChange = new Set<id>();
            for(Opportunity newOpp : newoptys){
                Opportunity oldOpp = (Opportunity) oldItems.get(newOpp.id);
                System.debug('newOpp.Credit_Approved_For__c:'+newOpp.Credit_Approved_For__c);
                System.debug('newOpp.Credit_Approved_For__c:'+oldOpp.Credit_Approved_For__c);
                System.debug('newOpp.PrimaryQuote__r.Status:'+newOpp.PrimaryQuote__r.Status);
                if(newOpp.Credit_Approved_For__c != oldOpp.Credit_Approved_For__c ){
                    OppIdsWithCreditChange.add(newOpp.id);
                }
                optyIds.add(newOpp.id);
            }
            List<Quote> PrimaryBookedQuotes = [Select id,name,OpportunityId from Quote where status in ('E0013','E0014') and OpportunityId in:optyIds]; //IBA-3828
            Map<id,id> oppsWithPrimaryQuotes = new Map<id,id>();
            for(Quote q:PrimaryBookedQuotes){
                oppsWithPrimaryQuotes.put(q.OpportunityId, q.OpportunityId);
            }
            for(Opportunity opp: newoptys){
                Opportunity oldOpp = (Opportunity) oldItems.get(opp.id);
                if(!oppsWithPrimaryQuotes.isEmpty() && oppsWithPrimaryQuotes.get(opp.id) != null
                   && opp.Credit_Approved_For__c <> oldOpp.Credit_Approved_For__c){
                       opp.addError('Quote is already booked for this opportunity. Credit Approved For cannot be changed');
                   }
            }
            
            List<Opportunity> oppList=newItems.values();
            Map<Id,Opportunity> childOptyMap=new Map<Id,Opportunity>();
            Map<Id,Opportunity> salesQuotaOptyMap=new Map<Id,Opportunity>();
            Map<Id,Opportunity> ownerUpdatedOptyMap=new Map<Id,Opportunity>();
            system.debug('hello');
            For(Opportunity opp: oppList){
                Opportunity oldOpp=(Opportunity)oldItems.get(opp.Id);
                system.debug(oldOpp);
                System.debug(opp);
                if(opp.Opportunity__c=='Annuity' && oldOpp.Opportunity__c!=opp.Opportunity__c){
                    if(! childOptyMap.containsKey(opp.Id))
                        childOptyMap.put(opp.Id,opp);
                }
                if(opp.StageName=='6 Closed Won' && oldOpp.OppStatus__c !=opp.OppStatus__c && (opp.OppStatus__c == 'Fully Booked' || opp.OppStatus__c == 'Commissionable - No Service PO')){ 
                    if(! salesQuotaOptyMap.containsKey(opp.Id))
                        salesQuotaOptyMap.put(opp.Id,opp);
                }
                //Updated Query by Pavan palla as part of new XR2 & IVX changes IBA-1135 Nov-Release
                if(opp.OwnerId!=NULL && oldOpp.OwnerId !=opp.OwnerId || (oldOpp.As_Service__c != opp.As_Service__c)
                   || (oldOpp.Credit_Approved_For__c != opp.Credit_Approved_For__c)){ 
                       if(! ownerUpdatedOptyMap.containsKey(opp.Id))
                           ownerUpdatedOptyMap.put(opp.Id,opp);
                   }
            }
            
            if(childOptyMap.values().size()>0)
                CreateChildOpty(oldItems,oppList);
            if(ownerUpdatedOptyMap.values().size()>0){
                UpdateQuoteOwner(oppList);
                updateQuoteApprvOptyOwner(oppList); //IBA-1004
            }
            if(salesQuotaOptyMap.values().size()>0){
                System.debug('Inside createSalesOpty');
                createSalesQuotaOpty(oppList);
                
            }
            List<Opportunity> otyList = new List<Opportunity>();
            //Added by Venu Kukkapalli as part of bug 266
            Map<Opportunity,Id> otyAccMap = new Map<Opportunity,Id>();
            //Bug 355
            List<Opportunity> pefOppList = new List<Opportunity>();
            for(Opportunity opp:oppList){
                Opportunity oldOpp=(Opportunity)oldItems.get(opp.Id);
                if(opp.stageName != '6 Closed Won' && opp.stageName !='7 Closed Lost' && !otyList.contains(opp))
                    otyList.add(opp);
                if(opp.stageName != '6 Closed Won' && opp.stageName !='7 Closed Lost' && oldopp.AccountId != opp.AccountId && !otyAccMap.containsKey(opp))
                    otyAccMap.put(opp,oldopp.AccountId);
                if(opp.Performance_Center_Product_Line__c != oldOpp.Performance_Center_Product_Line__c && opp.Performance_Center_Product_Line__c == False && !pefOppList.contains(opp))
                    pefOppList.add(opp);
            }
            //Modified by Rajat for SF-BUG-254
            /* IBA-3397 if(otyAccMap.size()>0 && (p.Name == System.Label.SystemAdministrator || p.Name == system.Label.BusinessAdministrator || p.Name == system.Label.Booking_Team)){
deleteOldOptyTeam(otyAccMap);
}*/
            /*if(otyList.size()>0) IBA-3397
populateOpportunityTeam(otyList);*/
            //Modified by Rajat for SF-BUG-254
            if(pefOppList.size()>0 && (p.Name == System.Label.SystemAdministrator || p.Name == system.Label.BusinessAdministrator || p.Name == system.Label.Booking_Team))
                deleteProductline(pefOppList);
            //SF-BUG-454 start
            if(!(System.IsBatch()|| System.isQueueable() || System.isScheduled()|| System.isFuture())) //&& !QuoteTriggerHandler.quoteUpdated //IBA-2933
            { 
                List<Id> idList = new List<Id>(); 
                idList.addAll(newItems.keySet());
                OpportunityTerritoryAssign handler = new OpportunityTerritoryAssign();
                handler.getOpportunityTerritory2Assignments(idList);
                List<Opportunity> oppFullList2 = [SELECT Id, AccountId, Territory2Id, OwnerId, Account.Facility_Type__c from Opportunity 
                                                  WHERE Id IN :idList and Account.IsDeleted__c = false
                                                  AND (OppStatus__c ='PO Received - Pending Paperwork' OR 
                                                       OppStatus__c ='PO Received' OR OppStatus__c ='Open')];
                
                if(COTMisDisabled == false){ //IBA-3937 if starts
                    CreateOpportunityTeamMembers job1 = new CreateOpportunityTeamMembers();
                    job1.oppFullList = oppFullList2; 
                    if(!Test.isRunningTest()){
                        System.enqueueJob(job1);
                    }
                } //IBA-3937 if ends
                
                //IBA-4182 starts
                if(poFlag == true && COTMisDisabled == false) { //added COTMisDisabled == false as part of IBA-3937
                    List<Opportunity> oppFullList1 = [SELECT Id, AccountId, Territory2Id, OwnerId, Account.Facility_Type__c from Opportunity 
                                                      WHERE Id IN :newItems.keyset()];
                    
                    CreateOpportunityTeamMembers job = new CreateOpportunityTeamMembers();
                    job.oppFullList = oppFullList1; 
                    System.enqueueJob(job);
                }
                // IBA-4182 ends 
                //IBA-2010 & //IBA-2111
                if(isStatusBooked == true && checkRecalculateFlag == true && COTMisDisabled == false) { //added COTMisDisabled == false as part of IBA-3937
                    List<Opportunity> oppFullList1 = [SELECT Id, AccountId, Territory2Id, OwnerId, Account.Facility_Type__c from Opportunity 
                                                      WHERE Id IN :newItems.keyset()];
                    
                    CreateOpportunityTeamMembers job = new CreateOpportunityTeamMembers();
                    job.oppFullList = oppFullList1; 
                    System.enqueueJob(job);
                }
            }
            //SF-BUG-454 end
            //SF-BUG-969 start
            if(!(System.IsBatch()|| System.isQueueable() || System.isScheduled()|| System.isFuture())&& !QuoteTriggerHandler.quoteUpdated)
            {
                Set<String> bookedStatusSet = new Set<String>();
                bookedStatusSet.add('Non Comissionable Booking');
                bookedStatusSet.add('Fully Booked');
                bookedStatusSet.add('Commissionable - No Service PO');
                bookedStatusSet.add('Non Comm. Book - No Service PO');
                //   bookedStatusSet.add('Non Comm. Book - No Proj. Plan');  IBA-4182
                bookedStatusSet.add('Booked with No PO');
                bookedStatusSet.add('Booked with No Service PO');
                bookedStatusSet.add('Booked with No Product PO'); // IBA-4182
                if(oppList.size() == 1)
                {
                    for(Opportunity opp:oppList){
                        Opportunity oldOpp=(Opportunity)oldItems.get(opp.Id);
                        if(oldOpp.OppStatus__c != opp.OppStatus__c && bookedStatusSet.contains(oldOpp.OppStatus__c) && !bookedStatusSet.contains(opp.OppStatus__c))
                        {
                            CreateCampaignInfluence.deleteCampaignInfluences(opp.Id);
                        }
                        else if(oldOpp.OppStatus__c != opp.OppStatus__c && !bookedStatusSet.contains(oldOpp.OppStatus__c) && bookedStatusSet.contains(opp.OppStatus__c))
                        {
                            CreateCampaignInfluence.addCampaignInfluences(opp.Id);
                        }
                    }  
                }
                
            }
            //SF-BUG-969 end
            //IBA-3356
            Set<String> oppRTforNetSuite = new Set<String>();//IBA-4831 Start
            List<NetSuite_Opp_RecordType__c> allnetsuiteRecType = NetSuite_Opp_RecordType__c.getall().values();
            for(NetSuite_Opp_RecordType__c rdType: allnetsuiteRecType){
                oppRTforNetSuite.add(rdType.Name);
            }
            Set<String> quoteOrderTypeforNetSuite = new Set<String>();
            List<NetSuite_Quote_Order_Type__c> allnetsuitequoteOrderTypes = NetSuite_Quote_Order_Type__c.getall().values();
            for(NetSuite_Quote_Order_Type__c qtOrdType: allnetsuitequoteOrderTypes){
                quoteOrderTypeforNetSuite.add(qtOrdType.Name);
            }
            Map<Id,Quote> quotesendToNetSuite = new Map<Id,Quote>([Select Id From Quote Where Opportunity.RecordType.Name IN :oppRTforNetSuite 
                                                                   AND NetSuite_ID__c = '' 
                                                                   AND Status = 'E0024' AND Opportunity.OpportunityGroup__c = 'Advanced Services' 
                                                                   AND Order_Type__c IN :quoteOrderTypeforNetSuite AND Opportunity.StageName = '6 Closed Won' 
                                                                   AND ECC_Sales_Order_Number__c != '' AND OpportunityId IN :newItems.keySet()]); 
            if(quotesendToNetSuite.keySet().size()>0){
                system.enqueueJob(new OrderInfoSendToNetSuiteQueueable(quotesendToNetSuite.keySet()));
            }
            //IBA-4831 End
        }
        //IBA-2917 starts
        List<opportunity> oldoptys = oldItems.values();
        List<Opportunity> newoptys = newItems.values();
        list<Opportunity_Field_Tracking__c> s = [select name from Opportunity_Field_Tracking__c];
        list<string> s1 = new list<string>();
        for(Opportunity_Field_Tracking__c i : s){
            s1.add(i.name);
        }
        set<string> st = new set<string>();
        st.addall(s1);
        Map<String, Schema.SObjectField> allOppFieldsMap = Schema.SObjectType.Opportunity.fields.getMap();
        Map<String, Schema.DescribeFieldResult> oppFieldsToTrack = new Map<String, Schema.DescribeFieldResult>();
        for (Schema.SObjectField oppField : allOppFieldsMap.values()) {
            Schema.DescribeFieldResult describeResult = oppField.getDescribe();
            
            if (describeResult.getName() != 'CreatedDate' &&
                describeResult.getName() != 'LastModifiedDate' &&
                describeResult.getName() != 'SystemModstamp' &&
                describeResult.isAccessible() &&
                !describeResult.isCalculated()
               )
            {
                oppFieldsToTrack.put(describeResult.getName(), describeResult);
            }
            
        }
        Opportunity newa = (Opportunity)newoptys[0];
        Opportunity olda = (Opportunity)oldoptys[0];
        for (Schema.DescribeFieldResult fieldDescribe : oppFieldsToTrack.values()) {
            if (olda.get(fieldDescribe.getName()) != newa.get(fieldDescribe.getName())) {
                System.debug('***'+st+'****'+fieldDescribe.getName().toUpperCase());
                if(st.contains(fieldDescribe.getName().toUpperCase()) == true){
                    if(fieldDescribe.getName().toUpperCase() == 'ACCOUNTID'){
                        string oppOld = '';
                        string oppNew = '';
                        if(string.valueOf((olda.get(fieldDescribe.getName()))) != null){
                            oppOld = [select name from Account where id =: string.valueOf((olda.get(fieldDescribe.getName()))) limit 1].name;
                        }
                        if(string.valueOf((newa.get(fieldDescribe.getName()))) != null){
                            oppNew = [select name from Account where id =: string.valueOf((newa.get(fieldDescribe.getName()))) limit 1].name;
                        }
                        Opportunity_Field_History__c oppHistory = createUpdateHistory(fieldDescribe, oppOld, oppNew, newa);
                        oppHistory.Field__c = 'Account Name';
                        opphistoriesToInsert.add(oppHistory);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'CREDIT_APPROVED_FOR__C'){
                        string oppOld = '';
                        string oppNew = '';
                        if(string.valueOf((olda.get(fieldDescribe.getName()))) != null){
                            oppOld = [select name from Account where id =: string.valueOf((olda.get(fieldDescribe.getName()))) limit 1].name;
                        }
                        if(string.valueOf((newa.get(fieldDescribe.getName()))) != null){
                            oppNew = [select name from Account where id =: string.valueOf((newa.get(fieldDescribe.getName()))) limit 1].name;
                        }
                        Opportunity_Field_History__c oppHistory = createUpdateHistory(fieldDescribe, oppOld, oppNew, newa);
                        opphistoriesToInsert.add(oppHistory);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'ASSOCIATED_OPPORTUNITY__C'){
                        string oppOld = '';
                        string oppNew = '';
                        if(string.valueOf((olda.get(fieldDescribe.getName()))) != null){
                            oppOld = [select name from Opportunity where id =: string.valueOf((olda.get(fieldDescribe.getName()))) limit 1].name;
                        }
                        if(string.valueOf((newa.get(fieldDescribe.getName()))) != null){
                            oppNew = [select name from Opportunity where id =: string.valueOf((newa.get(fieldDescribe.getName()))) limit 1].name;
                        }
                        Opportunity_Field_History__c oppHistory = createUpdateHistory(fieldDescribe, oppOld, oppNew, newa);
                        opphistoriesToInsert.add(oppHistory);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'COMPETITOR__C'){
                        string oppOld = '';
                        string oppNew = '';
                        if(string.valueOf((olda.get(fieldDescribe.getName()))) != null){
                            oppOld = [select name from Account where id =: string.valueOf((olda.get(fieldDescribe.getName()))) limit 1].name;
                        }
                        if(string.valueOf((newa.get(fieldDescribe.getName()))) != null){
                            oppNew = [select name from Account where id =: string.valueOf((newa.get(fieldDescribe.getName()))) limit 1].name;
                        }
                        Opportunity_Field_History__c oppHistory = createUpdateHistory(fieldDescribe, oppOld, oppNew, newa);
                        opphistoriesToInsert.add(oppHistory);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'OwnerId'){
                        string oppOld = '';
                        string oppNew = '';
                        if(string.valueOf((olda.get(fieldDescribe.getName()))) != null){
                            oppOld = [select name from User where id =: string.valueOf((olda.get(fieldDescribe.getName()))) limit 1].name;
                        }
                        if(string.valueOf((newa.get(fieldDescribe.getName()))) != null){
                            oppNew = [select name from User where id =: string.valueOf((newa.get(fieldDescribe.getName()))) limit 1].name;
                        }
                        Opportunity_Field_History__c oppHistory = createUpdateHistory(fieldDescribe, oppOld, oppNew, newa);
                        oppHistory.Field__c = 'Opportunity Owner';
                        opphistoriesToInsert.add(oppHistory);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'RECORDTYPEID'){
                        string oppOld = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(string.valueOf((olda.get(fieldDescribe.getName())))).getName();
                        string oppNew = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(string.valueOf((newa.get(fieldDescribe.getName())))).getName();
                        
                        Opportunity_Field_History__c oppHistory = createUpdateHistory(fieldDescribe, oppOld, oppNew, newa);
                        opphistoriesToInsert.add(oppHistory);
                        
                    }
                    
                    //IBA-4945 Starts
                    else if(fieldDescribe.getName().toUpperCase() == 'PAW_PHASE__C'){
                        Schema.DescribeFieldResult fieldResult = Opportunity.PAW_PHASE__C.getDescribe();
                        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
                        
                        Map<String,String> MapValueLabel = new Map<String,String>();
                        String publicLabel1;
                        String publicLabel2;
                        
                        for( Schema.PicklistEntry v : values) {
                            MapValueLabel.put(v.getValue(),v.getLabel());        
                        }
                        
                        publicLabel1 = MapValueLabel.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 = MapValueLabel.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        opphistoriesToInsert.add(oppHistory);
                    }
                    
                    else if(fieldDescribe.getName().toUpperCase() == 'PAW_PROJECT_STATUS__C'){
                        Schema.DescribeFieldResult fieldResult = Opportunity.PAW_PROJECT_STATUS__C.getDescribe();
                        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
                        
                        Map<String,String> MapValueLabel = new Map<String,String>();
                        String publicLabel1;
                        String publicLabel2;
                        
                        for( Schema.PicklistEntry v : values) {
                            MapValueLabel.put(v.getValue(),v.getLabel());        
                        }
                        
                        publicLabel1 = MapValueLabel.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 = MapValueLabel.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        opphistoriesToInsert.add(oppHistory);
                    }
                    
                    
                    
                    else if (fieldDescribe.getName().toUpperCase() == 'DATE_IN_PHASE__C') {
                        Date dateOld = (Date)olda.get(fieldDescribe.getName());
                        Date dateNew = (Date)newa.get(fieldDescribe.getName());
                        
                        String publicLabel1 = null;
                        String publicLabel2 = null;
                        
                        if (dateOld != null) {
                            publicLabel1 = String.valueOf(dateOld.month()).leftPad(2, '0') + '-' + String.valueOf(dateOld.day()).leftPad(2, '0') + '-' + String.valueOf(dateOld.year());
                        }
                        
                        if (dateNew != null) {
                            publicLabel2 = String.valueOf(dateNew.month()).leftPad(2, '0') + '-' + String.valueOf(dateNew.day()).leftPad(2, '0') + '-' + String.valueOf(dateNew.year());
                        }
                        
                        Opportunity_Field_History__c oppHistory = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        opphistoriesToInsert.add(oppHistory);
                    }
                    
                    
                    //IBA-4945 ENDS
                    else if(fieldDescribe.getName().toUpperCase() == 'STATUS_REASON__C'){//IBA-4197 Start
                        Schema.DescribeFieldResult fieldResult = Opportunity.STATUS_REASON__C.getDescribe();
                        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
                        
                        Map<String,String> MapValueLabel = new Map<String,String>();
                        String publicLabel1;
                        String publicLabel2;
                        
                        for( Schema.PicklistEntry v : values) {
                            MapValueLabel.put(v.getValue(),v.getLabel());        
                        }
                        
                        publicLabel1 = MapValueLabel.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 = MapValueLabel.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        opphistoriesToInsert.add(oppHistory);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'PROFESSIONAL_SERVICES_INTAKE_STATUS__C'){
                        Schema.DescribeFieldResult fieldResult = Opportunity.PROFESSIONAL_SERVICES_INTAKE_STATUS__C.getDescribe();
                        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
                        
                        Map<String,String> MapValueLabel = new Map<String,String>();
                        String publicLabel1;
                        String publicLabel2;
                        
                        for( Schema.PicklistEntry v : values) {
                            MapValueLabel.put(v.getValue(),v.getLabel());        
                        }
                        
                        publicLabel1 = MapValueLabel.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 = MapValueLabel.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        opphistoriesToInsert.add(oppHistory);
                    }//IBA-4197 End
                    //IBA-5809 Start Saptarsha Panthi
                    else if(fieldDescribe.getName().toUpperCase() == 'OPPORTUNITY_PUSH_REASON__C'){
                        
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PushReasonPickistMap.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 = PushReasonPickistMap.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory.Field__c = 'Opportunity Push Reason';
                        opphistoriesToInsert.add(oppHistory);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'OPPORTUNITY_PULL_REASON__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PullReasonPickistMap.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 = PullReasonPickistMap.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory.Field__c = 'Opportunity Pull Reason';
                        opphistoriesToInsert.add(oppHistory);
                    }
                    //IBA-5809 End Saptarsha Panthi
                    //IBA-5024 Start Sourav 
                    else if(fieldDescribe.getName().toUpperCase() == 'FUNDING_APPROVED_FOR_RELEASE__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap1.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap1.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory1 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory1.Field__c = 'Funding Approved for Release';
                        opphistoriesToInsert.add(oppHistory1);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'BUDGET_APPROVED__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap2.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap2.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory2 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory2.Field__c = 'Budget Approved';
                        opphistoriesToInsert.add(oppHistory2);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'WALKTHROUGH_GUIDES_COMPLETE__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap3.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap3.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory3 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory3.Field__c = 'Walkthrough Guides Complete';
                        opphistoriesToInsert.add(oppHistory3);
                    }
                    
                    else if(fieldDescribe.getName().toUpperCase() == 'FINAL_APPROVAL_PROCESS__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap5.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap5.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory5 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory5.Field__c = 'Final Approval Process';
                        opphistoriesToInsert.add(oppHistory5);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'KNOWN_PROCUREMENT_PROCESS__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap6.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap6.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory6 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory6.Field__c = 'Known Procurement Process';
                        opphistoriesToInsert.add(oppHistory6);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'KEY_STAKEHOLDER_ALIGNMENT__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap7.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap7.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory7 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory7.Field__c = 'Key Stakeholder Alignment';
                        opphistoriesToInsert.add(oppHistory7);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'FINAL_APPROVAL_ACQUIRED__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap8.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap8.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory8 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory8.Field__c = 'Final Approval Acquired';
                        opphistoriesToInsert.add(oppHistory8);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'CONFIGURATIONS_CONFIRMED__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap9.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap9.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory9 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory9.Field__c = 'Configurations Confirmed';
                        opphistoriesToInsert.add(oppHistory9);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'RISK_TO_CURRENT_QUARTER__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap10.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap10.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory10 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory10.Field__c = 'Risk to Current Quarter';
                        opphistoriesToInsert.add(oppHistory10);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'SALES_PROCESS_KICKOFF_MEETING__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap11.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap11.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory11 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory11.Field__c = 'Step 1 - Sales Process Kickoff Meeting';
                        opphistoriesToInsert.add(oppHistory11);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'STEP_10_IT_ENGAGEMENT__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap12.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap12.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory12 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory12.Field__c = 'Step 10 - IT Engagement';
                        opphistoriesToInsert.add(oppHistory12);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'STEP_11_IMPLEMENTATION_REVIEW__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap13.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap13.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory13 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory13.Field__c = 'Step 11 - Implementation Review';
                        opphistoriesToInsert.add(oppHistory13);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'EBC_SITE_VISIT_AND_OR_REF_CALL__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap14.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap14.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory14 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory14.Field__c = 'Step 12 - EBC Site Visit and/or Ref Call';
                        opphistoriesToInsert.add(oppHistory14);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'STEP_2_WORKFLOW_BUSINESS_ANALYSIS__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap15.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap15.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory15 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory15.Field__c = 'Step 2 - Workflow & Business Analysis';
                        opphistoriesToInsert.add(oppHistory15);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'GAP_ANALYSIS_AND_TECH_COMPARISONS__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap16.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap16.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory16 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory16.Field__c = 'Step 3 - GAP Analysis & Tech Comparisons';
                        opphistoriesToInsert.add(oppHistory16);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'DATA_COLLECTION_AND_VALIDATION__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap17.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap17.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory17 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory17.Field__c = 'Step 4 - Data Collection and Validation';
                        opphistoriesToInsert.add(oppHistory17);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'STEP_5_FINANCE_REVIEW__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap18.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap18.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory18 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory18.Field__c = 'Step 5 - Finance Review';
                        opphistoriesToInsert.add(oppHistory18);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'STEP_6_ROI_OR_PROFORMA_REVIEW__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap19.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap19.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory19 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory19.Field__c = 'Step 6 - ROI or Proforma Review';
                        opphistoriesToInsert.add(oppHistory19);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'STEP_7_VALIDATE_PROCUREMENT_PROCESS__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap20.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap20.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory20 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory20.Field__c = 'Step 7 - Validate Procurement Process';
                        opphistoriesToInsert.add(oppHistory20);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'BLUEPRINTING_DOCUMENTS_ON_QAP__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap21.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap21.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory21 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory21.Field__c = 'Step 8 - Blueprinting (documents on QAP)';
                        opphistoriesToInsert.add(oppHistory21);
                    }
                    else if(fieldDescribe.getName().toUpperCase() == 'STEP_9_CUSTOMER_SUCCESS_ENGAGEMENT__C'){
                        String publicLabel1;
                        String publicLabel2;
                        publicLabel1 = PickistMap22.get(string.valueOf((olda.get(fieldDescribe.getName()))));
                        publicLabel2 =  PickistMap22.get(string.valueof((newa.get(fieldDescribe.getName()))));
                        Opportunity_Field_History__c oppHistory22 = createUpdateHistory(fieldDescribe, publicLabel1, publicLabel2, newa);
                        oppHistory22.Field__c = 'Step 9 - Customer Success Engagement';
                        opphistoriesToInsert.add(oppHistory22);
                    }
                    
                    // IBA-5024 ENd Sourav
                    else{
                        Opportunity_Field_History__c oppHistory = createUpdateHistory(fieldDescribe, string.valueOf((olda.get(fieldDescribe.getName()))), string.valueof((newa.get(fieldDescribe.getName()))), newa);
                        if(oppHistory.Field__c == 'Expected Close Date' || oppHistory.Field__c == 'Expected Install Date' || oppHistory.Field__c == 'Next Step Date' ||
                           oppHistory.Field__c == 'Specialty Open Date'||oppHistory.Field__c == 'Projected Revenue Date ' || oppHistory.Field__c == 'Project Start Date' || 
                           oppHistory.Field__c == 'Anticipated CAD Completion Date' || oppHistory.Field__c == 'First Requested Land Date' || 
                           oppHistory.Field__c == 'Pre-sale Timeline Expired Date' || oppHistory.Field__c == 'Customer Requested Project Kickoff Date' || 
                           oppHistory.Field__c == 'Walkthrough Guide Complete Date'){ //IBA-3846  //IBA-5024 Sourav
                               if(oppHistory.ORIGINAL_VALUE__c != null){
                                   List<String> oldv = oppHistory.ORIGINAL_VALUE__c.split(' ');
                                   List<String> oldDate =   oldv[0].split('-');
                                   String originalVal = oldDate[1]+'-'+ oldDate[2]+'-'+oldDate[0];
                                   oppHistory.ORIGINAL_VALUE__c = originalVal ;
                               }
                               if(oppHistory.NEW_VALUE__c!= null ){
                                   List<String> newv = oppHistory.NEW_VALUE__c.split(' ');
                                   List<String> newDate =   newv[0].split('-');
                                   String newVal = newDate[1]+'-'+ newDate[2]+'-'+newDate[0];
                                   oppHistory.NEW_VALUE__c = newVal; 
                               }
                               
                           }
                        if(oppHistory.Field__c == 'Name'){
                            oppHistory.Field__c = 'Opportunity Name';
                        }
                        if(oppHistory.Field__c == 'Expected Booking'){
                            String oldv = oppHistory.ORIGINAL_VALUE__c;
                            String newv = oppHistory.NEW_VALUE__c;
                            
                            String se = ( Decimal.valueOf(oldv==null?'0':oldv).setScale(2) + 0.001 ).format();
                            String pe = se.substring(0,se.length()-1);
                            String nse = ( Decimal.valueOf(newv==null?'0':newv).setScale(2) + 0.001 ).format();
                            String npe = nse.substring(0,nse.length()-1);
                            
                            oppHistory.ORIGINAL_VALUE__c = olda.CurrencyIsoCode+' '+ pe;
                            oppHistory.NEW_VALUE__c = newa.CurrencyIsoCode+' '+npe;
                            
                        }
                        opphistoriesToInsert.add(oppHistory);
                    }
                    
                }
            }
        }
        if (!opphistoriesToInsert.isEmpty()) {
            List<Opportunity_Field_History__c> historiesToInsertWithoutDuplicates = new List<Opportunity_Field_History__c>();
            Set<Opportunity_Field_History__c> historiesSet = new Set<Opportunity_Field_History__c>();
            historiesSet.addAll(opphistoriesToInsert);
            historiesToInsertWithoutDuplicates.addAll(historiesSet);
            System.debug('*****historiesToInsertWithoutDuplicates'+ historiesToInsertWithoutDuplicates);
            if(OpportunityTriggerHandler.isFirstRun){
                OpportunityTriggerHandler.isFirstRun = false;
                insert historiesToInsertWithoutDuplicates;
            }
            
        }
        //IBA-2917 ends
        //IBA-3640 starts
        if(updateTotalContractval == true){
            //  System.debug('@@@@@@@@@updateTotalContractval Calling');
            System.enqueueJob(new UpdateTotalContractValue(Trigger.New));
            
        } //IBA-3640 ends
        //IBA-4546 Start --Saptarsha
        if(runRFPupdate==true){
            UpdateRFPforOpportunities updaterfp =new UpdateRFPforOpportunities();
            updaterfp.RFPupdateafteroppsupdate(oldrfpid, newrfpid, rfpidexpectedbook, rfpidstage, oppidsPLtoadd, newvalues, oldMap, newopprfpmap);
        }
        //IBA-4546 End --Saptarsha
    }
    
    /*Public void updateAnnuityCount(Map<Id, SObject> oldItems, List<Opportunity> newItems){
for(Opportunity op:newItems){
Opportunity opp=(Opportunity)oldItems.get(op.Id);
if(op.Opportunity__c!= opp.Opportunity__c && op.Opportunity__c=='Annuity')
op.Annuity_Count__c++;
}
}*/
    
    /*public static void checkStage(List<Opportunity> oppList){ IBA-3397
//26-05
List<Opportunity> testList = new List<Opportunity>();
testList = oppList;
Boolean check;
check = false;
if(check == false)
check = true;
if(check = true)
testList = NULL;
//
for(Opportunity opp:oppList){
if(opp.ownerId==userInfo.getUserId()&& (opp.StageName=='6 Closed Won' || opp.StageName=='7 Closed Lost'))
opp.adderror('You do not have permission to change'); 
}
String str=userInfo.getUserId();
System.debug(str);
}*/
    
    // This method is to get information related to IV Product Line 
    public void getIVProductLine(List<Opportunity> oppList){
        //26-05
        List<Opportunity> testList = new List<Opportunity>();
        testList = oppList;
        Boolean check;
        check = false;
        if(check == false)
            check = true;
        if(check = true)
            testList = NULL;
        //
        Map<id,OPPORTUNITY> oqMap=new Map<id,OPPORTUNITY>();
        
        for(Opportunity op:oppList){
            if(op.PrimaryQuote__c!=NULL){
                oqMap.put(op.PrimaryQuote__c,op);
            }    
        }
        /* List<Product_Line__c> pList = [SELECT Id,amount__c FROM Product_Line__c Where Quote__c =: oqMap.keyset()];
if(pList.size()>0){
for(Opportunity o:oppList){
for(Product_Line__c p:pList){
amountMap.put(o.id,p.amount__c);
}
}
}*/
        List<Product_Segment__c> pList = [SELECT Id,amount__c,opportunity__c FROM Product_Segment__c Where Quote__c =: oqMap.keyset() and product_segment__c = 'Performance Center'];
        System.debug('PList------------------------------------------'+pList);
        if(pList.size()>0){
            //for(Opportunity o:oppList){
            for(Product_Segment__c p:pList){
                //amountMap.put(o.id,p.amount__c);
                amountMap.put(p.Opportunity__c, p.Amount__c);
            }
            //}
        }
        System.debug('Amount Map:--------------------------------------'+amountMap);
        List<Quote_Line__c> qlList=[SELECT ID, IV_Product_Line__c,Quote__c FROM Quote_Line__c Where Quote__c =: oqMap.keyset() limit 1];
        for(Quote_Line__c ql: qlList){
            Integer count=0;
            if(ql.IV_Product_Line__c==TRUE){
                System.debug(oqMap.get(ql.Quote__c));
                oqMap.get(ql.Quote__c).IV_Product_Line__c=TRUE;
                count++;
            }                        
            if(count== 0)
                oqMap.get(ql.Quote__c).IV_Product_Line__c=FALSE;
        }
        /* for(Opportunity opp: oppList){
if(opp.PrimaryQuote__c!=NULL){
Integer count=0;
for(Quote_Line__c ql: [SELECT ID, IV_Product_Line__c FROM Quote_Line__c Where Quote__c =: opp.PrimaryQuote__c]){

if(ql.IV_Product_Line__c==TRUE){
opp.IV_Product_Line__c=TRUE;
count++;
}                        
}
if(count== 0)
opp.IV_Product_Line__c=FALSE;
}
}*/
    }
    //IBA-1004 Pabitra
    //copy Opportunity owner to QuoteApproval 
    public void updateQuoteApprvOptyOwner(List<Opportunity> oppList){
        Set<Id> optyIds = new Set<Id>();
        for (Opportunity o : oppList){
            optyIds.add(o.Id);
        }
        Map<Id,Opportunity> opptyMap = new Map<Id,Opportunity>([select id,OwnerId from Opportunity where id in:optyIds]);
        Map<Id,Quote> quoteMap = new Map<Id,Quote>([Select Id,OpportunityId,Opportunity_Owner__c from Quote where OpportunityId in :optyIds]);
        List<Quote_Approval__c> quoteApprvList=[SELECT Id,Quote__c,Opportunity_Owner__c,Status__c FROM Quote_Approval__c WHERE Quote__c IN:quoteMap.keySet() ];
        List<Quote_Approval__c> quoteApprvToUpdate = new List<Quote_Approval__c>();
        for (Quote_Approval__c qap: quoteApprvList){
            if(qap.Status__c!='Approved' && qap.Status__c!='Rejected'){
                Id oppId=(quoteMap.get(qap.Quote__c)).OpportunityId;
                qap.Opportunity_Owner__c = opptyMap.get(oppId).OwnerId;  
                quoteApprvToUpdate.add(qap);
            }
        }
        if(quoteApprvToUpdate!=null || !quoteApprvToUpdate.isEmpty()){
            QuoteApprovalTriggerHandler.TriggerDisabled =true;
            update quoteApprvToUpdate;
        }
    }//end IBA-1004 Pabitra
    
    //On Quote creation copy Opportunity Owner into Quote.Opportunity Owner.   
    public void UpdateQuoteOwner(List<Opportunity> oppList){
        //26-05
        List<Opportunity> testList = new List<Opportunity>();
        testList = oppList;
        Boolean check;
        check = false;
        if(check == false)
            check = true;
        if(check == true)
            testList = NULL;
        //
        Set<Id> optyIds = new Set<Id>();
        Set<Id> newoptyid = new Set<Id>();
        Map<Id, String> oldOwnerIds = new Map<Id, String>();
        Map<Id, String> newOwnerIds = new Map<Id, String>();
        List<Quote> quoteUpdates = new List<Quote>();
        
        for (Opportunity o : oppList)
        {
            optyIds.add(o.Id);
        }
        
        if (!optyIds.isEmpty()) {
            
            
            // Opportunity opp = [select id,OwnerId from Opportunity where id in:optyIds];
            //Updated Query by Pavan palla as part of new XR2 & IVX changes IBA-1135 Nov-Release
            Map<Id,Opportunity> opp = new Map<Id,Opportunity>([select id,OwnerId,As_Service__c,Credit_Approved_For__c from Opportunity where id in:optyIds]);
            system.debug('opp...'+opp);
            //Updated Query by Pavan palla as part of new XR2 & IVX changes IBA-1135 Nov-Release
            for (Quote q : [Select id,OwnerId,OpportunityId,Order_Type__c,subscription_Months__c,Opportunity_Owner__c,Locked__c,Primary_Quote__c,Early_Adopter_Flag__c from Quote where OpportunityId in :optyIds] )
            {
                
                if(q.Locked__c == false)
                {
                    //Quote updatedquote = new Quote(Id = q.Id, Opportunity_Owner__c = opp.OwnerId);
                    //Updated by Pavan palla as part of new XR2 & IVX changes IBA-1475 
                    Quote updatedquote = new Quote();
                    if(q.Primary_Quote__c){
                        updatedquote=new Quote(Id = q.Id, Credit_Approved_For_Lookup__c = opp.get(q.OpportunityId).Credit_Approved_For__c, Opportunity_Owner__c = opp.get(q.OpportunityId).OwnerId,Early_Adopter_Flag__c=opp.get(q.OpportunityId).As_Service__c);
                        
                        //Updated Query by Pavan palla as part of new XR2 & IVX changes IBA-1475
                        //Updated Query by Pavan palla as part of new XR2 & IVX changes IBA-1135 Nov-Release-UAT Enhancements
                        if(q.Order_Type__c=='ZQRS' && updatedquote.Early_Adopter_Flag__c==True){
                            updatedquote.Resident_Operator_Duration__c=q.subscription_Months__c;
                        }
                        system.debug('updatedquote ...'+updatedquote );
                        quoteUpdates.add(updatedquote);
                    }
                    /*else if(!q.Primary_Quote__c){
updatedquote=new Quote(Id = q.Id, Credit_Approved_For_Lookup__c = opp.get(q.OpportunityId).Credit_Approved_For__c);
system.debug('updatedquote ...'+updatedquote );
quoteUpdates.add(updatedquote);
}*/
                }
                
            }
            try{
                if(quoteUpdates.size()>0)
                {
                    QuoteTriggerHandler.isUpdatefrmOppty = true; //IBA-3828
                    update quoteUpdates;
                }
            }
            catch(Exception e){
                System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
                ErrorLogging.Log(e, 'UpdateQuoteOwner','App');
            }  
            
        }
    }
    
    public void CreateChildOpty(Map<Id, SObject> oldItems,List<Opportunity> opList){
        List<Opportunity> oppList=[SELECT Id,Name,OwnerId,Opportunity__c,AccountId FROM Opportunity WHERE Id in: opList AND Opportunity__c =: 'Annuity'];
        List<Opportunity> ChildOptyInsert = new List<Opportunity>();
        Map<Id,Boolean> annuityCheck=new Map<Id,Boolean>();
        List<Id> ownerList=new List<Id>();
        for(Opportunity op:oppList){
            ownerList.add(op.OwnerId);
        }
        for(User us:[SELECT Id, Annuity_Creator__c FROM User Where Id in: ownerList]){
            annuityCheck.put(us.id,us.Annuity_Creator__c);
        }
        
        Map<Id,Integer> optycount=new Map<Id,Integer>();
        Map<Id,Boolean> childCount=new Map<id,Boolean>();
        for(Opportunity opp:oppList){
            optycount.put(opp.id,0);
            childCount.put(opp.Id,FALSE);
        }
        for(OpportunityFieldHistory ofh:[SELECT Id, OpportunityId, Field, OldValue, NewValue FROM OpportunityFieldHistory where field='Opportunity__c' and opportunityid in : oppList]){
            if(ofh.NewValue=='Annuity'){
                Integer count = 0;
                if(optycount.containsKey(ofh.OpportunityId) ){
                    count = optycount.get(ofh.OpportunityId) + 1;
                }
                optycount.put(ofh.OpportunityId, count);
            }   
        }
        
        for(Opportunity opp: oppList){
            System.debug(opp.Id+'++++++++++++++++'+opp.Opportunity__c+'+++++++++'+annuityCheck.get(opp.OwnerId)+'+++++++++'+optycount.get(opp.Id));
            if(opp.Opportunity__c=='Annuity' && optycount.get(opp.id) == 0 && annuityCheck.get(opp.OwnerId)==TRUE ){
                for(integer i=1;i<13;i++)
                {  
                    opportunity o = new opportunity();
                    o.OwnerId = opp.OwnerId;
                    o.Amount=0;
                    o.Associated_Opportunity__c=opp.Id; 
                    //if(opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('U.S & Canada Opportunity').getRecordTypeId()){//Added for IBA-3745 stage picklist value change for US&CA.
                    if((opp.RecordTypeId==opptyRecordTypeNameId('NAA_Opportunity','Id') || opp.RecordTypeId==opptyRecordTypeNameId('US_Canada_Advanced_Services','Id') ||opp.RecordTypeId==opptyRecordTypeNameId('US_Canada_Specialty','Id'))){ //IBA-5992
                        o.StageName='1 Solution Design';}
                    else
                    {o.StageName='1 Initial Sales Activity';}
                    o.AccountId= opp.AccountId;
                    DateTime dt = system.now();
                    o.CloseDate = dt.date().addmonths(i);
                    o.Name=opp.Name+' - '+'Child - '+i;
                    ChildOptyInsert.add(o);
                }
                
            }           
            
        }
        try{
            System.debug('hello outer');
            if(ChildOptyInsert.size()>0)
            {
                System.debug(ChildOptyInsert);
                insert ChildOptyInsert;
            }  
        }
        catch(system.Dmlexception e){
            System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
            ErrorLogging.Log(e, 'CreateChildOpty','App'); 
        }  
    }
    
    // This method is written by Venu Kukkapalli to populate Opportunity Team from Account Team
    /*Public void populateOpportunityTeam(List<Opportunity> oppList){ IBA-3397

List<OpportunityTeamMember> oppTeamMembersList = new List<OpportunityTeamMember>();
Set<OpportunityTeamMember> oppTeamMembersSet = new Set<OpportunityTeamMember>();
Map< Id , Id > opportunityIdToAccountId = new Map< Id , Id >();
for(Opportunity o : oppList)  {
if(o.AccountId!=NULL)
opportunityIdToAccountId.put(o.Id,  o.AccountId );
}

//map of Account Owner id- Start
Map<id, id > accountOwners =new Map< Id , Id >();
for(Account accountOwner : [SELECT Id, Ownerid FROM Account WHERE Id in :opportunityIdToAccountId.values() ])   
{
accountOwners.put(accountOwner.id, accountOwner.Ownerid);                                          
}

//map of Account Owner id- End
Map<id, List<AccountTeamMember > > accountIdToAccountTeamMembers = new    Map<id,  List<AccountTeamMember > > ();
for(AccountTeamMember accountTeamMember : [SELECT a.UserId,a.User.Name,a.TeamMemberRole, a.Id, a.AccountId
FROM AccountTeamMember a
WHERE a.AccountId in :opportunityIdToAccountId.values() ])   
{
List<AccountTeamMember > accountTeamMembers = ( accountIdToAccountTeamMembers.get(accountTeamMember.Accountid) == null) ? new  List<AccountTeamMember >() :
accountIdToAccountTeamMembers.get(accountTeamMember.Accountid);                                          
accountTeamMembers.add(accountTeamMember);
accountIdToAccountTeamMembers.put(accountTeamMember.Accountid, accountTeamMembers);                                          
}

//Getting Roles Based on Customer Type and Product Line
List<Roles1__mdt> Roles=[SELECT Id, Label, QualifiedApiName, List_of_Roles__c, AllTypes__c FROM Roles1__mdt];
String listofdefRoles;
String listofExtRoles;
String listofIVRoles;
String listofPerfRoles;

for(Roles1__mdt rl: Roles){
if(rl.AllTypes__c == Label.OppTeamPopulate1){
listofdefRoles = rl.List_of_Roles__c;
}
else if(rl.AllTypes__c == Label.OppTeamPopulate2){
listofExtRoles = rl.List_of_Roles__c;
}
else if(rl.AllTypes__c == Label.OppTeamPopulate3){
listofIVRoles = rl.List_of_Roles__c;
}
else if(rl.AllTypes__c == Label.OppTeamPopulate4){
listofPerfRoles = rl.List_of_Roles__c;
}
}

List<String> defaultList= listofdefRoles.split(',');
List<String> extList= listofExtRoles.split(',');
List<String> IVList= listofIVRoles.split(',');
List<String> perfList= listofPerfRoles.split(',');

for(Opportunity o : oppList) {
Id accountId  = opportunityIdToAccountId.get(o.Id);    
Boolean checkAcctOwner = FALSE;
if(accountIdToAccountTeamMembers.get(accountId)!=NULL){
for ( AccountTeamMember accountTeamMember : accountIdToAccountTeamMembers.get(accountId) )  {            
OpportunityTeamMember opportunityTeamMember  = new OpportunityTeamMember();
opportunityTeamMember.UserId = accountTeamMember.UserId;
opportunityTeamMember.TeamMemberRole = accountTeamMember.TeamMemberRole;
opportunityTeamMember.OpportunityId = o.ID;
if(opportunityTeamMember.UserId!=NULL){
if(defaultList.contains(accountTeamMember.TeamMemberRole)){
oppTeamMembersList.add(opportunityTeamMember);
}
if(o.CustomerType__c == Label.OppTeamPopulate2 && extList.contains(accountTeamMember.TeamMemberRole)){
oppTeamMembersList.add(opportunityTeamMember);
}
if(o.IV_Product_Line__c==TRUE && IVList.contains(accountTeamMember.TeamMemberRole)){
oppTeamMembersList.add(opportunityTeamMember);
}
if(o.Performance_Center_Product_Line__c==TRUE && perfList.contains(accountTeamMember.TeamMemberRole)){
oppTeamMembersList.add(opportunityTeamMember);
}
if(accountOwners.get(accountId)==accountTeamMember.UserId){
oppTeamMembersList.add(opportunityTeamMember);
checkAcctOwner = TRUE;
}
}
}        
}
if(checkAcctOwner == FALSE){
OpportunityTeamMember opportunityTeamMember  = new OpportunityTeamMember();
opportunityTeamMember.UserId = accountOwners.get(accountId);
opportunityTeamMember.TeamMemberRole = Label.OppTeamPopulate5;
opportunityTeamMember.OpportunityId = o.ID;
if(opportunityTeamMember.UserId!=NULL)
oppTeamMembersList.add(opportunityTeamMember);
}
}
//Modified by Rajat for SF-BUG-254
if(oppTeamMembersList.size()>0){
Set<OpportunityTeamMember> otmSet = new Set<OpportunityTeamMember>();
otmSet.addAll(oppTeamMembersList);
List<OpportunityTeamMember> uniqOtmList = new List<OpportunityTeamMember>();
uniqOtmList.addAll(otmSet);
System.debug('oteam..................' +uniqOtmList);
//Below Lines are added by Rajat for SF-BUG-254
List<OpportunityTeamMember> finalList = new List<OpportunityTeamMember>();            
List<OpportunityTeamMember> oppTeam = [SELECT id,UserId,OpportunityId from OpportunityTeamMember where OpportunityId IN: opplist]; 
System.debug('oppTeam.................'  +oppTeam);
//for(OpportunityTeamMember o1 : oppTeam) { 

// }

integer flag;
if(oppTeam.size() > 0) {
for(OpportunityTeamMember o1 : uniqOtmList) {
flag = 0;
for(OpportunityTeamMember o2 : oppTeam) {
if(o1.UserId == o2.UserId) {
flag = 1;
// ot1 = o2;
}
}
if (flag==0){
finalList.add(o1);
}

}
System.debug('finalList.................'  +finalList);

Set<OpportunityTeamMember> otmSet1 = new Set<OpportunityTeamMember>();
otmSet1.addAll(finalList);
List<OpportunityTeamMember> finalList1 = new List<OpportunityTeamMember>();
finalList1.addAll(otmSet1);
System.debug('finalList1.................'  +finalList1.size());
insert finalList1;
}
else {
//Above Lines are added by Rajat for SF-BUG-254    
insert uniqOtmList;
}
}

}*/
    
    // This methos is to delete old opportunity tem when account gets updated
    // Commented under SF-BUG592
    /* public void deleteOldOptyTeam(Map<Opportunity,Id> oppAccMap){ IBA-3397
Map<Id,Id> accOwnerMap = new Map<Id,Id>();
Map<Id,List<AccountTeamMember>> accAtmMap = new Map<Id,List<AccountTeamMember>>();
for(Account acc:[SELECT Id, OwnerId,(SELECT Id,UserId,TeamMemberRole,AccountId FROM AccountTeamMembers) FROM Account WHERE Id IN: oppAccMap.values()]){
if(!accOwnerMap.containsKey(acc.id))
accOwnerMap.put(acc.id, acc.ownerId);
if(!accAtmMap.containsKey(acc.id))
accAtmMap.put(acc.id, acc.AccountTeamMembers);
}
Map<Id, List<OpportunityTeamMember>> optyOtmMap = new Map<Id, List<OpportunityTeamMember>>();
for(Opportunity opp:[SELECT Id, AccountId,(SELECT Id,UserId,TeamMemberRole,OpportunityId FROM OpportunityTeamMembers) FROM Opportunity WHERE Id IN: oppAccMap.KeySet()]){
if(!optyOtmMap.containsKey(opp.id) && opp.OpportunityTeamMembers.size()>0)
optyOtmMap.put(opp.Id, opp.OpportunityTeamMembers);
}
List<OpportunityTeamMember> delOtmList = new List<OpportunityTeamMember>();
for(Opportunity opp : oppAccMap.keySet()){
if(optyOtmMap.containsKey(opp.Id)){
for(OpportunityTeamMember otm:optyOtmMap.get(opp.Id)){
if(accAtmMap.containsKey(oppAccMap.get(opp))){
for(AccountTeamMember atm : accAtmMap.get(oppAccMap.get(opp))){
if(atm.UserId == otm.UserId && atm.TeamMemberRole == otm.TeamMemberRole && !delOtmList.contains(otm))
delOtmList.add(otm);
}
}
if(otm.UserId == accOwnerMap.get(oppAccMap.get(opp)) && !delOtmList.contains(otm))
delOtmList.add(otm);
}
}
}
delete delOtmList;
}*/
    
    // This method is to create Sales Quota Opportunity records when opportunity stage is Closed Won
    public void createSalesQuotaOpty(List<Opportunity> oppList){
        Map<id,OPPORTUNITY> oqMap=new Map<id,OPPORTUNITY>();
        
        for(Opportunity op:oppList){
            if(op.PrimaryQuote__c!=NULL){
                oqMap.put(op.PrimaryQuote__c,op);
            }    
        }
        
        List<Product_Segment__c> pList = [SELECT Id,amount__c,opportunity__c FROM Product_Segment__c Where Quote__c =: oqMap.keyset() and product_segment__c = 'Performance Center'];
        System.debug('PList------------------------------------------'+pList);
        if(pList.size()>0){
            //for(Opportunity o:oppList){
            for(Product_Segment__c p:pList){
                //amountMap.put(o.id,p.amount__c);
                amountMap.put(p.Opportunity__c, p.Amount__c);
            }
            //}
        }
        System.debug('Amount Map:--------------------------------------'+amountMap);
        System.debug('Amount Map Keys:---------------------------------------'+amountMap.keySet());
        
        System.debug('Inside Create Sales Quota Opp');
        List<Roles1__mdt> Roles=[SELECT Id, Label, QualifiedApiName, List_of_Roles__c, AllTypes__c FROM Roles1__mdt];
        String listofIVRoles;
        String listofPerfRoles;
        for(Roles1__mdt rl: Roles){
            if(rl.AllTypes__c == Label.OppTeamPopulate3){
                listofIVRoles = rl.List_of_Roles__c;
            }
            else if(rl.AllTypes__c == Label.OppTeamPopulate4){
                listofPerfRoles = rl.List_of_Roles__c;
            }
        }
        List<String> IVList= listofIVRoles.split(',');
        System.debug('IVList : '+listofIVRoles);
        System.debug('performance : '+listofPerfRoles);
        System.debug('Amount Map : '+amountMap);
        List<Opportunity> opList = [SELECT ID, StageName,CloseDate,Expected_Bookings__c,(SELECT id,opportunityId,TeamMemberRole,UserId,Compensation__c,OpportunityAccessLevel FROM OpportunityTeamMembers) FROM Opportunity WHERE Id in: oppList and StageName='6 Closed Won'];       
        List<Sales_Quota__c> sQta1=[SELECT ID,Fiscal_Year__c,Fiscal_Quarter2__c,Start_Date__c,End_Date__c,User__c FROM Sales_Quota__c];
        List<Sales_Quota__c> sQta=new List<Sales_Quota__c>();
        for(Opportunity opp: opList){
            for(Sales_Quota__c sq:sQta1){
                if(opp.CloseDate >= sq.Start_Date__c && opp.CloseDate <= sq.End_Date__c){
                    sQta.add(sq);
                }
            }    
        }
        System.debug('SQTA ---------------------'+sQta);
        List<Sales_Quota_Opportunity__c> sqopList= [SELECT Id, Opportunity__c, Sales_Quota__c from Sales_Quota_Opportunity__c];
        List<Sales_Quota_Opportunity__c> sqoList=new List<Sales_Quota_Opportunity__c>();
        for(Opportunity op: opList){
            System.debug('Inside OppList Loop 1');
            if(op.OpportunityTeamMembers!=NULL){
                System.debug('Inside OppTeam Loop 1');
                for(OpportunityTeamMember optm:op.OpportunityTeamMembers){
                    System.debug('Inside OppList Loop 2');
                    if(sQta!=NULL){
                        for(Sales_Quota__c sq: sQta){
                            System.debug('Inside Sales Quota Loop 1'+sQta.size());
                            Boolean check=false;
                            if(sqopList!=NULL){
                                for(Sales_Quota_Opportunity__c sqop:sqopList){
                                    System.debug('Inside Sales Quota Opportunity Loop 1');
                                    if(sqop.opportunity__c == op.Id && sqop.Sales_Quota__c == sq.Id)
                                    {
                                        check = true;
                                        break;
                                    }    
                                }
                            }
                            System.debug('sq User:--------------'+sq.User__c);
                            System.debug('Optm : ---------------'+optm.UserId);
                            System.debug('Check : ----------------'+check);
                            if(sq.user__c == optm.UserId && check==false){
                                System.debug('Inside creating sales quota opp');
                                Sales_Quota_Opportunity__c sqo= new Sales_Quota_Opportunity__c();
                                System.debug('TeamMemberRole :------------'+optm.TeamMemberRole);
                                System.debug('listofIvRoles----------------'+listofIVRoles);
                                System.debug('listofPerfRoles----------------'+listofPerfRoles);
                                if(optm.TeamMemberRole == listofIVRoles){
                                    //  System.debug('Inside optm comp IV-----'+op.Business_Line_Amount__c);
                                    //  sqo.Opportunity_Value__c = op.Business_Line_Amount__c;
                                }
                                else if(optm.TeamMemberRole == listofPerfRoles){
                                    System.debug('Inside optm comp perf'+amountMap.get(op.id));
                                    sqo.Opportunity_Value__c = amountMap.get(op.id);
                                }
                                else{
                                    System.debug('Inside optm comp others-------'+op.Expected_Bookings__c);
                                    sqo.Opportunity_Value__c = op.Expected_Bookings__c;
                                }
                                sqo.Sales_Quota__c=sq.id;
                                sqo.Opportunity__c=op.Id;
                                sqoList.add(sqo);
                                
                                break;
                            }
                        }
                    }
                }
            }
        }
        System.debug('SQO List:---------------'+sqoList);
        insert sqoList;    
    }
    //IBA-2917 starts
    private Opportunity_Field_History__c createUpdateHistory(Schema.DescribeFieldResult field, string oldacc, string newacc, Opportunity opp) {
        Opportunity_Field_History__c oppHistory = new Opportunity_Field_History__c();
        oppHistory.Opportunity__c = opp.Id;
        oppHistory.Field__c = field.getLabel();
        oppHistory.User__c = UserInfo.getUserId(); 
        oppHistory.Date__c = Datetime.now();
        if (oldacc != null) oppHistory.ORIGINAL_VALUE__c = oldacc;
        if (newacc != null) oppHistory.NEW_VALUE__c = newacc;
        return oppHistory;
    }//IBA-2917 ends
    //Added by Praneeth for SF Bug 312
    public void cannotDeleteOpp(Map<Id, SObject> oldItems){
        List<String> lstProfileName = new List<String>();
        lstProfileName.add(label.System_Admin);
        
        List<Profile> lstProfile = [select id, name from Profile where name IN: lstProfileName];
        for(Profile objProfile : lstProfile){
            if(UserInfo.getProfileId()==objProfile.id) return;
        }
        
        List<Opportunity> oppList=oldItems.values();
        for(Opportunity myOpps : oppList) {
            myOpps.addError('You are not allowed to delete an Opportunity. Please contact your System Admin.');
        }
    }
    /*Bug 355*/ 
    public void deleteProductline(List<Opportunity> opplist){
        
        list<OpportunityTeamMember> optm = [SELECT id,opportunityId,TeamMemberRole,UserId,Compensation__c,OpportunityAccessLevel FROM OpportunityTeamMember Where opportunityId in : opplist AND TeamMemberRole='Performance Center Consultant'];
        //List<Profile> pNames= [Select id,Name from Profile Where id=: userInfo.getProfileId()];
        //for(OpportunityTeamMember op:optm){
        //for(Profile p:pNames){
        
        //if((op.TeamMemberRole == system.Label.PerformanceCenterConsultant) && (p.Name == System.Label.SystemAdministrator || p.Name == system.Label.BusinessAdministrator)){
        delete optm;        
        //}
        //else{
        //ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Warning,'Sorry,You do not have permission to edit or delete the Opportunity team member' );
        //ApexPages.addmessage(msg);
        
        //}
        // }
        // }
    }
    /*public void createSalesQuotaOpty1(List<Opportunity> oList){

List<Opportunity> oppList=[SELECT Id,Stagename FROM Opportunity WHERE StageName='6 Closed Won' AND Id in: oList];
List<OpportunityTeamMember> optyTeam=[SELECT id,opportunityId,TeamMemberRole,UserId,Compensation__c,OpportunityAccessLevel FROM OpportunityTeamMember Where opportunityId in : oppList];
List<Sales_Quota__c> sQta=[SELECT ID,Fiscal_Year__c,Fiscal_Quarter2__c,Start_Date__c,User__c FROM Sales_Quota__c];

List<Sales_Quota_Opportunity__c> sqoList=new List<Sales_Quota_Opportunity__c>();   

for(Opportunity opp: oppList){    
for(OpportunityTeamMember otm: optyTeam){
Boolean check=false;
if(otm.opportunityId==opp.Id && check==false){
for(Sales_Quota__c sqt : sQta ){
if(sqt.User__c==otm.userId && check == false){
Sales_Quota_Opportunity__c sqo= new Sales_Quota_Opportunity__c();
sqo.Sales_Quota__c=sqt.id;
sqo.Opportunity__c=opp.Id;
if (oppty contains IV or performance segment)

sqoList.add(sqo);
check=true;
break;
}
}
}
if(check== true)
break;
}
}
insert sqoList;
}    */
    /*IBA-1312*/
    /*IBA-2555*/
    public void defineCustomerTypeForOpp(List<Opportunity> oppList){ //IBA-4781
        Set<id> accids = new Set<id>();
        for(Opportunity op1: oppList) {
            accids.add(op1.accountId);
        }
        List<Account> accs = [SELECT id,Account_Status__c from Account where Id IN: accids]; 
        Map<id,String> map1 = new Map<id,String>();
        for(Account a: accs) {
            map1.put(a.id,a.Account_Status__c);
        }     
        for(Opportunity op: oppList) {
            if(op.StageName != '6 Closed Won' && op.StageName != '7 Closed Lost' && op.RecordTypeId != opptyRecordTypeNameId('International_Opportunity','Id')) {//IBA-4781  IBA-6100
                if(map1.get(op.AccountId) == 'Active') {
                    op.CustomerType__c = 'Existing Customer'; 
                }else {
                    op.CustomerType__c = 'New Customer';
                }
            }
        }
        
    }
    //IBA-2111
    public void setRecalculateTeamValue(List<Opportunity> oldList,List<Opportunity> newList) {
        List<String> oppBookedStatus = new List<String>();
        //List<Opportunity> listToUpdate = new List<Opportunity>();
        oppBookedStatus.add(Label.Commissionable_Book_No_Service_PO);
        oppBookedStatus.add(Label.Non_Comm_Book_No_Service_PO);
        //   oppBookedStatus.add(Label.Non_Comm_Book_No_Proj_Plan); IBA-4182 Starts
        oppBookedStatus.add(Label.Booked_with_No_PO);
        oppBookedStatus.add(Label.Booked_with_No_Service_PO);
        oppBookedStatus.add(Label.Booked_with_No_Product_PO);  // IBA-4182 Ends 
        oppBookedStatus.add(Label.Fully_Booked);
        oppBookedStatus.add(Label.Non_Comissionable_Booking);
        System.debug('rj..' +oppBookedStatus);
        for(integer i=0;i<newList.size();i=i+1) {
            if(oldList[i].oppstatus__c != newList[i].oppstatus__c && !oppBookedStatus.contains(newList[i].oppstatus__c) && newList[i].Recalculate_Team__c != false) {
                newList[i].Recalculate_Team__c = false;
                //listToUpdate.add(newList[i]);
            }
            if(oldList[i].oppstatus__c != newList[i].oppstatus__c && !oppBookedStatus.contains(oldList[i].oppstatus__c) && oppBookedStatus.contains(newList[i].oppstatus__c) && newList[i].Recalculate_Team__c != true) {
                newList[i].Recalculate_Team__c = true; 
                //listToUpdate.add(newList[i]);
            }
        }
        /* if(listToUpdate.size()>0) {
update listToUpdate;
}*/
    }
    //IBA-1988
    public void setOppValues(List<Opportunity> oppList){ 
        String obj='Opportunity';
        Map<Id,String> recordTypeMap=new Map<Id,String>();
        //if(obj!= null){ IBA-3397
        for(Schema.RecordTypeInfo recInfo : Schema.getGlobalDescribe().get(obj).getDescribe().getRecordTypeInfosByName().values()){
            recordTypeMap.put(recInfo.getRecordTypeId(),recInfo.getName());
        }
        //} 
        for(Opportunity op: oppList) {
            String oppRecordTypeName =  recordTypeMap.get(op.RecordTypeId);
            if(op.Created_from_Lead__c == true) {
                //if(oppRecordTypeName == 'U.S & Canada Opportunity') { //IBA-5992
                if((oppRecordTypeName == opptyRecordTypeNameId('NAA_Opportunity','Name') || oppRecordTypeName == opptyRecordTypeNameId('US_Canada_Advanced_Services','Name') ||oppRecordTypeName == opptyRecordTypeNameId('US_Canada_Specialty','Name'))){  //IBA-5992
                    Date d = Date.today();
                    op.ExpectedInstallDate__c = d;  
                }
                //if(oppRecordTypeName == 'UK&I and NWE') { //IBA-2711-UK Merge
                if(oppRecordTypeName == 'International Opportunity') {
                    op.Framework__c = 'Not Applicable'; 
                }
            }
        }
    } 
    //IBA-3397 commented out
    /*public void createForecastAndCogsDimension(List<Opportunity> oppData){
Set<id> oppIds = new Set<id>();
List<Forecast_Dimension__c> forcastData = new List<Forecast_Dimension__c>();
List<COGS_Dimension__c > cogsDimentions = new List<COGS_Dimension__c >();
//List<COGS_Dimension__c> cogsToDelete = [Select id from COGS_Dimension__c where Primary_Opportunity_Id__c in:oppIds];
DateTime todayDate = DateTime.now();
for(Opportunity opp:oppData){
//if(opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('U.S & Canada Opportunity').getRecordTypeId()){ //IBA-5992
if(opp.RecordTypeId==opptyRecordTypeNameId('NAA_Opportunity','Id') || opp.RecordTypeId==opptyRecordTypeNameId('US_Canada_Advanced_Services','Id') ||opp.RecordTypeId==opptyRecordTypeNameId('US_Canada_Specialty','Id')){   //IBA-5992
oppIds.add(opp.id);
Forecast_Dimension__c forecast = new Forecast_Dimension__c();
forecast.Primary_Quote_ID__c = opp.PrimaryQuote__c;
forecast.Opportunity_Change_Datetime__c = todayDate;
forecast.Opportunity_Created_Date__c = opp.createddate;
if(opp.stageName == '6 Closed Won'){
forecast.Opportunity_Forecast_Category__c = 'Booked';
}else if(opp.Pipeline_Category__c == 'Lost'){
forecast.Opportunity_Forecast_Category__c = 'Development';
}else{
forecast.Opportunity_Forecast_Category__c = opp.Pipeline_Category__c;
}
if(opp.PrimaryQuote__c != null && opp.PrimaryQuote__r.SAP_Quote_Number_Truncated__c != null){
forecast.Primary_Quote_SAP_Number__c = Decimal.valueOf(opp.PrimaryQuote__r.SAP_Quote_Number_Truncated__c);
}
forecast.Opportunity_ID__c = opp.id;
forecast.Opportunity_Name__c = opp.name;
forecast.Opportunity_Owner_ID__c =opp.OwnerId;
forecast.Opportunity_Expected_Close_Date__c = opp.CloseDate;
forecast.Expected_Booking_Date__c = opp.Expected_Booking_Updated_Date__c;
forecast.Expected_Booking__c = opp.Expected_Bookings__c;//Currency.
forcastData.add(forecast);
}
}
List<Quote> quoteData = [Select id,Quote_Margin__c,name,OpportunityId,SAP_Quote_Number_Truncated__c,Labor_Cost__c,Material_Cost__c,Overhead_Cost__c,Total_Cost__c, Expected_Bookings__c, LastModifiedDate   from Quote where OpportunityId in:oppIds];
for(Quote q:quoteData){
COGS_Dimension__c cog = new COGS_Dimension__c();
if(q.SAP_Quote_Number_Truncated__c != null){
cog.COGS_Primary_Quote_SAP_Number__c = Decimal.valueOf(q.SAP_Quote_Number_Truncated__c); 
}
cog.COGS_Primary_Quote_Labor_Cost__c = q.Labor_Cost__c;    
cog.COGS_Primary_Quote_Material_Cost__c = q.Material_Cost__c;
cog.COGS_Primary_Quote_Overhead_Cost__c = q.Overhead_Cost__c;
cog.COGS_Primary_Quote_Margin__c = q.Quote_Margin__c;
cog.COGS_Primary_Quote_Expected_Booking__c = q.Expected_Bookings__c;  
cog.COGS_Primary_Quote_Change_Datetime__c = todayDate;
cog.Primary_Quote_ID__c = q.id;
cog.Primary_Opportunity_Id__c = q.OpportunityId;
cogsDimentions.add(cog);
}
if(!forcastData.isEmpty()){
insert forcastData;
}
if(!cogsDimentions.isEmpty()){
insert cogsDimentions;
}
}*/
    //IBA-3602
    public void udpatePLamount(list<id> oppid, map<id,string> oppMapNeg){
        list<Product_Line__c> plList = [select id, Amount__c, Opportunity__c from Product_Line__c where Opportunity__c =: oppid and Quote__c = null];
        list<Product_Line__c> plineList = new list<Product_Line__c>();
        for(Product_Line__c p : plList){
            
            if(oppMapNeg.containskey(p.Opportunity__c)){
                string oppStat = oppMapNeg.get(p.Opportunity__c);
                if(oppStat == 'new credit' && p.Amount__c > 0){
                    p.Amount__c = p.Amount__c * (-1);
                    plineList.add(p);
                }else if(oppStat == 'old credit' && p.Amount__c < 0){
                    p.Amount__c = p.Amount__c * (-1);
                    plineList.add(p);
                }
                
            }
            
        }
        if(plineList.size()>0){
            ProductLineTriggerHandler.TriggerDisabled = true;
            update plineList;
        }
    }   
    /*IBA-3448 Change AC: Start*/
    public static void sendOpportunityEmail(Id opportunityId){
        Opportunity oppData = [SELECT Id, Name, Requested_Credit_Value__c, Requestor_Name__r.Name, OwnerId FROM Opportunity WHERE Id = :opportunityId]; //REMOVED Requested_Term__c for IBA-5934
        User owner = [SELECT Email FROM User WHERE Id = :oppData.OwnerId];
        Group arTeamQueue = [SELECT Id FROM Group WHERE DeveloperName = 'AR_Team'];
        List<String> emailAddresses = new List<String>();
        if (arTeamQueue != null){
            emailAddresses.add(owner.Email);
            for (GroupMember member : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :arTeamQueue.Id]){
                User arTeamUser = [SELECT Email FROM User WHERE Id = :member.UserOrGroupId];
                emailAddresses.add(arTeamUser.Email);
            }
        }
        if (!emailAddresses.isEmpty()){
            String opportunityLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunityId;
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(emailAddresses);
            email.setSubject('Opportunity Credit Check Required: ' + oppData.Name);
            email.setPlainTextBody('A credit check request has been generated for an Opportunity. Please review the following details:\n\n' +
                                   'Opportunity Link: ' + opportunityLink + '\n' +
                                   'Opportunity Name: ' + oppData.Name + '\n' +
                                   'Requested Credit Value: ' + oppData.Requested_Credit_Value__c + '\n' +
                                   //'Requested Term: ' + oppData.Requested_Term__c + '\n' +  IBA-5934
                                   'Requestor Name: ' + oppData.Requestor_Name__r.Name + '\n\n' +
                                   'Regards,\n' + oppData.Requestor_Name__r.Name);
            try{
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            } catch (Exception e){
                System.debug('Email sending failed: ' +e.getMessage());
            }
        }
    }
    /*IBA-3448 Change AC: End*/
    
    //Added for IBA-5992 starts
    public static String opptyRecordTypeNameId(String recTypeApiName, String nameOrId){
        String opptyRecTypeNmId = '';
        String optyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(recTypeApiName).getRecordTypeId();
        if(String.isNotBlank(optyRecordTypeId) && nameOrId == 'Name'){
            opptyRecTypeNmId = [Select Name from RecordType where ID =: optyRecordTypeId].Name;
        }else{
            opptyRecTypeNmId = optyRecordTypeId;
        }
        return opptyRecTypeNmId;
    }// IBA-5992 Ends
    //IBA-5809 Start Saptarsha Panthi
    public static Map<String,String> getPickListMap(Schema.DescribeFieldResult pickList){
        Map<String,String> pickListMap = new Map<String,String>();
        List<Schema.PicklistEntry> pickListvalues = pickList.getPicklistValues();     
        for( Schema.PicklistEntry v : pickListvalues) {
            pickListMap.put(v.getValue(),v.getLabel());        
        }
        return pickListMap;
    }
    Public Integer getQuarter(Integer month){
        Integer quarter=0;
        if(month<=3 ){
            quarter=1;
        }
        else if(month>3 && month<=6){
            quarter=2;
        }
        else if(month>6 && month<=9){
            quarter=3;
        }
        else {
            quarter=4;
        }
        return quarter;
    }
    //IBA-5809 End Saptarsha Panthi
}