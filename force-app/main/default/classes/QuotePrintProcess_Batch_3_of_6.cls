/**
 * @File Name          : QuotePrintProcess_Batch_3_of_6.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 07-24-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    30/6/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
global class QuotePrintProcess_Batch_3_of_6 implements Database.Batchable<SObject>{
    Private Id qId;
    private Boolean pardettrue;
    private Boolean isGenericDrawer = false;
    private Boolean isProductsUnbundled = false;//Added by Sravan for SF-BUG-528
    private Boolean zerodollar = false;//Added zero dollar for SF-BUG-725
    public QuotePrintProcess_Batch_3_of_6(Id quoteid,Boolean pardettrue){
        qId = quoteid;
        this.pardettrue = pardettrue;
    }
    public QuotePrintProcess_Batch_3_of_6(Id quoteid,Boolean pardettrue, Boolean paramIsGenericDrawer){
        qId = quoteid;
        this.pardettrue = pardettrue;
         this.isGenericDrawer = paramIsGenericDrawer;
    }
    //Added by Sravan for SF-BUG-528 START
    public QuotePrintProcess_Batch_3_Of_6(Id quoteid,Boolean pardettrue, Boolean paramIsGenericDrawer,Boolean isProductsUnbundled){
        qId = quoteid;
        this.pardettrue = pardettrue;
        this.isGenericDrawer = paramIsGenericDrawer;
        this.isProductsUnbundled = isProductsUnbundled;
    }
    //Added by Sravan for SF-BUG-528 START
    //below constructor added for SF-BUG-725 by sravan
    public QuotePrintProcess_Batch_3_Of_6(Id quoteid,Boolean pardettrue, Boolean paramIsGenericDrawer,Boolean isProductsUnbundled,Boolean zerodollar){
        qId = quoteid;
        this.pardettrue = pardettrue;
        this.isGenericDrawer = paramIsGenericDrawer;
        this.isProductsUnbundled = isProductsUnbundled;
        this.zerodollar = zerodollar;
    }
    global Database.queryLocator start(Database.BatchableContext bc){
        String name = 'Checking this night again for big quote';
        //System.debug('qId from batch : '+qId);
        return Database.getQueryLocator('Select id, Name from Quote where id =:qId');
    }
    
    global void execute (Database.BatchableContext BC, List<Quote> Quote){
        //System.debug('Line 13 : '+System.now());
        Id qId = quote[0].id;
        List<Quote_Line__c> qliupdate = new List<Quote_Line__c>();
        //System.debug('qId from batch : '+qId);
        List<Quote_Line__c> qli = [select id,Conga_Par_Location_Total__c,
                                   quote__r.service_duration__c,quote__r.Free_Month_Service__c,
                                   Total_Monthly_Support_Services_by_Locati__c,Par_Location_Monthly_Total__c,Conga_Unit_Services__c,From_Quote_Print__c,Conga_Sales_Text_Long__c,
                                   conga_extended_price_materials__c,Quote__c,total_monthly_product_by_location__c,Conga_Summary_Unit_Price__c,
                                   Conga_Summary_Contract_List_Price__c,Conga_Summary_Extended_Price__c,Conga_Summary_By_Par_Extd_Services__c,Material_Type__c,
                                   USA_List_Price__c,Contract_List_Price__c,Part_of_a_Bundle__c,Resend_to_SAP__c,Conga_part_of_bundle_true__c,
                                   conga_solution_includes__c,Conga_part_of_bundle_check__c,conga_product_description__c,List_Price__c,Extended_Price__c,
                                   Conga_Unit_Services_Material_Type__c,Extended_Services__c,Conga_USA_Price_List__c,Cong_Extended_Price_Material_type__c,
                                   sap_line_number__c,conga_higher_level_item__c,Higher_Level_Item__c,Conga_Product__c,Conga_Product1__c,
                                   conga_grouped_product__c,quantity__c,Product_Code__c,Pricing_Reference_Model__r.Name,Conga_Quantity__c,par_location__c,
                                   Conga_Total_Support_Services_by_Location__c,customer_price__c,Conga_Total_Product_by_Location__c,Product__r.name, Product__r.DW_Product_Class__c, Intl_Conga_Total_Product_By_Location__c, Intl_Conga_Total_Support_Services_By_Loc__c /*IBA-4715 Change AC*/
                                   From Quote_Line__c where Quote__c =:qId 
                                   and (customer_price__c > 0 or usa_list_price__c >=0 or Product__r.DW_Product_Class__c = 'Training' OR (Contract_List_Price__c >= 0 and (customer_price__c = 0 OR customer_price__c = null)))//added usa_list_price__c >= 0 by sravan for SF-BUG-678// added = in Contract_List_Price__c for IBA-2305 by Prithan
                                   and Line_Status__c != :Label.Conga_Quote_Line_Status /*and par_location__c != null*/ // removed par_location__c != null for IBA-2352
                                   and (higher_level_item__c = 0 or part_of_a_bundle__c = false) AND ( NOT conga_product1__c LIKE 'Fr%' )  
                                   AND ( NOT conga_product1__c LIKE '%RENEWAL%' ) FOR UPDATE]; 
        /*//Adding as part of duplicate id fix - 12 NOV by SRAVAN START
        List<Quote_Line__c> qli = new List<Quote_Line__c>();
        for(Quote_line__c ql : qlist){
            qli.add(ql);
        }
        qli.sort();
        //Adding as part of duplicate id fix - 12 NOV by SRAVAN END*/
        //System.debug('Line 25 : '+System.now());
        Map<Decimal,Quote_Line__c> linemapserv= new Map<Decimal,Quote_Line__c>();
        //Map<String,List<Quote_Line__c>> linemapq3= new Map<String,List<Quote_Line__c>>();/////Added from 1_of_6 by sravan on 24 FEB for SF-BUG-724
        /*for(Quote_Line__c q : qli){
            //Integer sapnum = (Integer)q.SAP_Line_Number__c;
             if(q.Product__r.DW_Product_Class__c == 'Training'){
                q.Conga_Quantity__c = q.Quantity__c;
                q.conga_grouped_product__c = true;
                qliupdate.add(q);
                //system.debug('Training Added');
            }
            if(q.product__r.name == 'RENEWAL')
                linemapserv.put(q.SAP_Line_Number__c,q);//Added by Sravan for quote print optimisation
            /////Added below logic from 1_of_6 by sravan on 24 FEB for SF-BUG-724 START
            if(linemapq3.containsKey(q.par_location__c)){
                List<Quote_Line__c> proList=linemapq3.get(q.par_location__c);
                proList.add(q);
                linemapq3.put(q.par_location__c, proList);
            }
            else{
                linemapq3.put(q.par_location__c, new List<Quote_Line__c>{q});
            } commenting this soumyad sf-bug-1071
            /////Added below logic from 1_of_6 by sravan on 24 FEB for SF-BUG-724 END
        }*/
        Map<String,Decimal> mapaggtotal = new Map<String,Decimal>();
        Map<String,Decimal> mapaggexssumbypar = new Map<String,Decimal>();
        Map<String,Decimal> intmapaggtotal = new Map<String,Decimal>(); /*IBA-4715 change AC*/
        Map<String,Decimal> intmapaggexssumbypar = new Map<String,Decimal>(); /*IBA-4715 change AC*/
        Map<String,Decimal> mapaggtotalserv = new Map<String,Decimal>();
        Map<String,Decimal> mapaggextmat = new Map<String,Decimal>();
        Map<String,Decimal> mapaggextserv = new Map<String,Decimal>();
        if(pardettrue){
        /////Added below logic from 1_of_6 by sravan on 24 FEB for SF-BUG-724 START
        AggregateResult[] ql = [select sum(Conga_Extended_price_summbypar__c)total,sum(Conga_Extended_Service_summbypar__c) exssumbypar,sum(Conga_Unit_Services_Material_Type__c)totalserv,sum(Conga_Unit_Price_by_Par__c) extmat,sum(Conga_unit_services_by_par__c) extserv,sum(Conga_Intl_Extended_price_summbypar__c) intltotal, Sum(Conga_Intl_Extended_Service_summbypar__c) intlexssumbypar,par_location__c par /*IBA-4715 change*/
                                    from Quote_Line__c 
                                    where Quote__c =:qId 
                                    and Line_Status__c != :Label.Conga_Quote_Line_Status
                                    group by par_location__c];    
            /* commeting soumyad sf-bug-1071 
             Integer qlsize = ql.size();
        
            for(Integer i=0;i<qlsize;i++){
                String parloc;
                parloc = (String)ql[i].get('par');
                //System.debug('par location : '+parloc);
                List<Quote_Line__c> qlList = linemapq3.get(parloc);
                //System.debug('qlist size : '+qlList.size());
                if(qlList != null && !qlList.isempty()){
                    for(Quote_Line__c q : qlList){
                        //System.debug('product : '+q.conga_product1__c);
                        if(q.Par_Location__c == ql[i].get('par')){
                            
                            Decimal totalprdbyloc; 
                            if((Decimal)ql[i].get('total') != null)
                                totalprdbyloc = (Decimal)ql[i].get('total');
                            else
                                totalprdbyloc = 0;
                            q.Conga_Total_Product_by_Location__c = totalprdbyloc;
                            q.Conga_Par_Location_Total__c = totalprdbyloc+(Decimal)ql[i].get('totalserv');
                            //SF-BUG-810 fix by Rajat (now considering the "free month service" to calculate the "total monthly service")
                            if((Decimal)ql[i].get('exssumbypar') != null){
                                if(q.quote__r.service_duration__c != null) {
                                    if(q.quote__r.Free_Month_Service__c != null && q.quote__r.Free_Month_Service__c != 0) {
                                        q.Conga_Total_Support_Services_by_Location__c = (Decimal)ql[i].get('exssumbypar') * (q.quote__r.service_duration__c - q.quote__r.Free_Month_Service__c);
                                    }else {
                                        q.Conga_Total_Support_Services_by_Location__c = (Decimal)ql[i].get('exssumbypar') * q.quote__r.service_duration__c;
                                    }
                                }     
                                else
                                    q.Conga_Total_Support_Services_by_Location__c = (Decimal)ql[i].get('exssumbypar');
                            }else{
                                q.Conga_Total_Support_Services_by_Location__c = 0;
                            }
                            q.Total_Monthly_Support_Services_by_Locati__c = (Decimal)ql[i].get('extserv');
                            q.Par_Location_Monthly_Total__c = (Decimal)ql[i].get('extmat')+(Decimal)ql[i].get('extserv');
                            //system.debug('totalprd by loc : '+q.Conga_Total_Product_by_Location__c+' : '+totalprdbyloc);
                            if(!qliupdate.contains(q))
                                qliupdate.add(q);
                        }
                    }
                }
            }*/
        
        for(AggregateResult aggResult : ql)
        {
            mapaggtotal.put((String)aggResult.get('par'), (Decimal)aggResult.get('total'));
            mapaggexssumbypar.put((String)aggResult.get('par'), (Decimal)aggResult.get('exssumbypar'));
            intmapaggtotal.put((String)aggResult.get('par'), (Decimal)aggResult.get('intltotal'));  /*IBA-4715 change AC*/
            intmapaggexssumbypar.put((String)aggResult.get('par'), (Decimal)aggResult.get('intlexssumbypar')); /*IBA-4715 change AC*/
            mapaggtotalserv.put((String)aggResult.get('par'), (Decimal)aggResult.get('totalserv'));
            mapaggextmat.put((String)aggResult.get('par'), (Decimal)aggResult.get('extmat'));
            mapaggextserv.put((String)aggResult.get('par'), (Decimal)aggResult.get('extserv'));
        }
        }
        Decimal totalprdbyloc;
        Decimal inttotalprdbyloc; /*IBA-4715 change AC*/
        Map<Integer,Quote_Line__c> linemap= new Map<Integer,Quote_Line__c>();
                        for(Quote_Line__c q : qli){
                            Integer sapnum = (Integer)q.SAP_Line_Number__c;
            				linemap.put(sapnum,q);
                            system.debug('qli'+q.Product__r.name);
                            // Commented out this block of code for IBA-1623 - Starts here
                            /*if(q.Product__r.DW_Product_Class__c == 'Training'){
                                q.Conga_Quantity__c = q.Quantity__c;
                                q.conga_grouped_product__c = true;
                                qliupdate.add(q);
                                //system.debug('Training Added');
                            }*/
                            // Commented out till here for IBA-1623 - Ends here
                            if(q.Contract_List_Price__c>0 && q.Customer_Price__c == 0 && q.part_of_a_bundle__c == false){
                               // q.Conga_Quantity__c = q.Quantity__c;
                                //if(!qliupdate.contains(q))
                                    //qliupdate.add(q);
                                //system.debug('Training Added');
                            }
                            if(q.product__r.name == 'RENEWAL')
                                linemapserv.put(q.SAP_Line_Number__c,q);
                            system.debug('test qt name	'+q.Product_Code__c);
                            if(pardettrue){
                            Decimal ql1 = mapaggtotal.get(q.par_location__c);
                            Decimal ql2 = mapaggexssumbypar.get(q.par_location__c);
                            Decimal ql3 = mapaggtotalserv.get(q.par_location__c);
                            Decimal ql4 = mapaggextmat.get(q.par_location__c);
                            Decimal ql5 = mapaggextserv.get(q.par_location__c);
                            Decimal ql6 = intmapaggtotal.get(q.par_location__c); /*IBA-4715 change AC*/
                            Decimal ql7 = intmapaggexssumbypar.get(q.par_location__c); /*IBA-4715 change AC*/
                                    
                                     
                                    if(ql1 != null)
                                        totalprdbyloc = ql1;
                                    else
                                        totalprdbyloc = 0;
                                    q.Conga_Total_Product_by_Location__c = totalprdbyloc;
                                /*IBA-4715 change AC*/
                                if(ql1 != null)
                                        inttotalprdbyloc = ql6;
                                    else
                                        inttotalprdbyloc = 0;
                                	q.Intl_Conga_Total_Product_By_Location__c = inttotalprdbyloc;
                                /*IBA-4715 change AC*/
                                    q.Conga_Par_Location_Total__c = totalprdbyloc+ql3;
                                    if(ql2 != null){
                                        if(q.quote__r.service_duration__c != null) {
                                            if(q.quote__r.Free_Month_Service__c != null && q.quote__r.Free_Month_Service__c != 0) {
                                                q.Conga_Total_Support_Services_by_Location__c = ql2 * (q.quote__r.service_duration__c - q.quote__r.Free_Month_Service__c);
                                            }else {
                                                q.Conga_Total_Support_Services_by_Location__c = ql2 * q.quote__r.service_duration__c;
                                            }
                                        }     
                                        else
                                            q.Conga_Total_Support_Services_by_Location__c = ql2;
                                    }else{
                                        q.Conga_Total_Support_Services_by_Location__c = 0;
                                    }
                                /*IBA-4715 change Starts AC*/
                                if(ql7 != null){
                                    if(q.quote__r.service_duration__c != null) {
                                        if(q.quote__r.Free_Month_Service__c != null && q.quote__r.Free_Month_Service__c != 0) {
                                            q.Intl_Conga_Total_Support_Services_By_Loc__c = ql7 * (q.quote__r.service_duration__c - q.quote__r.Free_Month_Service__c);
                                        }else {
                                            q.Intl_Conga_Total_Support_Services_By_Loc__c = ql7 * q.quote__r.service_duration__c;
                                        }
                                    }
                                    else
                                        q.Intl_Conga_Total_Support_Services_By_Loc__c = ql7;
                                }else{
                                    q.Intl_Conga_Total_Support_Services_By_Loc__c = 0;
                                } /*IBA-4715 change Ends AC*/
                                q.Total_Monthly_Support_Services_by_Locati__c = ql5;
                                q.Par_Location_Monthly_Total__c = ql4+ql5;
                                system.debug('test debug	'+ql5);
                                if(!qliupdate.contains(q))
                                    qliupdate.add(q);
                            }
                        }
            /*AggregateResult[] ql1 = [select sum(Conga_Extended_price_summbypar__c)totalz,sum(Conga_Unit_Services_Material_Type__c)totalserv,sum(Conga_Unit_Price_by_Par__c) extmat,sum(Conga_unit_services_by_par__c) extserv,par_location__c par
                                     from Quote_Line__c 
                                     where Quote__c =:qId
                                     and Conga_Product1__c != null 
                                     and (NOT Conga_Product1__c like 'Fr%')  
                                     and (NOT Conga_Product1__c like '%SV')
                                     //and (NOT Conga_Product1__c like '%RENEWAL%') 
                                     and part_of_a_bundle__c  = FALSE
                                     and Line_Status__c != :Label.Conga_Quote_Line_Status
                                     group by par_location__c];   
            Integer qlsize1 = ql1.size();
            for(Integer i=0;i<qlsize1;i++){
                String parloc;
                parloc = (String)ql1[i].get('par');
                List<Quote_Line__c> qlList = linemapq3.get(parloc);//Added by Sravan for quote print optimisation
                if(qlList != null && !qlList.isempty()){
                    for(Quote_Line__c q : qlList){
                        if(q.Par_Location__c == ql1[i].get('par')){
                            q.Total_Monthly_Product_by_Location__c = (Decimal)ql1[i].get('totalz');
                            if(!qliupdate.contains(q))
                                qliupdate.add(q);
                        }    
                    }
                }
            }*/
        /////Added below logic from 1_of_6 by sravan on 24 FEB for SF-BUG-724 END
        if(!isProductsUnbundled){
        AggregateResult[] quantity4 = [select conga_higher_level_item__c hli,sum(Quantity__c) qty,sum(Extended_Services__c)cusmt,Sum(Cong_Extended_Price_Material_type__c)epst,sum(Contract_List_Price__c) lst, Sum(Customer_Price__c) cst,Sum(Extended_Price__c) extp,Sum(Total_Customer_Price__c) tcpcqty,Sum(Extended_Services__c) exts,sum(USA_List_Price__c) usa from Quote_Line__c 
                                       where Quote__c =:qId and (customer_price__c > 0 OR (Contract_List_Price__c > 0 and (customer_price__c = 0 OR customer_price__c = null))) and Line_Status__c != :Label.Conga_Quote_Line_Status
                                       and (NOT Product__r.name like '%LEASE BUYOUT%')
                                       and (NOT Product__r.name like '%RENEWAL%')
                                       and (NOT Higher_level_item__c in :linemapserv.keySet())
                                       group by conga_higher_level_item__c];
        //System.debug('Line 31 : '+System.now());
        /*Map<Integer,Quote_Line__c> linemap= new Map<Integer,Quote_Line__c>();
        for(Quote_Line__c q : qli){
            Integer sapnum = (Integer)q.SAP_Line_Number__c;
            linemap.put(sapnum,q);
        }*/
        //System.debug('Line 37 : '+System.now());
        
        for(Integer i=0;i<quantity4.size();i++){  
            //Boolean groupedcheck = false;
            Integer sapnum = Integer.valueof(quantity4[i].get('hli'));
            String prddesc = '';            
            // System.debug('prddesc : '+prddesc);
            //for(Quote_Line__c q : qli){    
            //q.conga_grouped_product__c = false;
            if(sapnum != null){
                //System.debug('batch 4 test : '+sapnum+'QuoteLine : '+linemap.get(sapnum));  
                if(linemap.get(sapnum) != null){
                    Quote_Line__c q = linemap.get(sapnum);//Added by Sravan for quote print optimisation
                    // if(q.sap_line_number__c == sapnum){
                    // System.debug('Quote Line : inside quant loop : '+q.SAP_Line_Number__c+sapnum);  
                    Decimal sumpl = (Decimal)quantity4[i].get('cusmt');
                    if((Decimal)quantity4[i].get('cusmt') != null)
                        q.Conga_Summary_By_Par_Extd_Services__c =   (Decimal)quantity4[i].get('cusmt'); 
                    // system.debug(sumpl);                
                    // }
                    
                    if(q.sap_line_number__c == sapnum && q.Conga_part_of_bundle_check__c == false){
                        if((Decimal)quantity4[i].get('cusmt') != null)
                            q.Conga_Unit_Services__c = (Decimal)quantity4[i].get('cusmt');
                        else
                            q.Conga_Unit_Services__c = 0;
                        if((Decimal)quantity4[i].get('exts') != null)
                            q.Conga_Extended_Services__c = (Decimal)quantity4[i].get('exts');
                        else
                            q.Conga_Extended_Services__c = 0;
                    }
                    if(!qliupdate.contains(q))
                    qliupdate.add(q);
                }
            }
            
            //}
        }
        }
        //System.debug('Line 75 : '+System.now()); 
        QuoteLineTriggerHandler.fromprint = true;
        QuoteLineTriggerHandler.TriggerDisabled = true;
        //Adding as part of duplicate id fix - 12 NOV by SRAVAN START
        /*Map<Id,Quote_Line__c> linesmaptoupdate = new Map<Id,Quote_Line__c>();
        for(Quote_Line__c qlitem : qliupdate){
            system.debug('test before update	'+qlitem.Product_Code__c);
            system.debug('test before update	'+qlitem.Total_Monthly_Support_Services_by_Locati__c);
            linesmaptoupdate.put(qlitem.id,qlitem);
        }
        //update linestoupdate;
        update linesmaptoupdate.values();*/
        //Adding as part of duplicate id fix - 12 NOV by SRAVAN END   
        update qliupdate;
    }
    global void finish(Database.BatchableContext BC){
        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :bc.getJobId()];
        //System.debug('job Status : '+a.status);
        if(a.Status == 'Completed' && a.NumberOfErrors == 0 && a.ExtendedStatus == null){
            //Added zero dollar for SF-BUG-725
            QuotePrintProcess_Batch_5_Of_6 b = new QuotePrintProcess_Batch_5_Of_6(qId, isGenericDrawer,isProductsUnbundled,zerodollar);//Added isProductsUnbundled by Sravan for SF-BUG-528 //4_of_6 is not useful and causing extra calculation which is not necessary
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
        
        
        
        //QuotePrintProcess_Batch_4_Of_6 b = new QuotePrintProcess_Batch_4_Of_6(qId);
        //database.executeBatch(b);
    }
}