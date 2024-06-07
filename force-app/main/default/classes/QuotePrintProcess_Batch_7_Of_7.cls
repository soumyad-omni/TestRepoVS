global class QuotePrintProcess_Batch_7_Of_7 implements Database.Batchable<SObject>{
    Private Id qId;
    private Boolean isGenericDrawer = false;
    private Boolean zerodollar = false;//Added zero dollar for SF-BUG-725
    public QuotePrintProcess_Batch_7_Of_7(Id quoteid){
        qId = quoteid;
    }
     public QuotePrintProcess_Batch_7_of_7(Id quoteid, Boolean paramIsGenericDrawer){
        qId = quoteid;
         this.isGenericDrawer = paramIsGenericDrawer;
    }
    //below constructor added by sravan for SF-BUG-725
    public QuotePrintProcess_Batch_7_of_7(Id quoteid, Boolean paramIsGenericDrawer,Boolean zerodollar){
        qId = quoteid;
        this.isGenericDrawer = paramIsGenericDrawer;
        this.zerodollar = zerodollar;
    }
    global Database.queryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('Select id, Name from Quote where id =:qId');
    }
    
    global void execute (Database.BatchableContext BC, List<Quote> Quote){
        List<Quote_Line__c> qli = [select id,Conga_Unit_Services__c,Conga_Extended_Services__c,Conga_Quantity_Update__c,
        conga_extended_price_materials__c,Quote__c,total_monthly_product_by_location__c,Conga_Summary_Unit_Price__c,
        Conga_Summary_Contract_List_Price__c,Conga_Summary_Extended_Price__c,Conga_Summary_By_Par_Extd_Services__c,Material_Type__c,
        USA_List_Price__c,Contract_List_Price__c,Part_of_a_Bundle__c,Resend_to_SAP__c,Conga_part_of_bundle_true__c,conga_solution_includes__c,
        Conga_part_of_bundle_check__c,conga_product_description__c,List_Price__c,Extended_Price__c,Conga_Unit_Services_Material_Type__c,
        Extended_Services__c,Conga_USA_Price_List__c,Cong_Extended_Price_Material_type__c,sap_line_number__c,conga_higher_level_item__c,
        Higher_Level_Item__c,Conga_Product__c,Conga_Product1__c,conga_grouped_product__c,quantity__c,Product_Code__c,Pricing_Reference_Model__r.Name,
        Conga_Quantity__c,par_location__c,Conga_Total_Support_Services_by_Location__c,customer_price__c,Conga_Total_Product_by_Location__c , Product__r.Name, 
        Conga_Renewal_Extended_Services__c, Conga_Renewal_Unit_Services__c,conga_Renewal_grouped_product__c
        from Quote_Line__c 
        where Quote__c =:qId and conga_product__c != null and Line_Status__c != :Label.Conga_Quote_Line_Status 
        and (Product__r.name like '%RENEWAL%')  FOR UPDATE];
       
        //insert new account();
          system.debug('Executig the Quote Line total and services method');
        try{
          calculateTotalProductandServices(Quote[0]); 
        }catch(Exception e){
            //return e.getMessage();
        }
                  
        setRenewalData(qli);
        try{
            QuoteLineTriggerHandler.fromprint = true;
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
        System.debug('job Status : '+a.status);
        if(a.Status == 'Completed' && a.NumberOfErrors == 0 && a.ExtendedStatus == null){
            //Added below zerodollar logic for SF-BUG-725
            if(zerodollar){
                QuotePrintProcess_Batch_8_Of_8 b = new QuotePrintProcess_Batch_8_Of_8 (qId, isGenericDrawer);
                database.executeBatch(b);
            }
            else{
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

        }
        else{
            List<Quote_Print_Status__c> qpsList = [select quote__c,print_status__c from Quote_Print_Status__c where quote__c=:qId];
            if(qpsList.size()>0){
                qpsList[0].print_status__c = 'FAILED';
                update qpsList[0];
            }
        }
    }
    
    
    public void setRenewalData(List<Quote_Line__c> qList)
    {
        if(qList==null || qList.isEmpty()) {
           return;
        }
        //Id qid = qList[0].Quote__c;
        Boolean setZeroServiceAmount = false;
        List<Quote> quoteList = [Select Id, Free_Month_Service__c, Service_Duration__c from quote where id =: qId];
        if(quoteList !=null || !quoteList.isEmpty()) 
        {
          if(quoteList[0].Free_Month_Service__c != null && quoteList[0].Service_Duration__c != null 
               && quoteList[0].Free_Month_Service__c == quoteList[0].Service_Duration__c)
               {
                   setZeroServiceAmount = true;        
               }  
         }
        
        Set<Integer> higherLineItemSet = new Set<Integer>();
        //Commented by sravan on 14 AUG as we are not using this anywhere
     /*   AggregateResult[] quantity8 = [Select Sum(quantity__c) qty, product__c, Pricing_Reference_Model__r.Name prdc1, sum(Extended_Services__c)cusmt,
                                           Sum(Cong_Extended_Price_Material_type__c)epst,sum(Contract_List_Price__c) lst,Sum(Customer_Price__c) cst,
                                           Sum(Total_Customer_Price__c) tcpcqty,Sum(Extended_Price__c) extp,Sum(Extended_Services__c) exts,
                                           Sum(USA_List_Price__c) usa  
                                      From Quote_Line__c 
                                      Where Quote__c =:qId and product__r.Name = 'RENEWAL' and Line_Status__c != :Label.Conga_Quote_Line_Status 
                                      Group By product__c, Pricing_Reference_Model__r.Name]; */  
                                   
      // groupRenewalItemsQuantity(quantity8, qList);
       for(Quote_Line__c q : qList){
              q.Conga_Renewal_Extended_Services__c = 0;
              q.Conga_Renewal_Unit_Services__c = 0;
        }
     
       AggregateResult[] quantity1 = [select conga_higher_level_item__c hli,sum(Quantity__c) qty,sum(Extended_Services__c)cusmt,
                                             Sum(List_price__c) lp, 
                                             Sum(Cong_Extended_Price_Material_type__c)epst,sum(Contract_List_Price__c) lst,
                                             Sum(Customer_Price__c) cst,Sum(Extended_Price__c) extp,Sum(Extended_Services__c) exts,
                                             sum(USA_List_Price__c) usa , Product__r.Name prd
                                      from Quote_Line__c 
                                      where Quote__c =:qId and Line_Status__c != :Label.Conga_Quote_Line_Status
                                      and ((Product__r.name like '%SV') OR (Product__r.name like '%SV1'))
                                      and (NOT Product__r.name like '%LEASE BUYOUT%')
                                      and (NOT Product__r.name like '%RENEWAL%') and conga_higher_level_item__c != null
                                      group by conga_higher_level_item__c,Product__r.Name];
         Integer sapnum = 0;                             
         Set<String> srvCodeList = new Set<String>();
                                                 
        for(Integer i=0;i<quantity1.size();i++){
            sapnum = Integer.valueof(quantity1[i].get('hli'));          
            for(Quote_Line__c q : qList){
               if(q.Product__r.name != 'RENEWAL'){continue;}                
               if(q.sap_line_number__c == sapnum)
               {  if(Integer.valueof(quantity1[i].get('cst')) != null &&
                    !srvCodeList.Contains(q.Pricing_Reference_Model__r.Name + String.valueof(quantity1[i].get('prd')))){
                    q.Conga_Renewal_Unit_Services__c = Double.valueof(quantity1[i].get('cst')) + q.Conga_Renewal_Unit_Services__c ;
                    srvCodeList.add(q.Pricing_Reference_Model__r.Name + String.valueof(quantity1[i].get('prd'))); }
                  q.Conga_Renewal_Extended_Services__c = Double.valueof(quantity1[i].get('cst')) * Integer.valueof(quantity1[i].get('qty')) + q.Conga_Renewal_Extended_Services__c ;
                }
            }
        }
        
        
         for(Quote_Line__c q : qList){
               
               for(Quote_Line__c q1 : qList)
               {
                  if(q.Pricing_Reference_Model__r.Name == q1.Pricing_Reference_Model__r.Name && q.id != q1.id                   
                       && q.conga_Renewal_grouped_product__c == true)
                  {
                    q.Conga_Renewal_Extended_Services__c =q.Conga_Renewal_Extended_Services__c+ q1.Conga_Renewal_Extended_Services__c;
                    q.Conga_Renewal_Unit_Services__c =q.Conga_Renewal_Unit_Services__c+ q1.Conga_Renewal_Unit_Services__c;
                  
                  }
               
               }
               if(q.Conga_Quantity__c != null && q.conga_Renewal_grouped_product__c == true)
               {
                 q.Conga_Extended_Services__c = q.Conga_Renewal_Extended_Services__c;
                 q.Conga_Unit_Services__c = q.Conga_Renewal_Unit_Services__c * q.Conga_Quantity__c;                 
               }
             
                                
          }
          
          if(setZeroServiceAmount)
          {
             for(Quote_Line__c q : qList){
                  q.Conga_Renewal_Extended_Services__c = 0;
                  q.Conga_Renewal_Unit_Services__c = 0;
                  q.Conga_Extended_Services__c = 0;
                  q.Conga_Unit_Services__c = 0;              
             }

          }
          
    }
    
    private void calculateTotalProductandServices(Quote q)
    {
    system.debug('In the calculateTotalProductandServices method');
    
    if(q == null ) {
           return;
        }
        Id qid = q.id;
        
        system.debug('qid is'+qid);
        
        Decimal materials, service;
        
        list<Quote> Quotelist = [ select id,QT_Conga_Total_Extended_Products__c ,QT_Conga_Total_Extended_Services__c  from Quote where id =:qid];
        
        AggregateResult[] quantity9= [Select SUM(QT_CONGA_EXTENDED_PRICE_MATERIALS__c)epm, SUM(QT_Conga_Extended_Services__c)eps
                                        FROM Quote_Line__c WHERE Quote__c =:qid and 
                                        (Customer_Price__c > 0 OR Usa_List_price__c > 0 OR Conga_Extended_Services__c >0 OR Conga_Renewal_Extended_Services__c > 0 OR Product__r.DW_Product_Class__c = 'Training' OR (Contract_List_Price__c > 0 and (customer_price__c = 0 OR customer_price__c = null))) and 
                                        (Conga_Grouped_Product__c=true OR Conga_Renewal_Grouped_Product__c=true or ( Is_Lease_Buyout__c = true and conga_quantity__c > 0 ) or Product__r.DW_Product_Class__c = 'Training' ) and
                                        Conga_Product1__c != null and (NOT Conga_Product1__c like 'Fr%') and (NOT Conga_Product1__c like '%SV')];

       if(quantity9 != null && quantity9.size() > 0)
        {
            system.debug('epm QT_CONGA_EXTENDED_PRICE_MATERIALS__c' + (Decimal)(quantity9[0].get('epm')));
            Quotelist[0].QT_Conga_Total_Extended_Products__c = (Decimal)(quantity9[0].get('epm'));
            system.debug('eps QT_Conga_Extended_Services__c' + (Decimal)(quantity9[0].get('eps')));
            Quotelist[0].QT_Conga_Total_Extended_Services__c = (Decimal)(quantity9[0].get('eps'));
        } 
        update Quotelist;
        
     
    }

}