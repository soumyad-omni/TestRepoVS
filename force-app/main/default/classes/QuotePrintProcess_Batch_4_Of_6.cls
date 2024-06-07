global class QuotePrintProcess_Batch_4_Of_6 implements Database.Batchable<SObject>{
    Private Id qId;
    private Boolean isGenericDrawer = false;
    
    public QuotePrintProcess_Batch_4_Of_6(Id quoteid){
        qId = quoteid;
    }
    public QuotePrintProcess_Batch_4_Of_6(Id quoteid,Boolean paramIsGenericDrawer){
        qId = quoteid;
        this.isGenericDrawer = paramIsGenericDrawer;
    }
    
    global Database.queryLocator start(Database.BatchableContext bc){
        String name = 'Checking this night again for big quote';
        System.debug('qId from batch : '+qId);
        return Database.getQueryLocator('Select id, Name from Quote where id =:qId');
    }
    
    global void execute (Database.BatchableContext BC, List<Quote> Quote){
        System.debug('Line 13 : '+System.now());
        Id qId = quote[0].id;
        System.debug('qId from batch : '+qId);
        List<Quote_Line__c> qli = [select id,Conga_Unit_Services__c,From_Quote_Print__c,conga_extended_price_materials__c,Quote__c,total_monthly_product_by_location__c,Conga_Summary_Unit_Price__c,
                                    Conga_Summary_Contract_List_Price__c,Conga_Summary_Extended_Price__c,Conga_Summary_By_Par_Extd_Services__c,Material_Type__c,
                                    USA_List_Price__c,Contract_List_Price__c,Part_of_a_Bundle__c,Resend_to_SAP__c,Conga_part_of_bundle_true__c,
                                    conga_solution_includes__c,Conga_part_of_bundle_check__c,conga_product_description__c,List_Price__c,Extended_Price__c,
                                    Conga_Unit_Services_Material_Type__c,Extended_Services__c,Conga_USA_Price_List__c,Cong_Extended_Price_Material_type__c,
                                    sap_line_number__c,conga_higher_level_item__c,Higher_Level_Item__c,Conga_Product__c,Conga_Product1__c,
                                    conga_grouped_product__c,quantity__c,Product_Code__c,Pricing_Reference_Model__r.Name,Conga_Quantity__c,par_location__c,
                                    Conga_Total_Support_Services_by_Location__c,customer_price__c,Conga_Total_Product_by_Location__c,Product__r.name 
                                  From Quote_Line__c where Quote__c =:qId and customer_price__c != 0 and customer_price__c != null and Line_Status__c != :Label.Conga_Quote_Line_Status FOR UPDATE];
        System.debug('Line 25 : '+System.now());
        AggregateResult[] quantity5 = [select conga_higher_level_item__c hli,sum(conga_unit_price__c) cupc,sum(conga_list_price1__c) clp1c,sum(Conga_Total_Product_by_Par_Monthly__c)ctpbym,sum(Extended_Services__c)cusmt,Sum(Cong_Extended_Price_Material_type__c)epst,sum(Contract_List_Price__c) lst, Sum(Customer_Price__c) cst,Sum(Extended_Price__c) extp,Sum(Total_Customer_Price__c) tcpcqty,Sum(Extended_Services__c) exts,sum(USA_List_Price__c) usa from Quote_Line__c 
                                      where Quote__c =:qId  and (NOT Conga_Product1__c like '%SV') and customer_price__c != 0 and customer_price__c != null and Line_Status__c != :Label.Conga_Quote_Line_Status
                                      and (NOT Product__r.name like '%LEASE BUYOUT%')
                                      and (NOT Product__r.name like '%RENEWAL%')
                                      group by conga_higher_level_item__c];
        System.debug('Line 31 : '+System.now());
       Map<Decimal,Quote_Line__c> linemap= new Map<Decimal,Quote_Line__c>();
        for(Quote_Line__c q : qli){
            //Integer sapnum = (Integer)q.SAP_Line_Number__c;
            linemap.put(q.SAP_Line_Number__c,q);
        } 
        System.debug('Line 37 : '+System.now());
                List<Quote_Line__c> qliupdate = new List<Quote_Line__c>();
       for(Integer i=0;i<quantity5.size();i++){  
            //Boolean groupedcheck = false;
            Integer sapnum = Integer.valueof(quantity5[i].get('hli'));
            String prddesc = '';            
           // System.debug('prddesc : '+prddesc);
            //for(Quote_Line__c q : qli){    
                //q.conga_grouped_product__c = false;
              //  if(q.sap_line_number__c == sapnum){
              if(sapnum != null){
              Quote_Line__c q = linemap.get(sapnum);
                  System.debug('q linemap : '+q);
                Decimal cupc = (Decimal)quantity5[i].get('cupc');
                Decimal clp1c = (Decimal)quantity5[i].get('clp1c');
                    if((Decimal)quantity5[i].get('clp1c')!=NULL)
                        q.Conga_Summary_Contract_List_Price__c=(Decimal)quantity5[i].get('clp1c');
                    /*if((Decimal)quantity5[i].get('ctpbym')!=NULL)
                        q.Conga_Summary_Extended_Price__c=(Decimal)quantity5[i].get('ctpbym');
                    if((Decimal)quantity5[i].get('cupc')!=NULL)
                        q.Conga_Summary_Unit_Price__c=(Decimal)quantity5[i].get('cupc');
                    system.debug(cupc);
                    system.debug(clp1c);*/
             //   }
           // }
           qliupdate.add(q);
              }
    }
        System.debug('Line 64 : '+System.now());
     QuoteLineTriggerHandler.fromprint = true;
        update qliupdate;
    }
    global void finish(Database.BatchableContext BC){
    
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :bc.getJobId()];
        System.debug('job Status : '+a.status);
        if(a.Status == 'Completed' && a.NumberOfErrors == 0 && a.ExtendedStatus == null){        
            QuotePrintProcess_Batch_5_Of_6 b = new QuotePrintProcess_Batch_5_Of_6(qId, isGenericDrawer);
            database.executeBatch(b);
        }
        else{
            List<Quote_Print_Status__c> qpsList = [select quote__c,print_status__c from Quote_Print_Status__c where quote__c=:qId];
            if(qpsList.size()>0){
                qpsList[0].print_status__c = 'FAILED';
                update qpsList[0];
            }
        }
        
        
        //QuotePrintProcess_Batch_5_Of_6 b = new QuotePrintProcess_Batch_5_Of_6(qId);
        //database.executeBatch(b);
    }
}