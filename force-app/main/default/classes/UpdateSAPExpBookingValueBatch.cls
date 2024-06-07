public class UpdateSAPExpBookingValueBatch implements Database.Batchable<SObject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String quoteStatus = 'E0017';
        String userID = '0051N000007IZZHQA4';
        String userName = 'Rajat Jain';
        String num = '1';
    	//return Database.getQueryLocator('Select id,Quote__c,Rebate_Buyout_Adjustment__c,SAP_Line_Expected_Booking__c,Material_Type__c,Product_Code__c,Line_Expected_Booking__c from Quote_Line__c where Quote__r.status !=:quoteStatus AND SAP_Line_Item_GUID__c != NULL');
    	//return Database.getQueryLocator('SELECT id,Line_Status__c, quote__c, rebate_buyout_adjustment__c, sap_line_expected_booking__c, material_type__c, product_code__c, line_expected_booking__c FROM quote_line__c WHERE quote__r.status != :quoteStatus AND sap_line_item_guid__c != NULL AND ( lastmodifiedbyid = :userID OR lastmodifiedby.NAME = :userName ) AND lastmodifieddate > yesterday');
    	//return Database.getQueryLocator('SELECT id,Line_Status__c, quote__c, rebate_buyout_adjustment__c, sap_line_expected_booking__c, material_type__c, product_code__c, line_expected_booking__c FROM quote_line__c WHERE quote__r.status != :quoteStatus AND sap_line_item_guid__c != NULL AND quote__r.Data_Load_Only__c = :num');
    	return Database.getQueryLocator('SELECT id,Line_Status__c, quote__c, rebate_buyout_adjustment__c, sap_line_expected_booking__c, material_type__c, product_code__c, line_expected_booking__c FROM quote_line__c WHERE quote__r.status != :quoteStatus AND sap_line_item_guid__c != NULL AND ( quote__r.lastmodifiedbyid = :userID OR quote__r.lastmodifiedby.NAME = :userName  ) AND quote__r.lastmodifieddate > yesterday');
    	
    }
    
    public void execute(Database.BatchableContext bc, List<Quote_Line__C> ql) {
        System.debug('rj....' +ql);
        calculateLineExpectedBookingValue(ql);
    }
    
    public void calculateLineExpectedBookingValue(List<Quote_Line__c> qlList){ 
        Set<Id> qtIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id,Id> OppMapping = new Map<Id,Id>();
        List<Quote_Line__C> linesToupdate = new List<Quote_Line__C>();
        for(Quote_Line__c ql:qlList){
            qtIds.add(ql.Quote__c);
        }
        Map<Id,Quote> QtRecords = new Map<Id,Quote>([Select id,Order_Type__c,OpportunityId from Quote where id in :qtIds]);
        for(Quote q: QtRecords.values()){
            oppIds.add(q.OpportunityId);
            OppMapping.put(q.id,q.OpportunityId);
        } 
        Map<Id,Opportunity> oppRecords = new Map<Id,Opportunity>([Select id,Opportunity__c from Opportunity where id in : oppIds]);
        for(Quote_Line__C ql: qlList) {
            if(ql.Line_Status__c == 'E0006') {
                ql.Line_Expected_Booking__c = 0;
                linesToupdate.add(ql);
            }else {
                Id oppId = OppMapping.get(ql.Quote__c);
                Opportunity oppRecord = oppRecords.get(oppId);
                System.debug('oppRecord.....' +oppRecord);
                Quote q = QtRecords.get(ql.Quote__c);
                Decimal rebate;
                if(ql.Rebate_Buyout_Adjustment__c != Null) {
                    if(ql.Rebate_Buyout_Adjustment__c < 0) {
                        rebate = ql.Rebate_Buyout_Adjustment__c * (-1);
                    }else {
                        rebate = ql.Rebate_Buyout_Adjustment__c;
                    }    
                }else {
                    rebate = 0;
                }
                //if(ql.Higher_Level_Item__c == 0) {
                if(ql.Product_Code__c == 'LEASE BUYOUT') {
                    ql.Line_Expected_Booking__c = 0;
                }
                if(ql.Material_Type__c == 'PRODUCT' && q.Order_Type__c != 'ZQRS' && ql.Product_Code__c != 'LEASE BUYOUT') {
                    if(ql.SAP_Line_Expected_Booking__c != Null && rebate != Null) {
                        ql.Line_Expected_Booking__c = ql.SAP_Line_Expected_Booking__c - rebate ;
                    }
                }
                if((ql.Material_Type__c == 'PRODUCT' || ql.Material_Type__c == 'SERVICE') && q.Order_Type__c == 'ZQRS' && ql.Product_Code__c != 'LEASE BUYOUT') {
                    if(ql.SAP_Line_Expected_Booking__c != Null && rebate != Null) {
                        ql.Line_Expected_Booking__c = ql.SAP_Line_Expected_Booking__c - rebate ;
                    }
                }
                if(oppRecord.Opportunity__c == 'Change Order - Credit' && ql.Line_Expected_Booking__c != Null && ql.Line_Expected_Booking__c != 0) {
                    ql.Line_Expected_Booking__c = ql.Line_Expected_Booking__c * (-1);
                }
                if(ql.Line_Expected_Booking__c != Null) {
                    linesToupdate.add(ql);
                }
                //}   
            }
        }
        try {
            System.debug('rj..' +qlList.size());
            Database.update(linesToupdate);
            //update linesToupdate;
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
    }
    
    public void finish(Database.BatchableContext bc) {
        
    } 
}