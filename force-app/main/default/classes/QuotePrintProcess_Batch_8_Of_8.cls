/**
 * @File Name          : QuotePrintProcess_Batch_8_Of_8.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 09-02-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    13/4/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
global class QuotePrintProcess_Batch_8_Of_8 implements Database.Batchable<SObject>{
    Private Id qId;
    private Boolean isGenericDrawer = false;    
    public QuotePrintProcess_Batch_8_Of_8(Id quoteid){
        qId = quoteid;
    } 
    public QuotePrintProcess_Batch_8_Of_8(Id quoteid, Boolean paramIsGenericDrawer ){
        qId = quoteid;
        this.isGenericDrawer = paramIsGenericDrawer;
    }
    
    global Database.queryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('Select id, Name from Quote where id =:qId');
    }
    
    global void execute (Database.BatchableContext BC, List<Quote> Quote){
        
        List<Quote_Line__c> qli = [select id,Conga_Unit_Services__c,Conga_Extended_Services__c,Conga_Quantity_Update__c,Conga_zero_dollar_byPar__c,
        conga_extended_price_materials__c,Quote__c,total_monthly_product_by_location__c,Conga_Summary_Unit_Price__c,
        Conga_Summary_Contract_List_Price__c,Conga_Summary_Extended_Price__c,Conga_Summary_By_Par_Extd_Services__c,Material_Type__c,
        USA_List_Price__c,Contract_List_Price__c,Part_of_a_Bundle__c,Resend_to_SAP__c,Conga_part_of_bundle_true__c,conga_solution_includes__c,
        Conga_part_of_bundle_check__c,conga_product_description__c,List_Price__c,Extended_Price__c,Conga_Unit_Services_Material_Type__c,
        Extended_Services__c,Conga_USA_Price_List__c,Cong_Extended_Price_Material_type__c,sap_line_number__c,conga_higher_level_item__c,
        Higher_Level_Item__c,Conga_Product__c,Conga_Product1__c,conga_grouped_product__c,quantity__c,Product_Code__c,Pricing_Reference_Model__r.Name,
        Conga_Quantity__c,par_location__c,Conga_Total_Support_Services_by_Location__c,customer_price__c,Conga_Total_Product_by_Location__c , Product__r.Name, 
        Conga_Renewal_Extended_Services__c, Conga_Renewal_Unit_Services__c,conga_Renewal_grouped_product__c,Conga_Zero_Dollar__C from Quote_Line__c 
        where Quote__c =:qId and conga_product__c != null and Line_Status__c != :Label.Conga_Quote_Line_Status 
        and conga_Renewal_grouped_product__c = false and conga_grouped_product__c = false
        //and Pricing_Reference_Model__c = null soumyad commented out sf-bug-806
        and (CONGA1_USA_LIST_PRICE__c = null OR CONGA1_USA_LIST_PRICE__C = 0 OR customer_price__c = 0 OR customer_price__c = null)
        and (CONGA_LIST_PRICE1__c = null OR CONGA_LIST_PRICE1__C = 0 OR customer_price__c = 0 OR customer_price__c = null) FOR UPDATE];
        
        setZeroDollarData(qli);
        try{
            QuoteLineTriggerHandler.fromprint = true;
            QuoteLineTriggerHandler.TriggerDisabled = true;//IBA-2305 Prithan
            system.debug('***************qli'+qli);
            update qli;
            //return 'updated';
        }catch(Exception e){
            //return e.getMessage();
        }
    }
    global void finish(Database.BatchableContext BC){
        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :bc.getJobId()];        
        
        if(a.Status == 'Completed' && a.NumberOfErrors == 0 && a.ExtendedStatus == null){    
           if(isGenericDrawer)
           {
              QuotePrintProcess_Batch_9_Of_9 b = new QuotePrintProcess_Batch_9_Of_9 (qId, isGenericDrawer);
              database.executeBatch(b);
           }
           else
           {
                List<Quote_Print_Status__c> qpsList = [select quote__c,print_status__c from Quote_Print_Status__c where quote__c=:qId];
                if(qpsList.size()>0){
                    qpsList[0].print_status__c = 'FINISHED';
                    update qpsList[0];
                }
                else{
                    Quote_Print_Status__c qps = new Quote_Print_Status__c();
                    qps.quote__c = qId;
                    qps.print_status__c = 'FINISHED';
                    insert qps;
                }
                FromPrint__c setting;
                Id profileId = userinfo.getProfileId();
                setting = FromPrint__c.getInstance(profileId);
                if (setting.fromprint__c == true) {
                    setting.fromprint__c = false;
                    upsert setting;
                }
           }    
            
        }
        else{
            List<Quote_Print_Status__c> qpsList = [select quote__c,print_status__c from Quote_Print_Status__c where quote__c=:qId];
            if(qpsList.size()>0){
                qpsList[0].print_status__c = 'FAILED';
                update qpsList[0];
            }
        }
        
    }
    
    
    public void setZeroDollarData(List<Quote_Line__c> qList)
    {
        if(qList==null || qList.isEmpty()) {
           return;
        }
        Id qid = qList[0].Quote__c;
        Set<Integer> higherLineItemSet = new Set<Integer>();
        List<Quote_Line__c> quotesgrouped = [select id,conga_product__c from quote_line__c where quote__c=:qid and conga_grouped_product__c = true and Conga_Extended_Price_Materials__c = 0];
        List<String> prdcts = new List<String>();
        for(Quote_Line__c ql : quotesgrouped){
            prdcts.add(ql.conga_product__c);
        }
        //sf-bug-806 soumyad start
        /*AggregateResult[] aggregateQty = [Select Sum(quantity__c) qty, product__c prd,  Product__r.Name prdName
                                      From Quote_Line__c 
                                      Where Quote__c =:qId and Line_Status__c != :Label.Conga_Quote_Line_Status 
                                        and conga_Renewal_grouped_product__c = false and conga_grouped_product__c = false
                                        and Pricing_Reference_Model__c = null
                                        and (CONGA1_USA_LIST_PRICE__c = null OR CONGA1_USA_LIST_PRICE__C = 0)
                                        and (CONGA_LIST_PRICE1__c = null OR CONGA_LIST_PRICE1__C = 0) 
                                       Group By product__c, Product__r.Name ]; */  
          AggregateResult[] aggregateQty = [Select Sum(quantity__c) qty, product__c prd,  Product__r.Name prdName
                                      From Quote_Line__c 
                                      Where Quote__c =:qId and Line_Status__c != :Label.Conga_Quote_Line_Status 
                                        and conga_Renewal_grouped_product__c = false and conga_grouped_product__c = false                                        
                                        and (((CONGA1_USA_LIST_PRICE__c = null OR CONGA1_USA_LIST_PRICE__C = 0) 
                                        and (CONGA_LIST_PRICE1__c = null OR CONGA_LIST_PRICE1__C = 0))
                                        or Discount_Percent__c < 0 or Discount_Amount__c < 0) // soumyad IBA-1145
                                       Group By product__c, Product__r.Name ]; 
        //sf-bug-806 soumyad end
          Map<String, Decimal> productMap = new Map<String, Decimal>();
          for(Integer i=0;i<aggregateQty.size();i++){
              productMap.put((String)aggregateQty[i].get('prdName'),(Decimal)aggregateQty[i].get('qty'));
          }  
          
          Set<String> productSet= new Set<String>();
          for(Quote_Line__c q : qlist){
        	  	q.Conga_zero_dollar_byPar__c= true; //IBA-2305 Prithan
             if(!productSet.contains(q.Product__r.Name))
             {
                productSet.add(q.Product__r.Name);
                q.conga_quantity__c = productMap.get(q.Product__r.Name);
                if(!prdcts.contains(q.Conga_Product__c))
                	q.Conga_Zero_Dollar__c = true;
             }
          
          }
                
    }

}