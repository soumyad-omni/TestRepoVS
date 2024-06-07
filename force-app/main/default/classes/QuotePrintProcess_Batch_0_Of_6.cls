global class QuotePrintProcess_Batch_0_Of_6 implements Database.Batchable<SObject>{
    Private Id qId;
    Private Boolean partrue;
    private Boolean pardettrue;
    private Boolean isGenericDrawer = false;
    private Boolean isProductsUnbundled = false;//Added by Sravan for SF-BUG-528
    private Boolean zerodollar = false;
     public QuotePrintProcess_Batch_0_Of_6(Id quoteid,Boolean partrue,Boolean pardettrue ){
        qId = quoteid;
        this.partrue = partrue;
        this.pardettrue = pardettrue;
    }
    public QuotePrintProcess_Batch_0_Of_6(Id quoteid,Boolean partrue,Boolean pardettrue, Boolean paramIsGenericDrawer ){
        qId = quoteid;
        this.partrue = partrue;
        this.pardettrue = pardettrue;
        this.isGenericDrawer = paramIsGenericDrawer;
    }
    //Added by Sravan for SF-BUG-528 START
    public QuotePrintProcess_Batch_0_Of_6(Id quoteid,Boolean partrue,Boolean pardettrue, Boolean paramIsGenericDrawer, Boolean isProductsUnbundled ){
        qId = quoteid;
        this.partrue = partrue;
        this.pardettrue = pardettrue;
        this.isGenericDrawer = paramIsGenericDrawer;
        this.isProductsUnbundled = isProductsUnbundled;
    }
    //Added by Sravan for SF-BUG-528 END
    //below constructor added for SF-BUG-725 by sravan
    public QuotePrintProcess_Batch_0_Of_6(Id quoteid,Boolean partrue,Boolean pardettrue, Boolean paramIsGenericDrawer, Boolean isProductsUnbundled,boolean zerodollar){
        qId = quoteid;
        this.partrue = partrue;
        this.pardettrue = pardettrue;
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
        System.debug('Line 17 : '+System.now());
        Id qId = quote[0].id;
        Quote quoteforserv = [select id,service_duration__c, Free_Month_Service__c from Quote where id=:qId]; //soumyad Sf-Bug-632 changed query
        System.debug('qId from batch : '+qId);
        List<Quote_Line__c> qli = [select id,par_location__c,Conga_Total_Product_by_Location__c,Conga_Par_Location_Total__c,
                                   quote__r.service_duration__c,quote__r.Free_Month_Service__c,Conga_Total_Support_Services_by_Location__c,
                                   Total_Monthly_Support_Services_by_Locati__c,Par_Location_Monthly_Total__c,Total_Monthly_Product_by_Location__c,Higher_Level_Item__c,customer_price__c,Contract_List_Price__c,USA_List_Price__c,Total_Customer_Price__c,
                                   Conga_contract_list_price_summbypar__c,Conga_Extended_price_summbypar__c,conga_higher_level_item__c,
                                   Conga_unit_price_summbypar__c,Conga_usa_list_price_summbypar__c,SAP_Line_Number__c,Conga_USA_Price_List__c,
                                   Cong_Extended_Price_Material_type__c,Conga_Extended_price_detbypar__c,Conga_Extended_Service_detbypar__c	,
                                   Conga_Extended_Service_summbypar__c,Conga_Product1__c, Conga_Intl_Extended_Service_summbypar__c, CurrencyIsoCode, Quote__r.SAP_Sales_Org__r.Sales_Org__c, Intl_Contract_List_Price__c, Conga_Intl_Contract_List_Price_Summbypar__c, Conga_Intl_Unit_Price_Summbypar__c, Conga_Intl_Extended_price_summbypar__c, Intl_Conga_Extended_Service_Detbypar__c  /*IBA-4715: New fields added to Query - AC*/
                                   From Quote_Line__c 
                                   where Quote__c =:qId 
                                   //and customer_price__c != 0 
                                   //and customer_price__c != null 
                                   and Line_Status__c != :Label.Conga_Quote_Line_Status 
                                   //and higher_level_item__c=0
                                   FOR UPDATE];
        /*//Adding as part of duplicate id fix - 12 NOV by SRAVAN START
        List<Quote_Line__c> qli = new List<Quote_Line__c>();
        for(Quote_line__c ql : qlist){
            qli.add(ql);
        }
        qli.sort();
        //Adding as part of duplicate id fix - 12 NOV by SRAVAN END*/
        System.debug('Line 33 : '+System.now());
        Map<Decimal,Quote_Line__c> linemap= new Map<Decimal,Quote_Line__c>();
        Map<String,List<Quote_Line__c>> linemapq2= new Map<String,List<Quote_Line__c>>();
        //Map<String,List<Quote_Line__c>> linemapq3= new Map<String,List<Quote_Line__c>>();/////Added from 1_of_6 by sravan on 24 FEB for SF-BUG-724
        for(Quote_Line__c q : qli){
            System.debug('Line 35 : '+System.now());
            //Integer sapnum = (Integer)q.SAP_Line_Number__c;
            linemap.put(q.SAP_Line_Number__c,q);
            if(linemapq2.containsKey(q.conga_higher_level_item__c)){
                    List<Quote_Line__c> proList=linemapq2.get(q.conga_higher_level_item__c);
                    proList.add(q);
                    linemapq2.put(q.conga_higher_level_item__c, proList);
                }
                else{
                    linemapq2.put(q.conga_higher_level_item__c, new List<Quote_Line__c>{q});
                }
            /*/////Added below logic from 1_of_6 by sravan on 24 FEB for SF-BUG-724 START
            if(linemapq3.containsKey(q.par_location__c)){
                List<Quote_Line__c> proList=linemapq3.get(q.par_location__c);
                proList.add(q);
                linemapq3.put(q.par_location__c, proList);
            }
            else{
                linemapq3.put(q.par_location__c, new List<Quote_Line__c>{q});
            }
            /////Added below logic from 1_of_6 by sravan on 24 FEB for SF-BUG-724 END*/
        } 
        System.debug('Line 40 : '+System.now());
        //System.debug('linemap : '+linemap.keyset());
        List<Quote_Line__c> qliupdate = new List<Quote_Line__c>();
        
        /*/////Added below logic from 1_of_6 by sravan on 24 FEB for SF-BUG-724 START
        AggregateResult[] ql = [select sum(Conga_Extended_price_summbypar__c)total,sum(Conga_Extended_Service_summbypar__c) exssumbypar,sum(Conga_Unit_Services_Material_Type__c)totalserv,sum(Conga_Unit_Price_by_Par__c) extmat,sum(Conga_unit_services_by_par__c) extserv,par_location__c par
                                    from Quote_Line__c 
                                    where Quote__c =:qId 
                                    and Line_Status__c != :Label.Conga_Quote_Line_Status
                                    group by par_location__c];    
            Integer qlsize = ql.size();
            for(Integer i=0;i<qlsize;i++){
                String parloc;
                parloc = (String)ql[i].get('par');
                System.debug('par location : '+parloc);
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
                            system.debug('totalprd by loc : '+q.Conga_Total_Product_by_Location__c+' : '+totalprdbyloc);
                            if(!qliupdate.contains(q))
                                qliupdate.add(q);
                        }
                    }
                }
            }
            AggregateResult[] ql1 = [select sum(Conga_Extended_price_summbypar__c)totalz,sum(Conga_Unit_Services_Material_Type__c)totalserv,sum(Conga_Unit_Price_by_Par__c) extmat,sum(Conga_unit_services_by_par__c) extserv,par_location__c par
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
            }
        /////Added below logic from 1_of_6 by sravan on 24 FEB for SF-BUG-724 END*/

        
        
        //if(partrue == true){
            AggregateResult[] quantity1 = [select conga_higher_level_item__c hli,sum(Quantity__c) qty,sum(Extended_Services__c)cusmt,Sum(Cong_Extended_Price_Material_type__c)epst,sum(Contract_List_Price__c) lst,Sum(Customer_Price__c) cst,Sum(Extended_Price__c) extp,Sum(Extended_Services__c) exts,sum(USA_List_Price__c) usa, sum(Intl_Contract_List_Price__c) intllst, sum(Intl_Customer_Price__c) intlcst, sum(Intl_Cong_Extended_Price_Material_type__c) intlepst /*IBA-4715: New field incorporated in calculation - AC*/
                                           from Quote_Line__c 
                                           where Quote__c =:qId and Line_Status__c != :Label.Conga_Quote_Line_Status 
                                           and (customer_price__c > 0 OR usa_list_price__c>0 OR 
                                           (Contract_List_Price__c > 0 and (customer_price__c = 0 OR customer_price__c = null)))
                                           and (NOT Conga_Product1__c like '%SV')
                                           group by conga_higher_level_item__c];
            System.debug('Line 51 : '+System.now());
            for(Integer i=0;i<quantity1.size();i++){
                Integer sapnum = Integer.valueof(quantity1[i].get('hli'));
                //for(Quote_Line__c q : qli){
                if(sapnum != null){
                    Quote_Line__c q = linemap.get(sapnum);
                    if(q.Higher_Level_Item__c == 0){
                        if((Decimal)quantity1[i].get('lst') != null && q.Contract_List_Price__c!= null)
                            q.Conga_contract_list_price_summbypar__c = (Decimal)quantity1[i].get('lst');
                        else
                            q.Conga_contract_list_price_summbypar__c = 0;
                        // System.debug('qoute Line total price :'+q.Conga_contract_list_price_summbypar__c);
                        /*IBA-4715 change starts - AC*/
                        if((Decimal)quantity1[i].get('intllst') != null && q.Intl_Contract_List_Price__c!= null && q.Quote__r.SAP_Sales_Org__r.Sales_Org__c == 'OM31')
                            q.Conga_Intl_Contract_List_Price_Summbypar__c = (Decimal)quantity1[i].get('intllst');
                        else
                            q.Conga_Intl_Contract_List_Price_Summbypar__c = 0;
                        /*IBA-4715 change Ends - AC*/
                        if((Decimal)quantity1[i].get('cst') != null)
                            q.Conga_unit_price_summbypar__c = (Decimal)quantity1[i].get('cst');
                        else
                            q.Conga_unit_price_summbypar__c = 0;
                        /*IBA-4715 change starts - AC*/
                        if((Decimal)quantity1[i].get('intlcst') != null && q.Quote__r.SAP_Sales_Org__r.Sales_Org__c == 'OM31')
                            q.Conga_Intl_Unit_Price_Summbypar__c = (Decimal)quantity1[i].get('intlcst');
                        else
                            q.Conga_Intl_Unit_Price_Summbypar__c = 0;
                        if((Decimal)quantity1[i].get('intlepst') != null && q.Quote__r.SAP_Sales_Org__r.Sales_Org__c == 'OM31')
                            q.Conga_Intl_Extended_price_summbypar__c = (Decimal)quantity1[i].get('intlepst');
                        else
                            q.Conga_Intl_Extended_price_summbypar__c = 0;
                        /*IBA-4715 change Ends - AC*/
                        if((Decimal)quantity1[i].get('usa') != null)
                            q.Conga_usa_list_price_summbypar__c = (Decimal)quantity1[i].get('usa');
                        else
                            q.Conga_usa_list_price_summbypar__c = 0;
                        // System.debug('qoute Line total price :'+q.Conga_usa_list_price_summbypar__c);
                        if((Decimal)quantity1[i].get('epst') != null)
                            q.Conga_Extended_price_summbypar__c= (Decimal)quantity1[i].get('epst');
                        else
                            q.Conga_Extended_price_summbypar__c= 0;
                        System.debug('qoute Line total price before adding base :'+q.Conga_Extended_price_summbypar__c);
                        if(!qliupdate.contains(q))
                            qliupdate.add(q);
                    }
                }
            }
            System.debug('Line 92 : '+System.now());
            AggregateResult[] quantityserv = [select conga_higher_level_item__c hli,sum(Quantity__c) qty,sum(Total_customer_price__c)cusmt,Sum(Cong_Extended_Price_Material_type__c)epst,sum(Contract_List_Price__c) lst,Sum(Customer_Price__c) cst,Sum(Extended_Price__c) extp,Sum(Extended_Services__c) exts,sum(USA_List_Price__c) usa, sum(Intl_Total_Customer_Price__c) extsint /*IBA-4715: New field incorporated in calculation - AC*/
                                              from Quote_Line__c 
                                              where Quote__c =:qId and Line_Status__c != :Label.Conga_Quote_Line_Status
                                              and Conga_Product1__c like '%SV' and (customer_price__c > 0 
                                              OR (Contract_List_Price__c > 0 and (customer_price__c = 0 OR customer_price__c = null)))
                                              group by conga_higher_level_item__c];
            System.debug('Line 99 : '+System.now());
            for(Integer i=0;i<quantityserv.size();i++){
                Integer sapnum = Integer.valueof(quantityserv[i].get('hli'));
                System.debug('hli : '+sapnum);
                
                if(sapnum != null && linemap.get(sapnum) != null){
                    Quote_Line__c q = linemap.get(sapnum);
                    if(q.Higher_Level_Item__c == 0){
                        if((Decimal)quantityserv[i].get('cusmt') != null && (quoteforserv.service_duration__c != 0 || quoteforserv.service_duration__c!= null)){
                            ////soumyad Sf-Bug-632 start
                            //q.Conga_Extended_Service_summbypar__c= (Decimal)quantityserv[i].get('cusmt')/quoteforserv.service_duration__c;
                            if(quoteforserv.Free_Month_Service__c != null) {
                                if(quoteforserv.Free_Month_Service__c != quoteforserv.service_duration__c) {//Added by sravan on 11 FEB
                        			q.Conga_Extended_Service_summbypar__c =  (Decimal)quantityserv[i].get('cusmt')/(quoteforserv.service_duration__c - quoteforserv.Free_Month_Service__c);
                                    q.Conga_Intl_Extended_Service_summbypar__c = (Decimal)quantityserv[i].get('extsint')/(quoteforserv.service_duration__c - quoteforserv.Free_Month_Service__c); /*IBA-4715 Changes - AC*/
                                }else{
                                    q.Conga_Extended_Service_summbypar__c = 0;
                                    q.Conga_Intl_Extended_Service_summbypar__c = 0; /*IBA-4715 Changes - AC*/
                                }
                            }else{
                                q.Conga_Extended_Service_summbypar__c= (Decimal)quantityserv[i].get('cusmt')/quoteforserv.service_duration__c;
                                q.Conga_Intl_Extended_Service_summbypar__c= (Decimal)quantityserv[i].get('extsint')/quoteforserv.service_duration__c; /*IBA-4715 Changes - AC*/
                            }
                        } else{
                            //soumyad Sf-Bug-632 end
                            q.Conga_Extended_Service_summbypar__c= 0;
                            q.Conga_Intl_Extended_Service_summbypar__c = 0; /*IBA-4715 Changes - AC*/
                        }
                        //System.debug('prod :'+q.Conga_Product1__c);
                        //System.debug('qoute Line total price before adding base :'+q.Conga_Extended_Service_summbypar__c);
                        if(!qliupdate.contains(q))
                            qliupdate.add(q);
                    }
                }
            }
            
        //}
        System.debug('Line 116 : '+System.now());
        //if(pardettrue == true){
            AggregateResult[] quantity2 = [select conga_higher_level_item__c hli,conga_product__c cp,sum(Extended_Service_detbypar__c) esdbp,sum(Extended_Price_detbypar__c) epdbp
                                           from Quote_Line__c 
                                           where Quote__c =:qId 
                                           and Line_Status__c != :Label.Conga_Quote_Line_Status
                                           and (customer_price__c > 0 
                                              OR (Contract_List_Price__c > 0 and (customer_price__c = 0 OR customer_price__c = null)))
                                           group by conga_higher_level_item__c,conga_product__c];
        
            System.debug('Line 127 : '+System.now());
            for(Integer i=0;i<quantity2.size();i++){
                //Integer sapnum = Integer.valueof(quantity2[i].get('hli'));
                //if(sapnum != null){
                //Quote_Line__c q = linemap.get(sapnum);
                List<Quote_Line__c> qlList = linemapq2.get((String)quantity2[i].get('hli'));
            	if(qlList != null && !qlList.isempty()){
                for(Quote_line__c q : qlList){
                    if(q.Conga_Product1__c == quantity2[i].get('cp') && q.conga_Higher_Level_Item__c == quantity2[i].get('hli')){
                        if((Decimal)quantity2[i].get('epdbp') != null && (quoteforserv.service_duration__c != 0 || quoteforserv.service_duration__c!= null))
                            q.Conga_Extended_price_Detbypar__c= (Decimal)quantity2[i].get('epdbp');
                        else
                            q.Conga_Extended_price_Detbypar__c= 0;
                        System.debug('Detail by Par :'+q.Conga_Extended_price_Detbypar__c);
                        /*if((Decimal)quantity2[i].get('esdbp') != null && (quoteforserv.service_duration__c != 0 || quoteforserv.service_duration__c!= null)){
                            //soumyad Sf-Bug-632 start
                            if(quoteforserv.Free_Month_Service__c != null) {
                                if(quoteforserv.service_duration__c != quoteforserv.Free_Month_Service__c)//Added by sravan on 11 FEB
                        			q.Conga_Extended_Service_Detbypar__c= (Decimal)quantity2[i].get('esdbp')/(quoteforserv.service_duration__c - quoteforserv.Free_Month_Service__c);
                                else
                                    q.Conga_Extended_Service_Detbypar__c = 0;
                            }else{
                            	q.Conga_Extended_Service_Detbypar__c= (Decimal)quantity2[i].get('esdbp')/quoteforserv.Service_Duration__c;
                            }
                        }
                        else
                            q.Conga_Extended_Service_Detbypar__c= 0;
                        //soumyad Sf-Bug-632 end
                        System.debug('Detail by Par :'+q.Conga_Extended_Service_Detbypar__c);*/
                        if(!qliupdate.contains(q))
                            qliupdate.add(q);
                    }
                }
            }
            }
        	AggregateResult[] quantity2serv = [select conga_higher_level_item__c hli,conga_higher_product__c cp,sum(Extended_Service_detbypar__c) esdbp,sum(Extended_Price_detbypar__c) epdbp,  Sum(Intl_Extended_Service_detbypar__c) intlesdbp /*IBA-4715: New field incorporated in calculation - AC*/
                                           from Quote_Line__c 
                                           where Quote__c =:qId 
                                           and Line_Status__c != :Label.Conga_Quote_Line_Status
                                           and (customer_price__c > 0 
                                              OR (Contract_List_Price__c > 0 and (customer_price__c = 0 OR customer_price__c = null)))
                                           group by conga_higher_level_item__c,conga_higher_product__c];

        for(Integer i=0;i<quantity2serv.size();i++){
                List<Quote_Line__c> qlList = linemapq2.get((String)quantity2serv[i].get('hli'));
            	if(qlList != null && !qlList.isempty()){
                for(Quote_line__c q : qlList){
                    if(q.Conga_Product1__c == quantity2serv[i].get('cp') && q.conga_Higher_Level_Item__c == quantity2serv[i].get('hli')){
                        if((Decimal)quantity2serv[i].get('esdbp') != null && (quoteforserv.service_duration__c != 0 || quoteforserv.service_duration__c!= null)){
                            //soumyad Sf-Bug-632 start
                            if(quoteforserv.Free_Month_Service__c != null) {
                                if(quoteforserv.service_duration__c != quoteforserv.Free_Month_Service__c){//Added by sravan on 11 FEB
                        			q.Conga_Extended_Service_Detbypar__c= (Decimal)quantity2serv[i].get('esdbp')/(quoteforserv.service_duration__c - quoteforserv.Free_Month_Service__c);
                                    q.Intl_Conga_Extended_Service_Detbypar__c = (Decimal)quantity2serv[i].get('intlesdbp')/(quoteforserv.service_duration__c - quoteforserv.Free_Month_Service__c); /*IBA-4715 Changes - AC*/
                                }else{
                                    q.Conga_Extended_Service_Detbypar__c = 0;
                                    q.Intl_Conga_Extended_Service_Detbypar__c = 0; /*IBA-4715 Changes - AC*/
                                }
                            }else{
                            	q.Conga_Extended_Service_Detbypar__c= (Decimal)quantity2serv[i].get('esdbp')/quoteforserv.Service_Duration__c;
                                q.Intl_Conga_Extended_Service_Detbypar__c= (Decimal)quantity2serv[i].get('intlesdbp')/quoteforserv.Service_Duration__c; /*IBA-4715 Changes - AC*/
                            }
                        }
                        else{
                            q.Conga_Extended_Service_Detbypar__c= 0;
                            q.Intl_Conga_Extended_Service_Detbypar__c = 0; /*IBA-4715 Changes - AC*/
                        }
                            
                        //soumyad Sf-Bug-632 end
                        System.debug('Detail by Par :'+q.Conga_Extended_Service_Detbypar__c);
                        System.debug('Detail by Par international :'+q.Intl_Conga_Extended_Service_Detbypar__c);
                        if(!qliupdate.contains(q))
                            qliupdate.add(q);
                    }
                }
            }
            }
        
        //}
        System.debug('Line 151 : '+System.now());
        
        if(partrue || pardettrue){
            QuoteLineTriggerHandler.fromprint = true;
            //Adding as part of duplicate id fix - 12 NOV by SRAVAN START
        Map<Id,Quote_Line__c> linesmaptoupdate = new Map<Id,Quote_Line__c>();
        for(Quote_Line__c qlitem : qliupdate){
            linesmaptoupdate.put(qlitem.id,qlitem);
        }
        update linesmaptoupdate.values();
        //Adding as part of duplicate id fix - 12 NOV by SRAVAN END
            
            
            //update qliupdate;
        }
        
        
    } 
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :bc.getJobId()];
        System.debug('job Status : '+a.status);
        if(a.Status == 'Completed' && a.NumberOfErrors == 0 && a.ExtendedStatus == null){        
             QuotePrintProcess_Batch_1_Of_6 b = new QuotePrintProcess_Batch_1_Of_6(qId,partrue,pardettrue,isGenericDrawer,isProductsUnbundled,zerodollar);//Added isProductsUnbundled by Sravan for SF-BUG-528
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
        //QuotePrintProcess_Batch_1_Of_6 b = new QuotePrintProcess_Batch_1_Of_6(qId);
        //database.executeBatch(b);
    }
    
}