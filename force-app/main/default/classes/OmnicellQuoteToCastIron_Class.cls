/**********************************************************************
Name:  OmnicellQuoteToCastIron_Class
Copyright © 2018
======================================================
======================================================
Purpose: 
Once Quote is created/updated,invoke REST api class to connect to CastIron.                                                            
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL                  Description
0.1          Amruta Dhumal         18/7/2018            Developed by CG Team    INITIAL DEVELOPMENT
***********************************************************************/

global class OmnicellQuoteToCastIron_Class{
    
    
    
    @future(callout=true)
    public static void callOutMethodInsert(set<Id> quoteIds){
        
        CastIronIntegration__c csValue1 = CastIronIntegration__c.getInstance('CastIronIntegration');
        String endpoint = csValue1.EndPoint__c; 
        
        ECC_Sales_Org_to_CRM__c csValue2 = ECC_Sales_Org_to_CRM__c.getInstance('AU SalesOrg Omnicell');
        String so1 = csValue2.CRM_Code__c; 
        
        ECC_Sales_Org_to_CRM__c csValue3 = ECC_Sales_Org_to_CRM__c.getInstance('MACH4 - GmbH');
        String so2 = csValue3.CRM_Code__c; 
        
        ECC_Sales_Org_to_CRM__c csValue4 = ECC_Sales_Org_to_CRM__c.getInstance('Omnicell - St.Petes');
        String so3 = csValue4.CRM_Code__c;
        
        ECC_Sales_Org_to_CRM__c csValue5 = ECC_Sales_Org_to_CRM__c.getInstance('Omnicell Inc.');
        String so4 = csValue5.CRM_Code__c; 
        
        ECC_Sales_Org_to_CRM__c csValue6 = ECC_Sales_Org_to_CRM__c.getInstance('Omnicell Ltd');
        String so5 = csValue6.CRM_Code__c; 
        
        ECC_Sales_Org_to_CRM__c csValue7 = ECC_Sales_Org_to_CRM__c.getInstance('Omnicell SAS');
        String so6 = csValue7.CRM_Code__c; 
        
        set<Id> sapid = new set<Id>();
        String quotename='';
        String jsonstr ='';
        String quoteid ='';
        string opid ='';
        string accid ='';
        string salesorgid = '';
        String SapQuoteNumber = '';
        Id templateId;
        string errormsg =''; 
        string responseString = '';
        string saperror ='';
        List<Quote> qteList = new List<Quote>();
        string salesorg ='';
        
        // Fetch email templateid 
        templateId = [select id, name from EmailTemplate where developername = 'QuoteCreated_in_SAP'].id;
        
        
        
        Quote [] quoteList = [SELECT Id,SAP_Sales_Org__r.Incoterms_1__c,GPO_Account__c,GPO_Account__r.SAP_Account_ID__c,IDN_Account__c,IDN_Account__r.SAP_Account_ID__c,Supplement1__c,
                              Contact.SAP_Contact_ID__c,SAPError__c,From__c,Service_Level__c,OwnerId,Hospital_Contact_Notes__c,Inv_Text_Notes__c,
                              Quote_Printout_Standard_Text__c,Other_Notes__c,Quote_Text__c,Special_Instructions__c,Sales_Ops_Notes__c,Posting_Date__c,
                              CreatedBy.Omnicell_Employee_Number__c,Consultant__r.Omnicell_Employee_Number__c,SSM_RD__r.Omnicell_Employee_Number__c,
                              Sales_Operation_Counterpart__r.Omnicell_Employee_Number__c,Opportunity_Owner__r.Omnicell_Employee_Number__c,Tax,Supplement__c,
                              Opportunity.AccountId,Opportunity.Account.Pricing_Code__c,Opportunity.Account.SAP_Account_ID__c,Notes__c,ExpirationDate,
                              SAP_Sales_Org__c,SAP_Sales_Org__r.Incoterms_2__c,SAP_Sales_Org__r.Distribution_Channel__c,SAP_Sales_Org__r.Sales_Office__c,
                              SAP_Sales_Org__r.Service_Level__c,SAP_Sales_Org__r.District__c,Bill_to_Account__r.SAP_Account_ID__c,Ship_to_Account__r.SAP_Account_ID__c,
                              Name,Terms_of_Payment__c,Currency__c,Exchange_Rate__c,Requested_Delivery_Date__c,Product_PO_Number__c,Booking_Date__c,Service_PO_Number__c,
                              CreatedById,Shipping_Contact__c,OpportunityId,Opportunity.Description,Primary_Quote__c,Status,CreatedDate,Total_Net__c,Opportunity_Owner__c,
                              ShippingAddress,BillingAddress,Payer__r.SAP_Account_ID__c,Description,Order_Type__c,Quote_Number__c,LineItemCount,Master_Agreement__c,Lease_Duration__c,
                              Free_Month_for_Lease__c,Service_Duration__c,Free_Month_Service__c,Pricing_Reference_Date__c,IDN_Price_List__c,GPO_Price_Lists__c,Incoterms_1__c,Incoterms_2__c,
                              Shipping_Conditions__c,Sales_Org__c,Opportunity.Opportunity_Number__c, Print_Currency__c, Print_Exchange_Rate__c,Pricing_Reference_Date_Service__c,Opportunity.Opportunity__c  
                              FROM Quote WHERE Id IN:quoteIds];
        system.debug('quoteList...'+quoteList);
        
        if(quoteList.size()>0)
        {
            for( Quote qte : quoteList) 
            {
                quotename = qte.Name;
                quoteid = qte.Id;
                opid = qte.OpportunityId;
                accid = qte.Opportunity.AccountId;
            }
        }
        
        Map<Id,SAP_Sales_Org__c> salesorglist = new Map<Id,SAP_Sales_Org__c>([select id,Service_Level__c,District__c,Distribution_Channel__c,Incoterms_2__c,Incoterms_1__c,Account__c,Sales_Office__c from SAP_Sales_Org__c where Account__c=:accid]);
        
        for(SAP_Sales_Org__c so : salesorglist.values())
        {
            salesorgid = so.id;
            sapid.add(salesorgid);            
        }
        
        
        Quote q = [select Id,Posting_Date__c,SAP_Sales_Org__r.Incoterms_1__c,Supplement1__c,From__c,Service_Level__c,SAPError__c,
                   GPO_Account__c,GPO_Account__r.SAP_Account_ID__c,IDN_Account__c,IDN_Account__r.SAP_Account_ID__c,
                   OwnerId,Hospital_Contact_Notes__c,Inv_Text_Notes__c,Quote_Printout_Standard_Text__c,Other_Notes__c,
                   Quote_Text__c,Special_Instructions__c,Sales_Ops_Notes__c,Opportunity_Owner__r.Omnicell_Employee_Number__c,
                   Consultant__r.Omnicell_Employee_Number__c,SSM_RD__r.Omnicell_Employee_Number__c,
                   Sales_Operation_Counterpart__r.Omnicell_Employee_Number__c,CreatedBy.Omnicell_Employee_Number__c,
                   Supplement__c,Opportunity.Account.Pricing_Code__c,Opportunity.Account.Special_Pricing_Code__c,Tax,
                   Opportunity.AccountId,Opportunity.Account.SAP_Account_ID__c,Name,Notes__c,ExpirationDate,SAP_Sales_Org__c,
                   SAP_Sales_Org__r.Incoterms_2__c,SAP_Sales_Org__r.Distribution_Channel__c,SAP_Sales_Org__r.Sales_Office__c,SAP_Sales_Org__r.Service_Level__c,
                   SAP_Sales_Org__r.District__c,Bill_to_Account__r.SAP_Account_ID__c,Ship_to_Account__r.SAP_Account_ID__c,
                   Terms_of_Payment__c,Currency__c,Exchange_Rate__c,Requested_Delivery_Date__c,Product_PO_Number__c,
                   Booking_Date__c,Service_PO_Number__c,CreatedById,Shipping_Contact__c,OpportunityId,Opportunity.Description,
                   Primary_Quote__c,Status,CreatedDate,Total_Net__c,Opportunity_Owner__c, ShippingAddress,BillingAddress,
                   Payer__r.SAP_Account_ID__c,Description,Order_Type__c,Quote_Number__c,LineItemCount,Master_Agreement__c,subscription_Months__c,
                   Lease_Duration__c,Free_Month_for_Lease__c,Service_Duration__c,Free_Month_Service__c,Contact.SAP_Contact_ID__c, Print_Currency__c, Print_Exchange_Rate__c,
                   Pricing_Reference_Date__c,IDN_Price_List__c,GPO_Price_Lists__c,Incoterms_1__c,Incoterms_2__c, Supplement_Generated__c, Milestone_Invoice_Term__c,
                   Shipping_Conditions__c,Sales_Org__c,Opportunity.Opportunity_Number__c,of_beds__c,Professional_services_duration__c,Omnicell_One_Account_Type__c,
                   X3rd_Deal_Rating_Spread__c, X3rd_Party_Interest_Rate__c, In_House_Interest_Rate__c, Rebate_Amount__c,Guarantor_SAP_Customer_Number__c, 
                   Associated_Sales_Order__c,Associated_Opportunity_Number__c,Early_Adopter_Flag__c,Opportunity_ID__c,Resident_Operator_Duration__c,Pricing_Reference_Date_Service__c,
                   Opportunity.Opportunity__c,Purchase_PO_Amount__c,Purchase_PO_Date__c,Service_PO_Amount__c,Service_PO_Date__c,
                   Opportunity.CloseDate,Opportunity.Expected_Bookings__c FROM Quote WHERE Id =:quoteid and Opportunity.AccountId =:accid] ;
        //added soumyad 3 new fields sf-bug- 964 & 965
        system.debug('q..'+q);

        String cid = q.Shipping_Contact__c;
	//IBA-5989 Start Saptarsha Panthi
        List<Contact> conlist = new List<Contact>();
        if(cid!=null || cid!=''){
         conlist = [select ID, SAP_Contact_ID__c from Contact Where ID=:cid];   
        }
	//IBA-5989 End Saptarsha Panthi
        // soumyad start IBA-1199
        string print_cur = q.Print_Currency__c;
        if(print_cur == null)
        {
            print_cur ='';
        }
        Decimal print_rate = q.Print_Exchange_Rate__c;
        if(print_rate == null)
        {
            print_rate =0.0;
        }
        // soumyad end IBA-1199
        string sfquoteid = q.Id;
        string hospitalnote = q.Hospital_Contact_Notes__c;
        if(hospitalnote == null)
        {
            hospitalnote ='';
        }
        string invtext= q.Inv_Text_Notes__c;
        if(invtext == null)
        {
            invtext ='';
        }
        string quoteprinttext= q.Quote_Printout_Standard_Text__c;
        if(quoteprinttext == null)
        {
            quoteprinttext ='';
        } 
        
        string othernote = q.Other_Notes__c ;
        if(othernote == null)
        {
            othernote ='';
        }
        string quotetext= q.Quote_Text__c;
        if(quotetext == null)
        {
            quotetext ='';
        }
        
        string specialinstruction = q.Special_Instructions__c;
        if(specialinstruction == null)
        {
            specialinstruction ='';
        }
        
        string salesops = q.Sales_Ops_Notes__c;
        if(salesops == null)
        {
            salesops ='';
        }
        
        string consultant = q.Consultant__r.Omnicell_Employee_Number__c;
        
        if(consultant == null)
        {
            consultant ='';
        }
        else {
            String consultantForm = formatempNum(consultant);//Updated by Sravan on March 3rd
            consultant = consultantForm;//Updated by Sravan on March 3rd
        }
        string ssm = q.SSM_RD__r.Omnicell_Employee_Number__c;
        if(ssm == null)
        {
            ssm ='';
        }
        else {
            String ssm1 = formatempNum(ssm);//Updated by Sravan on March 3rd
            ssm = ssm1; //Updated by Sravan on March 3rd
        }        
        string salesoperationcounter = q.Sales_Operation_Counterpart__r.Omnicell_Employee_Number__c;
        if(salesoperationcounter == null)
        {
            salesoperationcounter ='';
        } 
        else {
            String salesopcounter1 = formatempNum(salesoperationcounter);//Updated by Sravan on March 3rd
            salesoperationcounter = salesopcounter1;//Updated by Sravan on March 3rd
        }        
        string specialpricecode = q.Opportunity.Account.Special_Pricing_Code__c;
        if(specialpricecode == null)
        {
            specialpricecode ='';
        } 
        string supplement1 = q.Supplement1__c;
        if(supplement1 == null)
        {
            supplement1 ='';
            system.debug('supplement1...'+supplement1); 
        }
        
        string supplement = q.Supplement__c;
        if(supplement == null)
        {
            supplement ='';
        }
        
        string supplementGenerated = '';
        if(q.Supplement_Generated__c != null)
        {
            supplementGenerated = q.Supplement_Generated__c;
        }
        
        string mileStoneTerm = '';
        if(q.Milestone_Invoice_Term__c != null)
        {
            mileStoneTerm = q.Milestone_Invoice_Term__c;
        }
        
        string ordertype = q.Order_Type__c;
        if(ordertype == null)
        {
            ordertype ='';
        }
        system.debug('order..'+ordertype);
        string master = q.Master_Agreement__c;
        if(master == null)
        {
            master ='';
        }
        decimal leaseduration = q.Lease_Duration__c;
        if(leaseduration == null)
        {
            leaseduration = 0;
        }
        decimal freemonthlease = q.Free_Month_for_Lease__c;
        if(freemonthlease == null)
        {
            freemonthlease = 0;
        }
        decimal service = q.Service_Duration__c;
        if(service == null)
        {
            service =0;
        }
        decimal subMonths = q.subscription_Months__c;
        if(subMonths == null)
        {
            subMonths =0;
        }
        decimal freemonthservice = q.Free_Month_Service__c;
        if(freemonthservice == null)
        {
            freemonthservice = 0;
        }
        
        string pricingrefdate;
        Date prref = q.Pricing_Reference_Date__c;
        if(prref!=null){
            pricingrefdate = Datetime.newInstance(prref.year(), prref.month(),prref.day()).format('yyyyMMdd');}
        if(pricingrefdate == null)
        {
            pricingrefdate = '';
        }
        string idn = q.IDN_Price_List__c;
        if(idn == null)
        {
            idn = '';
        }
        string gpo = q.GPO_Price_Lists__c;
        if(gpo == null)
        {
            gpo = 'XX';
        }
        
        string inco = q.Incoterms_2__c;
        if(inco == null)
        {
            inco = '';
        }
        string shipcondition = q.Shipping_Conditions__c;
        if(shipcondition == null)
        {
            shipcondition = '';
        }
        
        if(q.Sales_Org__c == 'AU01')
        {
            salesorg = so1;
            system.debug('so1..'+so1);
            if(salesorg == null)
            {
                salesorg = '';
            }
        } 
        else if(q.Sales_Org__c == 'OM32')
        {
            salesorg = so2;
            system.debug('so2..'+so2);
            if(salesorg == null)
            {
                salesorg = '';
            }
        }
        
        else if(q.Sales_Org__c == 'OM01')
        {
            salesorg = so4;
            system.debug('so4..'+so4);
            if(salesorg == null)
            {
                salesorg = '';
            }
        }  
        else if(q.Sales_Org__c == 'OM31')
        {
            salesorg = so5;
            system.debug('so5..'+so5);
            if(salesorg == null)
            {
                salesorg = '';
            }
        }
        else if(q.Sales_Org__c == 'OM34')
        {
            salesorg = so6;
            system.debug('so6..'+so6);
            if(salesorg == null)
            {
                salesorg = '';
            }
        }    
        string quotenumber = q.Quote_Number__c;
        if(quotenumber == null)
        {
            quotenumber = '';
        }
        string soldto = q.Opportunity.Account.SAP_Account_ID__c;
        if(soldto == null)
        {
            soldto = '';
        }
        string shipto = q.Ship_to_Account__r.SAP_Account_ID__c;
        if(shipto == null)
        {
            shipto = '';
        }
        string billto = q.Bill_to_Account__r.SAP_Account_ID__c;
        if(billto == null)
        {
            billto = '';
        }
        string payer = q.Payer__r.SAP_Account_ID__c;
        if(payer == null)
        {
            payer = '';
        }
        string gpoacct = q.GPO_Account__r.SAP_Account_ID__c;
        if(gpoacct == null)
        {
            gpoacct = '';
        }
        string idnacct = q.IDN_Account__r.SAP_Account_ID__c;
        if(idnacct == null)
        {
            idnacct = '';
        }
        string description = q.Name;
        if(description == null)
        {
            description = '';
        }
        string owner = q.Opportunity_Owner__r.Omnicell_Employee_Number__c;
        if(owner == null)
        {
            owner = '';
        }
        else {
            String ownerForm = formatempNum(owner);//Updated by Sravan on March 3rd
            owner = ownerForm;//Updated by Sravan on March 3rd
        }      
        boolean theString = q.Primary_Quote__c;
        String primary = (theString) ? '1' : '0';
        
        string sts = q.Status;
        if(sts == null)
        {
            sts = '';
        }
        
        string crtdate ;
        Date postdte = q.Posting_Date__c;
        if(postdte!=null){
            crtdate = Datetime.newInstance(postdte.year(), postdte.month(),postdte.day()).format('yyyyMMdd');}
        System.debug('crtdate...'+crtdate);
        if(crtdate == null)
        {
            crtdate = '';
        }
        string fromdate;
        Date fromdte = q.From__c;
        if(fromdte !=null){
            fromdate = Datetime.newInstance(fromdte.year(), fromdte.month(),fromdte.day()).format('yyyyMMdd');}
        if(fromdate == null)
        {
            fromdate = '';
        }
        
        decimal totalnet = q.Total_Net__c;
        if(totalnet == null)
        {
            totalnet = 0;
        }
        
        string reqdate;
        Date reqdte = q.Requested_Delivery_Date__c;
        if(reqdte!=null){
            reqdate = Datetime.newInstance(reqdte.year(), reqdte.month(),reqdte.day()).format('yyyyMMdd');}
        if(reqdate == null)
        {
            reqdate = '';
        }
        
        string createby = q.CreatedBy.Omnicell_Employee_Number__c;
        if(createby == null)
        {
            createby = '';
        }
        //IBA-5989 Start Saptarsha Panthi
        string conct;
        if(conlist.size()>0){
        conct  = conlist[0].SAP_Contact_ID__c;
        }
        else
        {
            conct = '';
        }
        //IBA-5989 End Saptarsha Panthi
        string productpo = q.Product_PO_Number__c;
        if(productpo == null)
        {
            productpo = '';
        }
        //IBA-3628 start
        decimal purchsPOAmnt = q.Purchase_PO_Amount__c;
        if(purchsPOAmnt == null)
        {
            purchsPOAmnt = 0;
        }
        String purchsPODate;
        Date prchsPODt = q.Purchase_PO_Date__c;
        if(prchsPODt!=null){
            purchsPODate = Datetime.newInstance(prchsPODt.year(), prchsPODt.month(),prchsPODt.day()).format('yyyyMMdd');
        } else {
            purchsPODate = '';
        } //IBA-3628 end
        string servicepo = q.Service_PO_Number__c;
        if(servicepo == null)
        {
            servicepo = '';
        }
        //IBA-3628 start
        decimal servcPOAmnt = q.Service_PO_Amount__c;
        if(servcPOAmnt == null)
        {
            servcPOAmnt = 0;
        }
        String servcPODate;
        Date srvcPODt = q.Service_PO_Date__c;
        if(srvcPODt!=null){
            servcPODate = Datetime.newInstance(srvcPODt.year(), srvcPODt.month(),srvcPODt.day()).format('yyyyMMdd');
        } else {
            servcPODate = '';
        } 
        String opptyCloseDate;
        Date opptyClsDt = q.Opportunity.CloseDate;
        if(opptyClsDt!=null){
            opptyCloseDate = Datetime.newInstance(opptyClsDt.year(), opptyClsDt.month(),opptyClsDt.day()).format('yyyyMMdd');
        } else {
            opptyCloseDate = '';
        }
        decimal opptyExpBooking = q.Opportunity.Expected_Bookings__c;
        if(opptyExpBooking == null)
        {
            opptyExpBooking = 0;
        } //IBA-3628 end
        
        string bookingdate;
        Date bookd = q.Booking_Date__c;
        if(bookd!=null){
            bookingdate = Datetime.newInstance(bookd.year(), bookd.month(),bookd.day()).format('yyyyMMdd');}
        if(bookingdate == null)
        {
            bookingdate = '';
        }
        
        string termspayment = q.Terms_of_Payment__c;
        if(termspayment == null)
        {
            termspayment = '';
        }
        string curr = q.Currency__c;
        if(curr == null)
        {
            curr = '';
        }
        
        decimal exrate = q.Exchange_Rate__c;
        if(exrate == null)
        {
            exrate = 0;
        }
        string optyid = q.OpportunityId;
        string optydesc = q.Opportunity.Description;
        if(optydesc == null)
        {
            optydesc = '';
        }
        
        string expirationdt;
        Date expired = q.ExpirationDate;
        if(expired !=null){
            expirationdt = Datetime.newInstance(expired.year(), expired.month(),expired.day()).format('yyyyMMdd');
        }
        if(expirationdt == null)
        {
            expirationdt = '';
        }
        
        
        decimal tax = q.Tax;
        if(tax == null)
        {
            tax = 0;
        }
        
        string servicelevel = q.Service_Level__c;
        if(servicelevel == null)
        {
            servicelevel = '';
        }
        
        string district = q.SAP_Sales_Org__r.District__c;
        if(district == null)
        {
            district = '';
        }
        string distributionchanel = q.SAP_Sales_Org__r.Distribution_Channel__c;
        if(distributionchanel == null)
        {
            distributionchanel = '';
        }
        string salesoffice = q.SAP_Sales_Org__r.Sales_Office__c;
        if(salesoffice == null)
        {
            salesoffice = '';
        }
        
        string incoterms1 = q.Incoterms_1__c;
        if(incoterms1 == null)
        {
            incoterms1 = '';
        }
        
        //Pavan New IVX-Requirement
        String salesOrder = q.Associated_Sales_Order__c != null ? q.Associated_Sales_Order__c : '';
        String associatedOpportunityNumber = q.Associated_Opportunity_Number__c != null ? q.Associated_Opportunity_Number__c : '';
        String OpportunityId = q.Opportunity_ID__c != null ? q.Opportunity_ID__c : '';
        Boolean adopterFlag = q.Early_Adopter_Flag__c;
        Decimal residentOperator = q.Resident_Operator_Duration__c;
        
        string oppnumber = q.Opportunity.Opportunity_Number__c;
        //soumyad added sf-bug- 964 & 965 start
        decimal numberbed = q.of_beds__c; 
        decimal prfserv = q.Professional_services_duration__c ; 
        string omnione = q.Omnicell_One_Account_Type__c; 
        string guarantor = q.Guarantor_SAP_Customer_Number__c;
        if(guarantor == null){
            guarantor = '';
        }
        if(omnione == null)
        {
            omnione = '';
        }
        //start IBA-1979 Pabitra
        string pricingRefDateService;
        Date prRefSvc = q.Pricing_Reference_Date_Service__c;
        if(prRefSvc!=null){
            pricingRefDateService = Datetime.newInstance(prRefSvc.year(), prRefSvc.month(),prRefSvc.day()).format('yyyyMMdd');}
        System.debug('pricingrefdateserv...'+pricingRefDateService); 
        if(pricingRefDateService == null)
        {
            pricingRefDateService = '';
        }
        //end IBA-1979 Pabitra
        
        //soumyad added sf-bug- 964 & 965 end
        try{
            system.debug('in try...');
            if(quotename != '' && q.Quote_Number__c == null )
            {
                system.debug('quotename123..'+quotename);
                //Added by Rajat to fix SF-BUG-393
                Map<String, Object> jsondata = new Map<String, Object>{
                    'Guarantor' => guarantor,
                        'Print-currency' => print_cur,
                        'Print-exchange' => print_rate,
                        'Supplement Generated' => supplementGenerated,
                        'Milestone Inv. Term' => mileStoneTerm,
                        'Sold-to' => soldto,
                        'Ship-to' => shipto,
                        'Bill-to' => billto,
                        'Payer' => payer,
                        'GPO Account' => gpoacct,
                        'IDN Account' => idnacct,
                        'Supplement' => supplement1,
                        'Description' => description,
                        'Owner' => owner,
                        'Primary' => primary,
                        'Status' => sts,
                        'Posting Date' => crtdate,
                        'Total Net value' => totalnet,
                        'Requested Delivery Date' => reqdate,
                        'SSM/RD' => ssm,
                        'Special Pricing Code' => specialpricecode,
                        'Valid from' => fromdate,
                        'Valid to' => expirationdt,
                        'Created By' => createby,
                        'Shipping Contact' => conct,
                        'Master Agreement' => master,
                        'SAP Quote ID' => quotenumber,
                        'Tax Amount' => tax,
                        'Product PO number' => productpo,   
                        'Purchase PO Amount' => purchsPOAmnt, //IBA-3628
                        'Purchase PO Date' => purchsPODate,
                        'Service PO Number' => servicepo,
                        'Service PO Amount' => servcPOAmnt,
                        'Service PO Date' => servcPODate, 
                        'OPP_CLOSEDATE' => opptyCloseDate,
                        'OPP_EXP_BOOKING' => opptyExpBooking,
                        'Booking Date' => bookingdate,
                        'Payment Terms' => termspayment,
                        'Currency' => curr,
                        'Exchange Rate' => exrate,
                        'SF Quote Id' => sfquoteid,
                        'Quote Type' => ordertype,
                        'Lease Duration' => leaseduration,
                        'Free Month for Lease' => freemonthlease,
                        'Service Duration' => service,
                        'Subscription Months' => subMonths,
                        'Free Service Months' => freemonthservice,
                        'Pricing Date' => pricingrefdate,
                        'Default IDN Price List' => idn,
                        'Default GPO Price List' => gpo,
                        'IncoTerms1' => IncoTerms1,
                        'Shipping Conditions' => shipcondition,
                        'Sales Organization ' => salesorg,
                        'Service Level' => servicelevel,
                        'Sales District' => district,
                        ' Distribution Channel' => distributionchanel,
                        'Sales Office' => salesoffice,
                        'IncoTerms2' => inco,
                        'Hospital Contact Notes' => hospitalnote,
                        'Inv Text Notes' => invtext,
                        'Quote Printout Standard Text' => quoteprinttext,
                        'Other Notes' => othernote,
                        'Quote Text' => quotetext,
                        'Special Instructions' => specialinstruction,
                        'Sales Ops Notes' => salesops,
                        'SF Opportunity Number' => oppnumber,
                        'number of bed' => numberbed, //added soumyad sf-bug- 964 & 965
                        'Professional services duration' => prfserv, //added soumyad sf-bug- 964 & 965
                        'omnione' => omnione, //soumyad added sf-bug- 964 & 965
                        'Associated Opportunity Number' => associatedOpportunityNumber,//added Pavan new IVX requirement
                        'Opportunity ID' => OpportunityId,
                        'Associated Sales Order' => salesOrder,//added Pavan new IVX requirement
                        'Early Adopter Flag' => adopterFlag, //added Pavan new IVX requirement
                        'Resident Operator Duration' => residentOperator, //added Pavan new IVX requirement
                        '3rd Deal Rating Spread' => q.X3rd_Deal_Rating_Spread__c == null? 0: q.X3rd_Deal_Rating_Spread__c,
                            '3rd Party Interest Rate' => q.X3rd_Party_Interest_Rate__c == null? 0: q.X3rd_Party_Interest_Rate__c,
                                'In House Interest Rate' => q.In_House_Interest_Rate__c == null? 0: q.In_House_Interest_Rate__c,
                                    'Rebate Amount' => q.Rebate_Amount__c == null? 0: q.Rebate_Amount__c,
                                        'PRICING_DATE_SRV' => pricingRefDateService, //IBA-1979 Pabitra
                                        'OPPORTUNITY_TYPE' => q.Opportunity.Opportunity__c //IBA-2802    
                                        };
                                            //Added by Rajat to fix SF-BUG-393
                                            jsonstr = JSON.serialize(jsondata);
                system.debug('jsonstr...'+jsonstr);
            }
            Http h= new Http();
            HttpRequest req= new HttpRequest();
            req.setHeader('Content-Type','application/json');
            req.setHeader('accept','application/json');
            req.setBody(jsonstr);
            req.setMethod('POST');
            req.setEndpoint(endPoint);
            req.setTimeout(120000); 
            HttpResponse res=h.send(req);
            responseString = res.getBody();
            System.debug(responseString+'###responseString');
            
            if(res.getStatusCode() == 200){
                system.debug('res.getBody()..'+res.getBody());
            }
            
            if(res.getstatusCode() != 200){
                system.debug('errorbody..'+res.getBody());
                system.debug('errorstatus..'+res.getStatus());
                
                errormsg = res.getStatus();
                system.debug('errormsg..'+errormsg);
                if(errormsg!=null){
                    system.debug('callingclass..');
                    ErrorLogging.IntegrationLog(errormsg, 'callOutMethodInsert','App');
                }
                
            }   
        }
        catch(Exception e){
            System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
            ErrorLogging.Log(e, 'callOutMethodInsert','App');
        }         
    }
    
    Public static String formatempNum(String empno){
        String[] emp = empno.split('');
        System.debug('emp array : '+emp);
        Integer empsize = 0;
        if(emp.size()<8)
            empsize = 8-emp.size();
        
        String retStr = 'HR';
        Integer j = 0;
        for(j=0;j<empsize;j++){
            retStr = retStr+'0';
        }
        for(j=0;j<emp.size();j++){
            retStr = retStr+emp[j];
        }
        return retStr;
    }
    
    
    @future(callout=true)   
    public static void callOutMethodUpdate(set<Id> quoteIds, Map<string,String> qtOrderTypechangeMap){ //IBA-3929
        CastIronIntegration__c csValue1 = CastIronIntegration__c.getInstance('CastIronIntegration');
        String endpoint = csValue1.QuoteHeaderUpdateEndpoint__c; 
        
        ECC_Sales_Org_to_CRM__c csValue2 = ECC_Sales_Org_to_CRM__c.getInstance('AU SalesOrg Omnicell');
        String so1 = csValue2.CRM_Code__c; 
        system.debug('so1...'+so1);
        
        ECC_Sales_Org_to_CRM__c csValue3 = ECC_Sales_Org_to_CRM__c.getInstance('MACH4 - GmbH');
        String so2 = csValue3.CRM_Code__c; 
        system.debug('so2...'+so2);
        
        ECC_Sales_Org_to_CRM__c csValue4 = ECC_Sales_Org_to_CRM__c.getInstance('Omnicell - St.Petes');
        String so3 = csValue4.CRM_Code__c; 
        system.debug('so3...'+so3);
        
        ECC_Sales_Org_to_CRM__c csValue5 = ECC_Sales_Org_to_CRM__c.getInstance('Omnicell Inc.');
        String so4 = csValue5.CRM_Code__c; 
        system.debug('so4...'+so4);
        
        ECC_Sales_Org_to_CRM__c csValue6 = ECC_Sales_Org_to_CRM__c.getInstance('Omnicell Ltd');
        String so5 = csValue6.CRM_Code__c; 
        system.debug('so5...'+so5);
        
        ECC_Sales_Org_to_CRM__c csValue7 = ECC_Sales_Org_to_CRM__c.getInstance('Omnicell SAS');
        String so6 = csValue7.CRM_Code__c; 
        system.debug('so6...'+so6);
        
        set<Id> sapid = new set<Id>();
        String quotename='';
        String jsonstr ='';
        String quoteid ='';
        string opid ='';
        string accid ='';
        string salesorgid = '';
        String SapQuoteNumber = '';
        string errormsg ='';
        string salesorg ='';
        string responseString = '';
        string saperror ='';
        List<Quote> qteList = new List<Quote>();
        
        Quote [] quoteList = [SELECT Id,Posting_Date__c,SAP_Sales_Org__r.Incoterms_1__c,Supplement1__c,From__c,Service_Level__c,Contact.SAP_Contact_ID__c,
                              OwnerId,Hospital_Contact_Notes__c,Inv_Text_Notes__c,Quote_Printout_Standard_Text__c,Other_Notes__c,GPO_Account__c,GPO_Account__r.SAP_Account_ID__c,IDN_Account__c,IDN_Account__r.SAP_Account_ID__c,
                              Quote_Text__c,Special_Instructions__c,Sales_Ops_Notes__c,Opportunity_Owner__r.Omnicell_Employee_Number__c,
                              Consultant__r.Omnicell_Employee_Number__c,SSM_RD__r.Omnicell_Employee_Number__c,Print_Currency__c, Print_Exchange_Rate__c,
                              Sales_Operation_Counterpart__r.Omnicell_Employee_Number__c,CreatedBy.Omnicell_Employee_Number__c,
                              Supplement__c,Opportunity.Account.Pricing_Code__c,Opportunity.Account.Special_Pricing_Code__c,Tax,
                              Opportunity.AccountId,Opportunity.Account.SAP_Account_ID__c,Name,Notes__c,ExpirationDate,SAP_Sales_Org__c,
                              SAP_Sales_Org__r.Incoterms_2__c,SAP_Sales_Org__r.Distribution_Channel__c,SAP_Sales_Org__r.Sales_Office__c,SAP_Sales_Org__r.Service_Level__c,
                              SAP_Sales_Org__r.District__c,Bill_to_Account__r.SAP_Account_ID__c,Ship_to_Account__r.SAP_Account_ID__c,
                              Terms_of_Payment__c,Currency__c,Exchange_Rate__c,Requested_Delivery_Date__c,Product_PO_Number__c,
                              Booking_Date__c,Service_PO_Number__c,CreatedById,Shipping_Contact__c,OpportunityId,Opportunity.Description,
                              Primary_Quote__c,Status,CreatedDate,Total_Net__c,Opportunity_Owner__c, ShippingAddress,BillingAddress,
                              Payer__r.SAP_Account_ID__c,Description,Order_Type__c,Quote_Number__c,LineItemCount,Master_Agreement__c,
                              Lease_Duration__c,Free_Month_for_Lease__c,Service_Duration__c,subscription_Months__c,Free_Month_Service__c,
                              Pricing_Reference_Date__c,IDN_Price_List__c,GPO_Price_Lists__c,Incoterms_1__c,Incoterms_2__c,
                              Shipping_Conditions__c,Sales_Org__c,Quote_Type_Changed__c,Opportunity.Opportunity_Number__c,Supplement_Generated__c,
                              Milestone_Invoice_Term__c,of_beds__c,Professional_services_duration__c,Omnicell_One_Account_Type__c,
                              X3rd_Deal_Rating_Spread__c, X3rd_Party_Interest_Rate__c, In_House_Interest_Rate__c, Rebate_Amount__c,Guarantor_SAP_Customer_Number__c,
                              Associated_Sales_Order__c,Associated_Opportunity_Number__c,Early_Adopter_Flag__c,Opportunity_ID__c,Resident_Operator_Duration__c,Pricing_Reference_Date_Service__c,Opportunity.Opportunity__c,
                              Purchase_PO_Amount__c,Purchase_PO_Date__c,Service_PO_Amount__c,Service_PO_Date__c,Opportunity.CloseDate,
                              Opportunity.Expected_Bookings__c 
                              FROM Quote WHERE Id IN:quoteIds]; //IBA-3929 - Sourav
        //IBA-4179 Start  
        Set<Id>contactIds = new Set<Id>();
        for(Quote q:quoteList){
            contactIds.add(q.Shipping_Contact__c);
        }
        List<Map<String,Object>> jsonArrayData = new List<Map<String,Object>>();
        //IBA-5989 Start Saptarsha Panthi
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        If(contactIds.size()>0){
        contactMap = new Map<Id,Contact>([select Id, SAP_Contact_ID__c from Contact Where Id IN:contactIds]);
        }
        //IBA-5989 End Saptarsha Panthi
        for(Quote q:quoteList){          //IBA-4179 End  
            String cid = q.Shipping_Contact__c;
            Contact c = contactMap.get(cid);   //IBA-4179  Sourav       
            // soumyad start IBA-1199
            string print_cur = q.Print_Currency__c;
            if(print_cur == null){
                print_cur ='';
            }
            Decimal print_rate = q.Print_Exchange_Rate__c;
            if(print_rate == null){
                print_rate = 0.0;
            }
            // soumyad end IBA-1199
            string sfquoteid = q.Id;
            
            string hospitalnote = q.Hospital_Contact_Notes__c;
            if(hospitalnote == null){
                hospitalnote ='';
            }
            string invtext= q.Inv_Text_Notes__c;
            if(invtext == null){
                invtext ='';
            }
            string quoteprinttext= q.Quote_Printout_Standard_Text__c;
            if(quoteprinttext == null){
                quoteprinttext ='';
            }             
            string othernote = q.Other_Notes__c ;
            if(othernote == null){
                othernote ='';
            }
            string quotetext= q.Quote_Text__c;
            if(quotetext == null){
                quotetext ='';
            }            
            string specialinstruction = q.Special_Instructions__c;
            if(specialinstruction == null){
                specialinstruction ='';
            }            
            string salesops = q.Sales_Ops_Notes__c;
            if(salesops == null){
                salesops ='';
            }            
            string consultant = q.Consultant__r.Omnicell_Employee_Number__c;
            if(consultant == null){
                consultant ='';
            }
            else {                
                String consultantForm = formatempNum(consultant);//Updated by Sravan on March 3rd
                consultant = consultantForm;//Updated by Sravan on March 3rd                
            }        
            string ssm = q.SSM_RD__r.Omnicell_Employee_Number__c;
            if(ssm == null){
                ssm ='';
            }
            else {
                String ssm1 = formatempNum(ssm);//Updated by Sravan on March 3rd
                ssm = ssm1; //Updated by Sravan on March 3rd
            }            
            string salesoperationcounter = q.Sales_Operation_Counterpart__r.Omnicell_Employee_Number__c;
            if(salesoperationcounter == null){
                salesoperationcounter ='';
            } 
            else {
                String salesopcounter1 = formatempNum(salesoperationcounter);//Updated by Sravan on March 3rd
                salesoperationcounter = salesopcounter1;//Updated by Sravan on March 3rd
            }           
            string specialpricecode = q.Opportunity.Account.Special_Pricing_Code__c;
            if(specialpricecode == null){
                specialpricecode ='';
            } 
            string supplement1 = q.Supplement1__c;
            if(supplement1 == null){
                supplement1 =''; 
            }            
            string supplement = q.Supplement__c;
            if(supplement == null){
                supplement ='';
            }
            
            string ordertype = q.Order_Type__c;
            if(ordertype == null){
                ordertype ='';
            }
            string master = q.Master_Agreement__c;
            if(master == null){
                master ='';
            }
            decimal leaseduration = q.Lease_Duration__c;
            if(leaseduration == null){
                leaseduration = 0;
            }
            decimal freemonthlease = q.Free_Month_for_Lease__c;
            if(freemonthlease == null){
                freemonthlease = 0;
            }
            decimal service = q.Service_Duration__c;
            if(service == null){
                service =0;
            }
            decimal subMonths = q.subscription_Months__c;
            if(subMonths == null){
                subMonths =0;
            }
            decimal freemonthservice = q.Free_Month_Service__c;
            if(freemonthservice == null){
                freemonthservice = 0;
            }            
            string pricingrefdate;
            Date prref = q.Pricing_Reference_Date__c;
            if(prref!=null){
                pricingrefdate = Datetime.newInstance(prref.year(), prref.month(),prref.day()).format('yyyyMMdd');
            }
            if(pricingrefdate == null){
                pricingrefdate = '';
            }
            string idn = q.IDN_Price_List__c;
            if(idn == null){
                idn = '';
            }
            string gpo = q.GPO_Price_Lists__c;
            if(gpo == null){
                gpo = 'XX';
            }
            string inco = q.Incoterms_2__c;
            if(inco == null){
                inco = '';
            }
            string shipcondition = q.Shipping_Conditions__c;
            if(shipcondition == null){
                shipcondition = '';
            }
            if(q.Sales_Org__c == 'AU01'){
                salesorg = so1;
                if(salesorg == null){
                    salesorg = '';
                }
            } 
            else if(q.Sales_Org__c == 'OM32'){
                salesorg = so2;
                if(salesorg == null){
                    salesorg = '';
                }
            }
            else if(q.Sales_Org__c == 'OM01'){
                salesorg = so4;
                if(salesorg == null){
                    salesorg = '';
                }
            }  
            else if(q.Sales_Org__c == 'OM31'){
                salesorg = so5;
                if(salesorg == null){
                    salesorg = '';
                }
            }
            else if(q.Sales_Org__c == 'OM34'){
                salesorg = so6;
                if(salesorg == null){
                    salesorg = '';
                }
            }    
            string quotenumber = q.Quote_Number__c;
            if(quotenumber == null){
                quotenumber = '';
            }
            string soldto = q.Opportunity.Account.SAP_Account_ID__c;
            if(soldto == null){
                soldto = '';
            }
            string shipto = q.Ship_to_Account__r.SAP_Account_ID__c;
            if(shipto == null){
                shipto = '';
            }
            string billto = q.Bill_to_Account__r.SAP_Account_ID__c;
            if(billto == null){
                billto = '';
            }
            string payer = q.Payer__r.SAP_Account_ID__c;
            if(payer == null){
                payer = '';
            }
            string gpoacct = q.GPO_Account__r.SAP_Account_ID__c;
            if(gpoacct == null){
                gpoacct = '';
            }
            string idnacct = q.IDN_Account__r.SAP_Account_ID__c;
            if(idnacct == null){
                idnacct = '';
            }
            string description = q.Name;
            if(description == null){
                description = '';
            }
            string owner = q.Opportunity_Owner__r.Omnicell_Employee_Number__c;
            if(owner == null){
                owner = '';
            }
            else {
                String ownerForm = formatempNum(owner);//Updated by Sravan on March 3rd
                owner = ownerForm;//Updated by Sravan on March 3rd
            }               
            boolean theString = q.Primary_Quote__c;
            String primary = (theString) ? '1' : '0';
            string sts = q.Status;
            if(sts == null){
                sts = '';
            }
            string crtdate ;
            Date postdte = q.Posting_Date__c;
            
            if(postdte!=null){
                crtdate = Datetime.newInstance(postdte.year(), postdte.month(),postdte.day()).format('yyyyMMdd');
            }
            if(crtdate == null){
                crtdate = '';
            }
            string fromdate;
            Date fromdte = q.From__c;
            if(fromdte !=null){
                fromdate = Datetime.newInstance(fromdte.year(), fromdte.month(),fromdte.day()).format('yyyyMMdd');
            }
            
            if(fromdate == null){
                fromdate = '';
            }
            
            decimal totalnet = q.Total_Net__c;
            if(totalnet == null){
                totalnet = 0;
            }
            string reqdate;
            Date reqdte = q.Requested_Delivery_Date__c;
            if(reqdte!=null){
                reqdate = Datetime.newInstance(reqdte.year(), reqdte.month(),reqdte.day()).format('yyyyMMdd');
            }
            if(reqdate == null){
                reqdate = '';
            }
            string createby = q.CreatedBy.Omnicell_Employee_Number__c;
            if(createby == null){
                createby = '';
            }
            //IBA-5989 Start Saptarsha Panthi
            string conct=null;
            if(c!=null){
            conct = c.SAP_Contact_ID__c;//IBA-4179 Sourav
            }
            else{ 
                conct = '';
            }
            //IBA-5989 End Saptarsha Panthi
            string productpo = q.Product_PO_Number__c;
            if(productpo == null){
                productpo = '';
            } 
            //IBA-3628 start
            decimal purchsPOAmnt = q.Purchase_PO_Amount__c;
            if(purchsPOAmnt == null){
                purchsPOAmnt = 0;
            }
            String purchsPODate;
            Date prchsPODt = q.Purchase_PO_Date__c;
            if(prchsPODt!=null){
                purchsPODate = Datetime.newInstance(prchsPODt.year(), prchsPODt.month(),prchsPODt.day()).format('yyyyMMdd');
            } 
            else {
                purchsPODate = '';
            } //IBA-3628 end
            string servicepo = q.Service_PO_Number__c;
            if(servicepo == null){
                servicepo = '';
            }
            //IBA-3628 start
            decimal servcPOAmnt = q.Service_PO_Amount__c;
            if(servcPOAmnt == null){
                servcPOAmnt = 0;
            }
            String servcPODate;
            Date srvcPODt = q.Service_PO_Date__c;
            if(srvcPODt!=null){
                servcPODate = Datetime.newInstance(srvcPODt.year(), srvcPODt.month(),srvcPODt.day()).format('yyyyMMdd');
            } 
            else {
                servcPODate = '';
            } 
            String opptyCloseDate;
            Date opptyClsDt = q.Opportunity.CloseDate;
            if(opptyClsDt!=null){
                opptyCloseDate = Datetime.newInstance(opptyClsDt.year(), opptyClsDt.month(),opptyClsDt.day()).format('yyyyMMdd');
            } 
            else {
                opptyCloseDate = '';
            }
            decimal opptyExpBooking = q.Opportunity.Expected_Bookings__c;
            if(opptyExpBooking == null){
                opptyExpBooking = 0;
            }//IBA-3628 end
            string bookingdate;
            Date bookd = q.Booking_Date__c;
            if(bookd!=null){
                bookingdate = Datetime.newInstance(bookd.year(), bookd.month(),bookd.day()).format('yyyyMMdd');
            }
            if(bookingdate == null){
                bookingdate = '';
            }
            string supplementGenerated= q.Supplement_Generated__c;
            if(supplementGenerated  == null){
                supplementGenerated = '';
            }
            string mileStoneTerm = q.Milestone_Invoice_Term__c ;
            if(mileStoneTerm  == null){
                mileStoneTerm = '';
            }
            string termspayment = q.Terms_of_Payment__c;
            if(termspayment == null){
                termspayment = '';
            }
            string curr = q.Currency__c;
            if(curr == null){
                curr = '';
            }
            decimal exrate = q.Exchange_Rate__c;
            if(exrate == null){
                exrate = 0;
            }
            string optyid = q.OpportunityId;
            string optydesc = q.Opportunity.Description;
            if(optydesc == null){
                optydesc = '';
            }
            
            string expirationdt;
            Date expired = q.ExpirationDate;
            if(expired !=null){
                expirationdt = Datetime.newInstance(expired.year(), expired.month(),expired.day()).format('yyyyMMdd');
            }
            if(expirationdt == null){
                expirationdt = '';
            }
            decimal tax = q.Tax;
            if(tax == null){
                tax = 0;
            }
            string servicelevel = q.Service_Level__c;
            if(servicelevel == null){
                servicelevel = '';
            }
            
            string district = q.SAP_Sales_Org__r.District__c;
            if(district == null){
                district = '';
            }
            string distributionchanel = q.SAP_Sales_Org__r.Distribution_Channel__c;
            
            if(distributionchanel == null){
                distributionchanel = '';
            }
            string salesoffice = q.SAP_Sales_Org__r.Sales_Office__c;
            if(salesoffice == null){
                salesoffice = '';
            }          
            string incoterms1 = q.Incoterms_1__c;
            if(incoterms1 == null){
                incoterms1 = '';
            }            
            //Pavan Palla New IVX-Requirement            
            String salesOrder = q.Associated_Sales_Order__c != null ? q.Associated_Sales_Order__c : '';
            String associatedOpportunityNumber = q.Associated_Opportunity_Number__c != null ? q.Associated_Opportunity_Number__c : '';
            String OpportunityId = q.Opportunity_ID__c != null ? q.Opportunity_ID__c : '';
            Boolean adopterFlag = q.Early_Adopter_Flag__c;
            Decimal residentOperator = q.Resident_Operator_Duration__c;            
            String qtypechange= qtOrderTypechangeMap.get(q.Id);//(quoteTypeChanged) ? '1' : '0'; //IBA-3929
            system.debug(qtypechange);            
            string oppnumber = q.Opportunity.Opportunity_Number__c;            
            //soumyad added sf-bug- 964 & 965 start
            decimal numberbed = q.of_beds__c; 
            decimal prfserv = q.Professional_services_duration__c ; 
            string omnione = q.Omnicell_One_Account_Type__c; 
            if(omnione == null){
                omnione = '';
            }
            string guarantor = q.Guarantor_SAP_Customer_Number__c;
            if(guarantor == null){
                guarantor = '';
            }            
            //start IBA-1979 Pabitra
            string pricingRefDateService;
            Date prRefSvc = q.Pricing_Reference_Date_Service__c;
            if(prRefSvc!=null){
                pricingRefDateService = Datetime.newInstance(prRefSvc.year(), prRefSvc.month(),prRefSvc.day()).format('yyyyMMdd');
            }
            if(pricingRefDateService == null){
                pricingRefDateService = '';
            }
            //end IBA-1979 Pabitra            
            //soumyad added sf-bug- 964 & 965 end
            if(q.Quote_Number__c!=null){                
                Map<String, Object> jsondata = new Map<String, Object>{
                    // soumayd IBA-1199 start
                    'Guarantor' => guarantor,
                        'Print-currency' => print_cur,
                        'Print-exchange' => print_rate,
                        'SAP Quote Number' => quotenumber,
                        'Sold-to' => soldto,
                        'Ship-to' => shipto,
                        'Bill-to' => billto,
                        'Payer' => payer,
                        'GPO Account' => gpoacct,
                        'IDN Account' => idnacct,
                        'Supplement' => supplement1,
                        'Description' => description,
                        'Owner' => owner,
                        'Primary' => primary,
                        'Status' => sts,
                        'Posting Date' => crtdate,
                        'Total Net value' => totalnet,
                        'Requested Delivery Date' => reqdate,
                        'SSM/RD' => ssm,
                        'Special Pricing Code' => specialpricecode,
                        'Valid from' => fromdate,
                        'Valid to' => expirationdt,
                        'Created By' => createby,
                        'Shipping Contact' => conct,
                        'Master Agreement' => master,
                        'Tax Amount' => tax,
                        'Product PO number' => productpo,
                        'Purchase PO Amount' => purchsPOAmnt,
                        'Purchase PO Date' => purchsPODate,    
                        'Service PO Number' => servicepo,
                        'Service PO Amount' => servcPOAmnt,
                        'Service PO Date' => servcPODate,  
                        'OPP_CLOSEDATE' => opptyCloseDate,
                        'OPP_EXP_BOOKING' => opptyExpBooking,
                        'Booking Date' => bookingdate,
                        'Payment Terms' => termspayment,
                        'Currency' => curr,
                        'Exchange Rate' => exrate,
                        'SF Quote Id' => sfquoteid,
                        'Quote Type' => ordertype ,
                        'Lease Duration' => leaseduration ,
                        'Free Month for Lease' => freemonthlease ,
                        'Service Duration' => service,
                        'Subscription Months' => subMonths,
                        'Free Service Months' => freemonthservice ,
                        'Pricing Date' => pricingrefdate ,
                        'Default IDN Price List' => idn,
                        'Default GPO Price List' => gpo,
                        'IncoTerms1' => IncoTerms1,
                        'Shipping Conditions' => shipcondition ,
                        'Sales Organization ' => salesorg,
                        'Service Level' =>  servicelevel ,
                        'Sales District' =>  district ,
                        ' Distribution Channel' =>  distributionchanel ,
                        'Sales Office' => salesoffice,
                        'IncoTerms2' =>  inco ,
                        'Hospital Contact Notes' => hospitalnote,
                        'Inv Text Notes' => invtext,
                        'Quote Printout Standard Text' => quoteprinttext,
                        'Other Notes' => othernote,
                        'Quote Text' => quotetext,
                        'Special Instructions' => specialinstruction,
                        'Sales Ops Notes' => salesops,
                        'Quote Type Changed' => qtypechange,
                        'SF Opportunity Number' => oppnumber,
                        'Supplement Generated' => supplementGenerated,
                        'Milestone Inv. Term' => mileStoneTerm,
                        'number of bed' => numberbed, //added soumyad sf-bug- 964 & 965
                        'Professional services duration' => prfserv, //added soumyad sf-bug- 964 & 965
                        'omnione' => omnione, //soumyad added sf-bug- 964 & 965                        
                        'Associated Sales Order' => salesOrder,//added Pavan  new IVX requirement
                        'Associated Opportunity Number' => associatedOpportunityNumber, //added Pavan new IVX requirement
                        'Opportunity ID' => OpportunityId,//added Pavan new IVX requirement
                        'Associated Opportunity Number'=> associatedOpportunityNumber,//added Pavan new IVX requirement
                        'Early Adopter Flag' => adopterFlag, //added Pavan new IVX requirement
                        'Resident Operator Duration' => residentOperator, //added Pavan new IVX requirement                        
                        '3rd Deal Rating Spread' => q.X3rd_Deal_Rating_Spread__c == null? 0: q.X3rd_Deal_Rating_Spread__c,
                            '3rd Party Interest Rate' => q.X3rd_Party_Interest_Rate__c == null? 0: q.X3rd_Party_Interest_Rate__c,
                                'In House Interest Rate' => q.In_House_Interest_Rate__c == null? 0: q.In_House_Interest_Rate__c,
                                    'Rebate Amount' => q.Rebate_Amount__c == null? 0: q.Rebate_Amount__c,
                                        'PRICING_DATE_SRV' => pricingRefDateService, //IBA-1979 Pabitra    
                                        'OPPORTUNITY_TYPE' => q.Opportunity.Opportunity__c //IBA-2802
                                        };
                                            //Added by Rajat to fix SF-BUG-393
                                            jsonArrayData.add(jsondata);//IBA-4179
            }//IBA-4179 if
        }//IBA-4179 for loop  
        try{  //IBA-4179 move try        
            String EndPoint1 = endPoint;
            system.debug('EndPoint1...'+EndPoint1 );
            //Added by Rajat to fix SF-BUG-393
            String jsonstrupdate = JSON.serialize(jsonArrayData);  //IBA-4179
            system.debug('jsonupdate...'+jsonstrupdate);
            Http h2= new Http();
            HttpRequest req2= new HttpRequest();
            req2.setHeader('Content-Type','application/json');
            req2.setHeader('accept','application/json');
            req2.setHeader('X-HTTP-METHOD-Override','PATCH');
            req2.setBody(jsonstrupdate);
            req2.setMethod('POST');
            req2.setEndpoint(EndPoint1);
            req2.setTimeout(120000);
            HttpResponse res2=h2.send(req2);
            System.debug(res2+'###123createresp');
            responseString = res2.getBody();
            System.debug(responseString+'###responseString');
            if(res2.getStatusCode() == 200){
                System.debug(res2+'###123createresp');
                system.debug('res2.getBody()..'+res2.getBody());
            }
            
            if(res2.getstatusCode() != 200){
                system.debug('errorbody..'+res2.getBody());
                system.debug('errorstatus..'+res2.getStatus());
                
                errormsg = res2.getStatus();
                system.debug('errormsg..'+errormsg);
                if(errormsg!=null){
                    system.debug('callingclass..');
                    ErrorLogging.IntegrationLog(errormsg, 'callOutMethodUpdate','App');
                }
                
            }    
        }
        catch(Exception e){
            System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
            ErrorLogging.Log(e, 'callOutMethodUpdate','App');
        } 
    }
}