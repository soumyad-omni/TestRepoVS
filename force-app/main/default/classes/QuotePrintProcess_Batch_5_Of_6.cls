/**
 * @File Name          : QuotePrintProcess_Batch_5_Of_6.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 09-25-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    30/6/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
global class QuotePrintProcess_Batch_5_Of_6 implements Database.Batchable<SObject>{
    Private Id qId;
    private Boolean isGenericDrawer = false;
    private Boolean isProductsUnbundled = false;//Added by Sravan for SF-BUG-528
    private Boolean zerodollar = false;//Added zerodollar for SF-BUG-725
    public QuotePrintProcess_Batch_5_Of_6(Id quoteid){
        qId = quoteid;
    }
     public QuotePrintProcess_Batch_5_of_6(Id quoteid, Boolean paramIsGenericDrawer){
        qId = quoteid;
         this.isGenericDrawer = paramIsGenericDrawer;
    }
    //Added by Sravan for SF-BUG-528 START
    public QuotePrintProcess_Batch_5_Of_6(Id quoteid, Boolean paramIsGenericDrawer,Boolean isProductsUnbundled){
        qId = quoteid;
        this.isGenericDrawer = paramIsGenericDrawer;
        this.isProductsUnbundled = isProductsUnbundled;
    }
    //Added by Sravan for SF-BUG-528 END
    //below constructor added for SF-BUG-725 by sravan
    public QuotePrintProcess_Batch_5_Of_6(Id quoteid, Boolean paramIsGenericDrawer,Boolean isProductsUnbundled,boolean zerodollar){
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
        Id qId = quote[0].id;
        System.debug('qId from batch : '+qId);
        List<Quote_Line__c> qli = [select id,Conga_Unit_Services__c,From_Quote_Print__c,Conga_Sales_Text_Long__c,
                                   Sales_Text__c,
                                   conga_extended_price_materials__c,Quote__c,total_monthly_product_by_location__c,Conga_Summary_Unit_Price__c,
                                   Conga_Summary_Contract_List_Price__c,Conga_Summary_Extended_Price__c,Conga_Summary_By_Par_Extd_Services__c,Material_Type__c,
                                   USA_List_Price__c,Contract_List_Price__c,Part_of_a_Bundle__c,Resend_to_SAP__c,Conga_part_of_bundle_true__c,
                                   conga_solution_includes__c,Conga_part_of_bundle_check__c,conga_product_description__c,List_Price__c,Extended_Price__c,
                                   Conga_Unit_Services_Material_Type__c,Extended_Services__c,Conga_USA_Price_List__c,Cong_Extended_Price_Material_type__c,
                                   sap_line_number__c,conga_higher_level_item__c,Higher_Level_Item__c,Conga_Product__c,Conga_Product1__c,
                                   conga_grouped_product__c,quantity__c,Product_Code__c,Pricing_Reference_Model__r.Name,Conga_Quantity__c,par_location__c,
                                   Conga_Total_Support_Services_by_Location__c,customer_price__c,Conga_Total_Product_by_Location__c,Product__r.name,Conga1_USA_List_Price__c 
                                   From Quote_Line__c where Quote__c =:qId and Line_Status__c != :Label.Conga_Quote_Line_Status FOR UPDATE];
        /*//Adding as part of duplicate id fix - 12 NOV by SRAVAN START
        List<Quote_Line__c> qli = new List<Quote_Line__c>();
        for(Quote_line__c ql : qlist){
            qli.add(ql);
        }
        qli.sort();
        //Adding as part of duplicate id fix - 12 NOV by SRAVAN END*/
        System.debug('Line 25 : '+System.now());
        AggregateResult[] quantity6 = [select conga_higher_level_item__c hli,sum(conga_unit_price__c) cupc,sum(conga_list_price1__c) clp1c,sum(Conga_Total_Product_by_Par_Monthly__c)ctpbym,sum(Extended_Services__c)cusmt,Sum(Cong_Extended_Price_Material_type__c)epst,sum(Contract_List_Price__c) lst, Sum(Customer_Price__c) cst,Sum(Extended_Price__c) extp,Sum(Total_Customer_Price__c) tcpcqty,Sum(Extended_Services__c) exts,sum(USA_List_Price__c) usa from Quote_Line__c 
                                       where Quote__c =:qId  and (NOT Conga_Product1__c like '%SV') and part_of_a_bundle__C =False and Line_Status__c != :Label.Conga_Quote_Line_Status
                                       and (NOT Product__r.name like '%LEASE BUYOUT%')
                                       and (NOT Product__r.name like '%RENEWAL%')
                                       group by conga_higher_level_item__c];
        System.debug('Line 31 : '+System.now());
        AggregateResult[] quantity8 = [Select Sum(quantity__c) qty, product__c, Pricing_Reference_Model__r.Name prdc1, sum(Extended_Services__c)cusmt,
                                       Sum(Cong_Extended_Price_Material_type__c)epst,sum(Contract_List_Price__c) lst,Sum(Customer_Price__c) cst,
                                       Sum(Total_Customer_Price__c) tcpcqty,Sum(Extended_Price__c) extp,Sum(Extended_Services__c) exts,
                                       Sum(USA_List_Price__c) usa  
                                       From Quote_Line__c 
                                       Where Quote__c =:qId and product__r.Name = 'RENEWAL' and Line_Status__c != :Label.Conga_Quote_Line_Status
                                       Group By product__c, Pricing_Reference_Model__r.Name];   
        System.debug('Line 39 : '+System.now());
        //Commented by Sravan for quote print optimisation COMMENTED START
       /* for(Integer i=0;i<quantity6.size();i++){  
            //Boolean groupedcheck = false;
            Integer sapnum = Integer.valueof(quantity6[i].get('hli'));
            String prddesc = '';            
            // System.debug('prddesc : '+prddesc);
            for(Quote_Line__c q : qli){    
                //q.conga_grouped_product__c = false;
                if(q.sap_line_number__c == sapnum){
                    Decimal cupc = (Decimal)quantity6[i].get('cupc');
                    Decimal clp1c = (Decimal)quantity6[i].get('clp1c');
                    //if((Decimal)quantity6[i].get('clp1c')!=NULL)
                    //q.Conga_Summary_Contract_List_Price__c=(Decimal)quantity6[i].get('clp1c');
                    if((Decimal)quantity6[i].get('ctpbym')!=NULL)
                        q.Conga_Summary_Extended_Price__c=(Decimal)quantity6[i].get('ctpbym');
                    if((Decimal)quantity6[i].get('cupc')!=NULL)
                        q.Conga_Summary_Unit_Price__c=(Decimal)quantity6[i].get('cupc');
                    //    system.debug(cupc);
                    //    system.debug(clp1c);
                }
            }
        }*/
        //Commmented by Sravan for quote print optimisation COMMENTED END
        System.debug('Line 61 : '+System.now());
        groupRenewalItemsQuantity(quantity8, qli);
        System.debug('Line 63 : '+System.now());
        //isFirst = false;
        System.debug('Quote Lines before Update : '+qli);
        for(Quote_Line__c q: qli){
            if(q.Customer_Price__c == null)		
              q.Customer_Price__c = 0;
            if(q.Sales_Text__c != null){
                String salestext = q.Sales_Text__c;                                       
                System.debug('SalesText : '+salestext);
                //salestext = salestext.replaceAll('[^\\w\\s]', '');
                salestext = salestext.replaceAll('[^\\w\\s^;]', ''); // soumyad IBA-1289
                q.Conga_Sales_Text_Long__c = salestext;
                q.Sales_Text__c = salestext;
                System.debug('SalesText : '+salestext);
                System.debug('SalesText : '+q.Conga_Sales_Text_Long__c);
            }
            if(q.Conga_product__c == 'LEASE BUYOUT'){
                // q.conga_grouped_product__c = false;
                q.Is_Lease_buyout__c = true;
                q.Conga_Quantity__c = q.quantity__c;
                q.Conga_Extended_Price_Materials__c= q.extended_price__c;
                q.Conga_Unit_Price__c = q.Customer_Price__c;
                q.Conga1_USA_List_Price__c =  q.USA_List_Price__c;
            }
        }
        System.debug('Line 91 : '+System.now());
        /* for(Quote_Line__c q : qli){
if(q.Conga_product__c == 'LEASE BUYOUT'){
// q.conga_grouped_product__c = false;
q.Is_Lease_buyout__c = true;
q.Conga_Quantity__c = q.quantity__c;
q.Conga_Extended_Price_Materials__c= q.extended_price__c;
}        

}*/
        // soumyad sf-bug-631 start Conga_Total_Product_by_Par_Monthly__c
        
        AggregateResult[] ql1 = [select sum(Conga_Extended_price_summbypar__c)totalz,sum(Conga_Unit_Services_Material_Type__c)totalserv,sum(Conga_Unit_Price_by_Par__c) extmat,sum(Conga_unit_services_by_par__c) extserv,par_location__c par
                                 from Quote_Line__c 
                                 where Quote__c =:qId
                                 and Conga_Product1__c != null 
                                 and (NOT Conga_Product1__c like 'Fr%')  
                                 and (NOT Conga_Product1__c like '%SV')
                                 and (NOT Conga_Product1__c like '%RENEWAL%') 
                                 and part_of_a_bundle__c  = FALSE
                                 and Line_Status__c != :Label.Conga_Quote_Line_Status
                                 group by par_location__c];  
        // soumyad sf-bug-1071 start
        Map<String,Decimal> mapaggtotal = new Map<String,Decimal>();
        for(AggregateResult aggResult : ql1)
        {
            mapaggtotal.put((String)aggResult.get('par'), (Decimal)aggResult.get('totalz'));
        }
        for(Quote_Line__c q : qli){
            Decimal ql11 = mapaggtotal.get(q.par_location__c);
                if(ql11 != null){
                    q.Total_Monthly_Product_by_Location__c = ql11;  
                }    
            }
        // soumyad sf-bug-1071 end
        
        /* soumyad commented sf-bug-1071 
        Integer qlsize1 = ql1.size();
        for(Integer i=0;i<qlsize1;i++){
            for(Quote_Line__c q : qli){
                if(q.Par_Location__c == ql1[i].get('par')){
                    System.debug('par loc : '+ql1[i].get('par')+' product : '+q.Conga_Product1__c);
                    //q.Total_Monthly_Product_by_Location__c = 123; 
                    q.Total_Monthly_Product_by_Location__c = (Decimal)ql1[i].get('totalz');  
                    System.debug('total : '+q.Total_Monthly_Product_by_Location__c+' aggregate value : '+(Decimal)ql1[i].get('totalz'));
                }    
            }        
        }*/
        // soumyad sf-bug-631 end 
        QuoteLineTriggerHandler.fromprint = true;
        //Adding as part of duplicate id fix - 12 NOV by SRAVAN START
        Map<Id,Quote_Line__c> linesmaptoupdate = new Map<Id,Quote_Line__c>();
        for(Quote_Line__c qlitem : qli){
            linesmaptoupdate.put(qlitem.id,qlitem);
        }
        //update linestoupdate;
        update linesmaptoupdate.values();
        //Adding as part of duplicate id fix - 12 NOV by SRAVAN END  

    }
    private static void groupRenewalItemsQuantity(AggregateResult[] quantity8, List<Quote_Line__c> qli ){                                    
        System.debug('Line 105 : '+System.now());
        Map<String,List<Quote_Line__c>> linemapq2 = new Map<String,List<Quote_Line__c>>();
        for(Quote_Line__c q: qli){
            if(q.Product__r.Name == 'RENEWAL'){
                //Added by Sravan for quote print optimisation START
            if(linemapq2.containsKey(q.Pricing_Reference_Model__r.Name)){
                    List<Quote_Line__c> proList=linemapq2.get(q.Pricing_Reference_Model__r.Name);
                    proList.add(q);
                    linemapq2.put(q.Pricing_Reference_Model__r.Name, proList);
                }
                else{
                    linemapq2.put(q.Pricing_Reference_Model__r.Name, new List<Quote_Line__c>{q});
                }
                //Added by Sravan for quote print optimisation
            }
        }
        for(Integer i=0;i<quantity8.size();i++){
            Boolean groupedcheck = false;
            
            List<Quote_Line__c> qlList = linemapq2.get((String)quantity8[i].get('prdc1'));//Added by Sravan for quote print optimisation
            if(qlList != null && !qlList.isempty()){
            for(Quote_Line__c q : qlList){
                if (q.Resend_to_SAP__c) {
                    q.Resend_to_SAP__c=false;
                }  
                String prcode;
                prcode = (String)quantity8[i].get('product__c');
                System.debug('product1 : '+q.Conga_Product1__c);
                boolean serviceprd = false;
                
                if(q.Conga_Product1__c.contains('-sv')||q.Conga_Product1__c.contains('-SV'))
                    serviceprd = true;
                if(q.Product__r.Name == 'RENEWAL' && q.Pricing_Reference_Model__r.Name == quantity8[i].get('prdc1') ){
                    //system.assert(false,q.Product__r.Name +'----'+q.Pricing_Reference_Model__r.Name+'==='+quantity8[i].get('prdc1'));
                    if(groupedcheck == false ){
                        if(serviceprd == false){
                            q.conga_Renewal_grouped_product__c = true;
                            q.Conga_Quantity__c = (Decimal)quantity8[i].get('qty');
                            groupedcheck = true;
                        }
                        else{
                            q.conga_Renewal_grouped_product__c = false;
                            serviceprd = false;
                        }
                    }
                    else{
                        q.conga_Renewal_grouped_product__c = false;
                    }
                    
                    //if(q.Conga_part_of_bundle_check__c == false)
                    q.Conga_Unit_Price__c = q.Customer_Price__c;
                    // if(q.Conga_part_of_bundle_check__c == false)
                    // q.Conga_Total_Price__c = (Decimal)quantity8[i].get('extp');
                    //q.Conga_Unit_Services__c = (Decimal)quantity8[i].get('cusmt');
                    //System.debug('Conga Unit Services : '+q.Conga_Unit_Services__c);
                    
                    //q.Conga_Extended_Services__c = (Decimal)quantity8[i].get('exts');
                    //System.debug('Conga Unit Services : '+q.Conga_Extended_Services__c);
                    q.Conga1_USA_List_Price__c = (Decimal)quantity8[i].get('usa');
                    //if(q.Conga_part_of_bundle_check__c == false)
                    q.Conga_Extended_Price_Materials__c= (Decimal)quantity8[i].get('epst');
                    
                    System.debug('qoute Line total price :'+q.Conga_Extended_Price_Materials__c);
                    if(!qli.contains(q))
                        qli.add(q);
                }    
            }  
            }
        }
        System.debug('Line 154 : '+System.now());
    }
    global void finish(Database.BatchableContext BC){
        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :bc.getJobId()];
        System.debug('job Status : '+a.status);
        System.debug('zero dollar : '+zerodollar);
        if(a.Status == 'Completed' && a.NumberOfErrors == 0 && a.ExtendedStatus == null){
            //Added by Sravan for SF-BUG-528 START
            //Added zerodollar for SF-BUG-725
            if(!isProductsUnbundled){
            	QuotePrintProcess_Batch_6_Of_6 b = new QuotePrintProcess_Batch_6_Of_6(qId,isGenericDrawer,isProductsUnbundled,zerodollar);
                database.executeBatch(b);
            }else{
                QuotePrintProcess_Batch_7_Of_7 b = new QuotePrintProcess_Batch_7_Of_7(qId, isGenericDrawer,zerodollar);
            	database.executeBatch(b);
            }
            //Added by Sravan for SF-BUG-528 END
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
        
        
        
        
        
        //QuotePrintProcess_Batch_6_Of_6 b = new QuotePrintProcess_Batch_6_Of_6(qId);
        //database.executeBatch(b);
    }
}