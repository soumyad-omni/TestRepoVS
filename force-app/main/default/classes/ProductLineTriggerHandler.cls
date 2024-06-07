/**********************************************************************
Name:  ProductLineTriggerHandler
Copyright © 2018
======================================================
======================================================
Purpose: Handler contains method for ProductLineTrigger Events
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1          Supriya Ambre           10/17/2018        INITIAL DEVELOPMENT
0.2          Haripriya Maturi        10/31/2018        Implemented logic to update Expected Bookings on Opportunity
***********************************************************************/
public class ProductLineTriggerHandler implements ITriggerHandler{
    // Allows unit test (or other code) to disable this trigger for the transaction
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    public boolean isFromQuote = False;
    public static boolean isFromOppUpdate = false;
    public static boolean isFromOppcurrupdate = false;////Added by Sravan on 27 AUG for SF-BUG-566
    public static boolean isFromprodlineclass = false; //Added by sravan on 4 DEC for delete product line error
    // Check to see if the trigger has been disabled by either custom setting or code
    public boolean IsDisabled(){
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('ProductLineTriggerDisabled');
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
        //Added by sravan for sf-bug-566 start
        List<Product_Line__c> prodlineList=newItems;
        Map<Id,String> oppMap = new Map<Id,String>();
        //IBA-3630
        User currentUser = [select id,name,profile.name from User where id =: userInfo.getUserId() ];
        Map<String,PL_Cant_DelCreate_Profiles__c> plCantDCProfiles=PL_Cant_DelCreate_Profiles__c.getAll();
        //IBA-3602 start
    list<id> oppidList = new list<id>();
        for(Product_Line__c p : prodlineList){
            if(p.Opportunity__c != null && p.Quote__c == null){
                oppidList.add(p.Opportunity__c);
            }
        }
        //IBA-4546 Start
        Map<Id, Id> rfpoppmap = new Map<Id, Id>();
        List<Opportunity> opplist = [Select Id, Name, Request_for_Proposal_Id__c From Opportunity Where Id= :oppidList And Request_for_Proposal_Id__c!=Null];
        if(opplist.size()>0){
        for(Opportunity opp: opplist){
            rfpoppmap.put(opp.Id, opp.Request_for_Proposal_Id__c);
        }
        }
        //IBA-4546 End
        map<id,opportunity> optyMap = new map<id,opportunity>([select id, Opportunity__c from opportunity where id =: oppidList]);
        //IBA-3602 end
        for(Product_Line__c p : prodlineList){
            //IBA-3602 start
            if(p.Opportunity__c != null && p.Quote__c == null){
                if(optyMap.containskey(p.Opportunity__c)){
                    opportunity opp = optyMap.get(p.Opportunity__c);
                    if(opp.Opportunity__c == 'Change Order - Credit' && p.Amount__c > 0){
                        p.Amount__c = p.Amount__c * (-1);
                    }else if(opp.Opportunity__c != 'Change Order - Credit' && p.Amount__c < 0){
                        p.Amount__c = p.Amount__c * (-1);
                    }
                    
                }
                //IBA-4546 Start
                if(!rfpoppmap.isEmpty()){
                   if(rfpoppmap.get(p.Opportunity__c)!=Null)
                       p.Request_for_Proposal__c = rfpoppmap.get(p.Opportunity__c);
                }
                //IBA-4546 End
            }
            //IBA-3602 end
            p.CurrencyIsoCode = p.opp_currency__c;
            if((p.opp_status__c == 'Fully Booked' || p.opp_status__c == 'Non Comissionable Booking'
                || p.opp_status__c == 'Commissionable - No Service PO'
                ||p.opp_status__c== 'Non Comm. Book - No Service PO'
          // IBA-4182   || p.opp_status__c == 'Non Comm. Book - No Proj. Plan'
                ||p.opp_status__c=='Booked with No PO'
                ||p.opp_status__c=='Booked with No Service PO'
                ||p.opp_status__c=='Booked with No Product PO' //IBA-4182 Ends
               ) &&(plCantDCProfiles.containsKey(currentUser.profile.name))) {
                   
                   p.adderror('Sales user cannot create product lines on booked opportunities');
               }
        }
        //Added by sravan for sf-nug-566 end
    }
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
        // Added by Sravan for SF-BUG-744 START
        // User u = [select profile.Name from User where profileid =: UserInfo.getProfileId() limit 1];
        User currentUser = [select id,name,profile.name from User where id =: userInfo.getUserId() ];
        Conga_Print_Output__c sys = [select profile_Name__c from Conga_Print_Output__c where name = 'System Admin'];
        String sysadmin = sys.Profile_Name__c;
        Conga_Print_Output__c bus = [select profile_Name__c from Conga_Print_Output__c where name = 'Business Admin'];
        String busadmin = bus.Profile_Name__c;
        List<Product_Line__c> prdlinesold = oldItems.values();
        //IBA-3630
        Map<String,PL_Cant_DelCreate_Profiles__c> plCantDCProfiles=PL_Cant_DelCreate_Profiles__c.getAll();
        if(plCantDCProfiles.containsKey(currentUser.profile.name)){
            isFromprodlineclass = false;
        }//END IBA-3630
        
