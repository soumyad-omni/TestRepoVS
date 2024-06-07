global class QuotePrintProcess_Batch_6_Of_6 implements Database.Batchable<SObject>{
    Private Id qId;
    private Boolean isGenericDrawer = false;
    private Boolean isProductsUnbundled = false;
    private Boolean zerodollar = false;//Added zero dollar for sf-bug-725
    public QuotePrintProcess_Batch_6_Of_6(Id quoteid){
        qId = quoteid;
    } 
     public QuotePrintProcess_Batch_6_of_6(Id quoteid, Boolean paramIsGenericDrawer){
        qId = quoteid;
         this.isGenericDrawer = paramIsGenericDrawer;
    }
    public QuotePrintProcess_Batch_6_Of_6(Id quoteid, Boolean paramIsGenericDrawer,Boolean isProductsUnbundled){
        qId = quoteid;
        this.isGenericDrawer = paramIsGenericDrawer;
        this.isProductsUnbundled = isProductsUnbundled;
    }
    //below constructor added for SF-BUG-725 by sravan
    public QuotePrintProcess_Batch_6_Of_6(Id quoteid, Boolean paramIsGenericDrawer,Boolean isProductsUnbundled,boolean zerodollar){
        qId = quoteid;
        this.isGenericDrawer = paramIsGenericDrawer;
        this.isProductsUnbundled = isProductsUnbundled;
        this.zerodollar = zerodollar;
    }
    global Database.queryLocator start(Database.BatchableContext bc){
        String name = 'Checking this night again for big quote';
        System.debug('qId from batch : '+qId);
        return Database.getQueryLocator('Select id, Name from Quote where id =:qId');
    }
    
    global void execute (Database.BatchableContext BC, List<Quote> Quote){
        System.debug('Line 13 : '+System.now());
        //Added Conga_Extended_Service_Detbypar__c for SF-BUG-629 on 27 FEB by SRAVAN
        List<Quote_Line__c> qli = [select id,Conga_Extended_Service_Detbypar__c,Conga_Unit_Services__c,Conga_Extended_Services__c,Conga_Quantity_Update__c,conga_extended_price_materials__c,Quote__c,total_monthly_product_by_location__c,Conga_Summary_Unit_Price__c,Conga_Summary_Contract_List_Price__c,Conga_Summary_Extended_Price__c,Conga_Summary_By_Par_Extd_Services__c,Material_Type__c,USA_List_Price__c,Contract_List_Price__c,Part_of_a_Bundle__c,Resend_to_SAP__c,Conga_part_of_bundle_true__c,conga_solution_includes__c,Conga_part_of_bundle_check__c,conga_product_description__c,List_Price__c,Extended_Price__c,Conga_Unit_Services_Material_Type__c,Extended_Services__c,Conga_USA_Price_List__c,Cong_Extended_Price_Material_type__c,sap_line_number__c,conga_higher_level_item__c,Higher_Level_Item__c,Conga_Product__c,Conga_Product1__c,conga_grouped_product__c,quantity__c,Product_Code__c,Pricing_Reference_Model__r.Name,Conga_Quantity__c,par_location__c,Conga_Total_Support_Services_by_Location__c,customer_price__c,Conga_Total_Product_by_Location__c from Quote_Line__c where Quote__c =:qId and conga_product__c != null and Line_Status__c != :Label.Conga_Quote_Line_Status and (NOT Product__r.name like '%RENEWAL%') and (NOT Product__r.name like '%LEASE BUYOUT%')FOR UPDATE];
        /*//Adding as part of duplicate id fix - 12 NOV by SRAVAN START
        List<Quote_Line__c> qli = new List<Quote_Line__c>();
        for(Quote_line__c ql : qlist){
            qli.add(ql);
        }
        qli.sort();
        //Adding as part of duplicate id fix - 12 NOV by SRAVAN END*/
        System.debug('Line 15 : '+System.now());
        /*List<Quote_Line__c> qliserv = [select id,Conga_has_base__c,Conga_Base_Product__c,Conga_Extended_Services__c,Conga_Quantity_Update__c,conga_extended_price_materials__c,Quote__c,total_monthly_product_by_location__c,Conga_Summary_Unit_Price__c,Conga_Summary_Contract_List_Price__c,Conga_Summary_Extended_Price__c,Conga_Summary_By_Par_Extd_Services__c,Material_Type__c,USA_List_Price__c,Contract_List_Price__c,Part_of_a_Bundle__c,Resend_to_SAP__c,Conga_part_of_bundle_true__c,conga_solution_includes__c,Conga_part_of_bundle_check__c,conga_product_description__c,List_Price__c,Extended_Price__c,Conga_Unit_Services_Material_Type__c,Extended_Services__c,Conga_USA_Price_List__c,Cong_Extended_Price_Material_type__c,sap_line_number__c,conga_higher_level_item__c,Higher_Level_Item__c,Conga_Product__c,Conga_Product1__c,conga_grouped_product__c,quantity__c,Product_Code__c,Pricing_Reference_Model__r.Name,Conga_Quantity__c,par_location__c,Conga_Total_Support_Services_by_Location__c,customer_price__c,Conga_Total_Product_by_Location__c 
                                       from Quote_Line__c where Quote__c =:qId 
                                       //and part_of_a_bundle__c = TRUE 
                                       and Line_Status__c != :Label.Conga_Quote_Line_Status and (NOT Product__r.name like '%LEASE BUYOUT%') and (NOT Product__r.name like '%RENEWAL%') FOR UPDATE];
        System.debug('Line 18 : '+System.now());*/
        AggregateResult[] quantity8 = [select Conga_product__c prdcode,sum(conga_extended_price_materials__c) cepm,sum(Conga_Extended_Services__c) ces,sum(conga_unit_services__c) cus
                                       from Quote_Line__c 
                                       where Quote__c =:qId and conga_product__c != null and higher_level_item__c = 0 
                                       and Conga_part_of_bundle_true__c=true and (NOT Product__r.name like '%RENEWAL%')
                                       and Line_Status__c != :Label.Conga_Quote_Line_Status
                                       and (NOT Product__r.name like '%LEASE BUYOUT%')
                                       //and conga_quantity_update__c = true
                                       group by Conga_product__c];
        
        System.debug('size qli : '+quantity8.size());
       // List<Quote_line__c> qliprod = [select id,conga_product__c,higher_level_item__c,part_of_a_bundle__c from quote_line__c where quote__c=:qId and higher_level_item__c != 0 and part_of_a_bundle__c = true];
        //Added by Sravan for Quote Print Optimization START
        Map<String,List<Quote_Line__c>> linemapprod= new Map<String,List<Quote_Line__c>>();
        Map<Integer,Quote_Line__c> linemap= new Map<Integer,Quote_Line__c>();
        List<Quote_Line__c> linestoupdate = new List<Quote_Line__c>();
        Map<String,List<Quote_Line__c>> linemapq2 = new Map<String,List<Quote_Line__c>>();
        Map<Double,List<Quote_Line__c>> linemaphigh = new Map<Double,List<Quote_Line__c>>();
        for(Quote_Line__c q : qli){
            Integer sapnum = (Integer)q.sap_line_number__c;
            linemap.put(sapnum,q);
            if(linemapq2.containsKey(q.conga_product__c)){
                    List<Quote_Line__c> proList=linemapq2.get(q.conga_product__c);
                    proList.add(q);
                    linemapq2.put(q.conga_product__c, proList);
                }
                else{
                    linemapq2.put(q.conga_product__c, new List<Quote_Line__c>{q});
                }
            if(q.Higher_Level_Item__c != 0 && q.part_of_a_bundle__c == true){
                if(linemapprod.containsKey(q.conga_product__c)){
                    List<Quote_Line__c> proList=linemapprod.get(q.conga_product__c);
                    proList.add(q);
                    linemapprod.put(q.conga_product__c, proList);
                }
                else{
                    linemapprod.put(q.conga_product__c, new List<Quote_Line__c>{q});
                }
            }
            if(linemaphigh.containsKey(q.Higher_Level_Item__c)){
                    List<Quote_Line__c> proList=linemaphigh.get(q.Higher_Level_Item__c);
                    proList.add(q);
                    linemaphigh.put(q.Higher_Level_Item__c, proList);
                }
                else{
                    linemaphigh.put(q.Higher_Level_Item__c, new List<Quote_Line__c>{q});
                }
        }
        //Added by Sravan for Quote Print Optimization END
        //System.debug('Quantity : '+quantity8);
        System.debug('Line 28 : '+System.now());
        if(!isProductsUnbundled){
        for(Integer i=0;i<quantity8.size();i++){
            String prdc = String.valueof(quantity8[i].get('prdcode'));
            List<Quote_Line__c> qlList = linemapq2.get(prdc);
            if(qlList != null && !qlList.isempty()){
            for(Quote_Line__c q : qlList){
                System.debug('Conga Ex : '+q.conga_product__c+' : '+q.conga_extended_price_materials__c);
                if(q.Conga_Product__c.contains(prdc)){
                    q.Conga_Extended_Price_Materials__c = (Decimal)quantity8[i].get('cepm');
                    System.debug('After updating : '+(Decimal)quantity8[i].get('cepm'));
                    // q.Conga_Unit_Services__c = (Decimal)quantity8[i].get('cus');
                    // q.Conga_Extended_Services__c = (Decimal)quantity8[i].get('ces');
                    q.Conga_Quantity_Update__c = true;
                    q.From_Quote_Print__c = true;
                    linestoupdate.add(q);
                }
            }
            }
        }
        }
        System.debug('Line 45 : '+System.now());
        if(!isProductsUnbundled){
        for(Quote_Line__c q:qli){
            if(q.Conga_Solution_Includes__c == null && q.Conga_part_of_bundle_true__c == true)
                q.Conga_part_of_bundle_true__c = false;
            if(q.Higher_Level_Item__c == 0){
                q.Conga_Quantity_Update__c = true;
                q.From_Quote_Print__c = true;
                //List<Quote_Line__c> qlList = linemaphigh.get(q.SAP_Line_Number__c);
                //for(quote_line__c ql:qliserv){
                //if(!qlList.isempty()){
                if(linemaphigh.containskey(q.sap_line_number__c) && linemaphigh.get(q.SAP_Line_Number__c) != null){
                for(quote_line__c ql:linemaphigh.get(q.SAP_Line_Number__c)){
                    if(ql.Higher_Level_Item__c == q.SAP_Line_Number__c && ql.part_of_a_bundle__c == TRUE){
                        //Added Conga_Extended_Service_Detbypar__c for SF-BUG-629 on 27 FEB by SRAVAN START
                        if(ql.Conga_Extended_Service_Detbypar__c != null){
                            q.Conga_Extended_Service_Detbypar__c = q.Conga_Extended_Service_Detbypar__c+ql.Conga_Extended_Service_Detbypar__c;
                        }
                        //Added Conga_Extended_Service_Detbypar__c for SF-BUG-629 on 27 FEB by SRAVAN END
                        if(ql.Conga_Extended_Services__c != null){
                            System.debug('product : '+ql.Conga_Product1__c+ql.Extended_Services__c);
                            q.Conga_Extended_Services__c = q.Conga_Extended_Services__c+ql.Conga_Extended_Services__c;
                            q.Conga_Unit_Services__c = q.Conga_Extended_Services__c;
                            System.debug('product : '+ql.Conga_Product1__c+q.Conga_Extended_Services__c);
                        }
                    }
                    if(ql.Higher_Level_Item__c == q.SAP_Line_Number__c && ql.part_of_a_bundle__c == false && ql.Conga_Product1__c.contains('-SV') && ql.material_type__c == 'SERVICE'){
                        List<quote_line__c> qliprod = new List<quote_line__c>();
                        if(linemapprod.get(ql.Conga_Product__c) != null)
                        	qliprod = linemapprod.get(ql.Conga_Product__c);
                        if(!qliprod.isempty()){
                        for(quote_line__c qlip : qliprod){
                            if(qlip.conga_product__c == ql.Conga_Product__c){ //&& qlip.higher_level_item__c == ql.Higher_Level_Item__c){
                                Quote_line__c q1 = linemap.get((Integer)qlip.Higher_Level_Item__c);
                                Quote_line__c q2 = linemap.get((Integer)ql.Higher_Level_Item__c);
                                if(q1.Conga_Product1__c == q2.Conga_Product1__c)
                                if(ql.customer_price__c != null){
                                    q.Conga_Extended_Services__c = q.Conga_Extended_Services__c+ql.Customer_price__c;
                                    q.Conga_Unit_Services__c = q.Conga_Extended_Services__c;
                                }
                            }
                        }
                        }
                        
                    }
                    /*Following if block commented for sf-bug-473 */
                    /*if(ql.Higher_Level_Item__c == q.SAP_Line_Number__c && (ql.Pricing_Reference_Model__c == null && ql.Conga_Product1__c.contains('-SV') && ql.Conga_has_base__c == false)){
                        
                        if(ql.Customer_Price__c!=null){ 
                            q.Conga_Extended_Services__c = q.Conga_Extended_Services__c+ql.Customer_Price__c;
                            q.Conga_Unit_Services__c = q.Conga_Extended_Services__c;
                        }
                    }*/
                    /*Above if block commented for sf-bug-473 */
                    if(!linestoupdate.contains(q))
                    	linestoupdate.add(q);
                }
                }
            }
        }
        }
        System.debug('Line 60 : '+System.now());
        //isFirst = false;
        //quant8update = true;
        //quotelinecheck = true;
        try{
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
             if(setZeroServiceAmount)		
             {		
                 for(Quote_Line__c q : qli){		
                      q.Conga_Renewal_Extended_Services__c = 0;		
                      q.Conga_Renewal_Unit_Services__c = 0;		
                      q.Conga_Extended_Services__c = 0;		
                      q.Conga_Unit_Services__c = 0;              		
                 }		
    		
              }   	
            QuoteLineTriggerHandler.fromprint = true;
            //update qli;
            //Adding as part of duplicate id fix - 12 NOV by SRAVAN START
        Map<Id,Quote_Line__c> linesmaptoupdate = new Map<Id,Quote_Line__c>();
        for(Quote_Line__c qlitem : linestoupdate){
            linesmaptoupdate.put(qlitem.id,qlitem);
        }
        //update linestoupdate;
        update linesmaptoupdate.values();
        //Adding as part of duplicate id fix - 12 NOV by SRAVAN END
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
            //Added zero dollar for sf-bug-725
            QuotePrintProcess_Batch_7_Of_7 b = new QuotePrintProcess_Batch_7_Of_7(qId, isGenericDrawer,zerodollar);
            database.executeBatch(b);
        }
        else{
            List<Quote_Print_Status__c> qpsList = [select quote__c,print_status__c from Quote_Print_Status__c where quote__c=:qId];
            if(qpsList.size()>0){
                qpsList[0].Generic_Drawer__c = false;
                qpsList[0].products_unbundled__c = false;
                qpsList[0].summary_by_product__c = false;
                qpsList[0].summary_by_par__c = false;
                qpsList[0].Detail_by_par__c = false;
                qpsList[0].print_status__c = 'FAILED';
                update qpsList[0];
            }
        }
        
        
        
        //QuotePrintProcess_Batch_7_Of_7 b = new QuotePrintProcess_Batch_7_Of_7(qId);
        //database.executeBatch(b);
        
    }
}