/**********************************************************************
Name:  QuoteTriggerHandler
Copyright © 2018
======================================================
======================================================
Purpose: Handler contains method for QuoteTrigger Events
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1          Supriya Ambre                 ?          INITIAL DEVELOPMENT
0.2          Amruta Dhumal                   
0.3          Haripriya Maturi                         Developed Product Line/Product/Segment/Business Segment records in afterUpdate event
0.4          Debaranjan Ghosh                         Added updateQuoteCurrencies() to handle Multicurrency May Scope UAT-BUG-259 & 261
0.5          Debaranjan Ghosh                         Added checkgpopricelist() and checkidnpricelist() to handle GPO IDN Price List Update by Sales User to handle SF-BUG-684
***********************************************************************/
/*
Open    E0001,Auto Approved E0018,Pending Quote Approvals   E0004,Approved  E0007,Approved by Deal Desk E0009,
Under Rev. / Reject Approval    E0003,ASG - Pending Discovery   E0028,
Booked  E0013,Completed E0014,
Offline Build Quote E0019,Cancelled E0017,Zero Value    E0023,Advanced Services Order   E0024,
VC Update in progress   E0025,VC Update price change/Errors E0026
*/
public class QuoteTriggerHandler implements ITriggerHandler{
    // Allows unit test (or other code) to disable this trigger for the transaction
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    public static Boolean isFirstTime = true;
    public static boolean isInsert = false;
    public static boolean isSupplementVersionUpdate = false;
    public static boolean updatefromquotelines = false;
    public static boolean updateFromPrint = false;
    public static boolean updatefromqa = false;
    public static boolean quoteUpdated = false;
    public static boolean isUpdatefrmOppty = false; //IBA-3828
    // Check to see if the trigger has been disabled by either custom setting or code
    public boolean IsDisabled(){
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('QuoteTriggerDisabled');
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
        quoteUpdated = true;
        List<Quote> quoteList = newItems;
        List<Id> accIdList=new List<Id>(); //IBA-3929 soumyad
        List<Id> opptyid=new List<Id>(); //IBA-3929 soumyad
        
        for (Quote qn:quoteList){    
            if( qn.Name.contains('&') || qn.Name.contains('%') || qn.Name.contains('\'')|| qn.Name.contains('"')|| qn.Name.contains('|')|| qn.Name.contains('(')|| qn.Name.contains(')')){
                
                qn.Name.addError('Please remove the any of the following characters from the Quote Name: &  %  |  (  )  “ \'');
            }      
                        
            //IBA-3929 soumyad start
            
            if( qn.Booking_Date__c != null){   //WF-Clear Out Booking Date
                qn.Booking_Date__c = null;
            }
            
            if(qn.Legacy_SAP_Created_Date__c == null){//WF - Update Legacy SAP Created Date
                qn.Legacy_SAP_Created_Date__c = qn.CreatedDate__c;
            }
            
            opptyid.add(qn.OpportunityId);
                        
            //qn.of_beds__c = qn.Account.DHC_of_licensed_beds__c; //WF -    number of bed update
            
            if(qn.Professional_services_duration__c == null){ //WF - update Professional_services_duration
                qn.Professional_services_duration__c = 12;
            }
            
            if(!accIdList.contains(qn.Account_ID__c)){
                accIdList.add(qn.Account_ID__c);
            }
            //IBA-3929 soumyad end
        }
        map<id,opportunity> oppMap = new map<id,opportunity>([select id, LeadSource from opportunity where id = : opptyid]); //IBA-3929 soumyad
        checkProductLines(quoteList); //SF-BUG-480
        updateQuoteRegion(quoteList);
        InitialValue(quoteList,accIdList); //IBA-3929
        updateDHC_licensedBeds(quoteList); //IBA-3101
        List<Id> conId = new List<Id>();
        for (Quote q : quoteList){
            conId.add(q.Shipping_Contact__c);
            q.Pricing_Reference_Date_Service__c=date.today(); //IBA-1979 Pabitra
        }
        List<contact> contList = [select email,phone from contact where id=:conId];
        ////System.debug('Cont List : '+contList);
        
        Validation_Rules_Exception__c vre = Validation_Rules_Exception__c.getOrgDefaults();//Added by sravan for SF-BUG-846
        for (Quote q : quoteList){
            //IBA-3929 soumyad start
            if(q.Order_Type__c == 'ZQRS'){
                q.Service_Duration__c=q.subscription_Months__c;
            }
            opportunity op = oppMap.get(q.OpportunityId);
            if(q.Status =='E0013' && op.LeadSource =='Rapid Response'){ //WF - Set Rapid Response Delivery Date
                IF (q.Booking_Date__c != null){
                    q.Requested_Delivery_Date__c=q.Booking_Date__c.addDays(Integer.valueOf(q.RDD_Increment__c));
                }else{
                    q.Requested_Delivery_Date__c=system.Today().addDays(Integer.valueOf(q.RDD_Increment__c));
                }
            }
            //IBA-3929 soumyad end
            
            //Added by sravan for SF-BUG-846 START
            if(vre.Run_Validation_Rules__c && (q.opp_status__c == 'Lost' || q.opp_status__c==Label.Non_Comissionable_Booking
                                               ||q.opp_status__c==Label.Commissionable_Book_No_Service_PO
                                               ||q.opp_status__c==Label.Non_Comm_Book_No_Service_PO
                                               ||q.opp_status__c==Label.Booked_with_No_PO
                                               ||q.opp_status__c==Label.Booked_with_No_Service_PO
                                               ||q.opp_status__c==Label.Booked_with_No_Product_PO //IBA-4182 Ends
                                               ||q.opp_status__c==Label.Fully_Booked)){
                                                   q.addError('Quote cannot be created for Opportunities in status Lost, Fully Booked, Non Commissionable Booking, Commissionable – No Service PO, Non Comm. Book – No Service PO, Non Comm. Book – No Proj. Plan. Create a new Opportunity first');
                                               }
            //Added by sravan for SF-BUG-846 END
            integer i = 0;
            q.Related_Account__c=q.opportunity.accountid;
            q.Payer__c = q.Bill_to_Account__c;  //SF-BUG-1023
            if(contList.size()>0){
                Contact c = contList[i];
                q.Email = c.email;
                q.Phone = c.Phone;
            }
            i=i+1;
        }
        //updateService(quoteList);iba-3929 soumyad
        updateQuoteFields(quoteList); //Added by Pavan palla as part of new XR2 & IVX changes IBA-1135 Nov-Release
        
    }   
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
        quoteUpdated = true;
    }
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        User us = [select id,User_ID__c,profile.Name from User where profileid =: UserInfo.getProfileId() limit 1];
        //start IBA-871 Pabitra
        List<Quote> quoteList1=newItems.values();
        List<Quote> oldquoteList = oldItems.values(); //IBA-3824
        updateDHC_licensedBeds(quoteList1); //IBA-3101
        if(!isUpdatefrmOppty && !updatefromqa){  //IBA-6006
            checkQuoteDecommision(quoteList1); //IBA-2345   
        }
        if ( us.profile.name == 'System Administrator' || us.profile.name == 'Business Administrator') { 
            List<Quote> quoteNumBlankList=new List<Quote>();
            for(Quote q:quoteList1){
                if(q.Quote_Number__c==null)
                    quoteNumBlankList.add(q);
            }
            if(!quoteNumBlankList.isEmpty() && isInsert==false){
                isInsert=true;
                connectToCastIronForInsert(quoteNumBlankList);
            }
        }//end IBA-871 Pabitra
        
        if(updatefromqa == false){ // soumyad IBA-1368
            // soumyad sf-bug-968 start
            updateQuoteFields(newItems.values());//Added by Pavan palla as part of new XR2 & IVX changes IBA-1135 Nov-Release
        } // soumyad IBA-1368
        boolean notvalid = false;
        id opp;
        boolean isMatch1 = false; // soumyad IBA-1179
        boolean isMatch2 = false; // soumyad IBA-1179
        
        if ( us.profile.name == 'Sales Representative' && oldquoteList[0].Shipping_Contact__c == quoteList1[0].Shipping_Contact__c ) //IBA-3824 change
        {  
            for(Quote qt:(List<Quote>)newItems.values()){
                opp=qt.OpportunityId;
                if(qt.Status == 'E0013' || qt.Status == 'E0014'){
                    notvalid = true;                    
                }                
            }
            
        }
        
        // soumyad IBA-1179 start
        if ( us.profile.name == 'Sales Representative' || us.profile.name == 'Sales Development' ){  
            string newOrder; 
            string oldOrder; 
            for(Quote qt:(List<Quote>)newItems.values()){
                newOrder = qt.Order_Type__c;                                 
            }            
            
            for(Quote qt:(List<Quote>)oldItems.values()){
                oldOrder = qt.Order_Type__c;                
            }
            
            
            list<string> str = new list<string>{'ZQRL','ZQLI','ZQR3','ZQR','ZQL3'};
                if(newOrder != oldOrder){
                    if(str.contains(newOrder)){
                        isMatch1 = true;
                    }
                    if(str.contains(oldOrder)){
                        isMatch2 = true;
                    }
                }
            
        }
        
        
        for(Quote qt:(List<Quote>)newItems.values()){
            
            if( qt.Name.contains('&') || qt.Name.contains('%') || qt.Name.contains('\'')|| qt.Name.contains('"')|| qt.Name.contains('|')|| qt.Name.contains('(')|| qt.Name.contains(')')){
                
                qt.Name.addError('Please remove the any of the following characters from the Quote Name: &  %  |  (  )  “ \'');
            }
            
            if(qt.Quote_Number__c != null && qt.Statement_Of_Work__c == null && qt.Order_Type__c == 'ZQRS'){ //IBA-3929 soumyad
                qt.Statement_Of_Work__c = qt.SAP_Quote_Number_Truncated__c;
            }
            if(notvalid == true){
                qt.adderror('Sales Representatives cannot edit Booked or Completed quotes.');                    
            } 
            // soumyad IBA-1179 start
            if(isMatch1 == true && isMatch2 == true){
                qt.adderror(us.profile.name+' cannot Change this Order type.');
            }
            // soumyad IBA-1179 end
        }
        // soumyad sf-bug-968 end
        quoteUpdated = true;
        Map<Id,Quote> newQuoteMap = new Map<Id, Quote>();
        Map<Id,Quote> oldQuoteMap = new Map<Id, Quote>();
        List<Id> opptyid=new List<Id>(); //IBA-3929 soumyad
        for(Quote qt:(List<Quote>)newItems.values()){
            Quote oldqt = (Quote)oldItems.get(qt.Id);
            if(qt.IsFromEditPage__c != oldqt.IsFromEditPage__c){
                newQuoteMap.put(qt.Id, qt);
                oldQuoteMap.put(oldqt.id, oldqt);
            }
            //IBA-3929 soumyad start
            if(  qt.Status != oldqt.Status && //WF - Booking Date to Today (if changed)
               ( qt.Status =='E0013' || qt.Status =='E0024' || qt.Status =='E0014' || qt.Status =='E0019' || qt.Status =='E0023') &&
               ( oldqt.Status =='E0001' || oldqt.Status =='E0021' || oldqt.Status =='E0004' || oldqt.Status =='E0007' || oldqt.Status =='E0009' || oldqt.Status == 'E0003') /*&& 
               qt.Booking_Date__c == null*/){
                   qt.Booking_Date__c = system.today();
               }
            
            if(  qt.Status != oldqt.Status && //WF - Clear Out Booking Date
               ( oldqt.Status =='E0013' || oldqt.Status =='E0024' || oldqt.Status =='E0014' || oldqt.Status =='E0019' || oldqt.Status =='E0023') &&
               ( qt.Status =='E0001' || qt.Status =='E0021' || qt.Status =='E0004' || qt.Status =='E0007' || qt.Status =='E0009' || qt.Status == 'E0003') && 
               qt.Booking_Date__c != null){
                   qt.Booking_Date__c = null;
               }
            
            if(qt.Legacy_SAP_Created_Date__c == null){ //WF - Update Legacy SAP Created Date
                qt.Legacy_SAP_Created_Date__c = qt.CreatedDate__c;
            }
            
            opptyid.add(qt.OpportunityId);
            
            //IBA-3929 soumyad end
        }
        if(oldQuoteMap.size()>0)
            checkSelectedChange(newQuoteMap,oldQuoteMap);
        
        List<Quote> quoteList = newItems.values();
        map<id,opportunity> oppMap = new map<id,opportunity>([select id, LeadSource, RecordType.Name, Do_Not_Send_to_PAW__c, PAW_ExternalID__c from opportunity where id = : opptyid]); //IBA-3929 soumyad
        //SF-BUG-1023
        for(Quote q: quoteList){
            //IBA-3929 soumyad start
            if(q.Order_Type__c == 'ZQRS'){
                q.Service_Duration__c=q.subscription_Months__c;
            }
            opportunity op = oppMap.get(q.OpportunityId);
            //IBA-6134 start
            quote oldQT = (quote)oldItems.get(q.id);
            list<string> oppRecName= new list<string>{'US & Canada CORE', 'US & Canada Advanced Services', 'US & Canada Specialty'};
            
            if(q.Status != oldQT.Status && oppRecName.contains(op.RecordType.Name) 
            && op.Do_Not_Send_to_PAW__c != true && op.PAW_ExternalID__c == null
            && (q.Status == 'E0013' || q.Status == 'E0014'||q.Status == 'E0019'||q.Status == 'E0023'||q.Status == 'E0024')){
                q.addError(Label.Quote_Book_Error_PAW);
            }
            //IBA-6134 end

            if(q.Status =='E0013' && op.LeadSource =='Rapid Response'){ //WF - Set Rapid Response Delivery Date
                IF (q.Booking_Date__c != null){
                    q.Requested_Delivery_Date__c=q.Booking_Date__c.addDays(Integer.valueOf(q.RDD_Increment__c));
                }else{
                    q.Requested_Delivery_Date__c=system.Today().addDays(Integer.valueOf(q.RDD_Increment__c));
                }
            }
            //IBA-3929 soumyad end
            q.Payer__c = q.Bill_to_Account__c;
            //IBA-1929 Pabitra
            if( (q.Total_Discount_Amount__c!=null && math.abs(q.Total_Discount_Amount__c)>0) || 
                (q.Total_Discount_Percent__c!=null && math.abs(q.Total_Discount_Percent__c)>0)  ||
                (q.Total_Discount_Percent_Amount__c!=null && math.abs(q.Total_Discount_Percent_Amount__c)>0) ){
                q.Discounting__c=true;
            }//end IBA-1929 Pabitra
        }
        
        Map<Id,Quote> oldQuotesMap=new Map<Id,Quote>(oldquoteList);
        //renewal revenue calculation 
        //IBA-1592 Fix
        if(updatefromqa == false){ //
            UpdateRenewalRevenue(quoteList);
            //updateService(quoteList); iba-3929 soumyad
                for(Quote newqte: quoteList)
                {
                    
                        Quote oldqte=oldQuotesMap.get(newqte.Id); //IBA-3955
                            if ((oldqte.Print_Exchange_Rate__c != newqte.Print_Exchange_Rate__c) &&
                                (oldqte.Print_Currency__c == newqte.Print_Currency__c)){                                    
                                    newqte.Exchange_Rate_Override__c = true;
                                }
                            /* Following lines are added for SF-BUG-684*/
                            if ((oldqte.GPO_Price_Lists__c != newqte.GPO_Price_Lists__c)){
                                if ( us.profile.name == 'Sales Manager' ||
                                    us.profile.name == 'Sales Representative' ||
                                    us.profile.name == 'Sales Development' ||
                                    us.profile.name == 'International Sales Representative' ||
                                    us.profile.name == 'International Sales UK' ||
                                    us.profile.name == 'International Sales France'  ) 
                            {  
                                
                                 checkgpopricelist(newqte.Id,quoteList);}
                                
                            }
                            
                            if ((oldqte.IDN_Price_List__c != newqte.IDN_Price_List__c)){
                                
                                if ( us.profile.name == 'Sales Manager' ||
                                    us.profile.name == 'Sales Representative' ||
                                    us.profile.name == 'Sales Development' ||
                                    us.profile.name == 'Interntional Sales Representative' ||
                                    us.profile.name == 'International Sales UK' ||
                                    us.profile.name == 'International Sales France'  ) 
                            {  
                                 checkidnpricelist(newqte.Id,quoteList);}}
                            
                            /* Above lines are added for SF-BUG-684*/
                    }
        }
        
        //IBA-1592 Fix
        if(updatefromqa == false){ 
            updateQuoteRegion(quoteList);
            updateQuoteCurrencies(quoteList);   /* This Line is added for UAT-BUG-259&261 */
        }
        List<Id> conId = new List<Id>();
        Set<string> currencyISOSet = new Set<string>();
        for (Quote q : quoteList){
            currencyISOSet.add(q.currencyIsoCode);
            if(q.Update_from_quote_lines__c == true){
                updatefromquotelines = true;
                q.Update_from_quote_lines__c = false;
                
            }
            conId.add(q.ContactId);
        }
        if(currencyISOSet.size()>0){
            Map<string,string> ccMap = new Map<string,string>();
            for(CurrencyCulture__c cc: [Select isocode__c,culture_code__c  from CurrencyCulture__c where isocode__c IN :currencyISOSet]){
                ccMap.put(cc.isocode__c,cc.culture_Code__c);
            }
            for (Quote q : quoteList){
                if(ccMap != null && ccMap.keyset().contains(q.currencyIsoCode)){
                    q.Culture_Code__c = ccMap.get(q.currencyIsoCode); 
                }
            }
        }
        
        if(updatefromquotelines == false){
            List<contact> contList = [select email,phone from contact where id=:conId];
            for (Quote q : quoteList){
                
                integer i = 0;
                q.Related_Account__c=q.opportunity.accountid;
                if(contList.size()>0){
                    Contact c = contList[i];
                    q.Email = c.email;
                    q.Phone = c.Phone;
                }
                i=i+1;
            }
            List<Quote> quoteOld = oldItems.values();
            set<Id> oldqteid = new set<id>();
            for(Quote oldq : quoteOld)
            {
                oldqteid.add(oldq.id);
            }
            
            List<Quote_Field_history__c> qfhList = new List<Quote_Field_History__c>();
            //IBA-3828 start
            Map<String, Integer> quoteLineCountMap = new Map<String, Integer>();
            for(AggregateResult ar : [SELECT count(Id) cntVal, Quote__c from Quote_Line__c where Quote__c In:oldqteid GROUP BY Quote__c]){
                quoteLineCountMap.put(String.ValueOf(ar.get('Quote__c')),Integer.valueOf(ar.get('cntVal')));
            } //IBA-3828 end
            
            if(quoteList.size()>0)
            
            {
                for(Quote newqte: quoteList)
                {
                    Quote oldQuote = (Quote)oldItems.get(newqte.Id);
                    if(newqte.Order_Type__c != oldQuote.Order_Type__c){
                        if(!quoteLineCountMap.containsKey(newqte.Id)){    //IBA-3828
                            newqte.addError('When changing a quote order type, you must have at least one Quote Line associated with the quote.');
                        }
                        if((oldQuote.Service_Duration__c != newqte.Service_Duration__c || oldQuote.Lease_Duration__c != newqte.Lease_Duration__c) && checkOldAndNewQuote(oldQuote, newqte))
                        {
                            newqte.addError('When toggling the Order Type on a Quote, no other changes can be made.First change the Order Type, then Save, then make the additional changes and Save');
                        }
                    }
                } 
            }
            
 
            
            for (Integer i = 0; i < quoteList.size(); i++) {
                
                if(( quoteOld[i].Order_Type__c != quoteList[i].Order_Type__c ) ||
                   (( quoteOld[i].GPO_Price_Lists__c != quoteList[i].GPO_Price_Lists__c) ||
                    ( quoteOld[i].Name != quoteList[i].Name) ||
                    ( quoteOld[i].Master_Agreement__c != quoteList[i].Master_Agreement__c ) ||
                    ( quoteOld[i].ExpirationDate != quoteList[i].ExpirationDate) ||
                    ( quoteOld[i].Posting_Date__c != quoteList[i].Posting_Date__c) ||
                    ( quoteOld[i].From__c != quoteList[i].From__c) ||
                    ( quoteOld[i].Shipping_Contact__c!= quoteList[i].Shipping_Contact__c) ||
                    ( quoteOld[i].Fee_Increase__c!= quoteList[i].Fee_Increase__c) ||
                    ( quoteOld[i].Corporate_Agreement_Pricing_Expiration__c!= quoteList[i].Corporate_Agreement_Pricing_Expiration__c) ||
                    ( quoteOld[i].Sales_Org__c!= quoteList[i].Sales_Org__c) ||
                    ( quoteOld[i].IDN_Price_List__c != quoteList[i].IDN_Price_List__c)  || 
                    ( quoteOld[i].Ship_to_Account__c!= quoteList[i].Ship_to_Account__c) || 
                    ( quoteOld[i].Bill_to_Account__c!= quoteList[i].Bill_to_Account__c)  || 
                    ( quoteOld[i].Payer__c!= quoteList[i].Payer__c)  || 
                    ( quoteOld[i].GPO_Account__c!= quoteList[i].GPO_Account__c)  || 
                    ( quoteOld[i].IDN_Account__c!= quoteList[i].IDN_Account__c)  || 
                    ( quoteOld[i].Sales_Operation_Counterpart__c!= quoteList[i].Sales_Operation_Counterpart__c)  || 
                    ( quoteOld[i].EOL_Date__c!= quoteList[i].EOL_Date__c)  || 
                    ( quoteOld[i].SSM_RD__c!= quoteList[i].SSM_RD__c)  || 
                    ( quoteOld[i].Consultant__c!= quoteList[i].Consultant__c)  ||
                    ( quoteOld[i].Sales_Consultant__c!= quoteList[i].Sales_Consultant__c)  ||  
                    ( quoteOld[i].Description!= quoteList[i].Description)  || 
                    ( quoteOld[i].ownerid!= quoteList[i].ownerid)  ||
                    ( quoteOld[i].Currency__c!= quoteList[i].Currency__c)  ||  
                    ( quoteOld[i].Primary_Quote__c!= quoteList[i].Primary_Quote__c)  || 
                    ( quoteOld[i].Status!= quoteList[i].Status)  || 
                    ( quoteOld[i].Requested_Delivery_Date__c!= quoteList[i].Requested_Delivery_Date__c)  || 
                    ( quoteOld[i].Service_Level__c!= quoteList[i].Service_Level__c)  || 
                    ( quoteOld[i].Service_Duration__c!= quoteList[i].Service_Duration__c)  || 
                    ( quoteOld[i].Free_Month_Service__c!= quoteList[i].Free_Month_Service__c)  || 
                    ( quoteOld[i].Service_Escalator__c!= quoteList[i].Service_Escalator__c)  ||
                    ( quoteOld[i].Service_Start_Date__c!= quoteList[i].Service_Start_Date__c)  ||
                    ( quoteOld[i].Incoterms_2__c!= quoteList[i].Incoterms_2__c)  || 
                    ( quoteOld[i].Incoterms_1__c!= quoteList[i].Incoterms_1__c)  || 
                    ( quoteOld[i].Shipping_Conditions__c!= quoteList[i].Shipping_Conditions__c)  || 
                    ( quoteOld[i].Product_PO_Number__c!= quoteList[i].Product_PO_Number__c)  || 
                    ( quoteOld[i].Service_PO_Number__c!= quoteList[i].Service_PO_Number__c)  || 
                    ( quoteOld[i].Lease_Duration__c!= quoteList[i].Lease_Duration__c)  || 
                    ( quoteOld[i].Free_Month_for_Lease__c!= quoteList[i].Free_Month_for_Lease__c)  || 
                    ( quoteOld[i].Booking_Date__c!= quoteList[i].Booking_Date__c)  ||
                    ( quoteOld[i].Pricing_Reference_Date__c!= quoteList[i].Pricing_Reference_Date__c)  ||  
                    ( quoteOld[i].Terms_of_Payment__c!= quoteList[i].Terms_of_Payment__c)  ||
                    ( quoteOld[i].Total_Net__c!= quoteList[i].Total_Net__c)  ||
                    ( quoteOld[i].Exchange_Rate__c!= quoteList[i].Exchange_Rate__c)  ||
                    ( quoteOld[i].Tax!= quoteList[i].Tax)  ||
                    ( quoteOld[i].Hospital_Contact_Notes__c!= quoteList[i].Hospital_Contact_Notes__c)  ||
                    ( quoteOld[i].Internal_Notes__c!= quoteList[i].Internal_Notes__c)  ||
                    ( quoteOld[i].Inv_Text_Notes__c!= quoteList[i].Inv_Text_Notes__c)  ||
                    ( quoteOld[i].Quote_Printout_Standard_Text__c!= quoteList[i].Quote_Printout_Standard_Text__c)  ||
                    ( quoteOld[i].Rework_Comments__c!= quoteList[i].Rework_Comments__c)  ||
                    ( quoteOld[i].Quote_Text__c!= quoteList[i].Quote_Text__c)  ||
                    ( quoteOld[i].Other_Notes__c!= quoteList[i].Other_Notes__c)  ||
                    ( quoteOld[i].Special_Instructions__c!= quoteList[i].Special_Instructions__c)  ||
                    ( quoteOld[i].Sales_Ops_Notes__c!= quoteList[i].Sales_Ops_Notes__c)    ||
                    ( quoteOld[i].Print_Exchange_Rate__c!= quoteList[i].Print_Exchange_Rate__c) || 
                    ( quoteOld[i].Print_Currency__c!= quoteList[i].Print_Currency__c)  ||
                    ( quoteOld[i].Exchange_Rate_Date__c!= quoteList[i].Exchange_Rate_Date__c) ||
                    ( quoteOld[i].Exchange_Rate_Override__c!= quoteList[i].Exchange_Rate_Override__c)
                    
                   )){
                       if((quoteList[i].status == 'E0018' || quoteList[i].status == 'E0009') && quoteList[i].Supplement_Version__c >0){
                           quoteList[i].Supplement_Version__c = quoteOld[i].supplement_version__c+1;
                       }
                       else{
                           quoteList[i].Supplement_Version__c = 1;
                       }
                   }
                if(quoteold[i].Supplement_Version__c != quoteList[i].Supplement_Version__c)
                    isSupplementVersionUpdate = true;
                
                if(quoteold[i].Name != quoteList[i].Name){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Quote Name';    //IBA-3927
                    qfh.ORIGINAL_VALUE__c = quoteold[i].Name;
                    qfh.NEW_VALUE__c = quoteList[i].Name;
                    qfhList.add(qfh);
                }
                if(quoteold[i].Account_CSN__c != quoteList[i].Account_CSN__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Account CSN';      //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Account_CSN__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Account_CSN__c);
                    qfhList.add(qfh);
                }
                
                
                if(quoteold[i].Master_Agreement__c != quoteList[i].Master_Agreement__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Master Agreement';       //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Master_Agreement__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Master_Agreement__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Shipping_Instructions__c != quoteList[i].Shipping_Instructions__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Shipping Instructions';     //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Shipping_Instructions__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Shipping_Instructions__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Supplement1__c != quoteList[i].Supplement1__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Supplement';    //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Supplement1__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Supplement1__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Service_Level__c != quoteList[i].Service_Level__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Service Level';     //IBA-3927
                    List<Schema.PicklistEntry> picklistEntries = Quote.Service_Level__c.getDescribe().getPicklistValues();   
                    Map<String,String> serviceLevelApiToLabelMap = new Map<String,String>();
                    for(Schema.PicklistEntry ple :picklistEntries){
                         serviceLevelApiToLabelMap.put(ple.getValue(),ple.getLabel());  
                     }
                    qfh.ORIGINAL_VALUE__c = serviceLevelApiToLabelMap.get(quoteold[i].Service_Level__c);
                    qfh.NEW_VALUE__c = serviceLevelApiToLabelMap.get(quoteList[i].Service_Level__c); 
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Net_Weight__c != quoteList[i].Net_Weight__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Net Weight';   //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Net_Weight__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Net_Weight__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Total_Cost__c != quoteList[i].Total_Cost__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Total Cost';    //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Total_Cost__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Total_Cost__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Overhead_Cost__c != quoteList[i].Overhead_Cost__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Overhead Cost';    //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Overhead_Cost__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Overhead_Cost__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Labor_Cost__c != quoteList[i].Labor_Cost__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Labor Cost';      //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Labor_Cost__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Labor_Cost__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Net_Value__c != quoteList[i].Net_Value__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Net Value';     //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Net_Value__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Net_Value__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Posting_Date__c != quoteList[i].Posting_Date__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Posting Date';     //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Posting_Date__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Posting_Date__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Exchange_Rate__c != quoteList[i].Exchange_Rate__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Exchange Rate';     //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Exchange_Rate__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Exchange_Rate__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].EOL_Date__c != quoteList[i].EOL_Date__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'EOL Date';     //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].EOL_Date__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].EOL_Date__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Fee_Increase__c != quoteList[i].Fee_Increase__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Fee Increase (%)';    //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Fee_Increase__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Fee_Increase__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].SAP_Expected_Bookings__c != quoteList[i].SAP_Expected_Bookings__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'SAP Expected Bookings';     //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].SAP_Expected_Bookings__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].SAP_Expected_Bookings__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].SAP_NPV__c != quoteList[i].SAP_NPV__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'SAP NPV';      //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].SAP_NPV__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].SAP_NPV__c);
                    qfhList.add(qfh);
                }
                
                
                if(quoteold[i].Milestone_Invoice_Term__c != quoteList[i].Milestone_Invoice_Term__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Milestone Invoice Term';     
                     List<Schema.PicklistEntry> picklistEntries = Quote.Milestone_Invoice_Term__c.getDescribe().getPicklistValues();   //IBA-3927 starts
                    Map<String,String> milestoneApiToLabelMap = new Map<String,String>();
                    for(Schema.PicklistEntry ple :picklistEntries){
                         milestoneApiToLabelMap.put(ple.getValue(),ple.getLabel());  
                     }
                    qfh.ORIGINAL_VALUE__c = milestoneApiToLabelMap.get(quoteold[i].Milestone_Invoice_Term__c);
                    qfh.NEW_VALUE__c = milestoneApiToLabelMap.get(quoteList[i].Milestone_Invoice_Term__c); 
                    qfhList.add(qfh);
                }
                
                
                if(quoteold[i].Freight_price__c != quoteList[i].Freight_price__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Freight price';     
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Freight_price__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Freight_price__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Supplement_Generated__c != quoteList[i].Supplement_Generated__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Supplement Generated';
                    List<Schema.PicklistEntry> picklistEntries = Quote.Supplement_Generated__c.getDescribe().getPicklistValues();   //IBA-3927 Starts
                    Map<String,String> supplementApiToLabelMap = new Map<String,String>();
                    for(Schema.PicklistEntry ple :picklistEntries){
                         supplementApiToLabelMap.put(ple.getValue(),ple.getLabel());  
                     }
                    qfh.ORIGINAL_VALUE__c = supplementApiToLabelMap.get(quoteold[i].Supplement_Generated__c);
                    qfh.NEW_VALUE__c = supplementApiToLabelMap.get(quoteList[i].Supplement_Generated__c); 
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Status != quoteList[i].Status){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Status';
                    List<Schema.PicklistEntry> picklistEntries = Quote.Status.getDescribe().getPicklistValues();   //IBA-3927 Starts
                    Map<String,String> statusApiToLabelMap = new Map<String,String>();
                    for(Schema.PicklistEntry ple :picklistEntries){
                         statusApiToLabelMap.put(ple.getValue(),ple.getLabel());  
                     }
                    qfh.ORIGINAL_VALUE__c = statusApiToLabelMap.get(quoteold[i].Status);
                    qfh.NEW_VALUE__c = statusApiToLabelMap.get(quoteList[i].Status); 
                    qfhList.add(qfh); 
                }
                
                if(quoteold[i].Primary_Quote__c != quoteList[i].Primary_Quote__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Primary Quote?';     //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Primary_Quote__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Primary_Quote__c);
                    qfhList.add(qfh);
                }
                if(quoteold[i].From__c != quoteList[i].From__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Valid From';      //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].From__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].From__c);
                    qfhList.add(qfh);
                }
                
                
                if(quoteold[i].ExpirationDate != quoteList[i].ExpirationDate){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Valid To';       //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].ExpirationDate);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].ExpirationDate);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Has_Critical_Errors__c != quoteList[i].Has_Critical_Errors__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Has Critical Errors';       //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Has_Critical_Errors__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Has_Critical_Errors__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Forecast_Category__c != quoteList[i].Forecast_Category__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Forecast Category';   //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Forecast_Category__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Forecast_Category__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Region__c != quoteList[i].Region__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Region';    //IBA-3927 Starts
                    List<Schema.PicklistEntry> picklistEntries = Quote.Region__c.getDescribe().getPicklistValues();   
                    Map<String,String> regionApiToLabelMap = new Map<String,String>();
                    for(Schema.PicklistEntry ple :picklistEntries){
                         regionApiToLabelMap.put(ple.getValue(),ple.getLabel());  
                     }
                    qfh.ORIGINAL_VALUE__c = regionApiToLabelMap.get(quoteold[i].Region__c);
                    qfh.NEW_VALUE__c = regionApiToLabelMap.get(quoteList[i].Region__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Milestone_Invoice_Term__c != quoteList[i].Milestone_Invoice_Term__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Milestone Invoice Term';
                    List<Schema.PicklistEntry> picklistEntries = Quote.Milestone_Invoice_Term__c.getDescribe().getPicklistValues();   
                    Map<String,String> mileApiToLabelMap = new Map<String,String>();
                    for(Schema.PicklistEntry ple :picklistEntries){
                         mileApiToLabelMap.put(ple.getValue(),ple.getLabel());  
                     }
                    qfh.ORIGINAL_VALUE__c = mileApiToLabelMap.get(quoteold[i].Milestone_Invoice_Term__c);
                    qfh.NEW_VALUE__c = mileApiToLabelMap.get(quoteList[i].Milestone_Invoice_Term__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Description != quoteList[i].Description){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Description';
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Description);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Description);
                    qfhList.add(qfh);
                }
                if(quoteold[i].Supplement_Version__c != quoteList[i].Supplement_Version__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Supplement Version #';    //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Supplement_Version__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Supplement_Version__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Currency__c != quoteList[i].Currency__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Currency';       //IBA-3927
                    List<Schema.PicklistEntry> picklistEntries = Quote.Currency__c.getDescribe().getPicklistValues();   
                    Map<String,String> currencyApiToLabelMap = new Map<String,String>();
                    for(Schema.PicklistEntry ple :picklistEntries){
                         currencyApiToLabelMap.put(ple.getValue(),ple.getLabel());  
                     }
                    qfh.ORIGINAL_VALUE__c = currencyApiToLabelMap.get(quoteold[i].Currency__c);
                    qfh.NEW_VALUE__c = currencyApiToLabelMap.get(quoteList[i].Currency__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Discount != quoteList[i].Discount){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Discount';
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Discount);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Discount);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Quote_Margin__c != quoteList[i].Quote_Margin__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Quote Margin';       //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Quote_Margin__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Quote_Margin__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Subtotal != quoteList[i].Subtotal){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Subtotal';
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Subtotal);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Subtotal);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Tax != quoteList[i].Tax){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Tax';
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Tax);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Tax);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Print_Exchange_Rate__c != quoteList[i].Print_Exchange_Rate__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Print Exchange Rate';      //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Print_Exchange_Rate__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Print_Exchange_Rate__c);
                    qfhList.add(qfh);
                }   
                
                if(quoteold[i].Print_Currency__c != quoteList[i].Print_Currency__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Print Currency';     //IBA-3927
                    List<Schema.PicklistEntry> picklistEntries = Quote.Print_Currency__c.getDescribe().getPicklistValues();   
                    Map<String,String> allApiToLabelMap = new Map<String,String>();
                    for(Schema.PicklistEntry ple :picklistEntries){
                         allApiToLabelMap.put(ple.getValue(),ple.getLabel());  
                     }
                    qfh.ORIGINAL_VALUE__c = allApiToLabelMap.get(quoteold[i].Print_Currency__c);
                    qfh.NEW_VALUE__c = allApiToLabelMap.get(quoteList[i].Print_Currency__c);
                    qfhList.add(qfh);
                }   
                
                if(quoteold[i].Exchange_Rate_Date__c != quoteList[i].Exchange_Rate_Date__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Exchange Rate Date';        //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Exchange_Rate_Date__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Exchange_Rate_Date__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Exchange_Rate_Override__c != quoteList[i].Exchange_Rate_Override__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Exchange Rate Override';      //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Exchange_Rate_Override__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Exchange_Rate_Override__c);
                    qfhList.add(qfh);
                }
                
                
                //Above 4 Field History are captured as Per May Scope UAT BUG 259 & 261 by Dg
                
                if(quoteold[i].TotalPrice != quoteList[i].TotalPrice){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Total Price';       //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].TotalPrice);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].TotalPrice);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].GrandTotal != quoteList[i].GrandTotal){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Grand Total';    //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].GrandTotal);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].GrandTotal);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Expected_Bookings__c != quoteList[i].Expected_Bookings__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Expected Bookings';        //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Expected_Bookings__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Expected_Bookings__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Total_Net__c != quoteList[i].Total_Net__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Total Net';      //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Total_Net__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Total_Net__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].IDN_Price_List__c != quoteList[i].IDN_Price_List__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'IDN Price List';       //IBA-3927 starts
                    List<Schema.PicklistEntry> picklistEntries = Quote.IDN_Price_List__c.getDescribe().getPicklistValues();  
                    Map<String,String> idnApiToLabelMap = new Map<String,String>();
                    for(Schema.PicklistEntry ple :picklistEntries){
                         idnApiToLabelMap.put(ple.getValue(),ple.getLabel());  
                     }
                    qfh.ORIGINAL_VALUE__c = idnApiToLabelMap.get(quoteold[i].IDN_Price_List__c);
                    qfh.NEW_VALUE__c = idnApiToLabelMap.get(quoteList[i].IDN_Price_List__c);  
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].GPO_Price_Lists__c != quoteList[i].GPO_Price_Lists__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'GPO Price Lists';          //IBA-3927 starts
                    List<Schema.PicklistEntry> picklistEntries = Quote.GPO_Price_Lists__c.getDescribe().getPicklistValues();  
                    Map<String,String> gpoApiToLabelMap = new Map<String,String>();
                    for(Schema.PicklistEntry ple :picklistEntries){
                         gpoApiToLabelMap.put(ple.getValue(),ple.getLabel());  
                     }
                    qfh.ORIGINAL_VALUE__c = gpoApiToLabelMap.get(quoteold[i].GPO_Price_Lists__c);
                    qfh.NEW_VALUE__c = gpoApiToLabelMap.get(quoteList[i].GPO_Price_Lists__c); 
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Sales_Org__c != quoteList[i].Sales_Org__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Sales Org';              //IBA-3927
                    List<Schema.PicklistEntry> picklistEntries = Quote.Sales_Org__c.getDescribe().getPicklistValues();   
                    Map<String,String> allApiToLabelMap = new Map<String,String>();
                    for(Schema.PicklistEntry ple :picklistEntries){
                         allApiToLabelMap.put(ple.getValue(),ple.getLabel());  
                     }
                    qfh.ORIGINAL_VALUE__c = allApiToLabelMap.get(quoteold[i].Sales_Org__c);
                    qfh.NEW_VALUE__c = allApiToLabelMap.get(quoteList[i].Sales_Org__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Terms_of_Payment__c != quoteList[i].Terms_of_Payment__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Terms of Payment';         //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Terms_of_Payment__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Terms_of_Payment__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Incoterms_1__c != quoteList[i].Incoterms_1__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Incoterms 1';           //IBA-3927
                    List<Schema.PicklistEntry> picklistEntries = Quote.Incoterms_1__c.getDescribe().getPicklistValues();   
                    Map<String,String> allApiToLabelMap = new Map<String,String>();
                    for(Schema.PicklistEntry ple :picklistEntries){
                         allApiToLabelMap.put(ple.getValue(),ple.getLabel());  
                     }
                    qfh.ORIGINAL_VALUE__c = allApiToLabelMap.get(quoteold[i].Incoterms_1__c);
                    qfh.NEW_VALUE__c = allApiToLabelMap.get(quoteList[i].Incoterms_1__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Incoterms_2__c != quoteList[i].Incoterms_2__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Incoterms 2';        //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Incoterms_2__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].Incoterms_2__c);
                    qfhList.add(qfh);
                }
                if(quoteold[i].OpportunityId != quoteList[i].OpportunityId){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Opportunity Name';       //IBA-3927
                    qfh.ORIGINAL_VALUE__c = [Select id,name from Opportunity where id =: quoteold[i].OpportunityId].name;
                    qfh.NEW_VALUE__c = [Select id,name from Opportunity where id =: quoteList[i].OpportunityId].name;   
                    qfhList.add(qfh);
                }
                
              if(quoteold[i].AccountId != quoteList[i].AccountId){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Account Name';              //IBA-3927
                    if(quoteold[i].AccountId != null)
                        qfh.ORIGINAL_VALUE__c = [Select id,name from Account where id =: quoteold[i].AccountId].name;
                    else
                        qfh.ORIGINAL_VALUE__c = '';
                    qfh.NEW_VALUE__c = [Select id,name from Account where id =: quoteList[i].AccountId].name;   
                    qfhList.add(qfh);
                }
                
                
                if(quoteold[i].Sales_Operation_Counterpart__c != quoteList[i].Sales_Operation_Counterpart__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Deal Desk';     //IBA-3927
                    if(quoteold[i].Sales_Operation_Counterpart__c != null)
                        qfh.ORIGINAL_VALUE__c = [Select id,name from user where id =: quoteold[i].Sales_Operation_Counterpart__c].name;
                    else
                        qfh.ORIGINAL_VALUE__c = '';                    
                    qfh.NEW_VALUE__c = [Select id,name from user where id =: quoteList[i].Sales_Operation_Counterpart__c].name;
                    qfhList.add(qfh);
                }
                
                
                
                if(quoteold[i].Consultant__c != quoteList[i].Consultant__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Clinical Consultant';                    
                    //qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Consultant__c); //IBA-3927 updating names instead of ID  
                    if(quoteold[i].Consultant__c != null)
                        qfh.ORIGINAL_VALUE__c = [Select id,name from user where id =: quoteold[i].Consultant__c].name;
                    else
                        qfh.ORIGINAL_VALUE__c = '';                    
                    //qfh.NEW_VALUE__c = String.valueof(quoteList[i].Consultant__c); //IBA-3927 updating names instead of ID
                    qfh.NEW_VALUE__c = [Select id,name from user where id =: quoteList[i].Consultant__c].name;
                    System.debug('@@Clinical Consultant : '+ qfh.NEW_VALUE__c);
                    qfhList.add(qfh);
                }
                if(quoteold[i].SAP_Sales_Org__c != quoteList[i].SAP_Sales_Org__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'SAP Sales Org';     //IBA-3927
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].SAP_Sales_Org__c);
                    
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].SAP_Sales_Org__r.Name);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].SAP_Sales_Org__c);
                    qfhList.add(qfh);
                }
                
                if(quoteold[i].Sales_Consultant__c != quoteList[i].Sales_Consultant__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Sales Consultant';     //IBA-3927
                    if(quoteold[i].Sales_Consultant__c != null)
                        qfh.ORIGINAL_VALUE__c = [Select id,name from user where id =: quoteold[i].Sales_Consultant__c].name;
                    else
                        qfh.ORIGINAL_VALUE__c = '';
                    
                    
            qfh.NEW_VALUE__c = [Select id,name from user where id =: quoteList[i].Sales_Consultant__c].name;
                    qfhList.add(qfh);
                }
                
                
                if(quoteold[i].SSM_RD__c != quoteList[i].SSM_RD__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Direct Manager';     //IBA-3927
                    if(quoteold[i].SSM_RD__c != null)
                        qfh.ORIGINAL_VALUE__c = [Select id,name from user where id =: quoteold[i].SSM_RD__c].name;
                    else
                        qfh.ORIGINAL_VALUE__c = '';
                    
                    qfh.NEW_VALUE__c = [Select id,name from user where id =: quoteList[i].SSM_RD__c].name;
                    qfhList.add(qfh);
                }
                if(quoteold[i].Order_Net_Price__c!= quoteList[i].Order_Net_Price__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Order Net Price';      //IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Order_Net_Price__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Order_Net_Price__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].GSA_Result1__c!= quoteList[i].GSA_Result1__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'GSA Result';         //IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].GSA_Result1__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].GSA_Result1__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].GSA_Result__c!= quoteList[i].GSA_Result__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Fail GSA';          //IBA-3927
                   List<Schema.PicklistEntry> picklistEntries = Quote.GSA_Result__c.getDescribe().getPicklistValues();   
                    Map<String,String> allApiToLabelMap = new Map<String,String>();
                    for(Schema.PicklistEntry ple :picklistEntries){
                         allApiToLabelMap.put(ple.getValue(),ple.getLabel());  
                     }
                    qfh.ORIGINAL_VALUE__c = allApiToLabelMap.get(quoteold[i].GSA_Result__c);
                    qfh.NEW_VALUE__c = allApiToLabelMap.get(quoteList[i].GSA_Result__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].GSA_Net_Price__c!= quoteList[i].GSA_Net_Price__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'GSA Net Price';          //IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].GSA_Net_Price__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].GSA_Net_Price__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].GSA_Price_Difference__c!= quoteList[i].GSA_Price_Difference__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'GSA Price Difference';      //IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].GSA_Price_Difference__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].GSA_Price_Difference__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Quote_Revision__c!= quoteList[i].Quote_Revision__c) 
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Revision Number';      //IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Quote_Revision__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Quote_Revision__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Quote_Number__c!= quoteList[i].Quote_Number__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'SAP Quote Number';         //IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Quote_Number__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Quote_Number__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].SAP_Sales_Order_Number__c!= quoteList[i].SAP_Sales_Order_Number__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'SAP Sales Order Number';      //IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].SAP_Sales_Order_Number__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].SAP_Sales_Order_Number__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Quote_Margin_Comments__c!= quoteList[i].Quote_Margin_Comments__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Quote Margin Comments';       //IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Quote_Margin_Comments__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Quote_Margin_Comments__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Order_Type__c!= quoteList[i].Order_Type__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Order Type';      //IBA-3927
                   List<Schema.PicklistEntry> picklistEntries = Quote.Order_Type__c.getDescribe().getPicklistValues();   
                    Map<String,String> allApiToLabelMap = new Map<String,String>();
                    for(Schema.PicklistEntry ple :picklistEntries){
                         allApiToLabelMap.put(ple.getValue(),ple.getLabel());  
                     }
                    qfh.ORIGINAL_VALUE__c = allApiToLabelMap.get(quoteold[i].Order_Type__c);
                    qfh.NEW_VALUE__c = allApiToLabelMap.get(quoteList[i].Order_Type__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Product_PO_Number__c!= quoteList[i].Product_PO_Number__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Product PO Number';  // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Product_PO_Number__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Product_PO_Number__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Service_PO_Number__c != quoteList[i].Service_PO_Number__c )
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Service PO Number';  // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Service_PO_Number__c );
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Service_PO_Number__c );
                 qfhList.add(qfh);
                }
                if(quoteold[i].Re_Opened__c!= quoteList[i].Re_Opened__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Re-Opened';       // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Re_Opened__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Re_Opened__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Reopen_Reason__c!= quoteList[i].Reopen_Reason__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Reopen Reason';         // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Reopen_Reason__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Reopen_Reason__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Inpatient_EHR__c!= quoteList[i].Inpatient_EHR__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Inpatient EHR';           // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Inpatient_EHR__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Inpatient_EHR__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Payer__c!= quoteList[i].Payer__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Payer';               // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Payer__r.Name);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Payer__r.Name);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Opportunity_Owner__c!= quoteList[i].Opportunity_Owner__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Opportunity Owner';               // IBA-3927
                 String oldName=' ';
                 String newName=' ';
                 if(quoteold[i].Opportunity_Owner__c != null)
                     oldName=[select name from User where id =: string.valueOf((quoteold[i].Opportunity_Owner__c)) limit 1].name;
                 else
                     oldName = '';
                 
                 newName=[select name from User where id =: string.valueOf((quoteList[i].Opportunity_Owner__c)) limit 1].name;
                 qfh.ORIGINAL_VALUE__c=oldName;
                 qfh.NEW_VALUE__c=newName;
                 qfhList.add(qfh);
                }
                if(quoteold[i].Lease_Duration__c!= quoteList[i].Lease_Duration__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Lease Duration';               // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Lease_Duration__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Lease_Duration__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Free_Month_for_Lease__c!= quoteList[i].Free_Month_for_Lease__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Free Month for Lease';           // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Free_Month_for_Lease__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Free_Month_for_Lease__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Annual_Bill_Date__c!= quoteList[i].Annual_Bill_Date__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Annual Bill Date';              // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Annual_Bill_Date__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Annual_Bill_Date__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Shipping_Conditions__c!= quoteList[i].Shipping_Conditions__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Shipping Conditions';           // IBA-3927
                  List<Schema.PicklistEntry> picklistEntries = Quote.Shipping_Conditions__c.getDescribe().getPicklistValues();   
                    Map<String,String> allApiToLabelMap = new Map<String,String>();
                    for(Schema.PicklistEntry ple :picklistEntries){
                         allApiToLabelMap.put(ple.getValue(),ple.getLabel());  
                     }
                    qfh.ORIGINAL_VALUE__c = allApiToLabelMap.get(quoteold[i].Shipping_Conditions__c);
                    qfh.NEW_VALUE__c = allApiToLabelMap.get(quoteList[i].Shipping_Conditions__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Service_Escalator__c!= quoteList[i].Service_Escalator__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Service Escalator';             // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Service_Escalator__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Service_Escalator__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Free_Month_Service__c!= quoteList[i].Free_Month_Service__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Free Month Service';
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Free_Month_Service__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Free_Month_Service__c);
                 qfhList.add(qfh);
                }
                
                if(quoteold[i].Renewal_Revenue__c!= quoteList[i].Renewal_Revenue__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Conga Renewal Revenue';         // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Renewal_Revenue__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Renewal_Revenue__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Service_Duration__c!= quoteList[i].Service_Duration__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Service Duration';
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Service_Duration__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Service_Duration__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Service_Escalator_Value__c!= quoteList[i].Service_Escalator_Value__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Service Escalator Value';
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Service_Escalator_Value__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Service_Escalator_Value__c);
                 qfhList.add(qfh);
                }
                
                if(quoteold[i].Service_Start_Date__c!= quoteList[i].Service_Start_Date__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Service Start Date';            // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Service_Start_Date__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Service_Start_Date__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Net_NPV__c!= quoteList[i].Net_NPV__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Net NPV';             // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Net_NPV__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Net_NPV__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Net_Interest_Rate__c!= quoteList[i].Net_Interest_Rate__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Net Interest Rate';            // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Net_Interest_Rate__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Net_Interest_Rate__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Monthly_Product_Lease_Payment__c!= quoteList[i].Monthly_Product_Lease_Payment__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Monthly Product Lease Payment';        // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Monthly_Product_Lease_Payment__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Monthly_Product_Lease_Payment__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Monthly_Service_Lease_payment__c!= quoteList[i].Monthly_Service_Lease_payment__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Monthly Service Lease payment';              // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Monthly_Service_Lease_payment__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Monthly_Service_Lease_payment__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Product_NPV__c!= quoteList[i].Product_NPV__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Product NPV';                  // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Product_NPV__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Product_NPV__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Service_NPV__c!= quoteList[i].Service_NPV__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Service NPV';        // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Service_NPV__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Service_NPV__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Booking_Date__c!= quoteList[i].Booking_Date__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Booking Date';               // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Booking_Date__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Booking_Date__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Expected_Install_Date__c!= quoteList[i].Expected_Install_Date__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Expected Install Date';             // IBA-3927
                 System.debug('@@install date: '+quoteold[i].Expected_Install_Date__c);
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Expected_Install_Date__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Expected_Install_Date__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Expected_Close_Date__c!= quoteList[i].Expected_Close_Date__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Expected Close Date';             // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Expected_Close_Date__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Expected_Close_Date__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Pricing_Reference_Date__c!= quoteList[i].Pricing_Reference_Date__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Pricing Reference Date - Product';         // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Pricing_Reference_Date__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Pricing_Reference_Date__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Requested_Delivery_Date__c!= quoteList[i].Requested_Delivery_Date__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Requested Delivery Date';            // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Requested_Delivery_Date__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Requested_Delivery_Date__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Corporate_Agreement_Pricing_Expiration__c!= quoteList[i].Corporate_Agreement_Pricing_Expiration__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Corporate Agreement Pricing Expiration';        // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Corporate_Agreement_Pricing_Expiration__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Corporate_Agreement_Pricing_Expiration__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Legacy_SAP_Created_Date__c!= quoteList[i].Legacy_SAP_Created_Date__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Legacy SAP Created Date';             // IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Legacy_SAP_Created_Date__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Legacy_SAP_Created_Date__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Email!= quoteList[i].Email)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Email';
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Email);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Email);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Phone!= quoteList[i].Phone)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Phone';
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Phone);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Phone);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Ship_to_Account__c!= quoteList[i].Ship_to_Account__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Ship-to Account';               //IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Ship_to_Account__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Ship_to_Account__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Fax!= quoteList[i].Fax)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Fax';
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Fax);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Fax);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Bill_to_Account__c!= quoteList[i].Bill_to_Account__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Bill-to Account';           //IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].Bill_to_Account__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].Bill_to_Account__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].Shipping_Contact__c!= quoteList[i].Shipping_Contact__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'Shipping Contact';            //IBA-3927
                 If(quoteOld[i].Shipping_Contact__c!=null)
                    qfh.ORIGINAL_VALUE__c = [Select id,Name from Contact where id =: quoteOld[i].Shipping_Contact__c].Name;
                 else
                     qfh.ORIGINAL_VALUE__c = '';
                 qfh.NEW_VALUE__c = [Select id,Name from Contact where id =: quoteList[i].Shipping_Contact__c].Name;
                 qfhList.add(qfh);
                }
                if(quoteold[i].GPO_Account__c!= quoteList[i].GPO_Account__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'GPO Account';                 //IBA-3927
                 if(quoteold[i].GPO_Account__c != null)
                     qfh.ORIGINAL_VALUE__c = [Select id,name from Account where id =: quoteold[i].GPO_Account__c].name;
                 else
                     qfh.ORIGINAL_VALUE__c = '';                 
                 qfh.NEW_VALUE__c = [Select id,name from Account where id =: quoteList[i].GPO_Account__c].name;
                 qfhList.add(qfh);
                }
                if(quoteold[i].IDN_Account__c!= quoteList[i].IDN_Account__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'IDN Account';            //IBA-3927
                 if(quoteold[i].IDN_Account__c != null)
                     qfh.ORIGINAL_VALUE__c = [Select id,name from Account where id =: quoteold[i].IDN_Account__c].name;
                 else
                     qfh.ORIGINAL_VALUE__c = '';  
                 
                 qfh.NEW_VALUE__c = [Select id,name from Account where id =: quoteList[i].IDN_Account__c].name;
                 qfhList.add(qfh);
                }
                if(quoteold[i].ProductChangeError__c!= quoteList[i].ProductChangeError__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'ProductChangeError';          //IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].ProductChangeError__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].ProductChangeError__c);
                 qfhList.add(qfh);
                }
                if(quoteold[i].SAPError__c!= quoteList[i].SAPError__c)
                {Quote_Field_History__c qfh = new Quote_Field_History__c();
                 qfh.Quote__c = quoteold[i].id;
                 qfh.FIELD__c = 'SAPError';           //IBA-3927
                 qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].SAPError__c);
                 qfh.NEW_VALUE__c = String.valueof(quoteList[i].SAPError__c);
                 qfhList.add(qfh);
                }
                
                
                
                if(quoteold[i].Hospital_Contact_Notes__c != quoteList[i].Hospital_Contact_Notes__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Hospital Contact Notes';
                    qfh.ORIGINAL_VALUE__c = quoteold[i].Hospital_Contact_Notes__c;
                    qfh.NEW_VALUE__c = quoteList[i].Hospital_Contact_Notes__c;
                    qfhList.add(qfh);
                }
                if(quoteold[i].Inv_Text_Notes__c != quoteList[i].Inv_Text_Notes__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Inv Text Notes';
                    qfh.ORIGINAL_VALUE__c = quoteold[i].Inv_Text_Notes__c;
                    qfh.NEW_VALUE__c = quoteList[i].Inv_Text_Notes__c;
                    qfhList.add(qfh);
                }
                if(quoteold[i].Quote_Printout_Standard_Text__c != quoteList[i].Quote_Printout_Standard_Text__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Quote Printout Standard Text';
                    qfh.ORIGINAL_VALUE__c = quoteold[i].Quote_Printout_Standard_Text__c;
                    qfh.NEW_VALUE__c = quoteList[i].Quote_Printout_Standard_Text__c;
                    qfhList.add(qfh);
                }
                if(quoteold[i].Other_Notes__c    != quoteList[i].Other_Notes__c ){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Other Notes';
                    qfh.ORIGINAL_VALUE__c = quoteold[i].Other_Notes__c  ;
                    qfh.NEW_VALUE__c = quoteList[i].Other_Notes__c  ;
                    qfhList.add(qfh);
                }
                if(quoteold[i].Quote_Text__c != quoteList[i].Quote_Text__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Quote Text';
                    qfh.ORIGINAL_VALUE__c = quoteold[i].Quote_Text__c;
                    qfh.NEW_VALUE__c = quoteList[i].Quote_Text__c;
                    qfhList.add(qfh);
                }
                if(quoteold[i].Special_Instructions__c   != quoteList[i].Special_Instructions__c    ){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Special Instructions';
                    qfh.ORIGINAL_VALUE__c = quoteold[i].Special_Instructions__c ;
                    qfh.NEW_VALUE__c = quoteList[i].Special_Instructions__c ;
                    qfhList.add(qfh);
                }
                if(quoteold[i].Sales_Ops_Notes__c != quoteList[i].Sales_Ops_Notes__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Deal Desk Notes';
                    qfh.ORIGINAL_VALUE__c = quoteold[i].Sales_Ops_Notes__c;
                    qfh.NEW_VALUE__c = quoteList[i].Sales_Ops_Notes__c;
                    qfhList.add(qfh);
                }
                if(quoteold[i].Rework_Comments__c != quoteList[i].Rework_Comments__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'Rework Comments';
                    qfh.ORIGINAL_VALUE__c = quoteold[i].Rework_Comments__c;
                    qfh.NEW_VALUE__c = quoteList[i].Rework_Comments__c;
                    qfhList.add(qfh);
                }
                  //IBA-3335 STARTS
                if(quoteold[i].of_beds__c != quoteList[i].of_beds__c){
                    Quote_Field_History__c qfh = new Quote_Field_History__c();
                    qfh.Quote__c = quoteold[i].id;
                    qfh.FIELD__c = 'DHC # of licensed beds';
                    qfh.ORIGINAL_VALUE__c = String.valueof(quoteold[i].of_beds__c);
                    qfh.NEW_VALUE__c = String.valueof(quoteList[i].of_beds__c);
                    qfhList.add(qfh);
                }
              //IBA-3335 END  
                
            } //end for
            insert qfhList;  
            //IBA-1592 Fix
            if(updatefromqa == false){ 
                UpdateQuoteOwner(quoteOld);
            }
        }
        
        updateSAPErrorOnQuoteHeader(oldItems, newItems); 
        //}//Added by sravan for SF-BUG-877 on FEB 18th 
    }
    
    @TestVisible
    private static boolean checkOldAndNewQuote(Quote oldqte, Quote newqte) {
        if (
            ( oldqte.GPO_Price_Lists__c != newqte.GPO_Price_Lists__c) ||
            ( oldqte.Name != newqte.Name) ||
            ( oldqte.Master_Agreement__c != newqte.Master_Agreement__c ) ||
            ( oldqte.ExpirationDate != newqte.ExpirationDate) ||
            ( oldqte.Posting_Date__c != newqte.Posting_Date__c) ||
            ( oldqte.From__c != newqte.From__c) ||
            ( oldqte.Shipping_Contact__c!= newqte.Shipping_Contact__c) ||
            ( oldqte.Fee_Increase__c!= newqte.Fee_Increase__c) ||
            ( oldqte.Corporate_Agreement_Pricing_Expiration__c!= newqte.Corporate_Agreement_Pricing_Expiration__c) ||
            ( oldqte.Sales_Org__c!= newqte.Sales_Org__c) ||
            ( oldqte.IDN_Price_List__c != newqte.IDN_Price_List__c)  || 
            ( oldqte.Ship_to_Account__c!= newqte.Ship_to_Account__c) || 
            ( oldqte.Bill_to_Account__c!= newqte.Bill_to_Account__c)  || 
            ( oldqte.Payer__c!= newqte.Payer__c)  || 
            ( oldqte.GPO_Account__c!= newqte.GPO_Account__c)  || 
            ( oldqte.IDN_Account__c!= newqte.IDN_Account__c)  || 
            ( oldqte.Sales_Operation_Counterpart__c!= newqte.Sales_Operation_Counterpart__c)  || 
            ( oldqte.EOL_Date__c!= newqte.EOL_Date__c)  || 
            ( oldqte.SSM_RD__c!= newqte.SSM_RD__c)  || 
            ( oldqte.Consultant__c!= newqte.Consultant__c)  ||
            ( oldqte.Sales_Consultant__c!= newqte.Sales_Consultant__c)  ||  
            ( oldqte.Description!= newqte.Description)  || 
            ( oldqte.ownerid!= newqte.ownerid)  ||
            ( oldqte.Currency__c!= newqte.Currency__c)  ||  
            ( oldqte.Primary_Quote__c!= newqte.Primary_Quote__c)  || 
            ( oldqte.Status!= newqte.Status)  || 
            ( oldqte.Requested_Delivery_Date__c!= newqte.Requested_Delivery_Date__c)  || 
            ( oldqte.Service_Level__c!= newqte.Service_Level__c)  || 
            ( oldqte.Free_Month_Service__c!= newqte.Free_Month_Service__c)  || 
            ( oldqte.Service_Escalator__c!= newqte.Service_Escalator__c)  ||
            ( oldqte.Service_Start_Date__c!= newqte.Service_Start_Date__c)  ||
            ( oldqte.Incoterms_2__c!= newqte.Incoterms_2__c)  || 
            ( oldqte.Incoterms_1__c!= newqte.Incoterms_1__c)  || 
            ( oldqte.Shipping_Conditions__c!= newqte.Shipping_Conditions__c)  || 
            ( oldqte.Product_PO_Number__c!= newqte.Product_PO_Number__c)  || 
            ( oldqte.Service_PO_Number__c!= newqte.Service_PO_Number__c)  || 
            ( oldqte.Free_Month_for_Lease__c!= newqte.Free_Month_for_Lease__c)  || 
            ( oldqte.Booking_Date__c!= newqte.Booking_Date__c)  ||
            ( oldqte.Pricing_Reference_Date__c!= newqte.Pricing_Reference_Date__c)  ||  
            ( oldqte.Terms_of_Payment__c!= newqte.Terms_of_Payment__c)  ||
            ( oldqte.Total_Net__c!= newqte.Total_Net__c)  ||
            ( oldqte.Exchange_Rate__c!= newqte.Exchange_Rate__c)  ||
            ( oldqte.Tax!= newqte.Tax)  ||
            ( oldqte.Hospital_Contact_Notes__c!= newqte.Hospital_Contact_Notes__c)  ||
            ( oldqte.Internal_Notes__c!= newqte.Internal_Notes__c)  ||
            ( oldqte.Inv_Text_Notes__c!= newqte.Inv_Text_Notes__c)  ||
            ( oldqte.Quote_Printout_Standard_Text__c!= newqte.Quote_Printout_Standard_Text__c)  ||
            ( oldqte.Rework_Comments__c!= newqte.Rework_Comments__c)  ||
            ( oldqte.Quote_Text__c!= newqte.Quote_Text__c)  ||
            ( oldqte.Other_Notes__c!= newqte.Other_Notes__c)  ||
            ( oldqte.Special_Instructions__c!= newqte.Special_Instructions__c)  ||
            ( oldqte.Sales_Ops_Notes__c!= newqte.Sales_Ops_Notes__c) ) {
                return true;
            } else {
                return false;
            }
        
    }    
    /**
*  Updates the SAP Error field on Quote Header with the Error Messages   
*  from Quote Notifications having the same revision number as the Quote Header
*/
    private void updateSAPErrorOnQuoteHeader(Map<Id, SObject> oldItems, Map<Id, SObject> newItems) {
        
        for (SObject newItem : newItems.values()) {
            
            Quote newQuote = (Quote) newItem;
            Quote oldQuote = (Quote) oldItems.get(newQuote.Id); 
            
            if (newQuote.Quote_Revision__c == oldQuote.Quote_Revision__c) 
                continue;             
            
            String sapError = ''; 
            Boolean hasCriticalErrors = false; 
            Quote_Error__c [] notifications = 
                [Select Id, Error_Message__c, Type__c from Quote_Error__c where Revision_Number__c =: newQuote.Quote_Revision__c and Quote__c =: newQuote.Id];
            
            for (Quote_Error__c notification : notifications) {
                sapError += notification.Error_Message__c + '\n';
                if (notification.Type__c == 'E') {
                    hasCriticalErrors = true; 
                } 
                
            }
            
            newQuote.SAPError__c = sapError;         
            newQuote.Has_Critical_Errors__c = hasCriticalErrors; 
        }   
        
        return; 
    }
    
    
    //=============================================================================
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){
        
    }
    //=============================================================================
    // AFTER UNDELETE
    //=============================================================================
    public void afterUndelete(Map<Id, SObject> oldItems){
        
    }
    //=============================================================================
    // AFTER INSERT
    //=============================================================================
    public void afterInsert(Map<Id, SObject> newItems){ 
        ////System.debug('After Insert');
        List<Quote> quoteList = newItems.values();
        Map<Id,Quote> newQuotemap = convertSobjectToQuoteMap(newItems); //IBA-3307
        isInsert = true;
         updateOpportunityFields(quoteList,newQuotemap,true); //IBA-3307
        connectToCastIronForInsert(quoteList);
        
    }
    
    //Once Quote is created,invoke REST api class to connect to CastIron. 
    public void connectToCastIronForInsert(List<Quote> quoteList){
        
        Set<Id> quoteIds = new Set<Id>();
        if(quoteList.size()>0)
        {
            for (Quote q : quoteList)
            {
                quoteIds.add(q.Id);
                
            }
        }
        if(System.IsBatch() == false && System.isFuture() == false && quoteIds.size()>0){ 
            OmnicellQuoteToCastIron_Class.callOutMethodInsert(quoteIds);
            
        }
    }
    
    
    
    //On Quote creation copy Opportunity Owner into Quote.Opportunity Owner field. 
    public void UpdateQuoteOwner(List<Quote> quoteList){ 
        Set<Id> optyIds = new Set<Id>();
        Set<Id> newoptyid = new Set<Id>();
        Map<Id, String> oldOwnerIds = new Map<Id, String>();
        Map<Id, String> newOwnerIds = new Map<Id, String>();
        List<Quote> quoteUpdates = new List<Quote>();
        
        if(quoteList.size()>0)
        {
            for (Quote q : quoteList)
            {
                optyIds.add(q.OpportunityId);
            }
            
        }
        
        if (!optyIds.isEmpty()) {
            
            Map<Id,Opportunity> opp = new Map<Id,Opportunity>([select id,OwnerId,currencyisocode from Opportunity where id in:optyIds]);
            
            for (Quote q : [Select id,OwnerId,currency__c, OpportunityId,currencyisocode ,Opportunity_Owner__c,Locked__c, Primary_Quote__c from Quote where OpportunityId in:optyIds])
            {
                if(q.Locked__c == false)
                {
                    q.Opportunity_Owner__c = opp.get(q.OpportunityId).OwnerId;
                    quoteUpdates.add(q);
                }
                
                
            }            
        }     
    } 
    //Added by Prithan IBA-2388 starts
    public static Map<Id, Quote> convertSobjectToQuoteMap(Map<Id, SObject> sObjectMap){
        Map<Id, Quote> qliMap = new Map<Id, Quote>();
        for(sObject sobj: sObjectMap.values()){
            Quote q = (Quote) sobj;
            qliMap.put(q.Id, q);
        }
        return qliMap;
    }// IBA-2388 Ends
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        Boolean isStatusBooked = false;// IBA-3298
        List<Quote> quoteList = newItems.values();
        List<Quote> oldquoteList = oldItems.values();
        Map<String,String> qtOrderTypechangeMap = new Map<String,String>();//IBA-3929 - Sourav
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
        Map<Id,Quote> quotesendToNetSuite = new Map<Id,Quote>([Select Id From Quote Where Id IN :newItems.keySet()
                                    AND Opportunity.RecordType.Name IN :oppRTforNetSuite AND NetSuite_ID__c = '' 
                                    AND Status = 'E0024' AND Opportunity.OpportunityGroup__c = 'Advanced Services' 
                                    AND Order_Type__c IN :quoteOrderTypeforNetSuite AND Opportunity.StageName = '6 Closed Won' 
                                    AND ECC_Sales_Order_Number__c != '']);       
        //IBA-4831 End
        Map<Id,Quote> oldQuotemap = convertSobjectToQuoteMap(oldItems);
        Boolean isUpdate = false;//IBA-2388 starts
         List<COGS_Dimension__c> cogsDimentions = new List<COGS_Dimension__c>();//Added as part of IBA-3356 to handle the New Quote COGS entry.
        //Remove for IBA-4189
        for(Quote q : quoteList){
            //Remove for IBA-4189
            if(q.Order_Type__c != oldQuotemap.get(q.Id).Order_Type__c){//IBA-3929 - Start - Sourav
                qtOrderTypechangeMap.put(q.Id,'1');
            }
            else{
                qtOrderTypechangeMap.put(q.Id,'0');
            }                                                           //IBA-3929 - End - Sourav
            if(q.SAP_Expected_Bookings__c != oldQuotemap.get(q.Id).SAP_Expected_Bookings__c && oldQuotemap.get(q.Id).SAP_Expected_Bookings__c == 0 && q.SAP_Expected_Bookings__c > 0){
                COGS_Dimension__c cog = new COGS_Dimension__c();
                if(q.SAP_Quote_Number_Truncated__c != null){
                    cog.COGS_Primary_Quote_SAP_Number__c = Decimal.valueOf(q.SAP_Quote_Number_Truncated__c); 
                }
                cog.COGS_Primary_Quote_Labor_Cost__c = q.Labor_Cost__c;    
                cog.COGS_Primary_Quote_Material_Cost__c = q.Material_Cost__c;
                cog.COGS_Primary_Quote_Overhead_Cost__c = q.Overhead_Cost__c;
                cog.COGS_Primary_Quote_Margin__c = q.Quote_Margin__c;
                cog.COGS_Primary_Quote_Expected_Booking__c = q.Expected_Bookings__c;  
                cog.COGS_Primary_Quote_Change_Datetime__c = DateTime.now();
                cog.Primary_Quote_ID__c = q.id;
                cog.Primary_Opportunity_Id__c = q.OpportunityId;
                cogsDimentions.add(cog);
            }
            
            if(q.Print_Currency__c != oldQuotemap.get(q.Id).Print_Currency__c 
               || q.Print_Exchange_Rate__c != oldQuotemap.get(q.Id).Print_Exchange_Rate__c 
               || q.Supplement_Generated__c != oldQuotemap.get(q.Id).Supplement_Generated__c
               || q.Milestone_Invoice_Term__c != oldQuotemap.get(q.Id).Milestone_Invoice_Term__c  
               || q.Account_CSN__c != oldQuotemap.get(q.Id).Account_CSN__c
               || q.Ship_to_Account__c != oldQuotemap.get(q.Id).Ship_to_Account__c
               || q.Bill_to_Account__c != oldQuotemap.get(q.Id).Bill_to_Account__c 
               || q.GPO_Account__c != oldQuotemap.get(q.Id).GPO_Account__c
               || q.IDN_Account__c != oldQuotemap.get(q.Id).IDN_Account__c 
               || q.Pricing_Code__c != oldQuotemap.get(q.Id).Pricing_Code__c 
               || q.Supplement1__c != oldQuotemap.get(q.Id).Supplement1__c 
               || q.Name != oldQuotemap.get(q.Id).Name 
               || q.Opportunity_Owner__c != oldQuotemap.get(q.Id).Opportunity_Owner__c
               || q.Primary_Quote__c != oldQuotemap.get(q.Id).Primary_Quote__c
               || q.Status != oldQuotemap.get(q.Id).Status
               || q.Posting_Date__c != oldQuotemap.get(q.Id).Posting_Date__c 
               || q.Total_Net__c != oldQuotemap.get(q.Id).Total_Net__c
               || q.Requested_Delivery_Date__c != oldQuotemap.get(q.Id).Requested_Delivery_Date__c
               || q.SSM_RD__c != oldQuotemap.get(q.Id).SSM_RD__c
               || q.Special_Pricing_code__c != oldQuotemap.get(q.Id).Special_Pricing_code__c
               || q.From__c != oldQuotemap.get(q.Id).From__c || q.ExpirationDate != oldQuotemap.get(q.Id).ExpirationDate
               || q.CreatedBy != oldQuotemap.get(q.Id).CreatedBy
               || q.Shipping_Contact__c != oldQuotemap.get(q.Id).Shipping_Contact__c
               || q.Master_Agreement__c != oldQuotemap.get(q.Id).Master_Agreement__c
               || q.Quote_Number__c != oldQuotemap.get(q.Id).Quote_Number__c 
               || q.Tax != oldQuotemap.get(q.Id).Tax 
               || q.Product_PO_Number__c != oldQuotemap.get(q.Id).Product_PO_Number__c 
               || q.Service_PO_Number__c != oldQuotemap.get(q.Id).Service_PO_Number__c
               || q.Booking_Date__c != oldQuotemap.get(q.Id).Booking_Date__c 
               || q.Terms_of_Payment__c != oldQuotemap.get(q.Id).Terms_of_Payment__c 
               || q.Currency__c != oldQuotemap.get(q.Id).Currency__c 
               || q.Exchange_Rate__c != oldQuotemap.get(q.Id).Exchange_Rate__c
               || q.Id != oldQuotemap.get(q.Id).Id
               || q.Order_Type__c != oldQuotemap.get(q.Id).Order_Type__c
               || q.Lease_Duration__c != oldQuotemap.get(q.Id).Lease_Duration__c
               || q.Free_Month_for_Lease__c != oldQuotemap.get(q.Id).Free_Month_for_Lease__c
               || q.Service_Duration__c != oldQuotemap.get(q.Id).Service_Duration__c
               || q.subscription_Months__c != oldQuotemap.get(q.Id).subscription_Months__c
               || q.Free_Month_Service__c != oldQuotemap.get(q.Id).Free_Month_Service__c
               || q.Pricing_Reference_Date__c != oldQuotemap.get(q.Id).Pricing_Reference_Date__c
               || q.IDN_Price_List__c != oldQuotemap.get(q.Id).IDN_Price_List__c
               || q.GPO_Price_Lists__c != oldQuotemap.get(q.Id).GPO_Price_Lists__c
               || q.Incoterms_1__c != oldQuotemap.get(q.Id).Incoterms_1__c
               || q.Shipping_Conditions__c != oldQuotemap.get(q.Id).Shipping_Conditions__c
               || q.Sales_Org__c != oldQuotemap.get(q.Id).Sales_Org__c
               || q.Service_Level__c != oldQuotemap.get(q.Id).Service_Level__c
               || q.SAP_Sales_Org_district__c != oldQuotemap.get(q.Id).SAP_Sales_Org_district__c
               || q.Sales_org_Distribution_Channel__c != oldQuotemap.get(q.Id).Sales_org_Distribution_Channel__c
               || q.Sales_org_Sales_Office__c != oldQuotemap.get(q.Id).Sales_org_Sales_Office__c
               || q.Incoterms_2__c != oldQuotemap.get(q.Id).Incoterms_2__c
               || q.Hospital_Contact_Notes__c != oldQuotemap.get(q.Id).Hospital_Contact_Notes__c
               || q.Inv_Text_Notes__c != oldQuotemap.get(q.Id).Inv_Text_Notes__c
               || q.Quote_Printout_Standard_Text__c != oldQuotemap.get(q.Id).Quote_Printout_Standard_Text__c
               || q.Other_Notes__c != oldQuotemap.get(q.Id).Other_Notes__c
               || q.Quote_Text__c != oldQuotemap.get(q.Id).Quote_Text__c
               || q.Special_Instructions__c != oldQuotemap.get(q.Id).Special_Instructions__c
               || q.Sales_Ops_Notes__c != oldQuotemap.get(q.Id).Sales_Ops_Notes__c
               || q.OpportunityId != oldQuotemap.get(q.Id).OpportunityId
               || q.of_beds__c != oldQuotemap.get(q.Id).of_beds__c
               || q.Professional_services_duration__c != oldQuotemap.get(q.Id).Professional_services_duration__c
               || q.Omnicell_One_Account_Type__c != oldQuotemap.get(q.Id).Omnicell_One_Account_Type__c
               || q.Associated_Opportunity_Number__c != oldQuotemap.get(q.Id).Associated_Opportunity_Number__c
               || q.Opportunity_ID__c != oldQuotemap.get(q.Id).Opportunity_ID__c
               || q.Associated_Sales_Order__c != oldQuotemap.get(q.Id).Associated_Sales_Order__c
               || q.Early_Adopter_Flag__c != oldQuotemap.get(q.Id).Early_Adopter_Flag__c
               || q.Resident_Operator_Duration__c != oldQuotemap.get(q.Id).Resident_Operator_Duration__c
               || q.X3rd_Deal_Rating_Spread__c != oldQuotemap.get(q.Id).X3rd_Deal_Rating_Spread__c
               || q.X3rd_Party_Interest_Rate__c != oldQuotemap.get(q.Id).X3rd_Party_Interest_Rate__c
               || q.In_House_Interest_Rate__c != oldQuotemap.get(q.Id).In_House_Interest_Rate__c
               || q.Rebate_Amount__c != oldQuotemap.get(q.Id).Rebate_Amount__c
               || q.Pricing_Reference_Date_Service__c != oldQuotemap.get(q.Id).Pricing_Reference_Date_Service__c
               || q.Credit_Approved_For_Lookup__c != oldQuotemap.get(q.Id).Credit_Approved_For_Lookup__c
               || q.Purchase_PO_Amount__c != oldQuotemap.get(q.Id).Purchase_PO_Amount__c
               || q.Purchase_PO_Date__c != oldQuotemap.get(q.Id).Purchase_PO_Date__c
               || q.Service_PO_Amount__c != oldQuotemap.get(q.Id).Service_PO_Amount__c
               || q.Service_PO_Date__c != oldQuotemap.get(q.Id).Service_PO_Date__c){
                   
                  isUpdate = true;
                   System.debug('*** isUpdate: '+isUpdate);
            }
            //IBA-3298 starts
            if(((q.Status != oldQuotemap.get(q.Id).Status && q.Primary_Quote__c==true) && (q.Status == 'E0013' || q.Status == 'E0014' || q.Status == 'E0019' || q.Status == 'E0023'|| q.Status == 'E0024'))
              ||((q.Re_create_Product_Line__c==true && q.Primary_Quote__c==true)&&(q.Status == 'E0013' || q.Status == 'E0014' || q.Status == 'E0019' || q.Status == 'E0023'|| q.Status == 'E0024')) 
              ){ 
                isStatusBooked = true;
                System.debug('************'+isStatusBooked);
            }
            //IBA-3298 ends
        }//IBA-2388 Ends
        //updateOpportunityForQuote(quoteList); //IBA-1919 Abhrajit //Comment out for IBA-3929 - Sourav
        if(!cogsDimentions.isEmpty()){ //IBA-3356
            insert cogsDimentions;
        }
        if(isFirstTime){
            isFirstTime = false;
            if(userinfo.getName() != Label.Integration_admin_user && updatefromquotelines == false && QuoteLineTriggerHandler.updatefromAddProduct == false){   //&&updatefromquotelines == false
                if(isUpdate){ //IBA-2388
                     System.debug('calling Quote update castIron');
                    connectToCastIronForUpdate(oldquoteList,qtOrderTypechangeMap);
                    }
            }
            System.debug('Opp : '+quoteList[0].opportunityId);
             if(!updatefromqa && isStatusBooked==true){//IBA-3298 
                System.debug('************ ProdLineSegBSegForPriQuote_Class called');
                ProdLineSegBSegForPriQuote_Class obj = new ProdLineSegBSegForPriQuote_Class();
                obj.initiateProductUpdates(quoteList,oldquoteList);
            }          
            if((quotesendToNetSuite.keySet().size()>0 && UserInfo.getUserId() != Label.Admin_Integration_User_Id) ||
               (UserInfo.getUserId() == Label.Admin_Integration_User_Id && 
                    oldquoteList[0].ECC_Sales_Order_Number__c !=  quoteList[0].ECC_Sales_Order_Number__c)){ //IBA-4831 Sourav
                system.enqueueJob(new OrderInfoSendToNetSuiteQueueable(quotesendToNetSuite.keySet()));
            }
        }
        
        //For all Primary Quotes, update the Expected Booking field on Opportunity with SAP Expected Booking value of Quote
        if(!updatefromqa){//IBA-2952
            updateOpportunityFields(quoteList,oldQuotemap,false); //Added IBA-3307
        }        
    }
    
    //Written by Venu Kukkapalli to check editable permissions of the user
    public void checkSelectedChange(Map<Id, Quote> newItems, Map<Id, Quote> oldItems){
        // Pavan K. Offline Build Jira # IBA-1270, Date Modified - Nov 05, 2020
        // Lines added: 88,89,90,92 and 94.        
        Boolean quoteStatusEditable = false;
        List<PermissionSet> offlineBuildRequestPermissions = [Select Id,Name,(SELECT Id,AssigneeId FROM Assignments Where AssigneeId = :UserInfo.getUserId()) From PermissionSet Where Name = 'OfflineBuildRequestManager' OR Name = 'OfflineBuildRequestUser'];
        for(PermissionSet permissionSet : offlineBuildRequestPermissions){
            if(permissionSet.Assignments != null) quoteStatusEditable = true;
        } 
        
        String profileName = [Select Id,Name from Profile where Id=:UserInfo.getProfileId()].Name;   
        
        for(Quote newqte:newItems.values()){
            Quote oldqte = oldItems.get(newqte.Id);
            Boolean statusopencheck = True;
            Boolean salesRelatedCheck = false;
            Boolean unSelected = False;
            Boolean selected = False;        
            if( 
                ( oldqte.GPO_Price_Lists__c != newqte.GPO_Price_Lists__c) ||   
                ( oldqte.Master_Agreement__c != newqte.Master_Agreement__c ) ||
                ( oldqte.ExpirationDate != newqte.ExpirationDate) ||
                ( oldqte.Posting_Date__c != newqte.Posting_Date__c) ||
                ( oldqte.From__c != newqte.From__c) ||   
                ( oldqte.Fee_Increase__c!= newqte.Fee_Increase__c) ||
                ( oldqte.Corporate_Agreement_Pricing_Expiration__c!= newqte.Corporate_Agreement_Pricing_Expiration__c) ||
                ( oldqte.Sales_Org__c!= newqte.Sales_Org__c) ||
                ( oldqte.IDN_Price_List__c != newqte.IDN_Price_List__c)  || 
                ( oldqte.Ship_to_Account__c!= newqte.Ship_to_Account__c) || 
                ( oldqte.Bill_to_Account__c!= newqte.Bill_to_Account__c)  || 
                ( oldqte.Payer__c!= newqte.Payer__c)  || 
                ( oldqte.GPO_Account__c!= newqte.GPO_Account__c)  || 
                ( oldqte.IDN_Account__c!= newqte.IDN_Account__c)  || 
                ( oldqte.Sales_Operation_Counterpart__c!= newqte.Sales_Operation_Counterpart__c)  || 
                ( oldqte.EOL_Date__c!= newqte.EOL_Date__c)  || 
                ( oldqte.SSM_RD__c!= newqte.SSM_RD__c)  || 
                ( oldqte.Consultant__c!= newqte.Consultant__c)  ||
                ( oldqte.Sales_Consultant__c!= newqte.Sales_Consultant__c)  ||  
                ( oldqte.Description!= newqte.Description)  || 
                ( oldqte.ownerid!= newqte.ownerid)  ||
                ( oldqte.Currency__c!= newqte.Currency__c)  ||      
                ( oldqte.Status!= newqte.Status)  || 
                ( oldqte.Requested_Delivery_Date__c!= newqte.Requested_Delivery_Date__c)  || 
                ( oldqte.Service_Level__c!= newqte.Service_Level__c)  || 
                ( oldqte.Free_Month_Service__c!= newqte.Free_Month_Service__c)  || 
                ( oldqte.Service_Escalator__c!= newqte.Service_Escalator__c)  ||
                ( oldqte.Service_Start_Date__c!= newqte.Service_Start_Date__c)  ||
                ( oldqte.Incoterms_2__c!= newqte.Incoterms_2__c)  || 
                ( oldqte.Incoterms_1__c!= newqte.Incoterms_1__c)  || 
                ( oldqte.Shipping_Conditions__c!= newqte.Shipping_Conditions__c)  || 
                ( oldqte.Product_PO_Number__c!= newqte.Product_PO_Number__c)  || 
                ( oldqte.Service_PO_Number__c!= newqte.Service_PO_Number__c)  || 
                ( oldqte.Free_Month_for_Lease__c!= newqte.Free_Month_for_Lease__c)  || 
                ( oldqte.Booking_Date__c!= newqte.Booking_Date__c)  ||
                ( oldqte.Pricing_Reference_Date__c!= newqte.Pricing_Reference_Date__c)  ||  
                ( oldqte.Terms_of_Payment__c!= newqte.Terms_of_Payment__c)  ||
                ( oldqte.Total_Net__c!= newqte.Total_Net__c)  ||
                ( oldqte.Exchange_Rate__c!= newqte.Exchange_Rate__c)  ||
                ( oldqte.Tax!= newqte.Tax)  ||
                ( oldqte.Hospital_Contact_Notes__c!= newqte.Hospital_Contact_Notes__c)  ||
                ( oldqte.Internal_Notes__c!= newqte.Internal_Notes__c)  ||
                ( oldqte.Inv_Text_Notes__c!= newqte.Inv_Text_Notes__c)  ||
                ( oldqte.Quote_Printout_Standard_Text__c!= newqte.Quote_Printout_Standard_Text__c)  ||
                ( oldqte.Rework_Comments__c!= newqte.Rework_Comments__c)  ||
                ( oldqte.Quote_Text__c!= newqte.Quote_Text__c)  ||
                ( oldqte.Other_Notes__c!= newqte.Other_Notes__c)  ||
                ( oldqte.Special_Instructions__c!= newqte.Special_Instructions__c)  ||
                ( oldqte.Sales_Ops_Notes__c!= newqte.Sales_Ops_Notes__c)    ||
                ( oldqte.Milestone_Invoice_Term__c!=newqte.Milestone_Invoice_Term__c)   ||
                ( oldqte.Service_Duration__c!=newqte.Service_Duration__c)   ||
                ( oldqte.Lease_Duration__c!=newqte.Lease_Duration__c)    ||
                ( oldqte.ExpirationDate!=newqte.ExpirationDate)    
            ){
                unSelected = True;   
            }
            if(   
                ( oldqte.Name != newqte.Name) ||
                ( oldqte.Primary_Quote__c!= newqte.Primary_Quote__c)  || 
                ( oldqte.Shipping_Contact__c!= newqte.Shipping_Contact__c) || 
                ( oldqte.Print_Currency__c!= newqte.Print_Currency__c) ||
                ( oldqte.Print_Exchange_Rate__c!= newqte.Print_Exchange_Rate__c) ||
                ( oldqte.Exchange_Rate_Override__c!= newqte.Exchange_Rate_Override__c) ||
                ( oldqte.Exchange_Rate_Date__c!= newqte.Exchange_Rate_Date__c)
            ){
                selected = True;
            }
            if(unSelected == True && (newqte.Status != Label.Quote_Auto_Approved_Status || newqte.Status != Label.Quote_Pending_Quote_Approvals_Status || newqte.Status != Label.Quote_Approved_Status || newqte.Status != Label.Quote_Approved_by_Deal_Desk_Status || newqte.Status != Label.Quote_Under_Rev_Reject_Approval_Status || newqte.Status != Label.Quote_Status_Open_for_edit_page)
               && (profileName != Label.Booking_Team && profileName != Label.DealDesk_Legal && profileName != Label.Business_Admin && profileName != Label.System_Admin && profileName != Label.International_Sales_Ops)){
                   statusopencheck = False;
               }
            
            if(newqte.Status == oldqte.Status && (newqte.Status == Label.Quote_Auto_Approved_Status 
                                                  || newqte.Status == Label.Quote_Pending_Quote_Approvals_Status 
                                                  || newqte.Status == Label.Quote_Approved_Status 
                                                  || newqte.Status == Label.Quote_Approved_by_Deal_Desk_Status
                                                  || newqte.Status == Label.Quote_Under_Rev_Reject_Approval_Status 
                                                  || newqte.Status == Label.Quote_Status_Open_for_edit_page)
               && (profileName == System.Label.SalesDevelopment ||
                   profileName == System.Label.SalesManager ||
                   profileName == System.Label.SalesRepresentative ||
                   profileName == System.Label.InternationalSalesRepresentative))
            {
                statusopencheck = true;
                if (
                    ( oldqte.Master_Agreement__c != newqte.Master_Agreement__c ) ||                                     
                    ( oldqte.ExpirationDate != newqte.ExpirationDate) ||                                     
                    ( oldqte.Posting_Date__c != newqte.Posting_Date__c) || 
                    ( oldqte.From__c != newqte.From__c) || 
                    ( oldqte.Fee_Increase__c!= newqte.Fee_Increase__c) || 
                    ( oldqte.Corporate_Agreement_Pricing_Expiration__c!= newqte.Corporate_Agreement_Pricing_Expiration__c) || 
                    ( oldqte.Sales_Org__c!= newqte.Sales_Org__c) || 
                    ( oldqte.IDN_Price_List__c != newqte.IDN_Price_List__c)  ||  
                    ( oldqte.Bill_to_Account__c!= newqte.Bill_to_Account__c)  ||                                    
                    ( oldqte.Payer__c!= newqte.Payer__c)  ||           
                    ( oldqte.GPO_Account__c!= newqte.GPO_Account__c)  || 
                    ( oldqte.IDN_Account__c!= newqte.IDN_Account__c)  ||  
                    ( oldqte.Sales_Operation_Counterpart__c!= newqte.Sales_Operation_Counterpart__c)  ||  
                    ( oldqte.EOL_Date__c!= newqte.EOL_Date__c)  ||  
                    ( oldqte.SSM_RD__c!= newqte.SSM_RD__c)  ||  
                    ( oldqte.Consultant__c!= newqte.Consultant__c)  || 
                    ( oldqte.Sales_Consultant__c!= newqte.Sales_Consultant__c)  ||                                     
                    ( oldqte.Description!= newqte.Description)  ||                                     
                    ( oldqte.ownerid!= newqte.ownerid)  || 
                    ( oldqte.Currency__c!= newqte.Currency__c)||           
                    ( oldqte.Status!= newqte.Status)||            
                    ( oldqte.Requested_Delivery_Date__c!= newqte.Requested_Delivery_Date__c)  ||  
                    ( oldqte.Service_Level__c!= newqte.Service_Level__c)  ||  
                    ( oldqte.Free_Month_Service__c!= newqte.Free_Month_Service__c)  ||  
                    ( oldqte.Service_Escalator__c!= newqte.Service_Escalator__c)  || 
                    ( oldqte.Service_Start_Date__c!= newqte.Service_Start_Date__c)  || 
                    ( oldqte.Incoterms_2__c!= newqte.Incoterms_2__c)  || 
                    ( oldqte.Incoterms_1__c!= newqte.Incoterms_1__c)  ||   
                    ( oldqte.Product_PO_Number__c!= newqte.Product_PO_Number__c)  ||  
                    ( oldqte.Service_PO_Number__c!= newqte.Service_PO_Number__c)  || 
                    ( oldqte.Free_Month_for_Lease__c!= newqte.Free_Month_for_Lease__c)  ||  
                    ( oldqte.Booking_Date__c!= newqte.Booking_Date__c)  || 
                    ( oldqte.Pricing_Reference_Date__c!= newqte.Pricing_Reference_Date__c)  ||   
                    ( oldqte.Terms_of_Payment__c!= newqte.Terms_of_Payment__c)  || 
                    ( oldqte.Total_Net__c!= newqte.Total_Net__c)  || 
                    ( oldqte.Exchange_Rate__c!= newqte.Exchange_Rate__c)  || 
                    ( oldqte.Tax!= newqte.Tax)  || 
                    ( oldqte.Hospital_Contact_Notes__c!= newqte.Hospital_Contact_Notes__c)  || 
                    ( oldqte.Internal_Notes__c!= newqte.Internal_Notes__c)  || 
                    ( oldqte.Inv_Text_Notes__c!= newqte.Inv_Text_Notes__c)  || 
                    ( oldqte.Quote_Printout_Standard_Text__c!= newqte.Quote_Printout_Standard_Text__c)  || 
                    ( oldqte.Rework_Comments__c!= newqte.Rework_Comments__c)  || 
                    ( oldqte.Quote_Text__c!= newqte.Quote_Text__c)  || 
                    ( oldqte.Other_Notes__c!= newqte.Other_Notes__c)  || 
                    ( oldqte.Special_Instructions__c!= newqte.Special_Instructions__c)  || 
                    ( oldqte.Sales_Ops_Notes__c!= newqte.Sales_Ops_Notes__c)    || 
                    ( oldqte.Milestone_Invoice_Term__c!=newqte.Milestone_Invoice_Term__c)   ||                                 
                    ( oldqte.Service_Duration__c!=newqte.Service_Duration__c)   ||                                 
                    ( oldqte.Lease_Duration__c!=newqte.Lease_Duration__c)    ||                                
                    ( oldqte.ExpirationDate!=newqte.ExpirationDate) )
                { statusopencheck = False;}
                
            }
            if((newqte.Status == Label.Quote_Booked_Status || newqte.Status == Label.Quote_Completed_Status || 
                newqte.Status == Label.Quote_Offline_Build_Status || newqte.Status == Label.Quote_Cancelled_Status) 
               && (profileName == System.Label.SalesDevelopment ||
                   profileName == System.Label.SalesManager ||
                   profileName == System.Label.SalesRepresentative ||
                   profileName == System.Label.InternationalSalesRepresentative)){
                       statusopencheck = False;
                   }
            if(newqte.Status == Label.Quote_Open_Status || quoteStatusEditable){
                statusopencheck = True;
            }
            if(statusopencheck == False){
                newqte.addError(Label.Quote_Status_Error_Message);
            }
        }
    }
    
    //Once Quote is updated,invoke REST api class to connect to CastIron. 
    public void connectToCastIronForUpdate(List<Quote> oldquoteList,Map<String,String> qtOrderTypechangeMap ){//IBA-3929- Sourav
        
        Set<Id> qteIds = new Set<Id>();
        Set<Id> quoteIds = new Set<Id>();
        
        if(oldquoteList.size()>0)
        {
            for (Quote q : oldquoteList)
            {
                qteIds.add(q.Id);
            }
        }
        
        List<Quote> qList = [select Id,SAP_Sales_Org__r.Incoterms_1__c,Supplement1__c,From__c,Service_Level__c,
                             OwnerId,Hospital_Contact_Notes__c,Inv_Text_Notes__c,Quote_Printout_Standard_Text__c,Other_Notes__c,
                             Quote_Text__c,Special_Instructions__c,Sales_Ops_Notes__c,Opportunity_Owner__r.Omnicell_Employee_Number__c,
                             Consultant__r.Omnicell_Employee_Number__c,SSM_RD__r.Omnicell_Employee_Number__c,
                             Sales_Operation_Counterpart__r.Omnicell_Employee_Number__c,CreatedBy.Omnicell_Employee_Number__c,
                             Supplement__c,Opportunity.Account.Pricing_Code__c,Opportunity.Account.Special_Pricing_Code__c,Tax,
                             Opportunity.AccountId,Opportunity.Account.SAP_Account_ID__c,Name,Notes__c,ExpirationDate,SAP_Sales_Org__c,
                             SAP_Sales_Org__r.Incoterms_2__c,SAP_Sales_Org__r.Distribution_Channel__c,SAP_Sales_Org__r.Service_Level__c,
                             SAP_Sales_Org__r.District__c,Bill_to_Account__r.SAP_Account_ID__c,Ship_to_Account__r.SAP_Account_ID__c,
                             Terms_of_Payment__c,Currency__c,Exchange_Rate__c,Requested_Delivery_Date__c,Product_PO_Number__c,
                             Booking_Date__c,Service_PO_Number__c,CreatedById,ContactId,OpportunityId,Opportunity.Description,
                             Primary_Quote__c,Status,CreatedDate,Total_Net__c,Opportunity_Owner__c, ShippingAddress,BillingAddress,
                             Payer__r.SAP_Account_ID__c,Description,Order_Type__c,Quote_Number__c,LineItemCount,Master_Agreement__c,
                             Lease_Duration__c,Free_Month_for_Lease__c,Service_Duration__c,Free_Month_Service__c,
                             Pricing_Reference_Date__c,IDN_Price_List__c,GPO_Price_Lists__c,Incoterms_1__c,Incoterms_2__c,
                             Shipping_Conditions__c,Sales_Org__c,Create_Sales_Order__c,GPO_Account__r.SAP_Account_ID__c,
                             IDN_Account__r.SAP_Account_ID__c,Contact.SAP_Contact_ID__c,SAP_Sales_Org__r.Sales_Office__c,
                             Quote_Type_Changed__c,Milestone_Invoice_Term__c FROM Quote WHERE Id =:qteIds];
        
        if(qList.size()>0)
        {
            for(Quote qte : qList)
            {
                quoteIds.add(qte.Id);
            }
            
        }
        
        if(System.IsBatch() == false && System.isFuture() == false && quoteIds.size()>0 && isInsert == false)
        { 
            OmnicellQuoteToCastIron_Class.callOutMethodUpdate(quoteIds,qtOrderTypechangeMap);//IBA-3929
            
        }
        
    }     
    
    public void UpdateRenewalRevenue(List<Quote> quoteList)
    {
        AggregateResult[] prices = [select Quote__c quote,sum(sap_npv__c) sapnpv
                                    from Quote_Line__c 
                                    where Quote__c = :quoteList 
                                    and Line_Status__c != 'E0006'
                                    and material_type__c = 'PRODUCT'
                                    and (Product__r.ProductCode = 'Renewal'
                                         or Product__r.ProductCode = 'RENEWAL') 
                                    group by Quote__c];
        Id quoteId; 
        Decimal renewalRevenue = 0;                                       
        Map<Id, decimal> quoteRenewalMap = new  Map<Id, decimal>();
        for(Integer i=0;i<prices.size();i++)
        {
            quoteId = (Id)prices[i].get('quote');
            if(prices[i].get('sapnpv') != null)
                renewalRevenue = (Decimal)prices[i].get('sapnpv');
            quoteRenewalMap.put(quoteId,renewalRevenue);
            renewalRevenue = 0;
        }   
        //Pabitra : IBA-1694
        for (Quote q : quoteList)
          {
            q.renewal_revenue__c = quoteRenewalMap.get(q.id);
          }  //END IBA-1694 
    }
    
    //added below function soumyad 964 & 965
    public void InitialValue(List<Quote> newList, List<Id> accIdList){//IBA-3929 soumyad 
        
        string omni_one;
        
        for(Account acc:[SELECT Id, Omnicell_One_Account_Type__c FROM Account WHERE Id In: accIdList]){ 
            omni_one = acc.Omnicell_One_Account_Type__c;
        }
        for(Quote qt:newList){
            qt.Omnicell_One_Account_Type__c=omni_one;
        }
    }
    
    public void updateQuoteRegion(List<Quote> newList ){ 
        List<Id> accIdList=new List<Id>();
        Map<Id,String> accRegionMap=new Map<Id,String>();
        Map<Id,String> accDivisionMap=new Map<Id,String>(); // IBA-3797
        for(Quote qt: newList){
            if(!accIdList.contains(qt.Account_ID__c)){
                accIdList.add(qt.Account_ID__c);
            }
        }
        for(Account acc:[SELECT Id,Region__c,Division_Account__c FROM Account WHERE Id In: accIdList]){ // added Division_Account__c as part of IBA-3797
            if(!accRegionMap.containskey(acc.id)){
                accRegionMap.put(acc.Id, acc.Region__c);
                accDivisionMap.put(acc.id, acc.Division_Account__c); // IBA-3797
            }   
        }
        for(Quote qt:newList){
            if(qt.Region__c != accRegionMap.get(qt.Account_ID__c)){
                qt.Region__c=accRegionMap.get(qt.Account_ID__c);
                qt.Division__c = accDivisionMap.get(qt.Account_ID__c); // IBA-3797
            }
        }
    }
    
    /* Below function added for SF-BUG-684 */
    public static void checkgpopricelist(Id qid,List<Quote> quoteList){
        
        List<Quote> oldquoteList = [SELECT Id, name, Account.Name, Account.GPO_AC__r.name,GPO_Price_Lists__c, SAP_Sales_Org__r.Default_GPO_Price_List__c,
                                    SAP_Sales_Org__r.name
                                    FROM Quote
                                    where id = :qid];       
        /* Variables declared */
        boolean flg = false;       
        string AccountName = '';
        string GPOAcName = '';
        string SAPSalesOrgrName = '';
        string GPOPLists = '';
        
        for(Quote q: oldquoteList){
            
            AccountName = q.Account.Name;
            GPOAcName = q.Account.GPO_AC__r.name;
            SAPSalesOrgrName = q.SAP_Sales_Org__r.name;
            GPOPLists = q.GPO_Price_Lists__c;      
            for(Quote qnw: quoteList){
                if (String.isBlank(qnw.GPO_Price_Lists__c)) {
                    /*Returns true if the specified String is white space, empty (''), or null; otherwise, returns false.*/    
                    flg = true; 
                }
                else if ( qnw.GPO_Price_Lists__c == q.SAP_Sales_Org__r.Default_GPO_Price_List__c){
                    /* If the GPO Price List selected matches with Default GPO Price List of the corresponding SAP Sales Org*/
                    
                    GPOPLists = qnw.GPO_Price_Lists__c;
                    
                    for(GPODetails__c cc: [Select name,pick_val__c from GPODetails__c where pick_val__c = :GPOPLists ]){
                        
                        /* In a loop for selected GPO Price List from GPODetails__c if presnt */
                        
                        List<Relationship__c> relList = [ select Primary_Account__r.name,Secondary_Account__r.name,Primary_Account_Sales_Org__r.name  
                                                         from Relationship__c where 
                                                         Primary_Account__r.name = :AccountName 
                                                         //and Secondary_Account__r.name = :GPOAcName and 
                                                         and Relationship__c ='ZG'
                                                         and Primary_Account_Sales_Org__r.name  = :SAPSalesOrgrName ];
                        
                        /* Get the GPO A/c from Relationship for the Maching A/c, GPO A/c, GPO Type and Sap Sales Org */
                        
                        if(relList.size()>0)  // Matching Record obtained 
                        {
                            for(Relationship__c rel: relList){
                                
                                /* If both GPO Names matched */
                                
                                if(cc.name == rel.Secondary_Account__r.name){
                                    flg = true;}
                                
                                /*If the  GPO Name do not match*/ 
                                
                                if (cc.name <> rel.Secondary_Account__r.name){
                                    flg = false ;
                                } //End If 
                                
                                
                            }
                        }
                        /* If No GPO A/c is found from Relationship for the Maching A/c, GPO A/c, GPO Type and Sap Sales Org*/
                        else 
                        {flg = false ;
                        }}
                }
                else {
                    
                    GPOPLists = qnw.GPO_Price_Lists__c;
                    for(GPODetails__c cc: [Select name,pick_val__c from GPODetails__c where pick_val__c = :GPOPLists ]){
                        
                        /* In a loop for selected GPO Price List from GPODetails__c if presnt */
                        
                        List<Relationship__c> relList1 = [ select Primary_Account__r.name,Secondary_Account__r.name,Primary_Account_Sales_Org__r.name  
                                                          from Relationship__c where 
                                                          Primary_Account__r.name = :AccountName 
                                                          //and Secondary_Account__r.name = :GPOAcName 
                                                          and Relationship__c ='ZG'
                                                          and Primary_Account_Sales_Org__r.name  = :SAPSalesOrgrName ];
                        
                        /* Get the GPO A/c from Relationship for the Maching A/c, GPO A/c, GPO Type and Sap Sales Org */
                        
                        if(relList1.size()>0)  // Matching Record obtained 
                        {
                            for(Relationship__c rel: relList1){
                                
                                /* If both GPO Names matched */
                                
                                if(cc.name == rel.Secondary_Account__r.name){
                                    flg = true;}
                                
                                /*If the  GPO Name do not match*/ 
                                
                                if (cc.name <> rel.Secondary_Account__r.name){
                                    flg = false ;
                                } //End If 
                                
                                
                            }
                        }
                        /* If No GPO A/c is found from Relationship for the Maching A/c, GPO A/c, GPO Type and Sap Sales Org*/
                        else 
                        {flg = false ;
                        }}
                }
                
                if ( flg == false ){
                    qnw.GPO_Price_Lists__c.addError('Sales will only be able to update the GPO price list only to 1.USA price list,2.Default GPO price list,3.Applicable tiered GPO price list. No other options are allowed');
                }
                
            }
        }
        
        
    }
    /* Below function added for SF-BUG-684 */
    
    public static void checkidnpricelist(Id qid,List<Quote> quoteList){
        
        List<Quote> oldquoteList = [SELECT Id, name, Account.Name, Account.IDN_Account__r.name, IDN_Price_List__c,
                                    SAP_Sales_Org__r.Default_IDN_Price_List__c,SAP_Sales_Org__r.name
                                    FROM Quote
                                    where id = :qid];     
        
        boolean flg = false;
        
        for(Quote q: oldquoteList){
            string AccountName = q.Account.Name;
            string IDNAcName = q.Account.IDN_Account__r.name;
            string SAPSalesOrgrName = q.SAP_Sales_Org__r.name;
            string IDNPLists = q.IDN_Price_List__c;
            for(Quote qnw: quoteList){     
                if (String.isBlank(qnw.IDN_Price_List__c)) {
                    /*Returns true if the specified String is white space, empty (''), or null; otherwise, returns false.*/     
                    flg = true; 
                }
                else if ( qnw.IDN_Price_List__c == q.SAP_Sales_Org__r.Default_IDN_Price_List__c){
                    /* If the IDN Price List selected matches with Default IDN Price List of the corresponding SAP Sales Org*/
                    
                    /* In a loop for selected IDN Price List from Relationship__c if presnt */
                    
                    List<Relationship__c> relList = [ select Primary_Account__r.name,Secondary_Account__r.name,Primary_Account_Sales_Org__r.name  
                                                     from Relationship__c where 
                                                     Primary_Account__r.name = :AccountName  
                                                     and Relationship__c ='ZI'
                                                     and Primary_Account_Sales_Org__r.name  = :SAPSalesOrgrName ];
                    
                    /* Get the IDN A/c from Relationship for the Maching A/c, IDN A/c, IDN Type and Sap Sales Org */
                    
                    if(relList.size()>0)  // Matching Record obtained 
                    {
                        for(Relationship__c rel: relList){
                            
                            /*Commenting out the below check as we can not map here neither by list value nor by 2nd a/c name*/ 
                            flg = true;   
                        }
                    }
                    /* If No IDN A/c is found from Relationship for the Maching A/c, IDN A/c, IDN Type and Sap Sales Org*/
                    else 
                    {flg = false ;
                    }   
                }
                if ( flg == false ){
                    qnw.addError('Sales will only be able to update the IDN price list only to 1.USA price list,2.Default IDN price list. No other options are allowed');
                }
            }    
            
            
            
        }
        
        
    }
    
    /* Below function added for UAT 259 and 261 */
    public static void updateQuoteCurrencies(List<Quote> quoteList){
        Set<String> currencyCodeSet = new Set<String>();
        
        for(Quote q: quoteList){
            currencyCodeSet.add(q.CurrencyIsoCode.toUpperCase());
            if((q.Print_Currency__c != null)&&(q.Print_Currency__c != q.Quote_Currency__c ))
            {
                if(q.Print_Currency__c.contains('-'))
                {
                    currencyCodeSet.add(q.Print_Currency__c.split('-')[0].trim().toUpperCase()); 
                }
                else
                {
                    currencyCodeSet.add(q.Print_Currency__c.toUpperCase()); 
                    
                    
                }
                
                Map<String, DatedConversionRate> currency2DatedConversionRateMap = new Map<String, DatedConversionRate>();
                for(DatedConversionRate dcr: [SELECT ConversionRate,IsoCode,NextStartDate,StartDate FROM DatedConversionRate where IsoCode IN : currencyCodeSet ORDER BY LastModifiedDate DESC NULLS FIRST]){
                    if(!currency2DatedConversionRateMap.containsKey(dcr.IsoCode)){
                        currency2DatedConversionRateMap.put(dcr.IsoCode, dcr);
                    }
                }
                
                Map<string,string> ccMap = new Map<string,string>();
                for(CurrencyCulture__c cc: [Select isocode__c,culture_code__c  from CurrencyCulture__c where isocode__c IN :currencyCodeSet]){
                    ccMap.put(cc.isocode__c,cc.culture_Code__c);
                }
                
                Double var_exchange_rate = 0; 
                
                if(q.Print_Currency__c.contains(q.CurrencyIsoCode)){ // when Print Currency is same as quote currency
                    q.Exchange_Rate__c = 1;
                }else{
                    if(!q.Exchange_Rate_Override__c){ //If overwritten Flag is false get the value from repository.
                        q.Print_Exchange_Rate__c = currency2DatedConversionRateMap.get(q.Print_Currency__c.split('-')[0].trim().toUpperCase()).ConversionRate;
                        q.Exchange_Rate_Date__c = currency2DatedConversionRateMap.get(q.Print_Currency__c.split('-')[0].trim().toUpperCase()).StartDate;
                        var_exchange_rate  = currency2DatedConversionRateMap.get(q.Quote_Currency__c.split('-')[0].trim().toUpperCase()).ConversionRate;
                        if ((q.Print_Currency__c != null) && (q.Print_Currency__c != q.Quote_Currency__c)  ){
                            q.Print_Exchange_Rate__c = var_exchange_rate*q.Print_Exchange_Rate__c;
                        }
                    }
                    if(q.Exchange_Rate_Override__c){   //If overwritten is True get the value from the Form field                             
                        q.Exchange_Rate_Date__c =  date.today();                              
                    }
                }
                q.Alternate_Culture_Code__c = ccMap.get(q.Print_Currency__c.split('-')[0].trim());
                q.Mul_Cur_Print__c = true;
                
            }
            else {
                
                /* If Edit the Print Currency and blank it out */
                /* Change Print_Exchange_Rate, Alternate_Culture_Code, Exchange_Rate_Date to blank */
                /* Mul_Cur_Print__c & Change Exchange_Rate_Override__c to False */
                
                q.Alternate_Culture_Code__c =  null;
                q.Print_Currency__c = null;   // This is required when it is same as quote currency.
                q.Print_Exchange_Rate__c = null;
                q.Exchange_Rate_Date__c = null;
                q.Exchange_Rate_Override__c = false;
                q.Mul_Cur_Print__c = false;
            }  /* End If Else */
            
            
        }  /* End For */
        
    } /* End updateQuoteCurrencies UAT-BUG-259&261 */    
    
    /*public void updateService(List<Quote> qlists){// IBA-3929 soumyad
        
        for(Quote q: qlists){
            if(q.Order_Type__c == 'ZQRS'){
                q.Service_Duration__c=q.subscription_Months__c;
            }
        }
    }*/
    //SF-BUG-480 fix: This function is checking if product lines are present on Opportunity or not.
    public void checkProductLines(List<Quote> qList) {
        Set<ID> oppId = new Set<ID>();
        String errorMsg = System.Label.No_ProductLine_error_on_Opp;
        for(Quote q : qList) {
            oppId.add(q.OpportunityId);
        }
        List<Opportunity> op = [Select id,Pre_Approved_Parts__c from Opportunity where id IN :oppId];
        List<Product_Line__c> pl = [Select id,Opportunity__c from Product_Line__c where Opportunity__c IN : oppId];
        List<ID> opListApprovedID = new List<ID>();  
        Map<String,List<Product_Line__c>> linemapq2= new Map<String,List<Product_Line__c>>();
        for(Product_Line__c q : pl){
            if(linemapq2.containsKey(q.Opportunity__c)){
                List<Product_Line__c> proList=linemapq2.get(q.Opportunity__c);
                proList.add(q);
                linemapq2.put(q.Opportunity__c, proList);
            }
            else{
                linemapq2.put(q.Opportunity__c, new List<Product_Line__c>{q});
            }
        }
        
        for(Opportunity o : op){
            if(o.Pre_Approved_Parts__c == true) {
                opListApprovedID.add(o.id);
            }
        }
        
        for(Quote qq : qList) {
            if(!linemapq2.containsKey(qq.OpportunityId) && !opListApprovedID.contains(qq.OpportunityId)) {
                qq.addError(errorMsg);
            }
        }
        
    }
    public void updateDHC_licensedBeds(List<Quote> qList){//logic for IBA-3101
            Map<Id,Decimal> acctBedsMap = new Map<Id,Decimal>();
            List<Account> acctList = new List<Account>();
            Set<Id> accIds = new Set<Id>(); 
            for(Quote qt :qList){
                accIds.add(qt.Account_ID__c);
            }
            acctList = [Select Id,Licensed_Beds_for_OC1_Quoting__c From Account Where Id IN :accIds];
            for(Account ac :acctList){
                acctBedsMap.put(ac.Id,ac.Licensed_Beds_for_OC1_Quoting__c);
            }   
            for(Quote qt :qList){
                if(qt.Status == 'E0001' || qt.Status == null){
                    Id actId = qt.Account_ID__c; 
                    qt.of_beds__c = acctBedsMap.get(actId);
                }
            }

    }
    
    //Added by Pavan palla as part of new XR2 & IVX changes IBA-1135 Nov-Release
        public void updateQuoteFields(List<Quote> qList) {
        Set<Id> opportunityIds = new Set<Id>(); 
        for(Quote q : qList){
            opportunityIds.add(q.OpportunityId);
        }
        Map<Id,Id> oppMap = new Map<Id,Id>();
        Map<Id,Id> oppMapQ = new Map<Id,Id>();
        Map<Id,Boolean> oppMapASService = new Map<Id,Boolean>();
        Map<Id,String> oppMapSales = new Map<Id,String>();
        Map<Id,String> oppMapQuote = new Map<Id,String>();
        Map<Id,String> creditApprovedForMap = new Map<Id,String>();
        for(Opportunity opp : [SELECT Id,Associated_Opportunity__c,As_Service__c, Credit_Approved_For__c from opportunity where Id IN: opportunityIds]){
            oppMap.put(opp.Associated_Opportunity__c,opp.Id);
            oppMapQ.put(opp.Id,opp.Associated_Opportunity__c);
            oppMapASService.put(opp.Id,opp.As_Service__c);
            creditApprovedForMap.put(opp.id, opp.Credit_Approved_For__c);
        }
        for(Quote quote : [SELECT Id,SAP_Sales_Order_Number__c,Quote_Number__c,OpportunityId from Quote WHERE Primary_Quote__c = true AND OpportunityId IN: oppMap.keyset() ]){
            oppMapSales.put(oppMap.get(quote.OpportunityId),quote.SAP_Sales_Order_Number__c);
            oppMapQuote.put(oppMap.get(quote.OpportunityId),quote.Quote_Number__c);
        }
        for(Quote q : qList){
                q.Associated_Sales_Order__c = oppMapSales.get(q.OpportunityId);
                q.Associated_Opportunity_Number__c = oppMapQ.get(q.OpportunityId);
                q.Opportunity_ID__c = q.OpportunityId;
                q.Early_Adopter_Flag__c = oppMapASService.get(q.OpportunityId);
            
            //Updated Query by Pavan palla as part of new XR2 & IVX changes IBA-1135 Nov-Release-Enhancements
                if(q.Order_Type__c == 'ZQRS' && q.Early_Adopter_Flag__c == True){
                    q.Resident_Operator_Duration__c = q.subscription_Months__c;
                } 
            
                  
            if(trigger.isInsert && trigger.isBefore && creditApprovedForMap.containsKey(q.OpportunityId)){
                q.Credit_Approved_For_Lookup__c = creditApprovedForMap.get(q.OpportunityId);
            }
        }
    }
    //IBA-2345
    public void checkQuoteDecommision(List<Quote> quoteList) {
        System.debug('inside checkQuoteDecommision..');
        List<Quote_Line__C> qlList = [Select id,Quote__c,Quote_Line_Item_Type__c from Quote_Line__C where Quote__C IN : quoteList];
        Map<Id, List<Quote_Line__c>> qToQL = new  Map<Id, List<Quote_Line__c>>();
        if(qlList != Null && qlList.size()>0) {
            for(Quote_Line__C ql: qlList) {
                if(qToQL.containsKey(ql.Quote__c)) {
                    List<Quote_Line__C> qlValues = qToQL.get(ql.Quote__c);
                    qlValues.add(ql);
                    qToQL.put(ql.Quote__c,qlValues);
                }else {
                    qToQL.put(ql.Quote__c,new List<Quote_Line__C>{ql});
                }
                
            }
            for(Quote q: quoteList) {
                q.Is_Decommision_Quote__c = false;
                if(qToQL.containsKey(q.id))
                {
                    List<Quote_Line__C> qlines = qToQL.get(q.id);
                    for(Quote_Line__C ql: qlines) {
                        if(ql.Quote_Line_Item_Type__c == 'Decommission') {
                            q.Is_Decommision_Quote__c = true;
                        }
                    }
                }
            }
        }
        
    }
       //Added IBA-3307 START
    public static void updateOpportunityFields(List<Quote> quoteList, Map<Id,Quote> oldItems, Boolean isInsert) {
        Set<Id> opportunityIds = new Set<Id>(); 
        User us = [select id,User_ID__c,profile.Name from User where profileid =: UserInfo.getProfileId() limit 1]; //IBA-3929 - Sourav
        for (Quote q : quoteList) {
            if (q.OpportunityId != null && q.Update_from_quote_lines__c != true) {
                opportunityIds.add(q.OpportunityId);
            }
        }
        
        //where clause oppstatus__c condition added on 17 June by Sravan
        
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([SELECT Id, CurrencyIsoCode, Expected_Bookings__c,Project_Name__c,
                                                                        Ship_to_Account_Name_ML__c,PrimaryQuote__c,OppStatus__c
                                                                        FROM Opportunity where Id in :opportunityIds]);        
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>(); 
        Map<Id,Opportunity> opportunitiesToUpdateMap = new Map<Id,Opportunity>();//IBA-4179 Sourav
        list<Update_Opportunity_From_Quote__c> oqList = new list<Update_Opportunity_From_Quote__c>(); //IBA-3398
        list<id> oqOpp = new list<id>(); //IBA-3398
        for(Quote q : quoteList) {
            boolean wasPrimaryQuote = ((Quote) oldItems.get(q.Id)).Primary_Quote__c; 
            Boolean isOppBooked = false;
            Opportunity oppToUpdate = opportunityMap.get(q.OpportunityId);
            if(oppToUpdate.OppStatus__c == Label.Non_Comissionable_Booking || oppToUpdate.OppStatus__c == Label.Commissionable_Book_No_Service_PO ||
              oppToUpdate.OppStatus__c == Label.Non_Comm_Book_No_Service_PO || oppToUpdate.OppStatus__c == Label.Non_Comm_Book_No_Proj_Plan ||
             oppToUpdate.OppStatus__c == Label.Fully_Booked ) {
                isOppBooked = true;
            }
            Quote oldQuoteValues = oldItems.get(q.Id);
            Boolean addToList = false;
            //IBA-3398 start
            Boolean addToList2 = false;
            
            Update_Opportunity_From_Quote__c oq = new Update_Opportunity_From_Quote__c();
            Boolean isTrue = checkOrderDetails(oldQuoteValues,q,isInsert) ;
            if(isTrue) {
                oq.Project_Name__c = 'blank';
                addToList2 = true;
            }
            Boolean isTrue1 = checkShipToAccount(oldQuoteValues,q,isInsert);
            if(isTrue1) {
                oq.Ship_to_Account_Name_ML__c = q.Ship_to_Account__c;
                addToList2 = true;
            }
            //IBA-3398 end
            String updatePrimaryQuote = checkIsPrimary(oldQuoteValues,q,isInsert); //IBA-3929 - Sourav
            if(updatePrimaryQuote == 'primarytrue') { //IBA-3929 - Sourav
                oppToUpdate.PrimaryQuote__c = q.id;
                //IBA-4179 - Sourav Start
                if(opportunitiesToUpdateMap.get(q.OpportunityId) != null){
                    Opportunity currOpp = opportunitiesToUpdateMap.get(q.OpportunityId);
                    currOpp.PrimaryQuote__c = q.id;
                    opportunitiesToUpdateMap.put(q.OpportunityId,currOpp);
                }
                else{
                    opportunitiesToUpdateMap.put(q.OpportunityId,oppToUpdate);
                }
                //IBA-4179 - Sourav End
            }
            else if(updatePrimaryQuote == 'primaryfalse'){ //IBA-3929 - Sourav
                oppToUpdate.PrimaryQuote__c = null;
        //IBA-4179 - Sourav Start
                if(opportunitiesToUpdateMap.get(q.OpportunityId) != null){
                    Opportunity currOpp = opportunitiesToUpdateMap.get(q.OpportunityId);
                    currOpp.PrimaryQuote__c = null;
                    opportunitiesToUpdateMap.put(q.OpportunityId,currOpp);
                }
                else{
                    opportunitiesToUpdateMap.put(q.OpportunityId,oppToUpdate);
                }
                //IBA-4179 - Sourav End
            }
            else if(updatePrimaryQuote == 'primaryfalse'){ //IBA-3929 - Sourav
                oppToUpdate.PrimaryQuote__c = null;
                addToList = true;
            }
            //Case 1 : A Quote is the Primary Quote; update the Opportunity Expected Booking field
            if (q.Primary_Quote__c && opportunityMap.get(q.OpportunityId) != null && isOppBooked == true && isInsert == false) {
                oppToUpdate.Expected_Bookings__c = q.SAP_Expected_Bookings__c;
        //IBA-4179 - Sourav Start
                if(opportunitiesToUpdateMap.get(q.OpportunityId) != null){
                    Opportunity currOpp = opportunitiesToUpdateMap.get(q.OpportunityId);
                    currOpp.Expected_Bookings__c = q.SAP_Expected_Bookings__c;
                    opportunitiesToUpdateMap.put(q.OpportunityId,currOpp);
                }
                else{
                    opportunitiesToUpdateMap.put(q.OpportunityId,oppToUpdate);
                }
                //IBA-4179 - Sourav End

            }
            
            //Case 2 : A Quote *was* the Primary Quote but no longer; set the Opportunity Expected Booking field to zero
            if (q.Primary_Quote__c == false &&  wasPrimaryQuote && opportunityMap.get(q.OpportunityId) != null && isOppBooked == true && isInsert == false) {
                oppToUpdate.Expected_Bookings__c = 0;
        //IBA-4179 - Sourav Start
                if(opportunitiesToUpdateMap.get(q.OpportunityId) != null){
                    Opportunity currOpp = opportunitiesToUpdateMap.get(q.OpportunityId);
                    currOpp.Expected_Bookings__c = 0;
                    opportunitiesToUpdateMap.put(q.OpportunityId,currOpp);
                }
                else{
                    opportunitiesToUpdateMap.put(q.OpportunityId,oppToUpdate);
                }
                //IBA-4179 - Sourav End
            }
            
            //IBA-3929 - Sourav - Start        
            if(q.LastModifiedDate != null && (us.Profile.Name != 'System Administrator' && us.Profile.Name != 'Business Administrator' && us.Profile.Name != 'API Only') 
               && isInsert == false) {            
                   oppToUpdate.Quote_Last_Modified_Date__c = q.LastModifiedDate.date();
           //IBA-4179 - Sourav Start
                    if(opportunitiesToUpdateMap.get(q.OpportunityId) != null){
                        Opportunity currOpp = opportunitiesToUpdateMap.get(q.OpportunityId);
                        currOpp.Quote_Last_Modified_Date__c = q.LastModifiedDate.date();
                        opportunitiesToUpdateMap.put(q.OpportunityId,currOpp);
                    }
                    else{
                        opportunitiesToUpdateMap.put(q.OpportunityId,oppToUpdate);
                    }
                    //IBA-4179 - Sourav End
            }
            if(isInsert && (oppToUpdate.CurrencyIsoCode != q.CurrencyIsoCode)){
                oppToUpdate.CurrencyIsoCode = q.CurrencyIsoCode;
        //IBA-4179 - Sourav Start
                if(opportunitiesToUpdateMap.get(q.OpportunityId) != null){
                    Opportunity currOpp = opportunitiesToUpdateMap.get(q.OpportunityId);
                    currOpp.CurrencyIsoCode = q.CurrencyIsoCode;
                    opportunitiesToUpdateMap.put(q.OpportunityId,currOpp);
                }
                else{
                    opportunitiesToUpdateMap.put(q.OpportunityId,oppToUpdate);
                }
                //IBA-4179 - Sourav End
            }
            //IBA-3929 - Sourav - End
            // removed for IBA-4179 Sourav
            if(addToList2) { //IBA-3398
                oq.Opportunity__c = q.OpportunityId;
                oqOpp.add(q.OpportunityId);
                oqList.add(oq);
            }
        }                
        OpportunityTriggerHandler.triggerdisabled = true; //IBA-3398
        if (opportunitiesToUpdateMap.values().size() > 0) {//IBA-4179 Sourav
            update opportunitiesToUpdateMap.values();
        }
        if (oqList.size() > 0) { //IBA-3398
            list<Update_Opportunity_From_Quote__c> oldOq = [select id,Ship_to_Account_Name_ML__c,Opportunity__c from Update_Opportunity_From_Quote__c where Opportunity__c =: oqOpp];
            if(oldOq.size()>0){
                map<string,Update_Opportunity_From_Quote__c> mapOq = new map<string,Update_Opportunity_From_Quote__c>();
                for(Update_Opportunity_From_Quote__c oq:oldOq){
                    mapOq.put(oq.Opportunity__c,oq);
                }
                for(Update_Opportunity_From_Quote__c oq:oqList){
                    if(mapOq.containsKey(oq.Opportunity__c)){
                        Update_Opportunity_From_Quote__c oldrec = mapOq.get(oq.Opportunity__c);
                        if((oldrec.Ship_to_Account_Name_ML__c != null || oldrec.Ship_to_Account_Name_ML__c != '') && (oq.Ship_to_Account_Name_ML__c == null || oq.Ship_to_Account_Name_ML__c == '')){
                            oq.Ship_to_Account_Name_ML__c = oldrec.Ship_to_Account_Name_ML__c;
                        }
                    }
                    
                }
            
                delete oldOq;
            }
            insert oqList;
        }
    }



    public static Boolean checkOrderDetails(Quote oldQuoteValues, Quote newQuoteValues,Boolean isInsert) {
        if((newQuoteValues.SAP_Sales_Order_Number__c != Null && oldQuoteValues.SAP_Sales_Order_Number__c  != newQuoteValues.SAP_Sales_Order_Number__c) || 
            (newQuoteValues.ECC_Sales_Order_Number__c != Null && oldQuoteValues.ECC_Sales_Order_Number__c  != newQuoteValues.ECC_Sales_Order_Number__c)) {
            return true;
        }
        if(isInsert && (newQuoteValues.SAP_Sales_Order_Number__c != Null || newQuoteValues.ECC_Sales_Order_Number__c != Null)) {
            return true;
        }
        return false;
    }
    public static Boolean checkShipToAccount(Quote oldQuoteValues, Quote newQuoteValues,Boolean isInsert) {
        if(newQuoteValues.Primary_Quote__c == true && newQuoteValues.Ship_to_Account__c != Null && oldQuoteValues.Ship_to_Account__c  != newQuoteValues.Ship_to_Account__c) {
            return true;
        }
        if(isInsert && newQuoteValues.Ship_to_Account__c != Null && newQuoteValues.Primary_Quote__c == true) {
            return true;
        }
        if(newQuoteValues.Primary_Quote__c == true && oldQuoteValues.Primary_Quote__c  != newQuoteValues.Primary_Quote__c) {
            return true;
        }
        return false;
    }
    public static String checkIsPrimary(Quote oldQuoteValues, Quote newQuoteValues,Boolean isInsert) {//IBA-3929 - Sourav
        
        if(newQuoteValues.Primary_Quote__c == true && oldQuoteValues.Primary_Quote__c  != newQuoteValues.Primary_Quote__c && newQuoteValues.IsSyncing == false) {
            return 'primarytrue';
        }
        if(isInsert && newQuoteValues.Primary_Quote__c == true && newQuoteValues.IsSyncing == false) {
            return 'primarytrue'; 
        }
        if(newQuoteValues.Primary_Quote__c == false && oldQuoteValues.Primary_Quote__c  != newQuoteValues.Primary_Quote__c && newQuoteValues.IsSyncing == false) {
            return 'primaryfalse';
        }
        return 'noPrimaryCheckUpdate';
    }
    //Added IBA-3307 END
   //Remove for IBA-4189
}