        for(Product_Line__c p: prdlinesold){
            if(p.Quote__c != null){
                if(currentUser.profile.name != sysadmin && currentUser.profile.name != busadmin && isFromprodlineclass == false && isFromOppUpdate== false)
                    p.adderror('Product Lines with Quote Should be Deleted by System and Business Admin only');
            }
        }
        // Added by Sravan for SF-BUG-744 END
    }
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        //Added logic in before update for SF-BUG-744 by SRAVAN on 05 DEC START
        User u = [select profile.Name from User where profileid =: UserInfo.getProfileId() limit 1];
        Conga_Print_Output__c sys = [select profile_Name__c from Conga_Print_Output__c where name = 'System Admin'];
        String sysadmin = sys.Profile_Name__c;
        Conga_Print_Output__c bus = [select profile_Name__c from Conga_Print_Output__c where name = 'Business Admin'];
        String busadmin = bus.Profile_Name__c;
        List<Product_Line__c> prdlinesold = oldItems.values();
        List<Product_Line__c> prdlines = newItems.values();
        List<Id> optyids = new List<Id>();
        list<id> oppidList = new list<id>();//IBA-3602
        Map<Id, Product_Line__c> oldMap = new Map<Id, Product_Line__c>(prdlinesold);//IBA-3602
        //Map<Id,List<OpportunityTeamMember>> opteam = new Map<Id,List<OpportunityTeamMember>>();
        for(Product_Line__c p : prdLines){
            if(p.Opportunity__c != null)
                optyids.add(p.Opportunity__c);
            //IBA-3602 start
            if(p.Opportunity__c != null && p.Quote__c == null){
                Product_Line__c pl = oldMap.get(p.id);
                if(pl.Amount__c != p.Amount__c)
                oppidList.add(p.Opportunity__c);
            }
            //IBA-3602 end
        }
        map<id,opportunity> optyMap = new map<id,opportunity>([select id, Opportunity__c from opportunity where id =: oppidList]);//IBA-3602
        Map<Id,String> oppmap = new Map<Id,String>();
        for(Opportunity o : [select id,OppStatus__c from opportunity where id=:optyids]){
            oppmap.put(o.id,o.OppStatus__c);
        }
        for(Product_Line__c p : prdLines){
            //IBA-3602 start
            if(p.Opportunity__c != null && p.Quote__c == null){
                if(optyMap.containskey(p.Opportunity__c)){
                    opportunity opp = optyMap.get(p.Opportunity__c);
                    if(opp.Opportunity__c == 'Change Order - Credit' && p.Amount__c > 0){
                        p.Amount__c = p.Amount__c * (-1);
                    }else if(opp.Opportunity__c != 'Change Order - Credit' && p.Amount__c < 0){
                        p.Amount__c = p.Amount__c * (-1);
                    }
                    
                }
            }
            //IBA-3602 end
        if(oppmap.get(p.opportunity__c) == 'Fully Booked'){
                if(u.profile.name != sysadmin && u.profile.name != busadmin && isFromprodlineclass == false && isFromOppUpdate== false){//Added isFromprodlineclass and isFromOppUpdate on 17 DEC by SRAVAN.
                    p.adderror('product lines cannot be edited when opportunity is booked');
                }
            }
        }
    }
    //=============================================================================
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){
        List<Product_Line__c> pl = oldItems.values();
        //Bug-355
        List<Id> optyIdList = new List<Id>();
        Set<Id> OppIdset = new Set<Id>();
        for(Product_Line__c p : pl){
            OppIdSet.add(p.Opportunity__c);
            /*if(p.Quote__r.Id != null){
isFromQuote = true;
}*/
            if(p.Quote__c != null){
                isFromQuote = true;
            }
            if(p.Product_Line_Picklist2__c=='Performance Center' && !optyIdList.contains(p.Opportunity__c)){        
                optyIdList.add(p.Opportunity__c);       
            }
        }
        if(!isFromQuote && !isFromOppUpdate){//Expected Booking must be updated on Opp only for Forecasting product lines, not from quote
            updateExpectedBookingOnOppty(OppIdSet);
        }
    }
    //=============================================================================
    // AFTER UNDELETE
    //=============================================================================
    public void afterUndelete(Map<Id, SObject> oldItems){
        List<Product_Line__c> pl = oldItems.values();
        Set<Id> OppIdSet = new Set<Id>();
        for(Product_Line__c p : pl){
            OppIdSet.add(p.Opportunity__c);
            if(p.Quote__c != null){
                isFromQuote = true;
            }
        }
        if(!isFromQuote){//Expected Booking must be updated on Opp only for Forecasting product lines
            updateExpectedBookingOnOppty(OppIdSet);
        }
    }
    //=============================================================================
    // AFTER INSERT
    //=============================================================================
    public void afterInsert(Map<Id, SObject> newItems){
        List<Product_Line__c> pl = newItems.values();
        Set<Id> OppIdSet = new Set<Id>();
        Set<Id> advSvcOpptySet=new Set<Id>(); //IBA-2035 Pabitra                                              
        for(Product_Line__c p : pl){
            //IBA-2035 Pabitra
            if(p.Portfolio_Segment__c=='IVX Workflow'||p.Portfolio_Segment__c=='IV Compounding Service'||p.Portfolio_Segment__c=='Inventory Optimization Service and Platform'|| //IBA-4331
               p.Portfolio_Segment__c=='IV Legacy' ||p.Portfolio_Segment__c=='IV Legacy'||p.Portfolio_Segment__c=='Services' || //IBA-4331
               p.Portfolio_Segment__c=='Central Pharmacy Dispensing Service'){
                   advSvcOpptySet.add(p.Opportunity__c); 
               }//IBA-2035 Pabitra
            
            OppIdSet.add(p.Opportunity__c);
            if(p.Quote__c != null){
                isFromQuote = true;
            }
        }
        //IBA-2035 Pabitra 
        List<Opportunity> opprToUpdate=new List<Opportunity>();
        List<Opportunity> opprList=[SELECT Id,OpportunityGroup__c,RecordTypeId,OppStatus__c,StageName FROM Opportunity where Id IN:advSvcOpptySet];  
        for(Opportunity oppr:opprList){
            //if((oppr.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('U.S & Canada Opportunity').getRecordTypeId())  //IBA-4641
            if((oppr.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('NAA_Opportunity').getRecordTypeId() || oppr.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('US_Canada_Advanced_Services').getRecordTypeId() || oppr.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('US_Canada_Specialty').getRecordTypeId())	//IBA-5992
                 && oppr.OppStatus__c !='Fully Booked' && oppr.StageName!='6 Closed Won' ){ 
                   oppr.OpportunityGroup__c='Advanced Services'; 
                   opprToUpdate.add(oppr);   
               }
        }
        if(opprToUpdate!=null&&!opprToUpdate.isEmpty()) {                                              
            OpportunityTriggerHandler.TriggerDisabled = true;
            update opprToUpdate; 
        }
        //end IBA-2035 Pabitra                                               
        if(!isFromQuote){//Expected Booking must be updated on Opp only for Forecasting product lines
            updateExpectedBookingOnOppty(OppIdSet);
        }
        //Sahid Hussain IBA-1374 -starts
        Map<Id, AggregateResult> oppId2AggResultMap = new Map<Id, AggregateResult>();
        for(AggregateResult ag: [Select sum(Number_of_Units__c) val_NOU, Opportunity__c oppId from Product_line__c where Opportunity__c IN :OppIdSet Group By Opportunity__c]){
            if(!oppId2AggResultMap.containsKey((Id)ag.get('oppId'))){
                oppId2AggResultMap.put((Id)ag.get('oppId'), ag);
            }
        }
        
        List<Opportunity> opList2Update = new List<Opportunity>();
        List<Opportunity> opList = [Select Number_of_Units__c from Opportunity where Id IN :OppIdSet];
        if(opList != null && opList.size() > 0){
            for(Opportunity op: opList){
                if(op.Number_of_Units__c != oppId2AggResultMap.get(op.Id).get('val_NOU')){
                    op.Number_of_Units__c = (Decimal)oppId2AggResultMap.get(op.Id).get('val_NOU');
                    opList2Update.add(op);
                }
            }
        }
        if(opList2Update.size() > 0){
            OpportunityTriggerHandler.TriggerDisabled = true;
            update opList2Update;
            OpportunityTriggerHandler.TriggerDisabled = false;
        }
    }
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        if(!isFromOppcurrupdate){////Added by Sravan on 27 AUG for SF-BUG-566
            List<Product_Line__c> pl = newItems.values();
            Set<Id> OppIdSet = new Set<Id>();
            Set<Id> advSvcOpptySet=new Set<Id>(); //IBA-2035 Pabitra 
            for(Product_Line__c p : pl){
                //IBA-2035 Pabitra
                if(p.Portfolio_Segment__c=='IVX Workflow'||p.Portfolio_Segment__c=='IV Compounding Service'||p.Portfolio_Segment__c=='Inventory Optimization Service and Platform'|| //IBA-4331
                   p.Portfolio_Segment__c=='IV Legacy' ||p.Portfolio_Segment__c=='IV Legacy'||p.Portfolio_Segment__c=='Services' || //IBA-4331
                   p.Portfolio_Segment__c=='Central Pharmacy Dispensing Service'){
                       advSvcOpptySet.add(p.Opportunity__c); 
                   }//IBA-2035 Pabitra
                OppIdSet.add(p.Opportunity__c);
                if(p.Quote__c != null){
                    isFromQuote = true;
                }
            }
            
            //IBA-2035 Pabitra 
            List<Opportunity> opprToUpdate=new List<Opportunity>();
            List<Opportunity> opprList=[SELECT Id,OpportunityGroup__c,RecordTypeId,OppStatus__c,StageName FROM Opportunity where Id IN:advSvcOpptySet];  
            for(Opportunity oppr:opprList){
                //if((oppr.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('U.S & Canada Opportunity').getRecordTypeId())  //IBA-4641
                if((oppr.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('NAA_Opportunity').getRecordTypeId() || oppr.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('US_Canada_Advanced_Services').getRecordTypeId() || oppr.RecordTypeId ==Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('US_Canada_Specialty').getRecordTypeId())	//IBA-5992
                     && oppr.OppStatus__c !='Fully Booked' && oppr.StageName!='6 Closed Won' ){ 
                       oppr.OpportunityGroup__c='Advanced Services'; 
                       opprToUpdate.add(oppr);   
                   }
            }
            if(opprToUpdate!=null&&!opprToUpdate.isEmpty()) {                                              
                OpportunityTriggerHandler.TriggerDisabled = true;
                update opprToUpdate; 
            }
            //end IBA-2035 Pabitra
            for(Product_Line__c p: (List<Product_Line__c>)oldItems.values()){
                OppIdSet.add(p.Opportunity__c);
            }
            //Sahid Hussain IBA-1374 -starts
            Map<Id, AggregateResult> oppId2AggResultMap = new Map<Id, AggregateResult>();
            for(AggregateResult ag: [Select sum(Number_of_Units__c) val_NOU, Opportunity__c oppId from Product_line__c where Opportunity__c IN :OppIdSet Group By Opportunity__c]){
                if(!oppId2AggResultMap.containsKey((Id)ag.get('oppId'))){
                    oppId2AggResultMap.put((Id)ag.get('oppId'), ag);
                }
            }
            
            List<Opportunity> opList2Update = new List<Opportunity>();
            List<Opportunity> opList = [Select Number_of_Units__c from Opportunity where Id IN :OppIdSet];
            if(opList != null && opList.size() > 0){
                for(Opportunity op: opList){
                    if(op.Number_of_Units__c != oppId2AggResultMap.get(op.Id).get('val_NOU')){
                        op.Number_of_Units__c = (Decimal)oppId2AggResultMap.get(op.Id).get('val_NOU');
                        opList2Update.add(op);
                    }
                }
            }
            
            //Update o;
            //Sahid Hussain IBA-1374 -ends
            if(!isFromQuote){//Expected Booking must be updated on Opp only for Forecasting product lines
                updateExpectedBookingOnOppty(OppIdSet);        
            }
            //Bug-355
            List<Id> optyIdList = new List<Id>();
            for(Product_Line__c plr:pl){
                Product_Line__c oldPl = (Product_Line__c)oldItems.get(plr.id);
                if(plr.Product_Line_Picklist2__c != oldPl.Product_Line_Picklist2__c && oldPl.Product_Line_Picklist2__c=='Performance Center' && !optyIdList.contains(plr.Opportunity__c))
                    optyIdList.add(plr.opportunity__c);
            }
            if(optyIdList.size()>0)
                setPerfOpty(optyIdList);
            if(opList2Update.size() > 0){
                OpportunityTriggerHandler.TriggerDisabled = true;
                update opList2Update;
                OpportunityTriggerHandler.TriggerDisabled = false;
            }
        }////Added by Sravan on 27 AUG for SF-BUG-566
    }
    public void updateExpectedBookingOnOppty(Set<Id> OppIdSet){
        List<Product_Line__c> pline = new List<Product_Line__c>();
        List<Opportunity> opp = new List<Opportunity>();
        Double expBook = 0;
        for(Opportunity o : [select Expected_Bookings__c,Opportunity__c from Opportunity where Id IN :OppIdSet]){
            for(Product_Line__c pl : [select Amount__c from Product_Line__c where Estimate__c=true and Opportunity__c = :o.Id]){// and isdelete__c = false Added isdelete = false for SF-BUG-744 by SRAVAN
                if(pl!=null && pl.Amount__c != null)
                    expBook += pl.Amount__c;
            }
            //Sf-BUG-787 fix
            if(o.Opportunity__c == 'Change Order - Credit') {
                Double expBook1 = math.abs(expBook);
                o.Expected_Bookings__c = expBook1;
            }else {
                o.Expected_Bookings__c = expBook;
            } 
            opp.add(o);
            expBook = 0; //reset this value else it carries forward to the next opportunity loop.
        }
        update opp;
    }
    
    /*product line update -bug- 355*/
    public void setPerfOpty(List<Id> idList){
        List<Opportunity> oppList = [SELECT Id,Performance_Center_Product_Line__c, (SELECT Id FROM Product_Families__r WHERE Product_line__c='Performance Center') FROM Opportunity WHERE Id IN: idList];
        List<Opportunity> oppUpdateList = new List<Opportunity>();
        for(Opportunity opp:oppList){
            if(opp.Product_Families__r.size()<=0) {
                if(!oppUpdateList.contains(opp)){
                    opp.Performance_Center_Product_Line__c = False;
                    
                    oppUpdateList.add(opp);
                }
                
            }
        }
        
        if(oppUpdateList.size()>0){
            update oppUpdateList;
        }
    }
}