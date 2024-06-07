/*********************************************************************
Jira Number: IBA-4546
Name:      UpdateRFPforOpportunities
Test Class:   UpdateRFPforOpportunitiesTest
Purpose:   This class contains the logic to update the Records of 'Request for Proposal' Object after processing the trigger events of opportunity object.
=======================================================================
-----------------------------------------------------------------------
Developer                  Date                Description
-------------------------------------------------------------- --------
Saptarsha Panthi        10/08/2023            Initial Creation
************************************************************************/
public class UpdateRFPforOpportunities {
    public void RFPupdateafteroppsinsert(Set<Id>rfpidstage, List<Opportunity> oppListToAdd){
        List<Request_for_Proposal__c> rfptoupdatelist = new List<Request_for_Proposal__c>();
        List<Request_for_Proposal__c> rfpslist = [Select Id, Deal_Value__c, Result__c From Request_for_Proposal__c Where Id= :rfpidstage];
        Map<Id,Request_for_Proposal__c> rfpmap = new Map<Id,Request_for_Proposal__c>(rfpslist);
        for(Opportunity o: oppListToAdd){
            if(o.Request_for_Proposal_Id__c!=null)
            {
                if(o.StageName=='6 Closed Won' && rfpmap.get(o.Request_for_Proposal_Id__c).Result__c!='Won'){
                    rfpmap.get(o.Request_for_Proposal_Id__c).Result__c='Won';
                    rfptoupdatelist.add(rfpmap.get(o.Request_for_Proposal_Id__c));
                }
                if(o.StageName=='7 Closed Lost' && rfpmap.get(o.Request_for_Proposal_Id__c).Result__c!='Won' && rfpmap.get(o.Request_for_Proposal_Id__c).Result__c!='Lost'){
                    rfpmap.get(o.Request_for_Proposal_Id__c).Result__c='Lost';
                    rfptoupdatelist.add(rfpmap.get(o.Request_for_Proposal_Id__c));
                }
            }
        }
        if(rfptoupdatelist.size()>0){
            RequestforProposal_TriggerHandler.isUpdatefromOpps=True;
            update rfptoupdatelist;
        }
    }
       
    
    public void RFPupdateafteroppsdelete(Set<Id> rfpidstage, Set<Id> rfpidexpectedbook, List<Opportunity> oppList){
        Map<Id, Integer> countopportunitywon = new Map<Id, Integer>();
        Map<Id, Integer> countopportunitylost = new Map<Id, Integer>();
        Map<Id, Decimal> newrfpdealvaluemap = new Map<Id, Decimal>();
        Double dealvalue=0;
        Map<Id, String> newrfpresultmap = new Map<Id, String>();
        Set<Id>OppidsPLtoremove = new Set<Id>();
        Set<Id> rfpidtoadd = new Set<Id>();
        rfpidtoadd.addAll(rfpidexpectedbook);
        rfpidtoadd.addAll(rfpidstage);
        List<Request_for_Proposal__c> rfptoupdate = new List<Request_for_Proposal__c>();
        If(rfpidtoadd.size()>0){
            List<Request_for_Proposal__c> rfpslist = [Select Id, Deal_Value__c, Result__c From Request_for_Proposal__c Where Id= :rfpidtoadd];
            Map<Id,Request_for_Proposal__c> rfpmap = new Map<Id,Request_for_Proposal__c>(rfpslist);
            List<Opportunity> opplistforrfp = [Select Id, Expected_Bookings__c, StageName, Request_for_Proposal_Id__c From Opportunity Where Request_for_Proposal_Id__c= :rfpidtoadd];
            for(Opportunity opp: opplistforrfp){
                if(opp.StageName=='6 Closed Won' && countopportunitywon.get(opp.Request_for_Proposal_Id__c)!=null){
                    countopportunitywon.put(opp.Request_for_Proposal_Id__c, countopportunitywon.get(opp.Request_for_Proposal_Id__c)+1);
                }
                else{
                    countopportunitywon.put(opp.Request_for_Proposal_Id__c, 1);  
                }
                if(opp.StageName=='7 Closed Lost' && countopportunitylost.get(opp.Request_for_Proposal_Id__c)!=null){
                    countopportunitylost.put(opp.Request_for_Proposal_Id__c, countopportunitylost.get(opp.Request_for_Proposal_Id__c)+1);
                }
                else{
                    countopportunitylost.put(opp.Request_for_Proposal_Id__c, 1);  
                }  
            }
            for(Opportunity op: opplist){
                
                if(rfpidstage.contains(op.Request_for_Proposal_Id__c)){
                    if(countopportunitywon.get(op.Request_for_Proposal_Id__c) < 1 && countopportunitylost.get(op.Request_for_Proposal_Id__c)>=1){
                        newrfpresultmap.put(op.Request_for_Proposal_Id__c,'Lost');
                    }  
                }
                if(rfpidexpectedbook.contains(op.Request_for_Proposal_Id__c)){
                    if(newrfpdealvaluemap.get(op.Request_for_Proposal_Id__c)==null){
                        dealvalue = rfpmap.get(op.Request_for_Proposal_Id__c).Deal_Value__c - op.Expected_Bookings__c;
                        newrfpdealvaluemap.put(op.Request_for_Proposal_Id__c,dealvalue);
                    }
                    else{
                        dealvalue = newrfpdealvaluemap.get(op.Request_for_Proposal_Id__c) - op.Expected_Bookings__c;
                        newrfpdealvaluemap.put(op.Request_for_Proposal_Id__c,dealvalue);
                    }
                }
            }
            for(Request_for_Proposal__c rfp : rfpslist){
                if(newrfpresultmap.get(rfp.Id)!=null){
                    rfp.Result__c=newrfpresultmap.get(rfp.Id);
                    rfptoupdate.add(rfp);
                }
                if(newrfpdealvaluemap.get(rfp.Id)!=null)
                {
                    rfp.Deal_Value__c=newrfpdealvaluemap.get(rfp.Id);
                    rfptoupdate.add(rfp);
                }
            }
            if(rfptoupdate.size()>0){
                RequestforProposal_TriggerHandler.isUpdatefromOpps=True;
                update rfptoupdate;
            }
        }
    }

    public void RFPupdateafteroppsupdate(Set <Id> oldrfpid, Set <Id> newrfpid, Set <Id> rfpidexpectedbook, Set <Id> rfpidstage, Set <Id>oppidsPLtoadd, List<Opportunity> newValues, Map<Id, Opportunity> oldMap, Map<Id, Id> newopprfpmap){
        Set<Id> allrfpchangedids = new Set<Id>();
        allrfpchangedids.addall(oldrfpid);
        System.debug(oldrfpid);
        allrfpchangedids.addall(newrfpid);
        System.debug(newrfpid);
        allrfpchangedids.addall(rfpidexpectedbook);
        System.debug(rfpidexpectedbook);
        allrfpchangedids.addall(rfpidstage);
        System.debug(rfpidstage);
        System.debug(allrfpchangedids.size());
        System.debug(allrfpchangedids);
        Double dealvalue = 0;
            List<Request_for_Proposal__c> rfptoupdatelist = new List<Request_for_Proposal__c>();
            Map<Id,Integer> countopportunitywon = new Map<Id,Integer>();
            Map<Id,Integer> countopportunitylost = new Map<Id,Integer>();
            List<Opportunity> opplistforrfp = [Select Id, Expected_Bookings__c, StageName, Request_for_Proposal_Id__c From Opportunity Where Request_for_Proposal_Id__c= :allrfpchangedids];
            System.debug(opplistforrfp);
            for(Opportunity opp: opplistforrfp){
                if(opp.StageName=='6 Closed Won' && countopportunitywon.get(opp.Request_for_Proposal_Id__c)!=null){
                    countopportunitywon.put(opp.Request_for_Proposal_Id__c, countopportunitywon.get(opp.Request_for_Proposal_Id__c)+1);
                }
                else{
                    countopportunitywon.put(opp.Request_for_Proposal_Id__c, 1);  
                }
                if(opp.StageName=='7 Closed Lost' && countopportunitylost.get(opp.Request_for_Proposal_Id__c)!=null){
                    countopportunitylost.put(opp.Request_for_Proposal_Id__c, countopportunitylost.get(opp.Request_for_Proposal_Id__c)+1);
                }
                else{
                    countopportunitylost.put(opp.Request_for_Proposal_Id__c, 1);  
                }  
            }
            List<Request_for_Proposal__c> rfpslist = [Select Id, Deal_Value__c, Result__c From Request_for_Proposal__c Where Id= :allrfpchangedids];
            Map<Id, Request_for_Proposal__c> RFPmap = new Map<Id, Request_for_Proposal__c>(rfpslist);
        System.debug('RFPMap:'+RFpmap);
            for(Opportunity op: newValues){
                if(rfpidstage.contains(op.Request_for_Proposal_Id__c)){
                if(op.StageName=='6 Closed Won' && RFPmap.get(op.Request_for_Proposal_Id__c).Result__c!='Won'){
                    RFPmap.get(op.Request_for_Proposal_Id__c).Result__c='Won';
                    rfptoupdatelist.add(RFPmap.get(op.Request_for_Proposal_Id__c));
                }
                  if(op.StageName=='7 Closed Lost' && countopportunitywon.get(op.Request_for_Proposal_Id__c)>1 && RFPmap.get(op.Request_for_Proposal_Id__c).Result__c!='Lost'){
                    RFPmap.get(op.Request_for_Proposal_Id__c).Result__c='Won';
                    rfptoupdatelist.add(RFPmap.get(op.Request_for_Proposal_Id__c));  
                }
                }
                 if(rfpidexpectedbook.contains(op.Request_for_Proposal_Id__c)){
                     Double dbsubstract= 0;
                     Double dbadd=0;
                     if( oldmap.get(op.Id).Expected_Bookings__c!=null){
                        dbsubstract=oldmap.get(op.Id).Expected_Bookings__c; 
                     }
                     if( op.Expected_Bookings__c!=null){
                        dbadd=op.Expected_Bookings__c; 
                     }
                   RFPmap.get(op.Request_for_Proposal_Id__c).Deal_Value__c = RFPmap.get(op.Request_for_Proposal_Id__c).Deal_Value__c - dbsubstract + dbadd;
                     rfptoupdatelist.add(RFPmap.get(op.Request_for_Proposal_Id__c));
                 }
                if(oldmap.get(op.Id).Request_for_Proposal_Id__c!=null && oldrfpid.contains(oldmap.get(op.Id).Request_for_Proposal_Id__c)){
                    if(oldmap.get(op.Id).StageName=='6 Closed Won' && RFPmap.get(oldmap.get(op.Id).Request_for_Proposal_Id__c).Result__c=='Won'){
                        if(countopportunitywon.get(oldmap.get(op.Id).Request_for_Proposal_Id__c)<=1 && countopportunitywon.get(oldmap.get(op.Id).Request_for_Proposal_Id__c)>=1){
                          RFPmap.get(oldmap.get(op.Id).Request_for_Proposal_Id__c).Result__c='Lost';
                           rfptoupdatelist.add(RFPmap.get(oldmap.get(op.Id).Request_for_Proposal_Id__c));
                        }
                    }
                    if(oldmap.get(op.Id).Expected_Bookings__c!=Null && RFPmap.get(oldmap.get(op.Id).Request_for_Proposal_Id__c).Deal_Value__c!=Null){
                        RFPmap.get(oldmap.get(op.Id).Request_for_Proposal_Id__c).Deal_Value__c = RFPmap.get(oldmap.get(op.Id).Request_for_Proposal_Id__c).Deal_Value__c - oldmap.get(op.Id).Expected_Bookings__c;
                        rfptoupdatelist.add(RFPmap.get(oldmap.get(op.Id).Request_for_Proposal_Id__c));
                    }
                }
                if(op.Request_for_Proposal_Id__c!=null && newrfpid.contains(op.Request_for_Proposal_Id__c)){
                    if(op.StageName=='7 Closed Lost' && RFPmap.get(op.Request_for_Proposal_Id__c).Result__c!='Won' && RFPmap.get(op.Request_for_Proposal_Id__c).Result__c!='Lost'){
                        RFPmap.get(op.Request_for_Proposal_Id__c).Result__c='Lost';
                        rfptoupdatelist.add(RFPmap.get(op.Request_for_Proposal_Id__c));
                    }
                    if(op.StageName=='6 Closed Won' && RFPmap.get(op.Request_for_Proposal_Id__c).Result__c!='Won'){
                        RFPmap.get(op.Request_for_Proposal_Id__c).Result__c='Won';
                        rfptoupdatelist.add(RFPmap.get(op.Request_for_Proposal_Id__c));
                    }
                    if(op.Expected_Bookings__c!=Null && RFPmap.get(op.Request_for_Proposal_Id__c).Deal_Value__c!=Null){
                      RFPmap.get(op.Request_for_Proposal_Id__c).Deal_Value__c = RFPmap.get(op.Request_for_Proposal_Id__c).Deal_Value__c + op.Expected_Bookings__c;
                    rfptoupdatelist.add(RFPmap.get(op.Request_for_Proposal_Id__c));  
                    }
                } 
            }
        System.debug(rfptoupdatelist);
            if(rfptoupdatelist.size()>0){
                Set<Request_for_Proposal__c> rfpremovedulipcate = new Set<Request_for_Proposal__c>();
                rfpremovedulipcate.addall(rfptoupdatelist);
                List <Request_for_Proposal__c> rfptoupdatelistwithoutdulpicates = new List<Request_for_Proposal__c>();
                rfptoupdatelistwithoutdulpicates.addAll(rfpremovedulipcate);
                RequestforProposal_TriggerHandler.isUpdatefromOpps=True;
                update rfptoupdatelistwithoutdulpicates;
            }
        if(oppidsPLtoadd.size()>0){
            List<Product_Line__c> prlinestoupdate = new List<Product_Line__c>();
            List<Product_Line__c> prdlines = [Select Id, Request_for_Proposal__c, Opportunity__c From Product_Line__c Where Opportunity__c=:oppidsPLtoadd];
            for(Product_Line__c pl: prdlines){
                pl.Request_for_Proposal__c = newopprfpmap.get(pl.Opportunity__c);
                prlinestoupdate.add(pl); 
            }
            ProductLineTriggerHandler.TriggerDisabled=True;
            update  prlinestoupdate; 
        }
    }
}