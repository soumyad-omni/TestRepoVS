global class OmniCellBillingAddressController{
    public string companyattn { get; set; } // SCP-763
    public string accountName { get; set; }
    global Transient string accountName2{get;set;}
    global Transient string accountName3{get;set;}
    global Transient string LoggedUserFirstName{get;set;}
    global Transient string  LoggedUserLastName{get;set;}
    global Transient List<Account> accList{get;set;}
    global Transient string accListJSON{get;set;}
    global Transient string defaultRelJSON{get;set;}//IBA-4266
    global Transient string accListBillingJSON{get;set;}
    global Transient Account currentAccount{get;set;}
    global Transient String currentAccountObj{get;set;}
    global Transient String cartshipAccountObj{get;set;}
    global Transient String cccartshipAccountObj{get;set;}
    global boolean newCart{get;set;}
    global boolean attemptcheckout{get;set;}
    global Transient String currentCart{get;set;}//IBA-4134
        
    global OmniCellBillingAddressController(){
        accList = new List<Account>();
        accListJSON = '';
        accListBillingJSON = '';
        try{
              String cartId   = apexpages.currentpage().getparameters().get('cartID');
              ccrz__E_Cart__c  cartObj = [Select Id,New_Cart__c,Order_attempt__c,ccrz__ShipTo__c,Shipping_Company_Name2__c,SAP_Billing_Customer_Number__c,ccrz__Note__c, //IBA-4134
                                          SAP_Shipping_Customer_Number__c,SAP_SOLD_TO__c from ccrz__E_Cart__c where ccrz__EncryptedId__c=:cartId   LIMIT 1];
              currentCart= JSON.serialize(cartObj);
              newCart = cartObj.New_Cart__c ;
              attemptcheckout = cartObj.Order_attempt__c;
              String currEffAcc = apexpages.currentpage().getparameters().get('effectiveAccount');
              User userObj = [Select account.Account_Name2__c,Contact.AccountId from user where id=:UserInfo.getUserId() LIMIT 1];
              if(cartObj.Order_attempt__c == false){
                    currentAccount = [Select Id,PO_BOX__c,Account_Role__c,SAP_Customer_Number__c,Address_Line_2__c,BillingCity,BillingCountryCode,BillingCountry,BillingPostalCode,BillingState,BillingStateCode,Transportation_Zone_Country__c,
                                          BillingStreet,Name,SAP_Account_Id__c,Account_Name2__c from Account where Id =:currEffAcc  LIMIT 1];
                    cartshipAccountObj = JSON.serialize(currentAccount);
                    cccartshipAccountObj = JSON.serialize(currentAccount);
              }
              else{
                    currentAccount = [Select Id,PO_BOX__c,Account_Role__c,SAP_Customer_Number__c,Address_Line_2__c,BillingCity,BillingCountryCode,BillingCountry,BillingPostalCode,BillingState,BillingStateCode,Transportation_Zone_Country__c,
                                          BillingStreet,Name,SAP_Account_Id__c,Account_Name2__c from Account where SAP_Customer_Number__c =:cartObj.SAP_Billing_Customer_Number__c or SAP_Account_Id__c =:cartObj.SAP_Billing_Customer_Number__c  LIMIT 1];
                  
                    account shipcurrentAccount = [Select Id,PO_BOX__c,Account_Role__c,SAP_Customer_Number__c,Address_Line_2__c,BillingCity,BillingCountryCode,BillingCountry,BillingPostalCode,BillingState,BillingStateCode,Transportation_Zone_Country__c,
                                          BillingStreet,Name,SAP_Account_Id__c,Account_Name2__c from Account where SAP_Customer_Number__c =:cartObj.SAP_Shipping_Customer_Number__c or SAP_Account_Id__c =:cartObj.SAP_Shipping_Customer_Number__c  LIMIT 1];
                  
                    cartshipAccountObj = JSON.serialize(shipcurrentAccount);
                  
                    ccrz__E_ContactAddr__c  contactAddressList = [select ccrz__FirstName__c,ccrz__LastName__c,ccrz__HomePhone__c
                                                                        from ccrz__E_ContactAddr__c where id =:cartObj.ccrz__ShipTo__c ];
                  
                    cccartshipAccountObj = JSON.serialize(contactAddressList);
              
              }
              currentAccountObj= JSON.serialize(currentAccount);
              accountName2 = currentAccount.Account_Name2__c;
              accountName3 = cartObj.Shipping_Company_Name2__c;
              LoggedUserFirstName=UserInfo.getFirstname();
              LoggedUserLastName =Userinfo.getLastName();
                // SCP-817 code begins
              Set<String> primAccSet = new Set<String>();
              primAccSet.add(currEffAcc);
              String keyId = currEffAcc;
              String parentId = '';
              do{
                  Account parent = [SELECT ParentId FROM Account WHERE Id = :keyId];
                  parentId = parent.parentId;
                  if (parentId != null){
                      primAccSet.add(parentId);
                      keyId = parentId;
                  }
              } while (parentId != null);
          
              // SCP-817 code ends 
              List<Relationship__c> relationshipList = [Select Id,Relationship__c ,Secondary_Account__c,Default_Partner_Flag__c,
                                                        Secondary_Account__r.X3rd_Party_Leasing_Company__c,Secondary_Account__r.IsDeleted__c,
                                                        Secondary_Account__r.Validation_Status__c from Relationship__c  
                                                        where Primary_Account__c IN :primAccSet   // changed for SCP-817 
                                                           and (Relationship__c ='WE' OR Relationship__c = 'RE')]; //IBA-4266
              system.debug('relationshipList-->'+relationshipList);
              Set<String> accountIds = new Set<String>();
          Set<String> accountIdsTemp = new Set<String>(); //added for IBA-2155
              Set<String> accountIdsBilling = new Set<String>();
              Set<String> accountIdsBillingTemp = new Set<String>(); //added for SCP-766
            Map<String,String> defaultRelMap = new Map<String,String>();//IBA-4266
              for(Relationship__c relationObj : relationshipList){
                  if(relationObj.Secondary_Account__c != null){
                    String value = ' ';   //IBA-4266                
                    if(relationObj.Relationship__c == 'WE'){ //ship to party
                        if(relationObj.Secondary_Account__r.IsDeleted__c != true && relationObj.Secondary_Account__r.Validation_Status__c != 'Invalid'){ //IBA-4266-Start
                            String key = 'defaultshipTo'+relationObj.Secondary_Account__c;
                            if(relationObj.Default_Partner_Flag__c == True){
                                value = 'Default';
                            }
                            if(defaultRelMap.get(key) != 'Default'){
                                defaultRelMap.put(key,value);		
                            }
                        }  //IBA-4266-End                        
                        accountIdsTemp.add(relationObj.Secondary_Account__c);
                    }else{
                        if(relationObj.Secondary_Account__r.X3rd_Party_Leasing_Company__c != 'X' && relationObj.Secondary_Account__r.IsDeleted__c != true 
                           && relationObj.Secondary_Account__r.Validation_Status__c != 'Invalid'){ //IBA-4266-Start
                            String key = 'defaultbillTo'+relationObj.Secondary_Account__c;
                            if(relationObj.Default_Partner_Flag__c == True){
                                value = 'Default';
                            }
                            if(defaultRelMap.get(key) != 'Default'){
                                defaultRelMap.put(key,value);		
                            }
                        }//IBA-4266-End
                        accountIdsBillingTemp.add(relationObj.Secondary_Account__c);
                    }
                }
            }
            defaultRelJSON = JSON.serializePretty(defaultRelMap);//IBA-4266 
              List<Account> billingAccList = [select id from Account where X3rd_Party_Leasing_Company__c != 'X' and IsDeleted__c != true and Validation_Status__c != 'Invalid' and id in :accountIdsBillingTemp]; //SCP-766 begins. Added isDeleted and Validation status for IBA-2155
              for (Account acctBilling : billingAccList)
                  accountIdsBilling.add(acctBilling.id); //SCP-766 ends
          
        List<Account> shippingAccList = [select id from Account where IsDeleted__c != true and Validation_Status__c != 'Invalid' and id in :accountIdsTemp]; //IBA-2155 begins. 
          for (Account acctShipping : shippingAccList)
              accountIds.add(acctShipping.id); //IBA-2155 ends
      
              if(accountIds.size() > 0){
                    accList = [Select Id,PO_BOX__c,Account_Role__c,Address_Line_2__c,BillingCity,BillingCountryCode,BillingCountry,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,Name,SAP_Account_Id__c,
                               Account_Name2__c,(Select Id,SAP_Contact_Number__c,Name,SAP_Contact_ID__c from Contacts ) from Account where Id in:accountIds
                              or id = : currEffAcc];
                  
                   accListJSON = JSON.serializePretty(accList);
              }
              else{
                   for(Account acc:[Select Id,PO_BOX__c,Account_Role__c,Address_Line_2__c,BillingCity,BillingCountryCode,BillingCountry,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,Name,SAP_Account_Id__c,
                                   Account_Name2__c,(Select Id,SAP_Contact_Number__c,Name,SAP_Contact_ID__c from Contacts ) from Account where  
                                   id = : currEffAcc]){
                                   accList.add(acc);
                   }
                    /*accList = [Select Id,PO_BOX__c,Account_Role__c,Address_Line_2__c,BillingCity,BillingCountryCode,BillingCountry,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,Name,SAP_Account_Id__c,
                                   Account_Name2__c,(Select Id,SAP_Contact_Number__c,Name,SAP_Contact_ID__c from Contacts ) from Account where  
                                   id = : currEffAcc]; */
                      
                    accListJSON = JSON.serializePretty(accList);   
              }
         
              if(accountIdsBilling.size() > 0){
                    accList = [Select Id,PO_BOX__c,Account_Role__c,Address_Line_2__c,BillingCity,BillingCountryCode,BillingCountry,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,Name,SAP_Account_Id__c,Account_Name2__c,(Select Id,SAP_Contact_Number__c,Name,SAP_Contact_ID__c from Contacts)
                               from Account where Id in : accountIdsBilling   or id = : currEffAcc];  
                  accListBillingJSON = JSON.serializePretty(accList);
              }
              else{
                  accList = [Select Id,PO_BOX__c,Account_Role__c,Address_Line_2__c,BillingCity,BillingCountryCode,BillingCountry,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,Name,SAP_Account_Id__c,Account_Name2__c,(Select Id,SAP_Contact_Number__c,Name,SAP_Contact_ID__c from Contacts)
                               from Account where  id = : currEffAcc];  
                  accListBillingJSON = JSON.serializePretty(accList);
              }
              ccrz.ccLog.log(System.LoggingLevel.DEBUG,'accListJSON',accList);
              ccrz.ccLog.log(System.LoggingLevel.DEBUG,'accListBillingJSON',accListBillingJSON);
          }
          catch(Exception e){
                 ccrz.ccLog.log(System.LoggingLevel.DEBUG,'exception in constructer',e.getMessage() + '--'+e.getLineNumber());
        }
  
  }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getContactAddressContactList(ccrz.cc_RemoteActionContext ctx,String contactId){
         ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
         ccRemoteActionResult.success = false;  
         Map<String,object> outputMap= new Map<String,Object>();
        try{
            String accountId = '';
            if(String.isNotBlank(contactId)){
                List<Contact> currentContact = [Select Id,AccountId,SAP_Contact_Number__c from contact where SAP_Contact_Number__c=:contactId];
                if(currentContact.isEmpty()){
                        accountId = ccrz.cc_CallContext.effAccountId;
                }else{
                    accountId = currentContact[0].AccountId;
                }
            }
            else{
                accountId = ccrz.cc_CallContext.effAccountId;
            }
            List<contact> contactList = [Select Id,AccountId,Name,SAP_Contact_Number__c from Contact where AccountId=:accountId order by Name asc ]; //Order by added for B2B-33
            List<contact> defaultContactList = [Select Id,AccountId,Name,SAP_Contact_Number__c from Contact where AccountId=:ccrz.cc_CallContext.effAccountId order by Name asc]; //Order by added for B2B-33
            ccRemoteActionResult.success = true; 
            outputMap.put('contactList',contactList); 
            outputMap.put('defaultContactList',defaultContactList); 
        }
        catch(Exception e) {
            ccRemoteActionResult.success = false; 
        }
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    
   @RemoteAction
    global static ccrz.cc_RemoteActionResult updateCartCustomFields (ccrz.cc_RemoteActionContext ctx,String contactData, string companyattn, string billcsn, String cartItemData){ // SCP-763//IBA-3736
         ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
         ccRemoteActionResult.success = false;  
         Map<String,object> outputMap= new Map<String,Object>();
         Map<String,object> contactDataMap = (Map<String, Object>)JSON.deserializeUntyped(contactData);
         List<object> cartItemDataMap = (List<Object>)JSON.deserializeUntyped(cartItemData);//IBA-3736
         Map<String,String> cartItemMap = new Map<String,String>();//IBA-3736
         
         outputMap.put('isUpdated',false);
         String cartId = ccrz.cc_CallContext.currCartId; 
         outputMap.put('currentCart',cartId ); 
            if(cartItemDataMap.size()>0){//IBA-3736
                for(Object obj:cartItemDataMap){
                     Map<String,Object> data = (Map<String,Object>)obj;
                     cartItemMap.put((String)data.get('ItemNumber'), (String)data.get('Date'));
                 }
                 updateCartItemDeliveryDate(cartItemMap,cartId);
            }
         
         List<Contact> cons = new list<contact>(); 
         List<account> acc  = new list<account>(); 
        string contsapid = null;
        string contid = null;
        try{
            ccrz__E_Cart__c  cartObj = [Select Id,New_Cart__c ,ccrz__ShipAmount__c,ccrz__ShipMethod__c,ccrz__TaxAmount__c,SAP_Billing_Company_Name2__c,ccrz__EffectiveAccountID__c, SAP_Billing_Customer_Number__c,SAP_CONTACT_ID__c,Shipping_Company_Name2__c,
                                        ccrz__Account__r.SAP_Account_ID__c,Attn__c,ccrz__BillTo__c,SAP_SOLD_TO__c, // SCP-763
                                        SAP_Shipping_Customer_Number__c  from ccrz__E_Cart__c where ccrz__EncryptedId__c=:cartId   LIMIT 1];
            
            ccrz__E_ContactAddr__c  contactAddressList = [select ccrz__CompanyName__c,Id,NewFirstName__c,SAP_Customer_Number__c,Company_Name_2__c,SAP_Contact_ID__c,ccrz__StateISOCode__c,ccrz__State__c 
                                                                from ccrz__E_ContactAddr__c
                                                                   where id =:cartObj.ccrz__BillTo__c  ];
            
            acc = [select id,PO_BOX__c,Account_Role__c,SAP_Account_ID__c,Address_Line_2__c,BillingCity,BillingCountryCode,BillingCountry,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,Name,
                   Transportation_Zone_Country__c,Account_Name2__c from account where SAP_Customer_Number__c =:billcsn or SAP_Account_Id__c =:billcsn];    
             system.debug('## cartObj --'+cartObj.id);
             
            
            if(acc.size()>0){
                cartObj.SAP_SOLD_TO__c = cartObj.ccrz__Account__r.SAP_Account_ID__c ;
                contactAddressList.ccrz__CompanyName__c = acc[0].name;
                contactAddressList.ccrz__AddressFirstline__c =acc[0].BillingStreet;
                    contactAddressList.ccrz__AddressSecondline__c =(string)contactDataMap.get('billAddress2');
                    contactAddressList.ccrz__AddressThirdline__c =acc[0].PO_BOX__c;
                    contactAddressList.ccrz__CountryISOCode__c =acc[0].Transportation_Zone_Country__c;
                    contactAddressList.ccrz__City__c =acc[0].BillingCity;
                    contactAddressList.ccrz__PostalCode__c =acc[0].BillingPostalCode;
                    contactAddressList.ccrz__Country__c =acc[0].BillingCountry;
                    contactAddressList.ccrz__StateISOCode__c=acc[0].BillingStateCode;
                    contactAddressList.ccrz__State__c = acc[0].BillingState;
                update contactAddressList;
            }
                
            
             system.debug('## conactis --'+contactDataMap.get('contactId')); 
            //system.debug('## cartObj.SAP_SOLD_TO__c --'+ cartObj.SAP_SOLD_TO__c );
            // SCP-763 start
            if(companyattn != null){
                cartObj.Attn__c = companyattn;
            }
            // SCP-763 end
            if( contactDataMap.get('contactId') != null && contactDataMap.get('contactId') != 'undefined'){ 
                contid = (string)contactDataMap.get('contactId') ; 
                 cons = [select SAP_CONTACT_ID__c from contact Where id = :contid or SAP_CONTACT_ID__c =: contid
                        or SAP_Contact_Number__c =: contid ];  
                contsapid = cons[0].SAP_CONTACT_ID__c; 
            } 
             
           if(contsapid != null) 
            cartObj.SAP_CONTACT_ID__c = contsapid ; 
            
            system.debug('##  shippingCustomerNumber--' + contactDataMap.get('shippingCustomerNumber'));
            
            if( ! string.isBlank( (string) contactDataMap.get('shippingCustomerNumber')))
            cartObj.SAP_Shipping_Customer_Number__c = String.valueOf(contactDataMap.get('shippingCustomerNumber'));
            else
            cartObj.SAP_Shipping_Customer_Number__c =  cartObj.SAP_SOLD_TO__c;    
            
             if( ! string.isBlank( (string) contactDataMap.get('billingCustomerNumber')))
            cartObj.SAP_Billing_Customer_Number__c = String.valueOf(contactDataMap.get('billingCustomerNumber'));
            else
            cartObj.SAP_Billing_Customer_Number__c =  cartObj.SAP_SOLD_TO__c;   
            
            
            
            cartObj.Shipping_Company_Name2__c = String.valueOf(contactDataMap.get('shippingcompanyName2'));
            //cartObj.SAP_Billing_Customer_Number__c = String.valueOf(contactDataMap.get('billingCustomerNumber'));
            cartObj.SAP_Billing_Company_Name2__c = String.valueOf(contactDataMap.get('billingcompanyName2'));
            system.debug('###cartObj-- '+cartObj);
            if( ! string.isBlank( (string) contactDataMap.get('shippingMh')))
            cartObj.ccrz__ShipMethod__c = (string) contactDataMap.get('shippingMh');
            if(  (decimal) contactDataMap.get('shipc') != null)
            cartObj.ccrz__ShipAmount__c = (decimal) contactDataMap.get('shipc');
            if(  (decimal) contactDataMap.get('shipc') != null)
            cartObj.ccrz__TaxAmount__c = (decimal) contactDataMap.get('tx');
            update cartObj;
            ccRemoteActionResult.success = true; 
            outputMap.put('isUpdated',true); 
        }
        catch(Exception e) {
            ccrz.ccLog.log(System.LoggingLevel.DEBUG,'exception is ---'+e.getMessage()+e.getLineNumber());
            ccRemoteActionResult.success = false; 
        }
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }

  // SCP-789 start
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getpo (ccrz.cc_RemoteActionContext ctx,String accountName){
         
         ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
         ccRemoteActionResult.success = false;  
         Map<String,object> outputMap= new Map<String,Object>();
         system.debug('##accpo-- '+accountName);
         list<ccrz__E_TransactionPayment__c> po = [select id from ccrz__E_TransactionPayment__c where ccrz__StoredPayment__r.ccrz__AccountNumber__c =: accountName];
        if(po.size()>=1){
            outputMap.put('isUpdated',true);
        }else{
            outputMap.put('isUpdated',false);
        }
        ccRemoteActionResult.success = true;
         
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    // SCP-789 end
    @RemoteAction
    global static ccrz.cc_RemoteActionResult simulate(ccrz.cc_RemoteActionContext ctx){
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        String cartId = ccrz.cc_CallContext.currCartId;
        list<ccrz__E_Cart__c> cartObj= [select Id from ccrz__E_Cart__c where ccrz__EncryptedId__c= :cartId  LIMIT 1];
        Map<String,object> outputMap= new Map<String,Object>();
        system.debug('test ***'+cartId);
        List<ccrz.cc_ctrl_hlpr_ShippingOption> shipList = new List<ccrz.cc_ctrl_hlpr_ShippingOption>();
        list<string> tax = new list<string>();
        List<String> drugsNonExistinSAP = new List<String>();//IBA-3736
        List<SCP_OrderSimulate_Res_Parser.ET_ITEMLIST> ITEMLIST = new list<SCP_OrderSimulate_Res_Parser.ET_ITEMLIST>(); //iba-2669
        List<SCP_OrderSimulate_Res_Parser.ET_ITEM_DELIVERY_DATES> ET_ITEM_DELIVERY_DATES = new list<SCP_OrderSimulate_Res_Parser.ET_ITEM_DELIVERY_DATES>(); //IBA-3736
        Map<String,String> estDelMap = new Map<String,String>();//IBA-3736
        List<SCP_OrderSimulate_Res_Parser.ShipMethodMap> ShipMethodMap = new List<SCP_OrderSimulate_Res_Parser.ShipMethodMap>();//IBA-3736
        List<SCP_ShippingMethodMap__c> shipMethodList = SCP_ShippingMethodMap__c.getAll().values();//IBA-3736 -- Start
        for(SCP_ShippingMethodMap__c sm:shipMethodList){
            SCP_OrderSimulate_Res_Parser.ShipMethodMap ShipMethodMapItem = new SCP_OrderSimulate_Res_Parser.ShipMethodMap();
            ShipMethodMapItem.ship_desc = sm.Name;
            ShipMethodMapItem.ship_code = sm.SHIP_Code__c;
            ShipMethodMap.add(ShipMethodMapItem);
        }
        List<SCP_OrderSimulate_Res_Parser.ET_DelMap> ET_DelMap = new List<SCP_OrderSimulate_Res_Parser.ET_DelMap>();//IBA-3736 -- End
        try{
            SCP_OrderSimulate_Res_Parser  responseParserObj = new SCP_OrderSimulate().SendOrderInfoToSAP(String.valueOf(cartObj[0].id),false);//iba-4378
            
            system.debug('## shiping responseParserObj --'+ responseParserObj ); 
            List<String> statCodes = System.Label.SCP_OrderSimulateDownCode.Split(',');
            SCP_OrderSimulate_Res_Parser.Row rowObj = responseParserObj.row;
            String exCRBlock = rowObj.EX_CR_BLOCK;
            List<SCP_OrderSimulate_Res_Parser.ET_FREIGHT_OPTIONLIST> etOptionList = rowObj.ET_FREIGHT_OPTIONLIST;
                ITEMLIST = rowObj.ET_ITEMLIST; //iba-2669
                
            List<SCP_OrderSimulate_Res_Parser.ET_ITEM_DELIVERY_DATES> etOptionListDD = rowObj.ET_ITEM_DELIVERY_DATES;//IBA-3736
            ET_ITEM_DELIVERY_DATES = rowObj.ET_ITEM_DELIVERY_DATES; //IBA-3736
            
            if( rowObj.EX_CR_BLOCK == null || rowObj.EX_CR_BLOCK == '') {
    
                    if(rowObj.EX_EXCEPTION != 'X'){ 
                        ccrz.ccLog.log(System.LoggingLevel.DEBUG,'exCRBlock ',exCRBlock );
    
                        system.debug('## shiping exCRBlock --'+ exCRBlock ); 
                        system.debug('## shiping etOptionList --'+ etOptionList );
                        //system.debug('## shiping exCRBlock SIZE  --'+ exCRBlock.length() );
    
                        //caculate cart weight    
                        Decimal shipweight = 0.0;
                        for( ccrz__E_CartItem__c cit : [select ccrz__Product__r.ccrz__ShippingWeight__c   ,ccrz__Product__r.ccrz__ProductWeight__c from ccrz__E_CartItem__c where  ccrz__Cart__c = :cartId ]){
                            if(cit.ccrz__Product__r.ccrz__ShippingWeight__c!=null){
                                System.debug('Prinitng product team'+cit.ccrz__Product__r.ccrz__ShippingWeight__c);
    
                                shipweight = shipweight + cit.ccrz__Product__r.ccrz__ShippingWeight__c ; 
                            }
                        }
                        system.debug('## shipweight--'+shipweight); 
                        system.debug('## etOptionList--'+etOptionList); 
                        system.debug('## etOptionList size s--'+etOptionList.size());  
                        
                                            
                        Boolean drugMissingInSAP = FALSE;      // Canister and Cassette project
                        for (SCP_OrderSimulate_Res_Parser.ET_ITEMLIST iListItem : ITEMLIST){
                            if (iListItem.CAS_NOT_SETUP == 'X') {
                                drugsNonExistinSAP.add(iListItem.ITM_NUMBER);//IBA-3736
                                drugMissingInSAP = TRUE;
                                //break;//IBA-3736
                            }
                        }
                        ccrz.cc_ctrl_hlpr_ShippingOption tempObj; // Canister and Cassette project ends
    
                        if(etOptionList != NULL && etOptionList.size()>0 ){
    
                           
                            for(SCP_OrderSimulate_Res_Parser.ET_FREIGHT_OPTIONLIST optionObj : etOptionList){
                                String shippingDescription = optionObj.SHIP_DESC + '----'+optionObj.REQ_DATE;
                                system.debug('## optionObj.SHIP_COND--'+optionObj.SHIP_COND);   
                                if (drugMissingInSAP == TRUE) // Canister and Cassette project
                                   tempObj = new ccrz.cc_ctrl_hlpr_ShippingOption( 'SHIP','New Drug - Delivery will be delayed',optionObj.SHIP_DESC,Decimal.valueOf(optionObj.FREIGHT_VAL),0);  
                                else  // Canister and Cassette project ends
                                   tempObj = new ccrz.cc_ctrl_hlpr_ShippingOption( 'SHIP',optionObj.REQ_DATE,optionObj.SHIP_DESC,Decimal.valueOf(optionObj.FREIGHT_VAL),0);
                  
                                if(shipweight >150  &&  optionObj.SHIP_DESC.contains('STANDARD')) {
                                    shipList.clear(); 
                                    shipList.add(tempObj);
                                    tax.add(optionObj.TOTAL_TAX);
                                    break; 
                                }
                                shipList.add(tempObj);
                                tax.add(optionObj.TOTAL_TAX);
                            } 
                        }else{  
                            // list null--complete exception 
                            tempObj = new ccrz.cc_ctrl_hlpr_ShippingOption('SHIP','DefaultSHIP','Standard Ground',null,0);
                            shipList.add(tempObj);  
                        }    
                    }else if(etOptionList == NULL && (exCRBlock == null || exCRBlock=='') && statCodes.contains(rowObj.Status_Code)){
                        //when SAP is down or Endpoint wrong
                        ccrz.cc_ctrl_hlpr_ShippingOption tempObj = new ccrz.cc_ctrl_hlpr_ShippingOption('SHIP','SAP_Down','Standard Ground',null,0);
                        shipList.add(tempObj); 
                    }else{        
                        system.debug('## shiping rowObj.EX_EXCEPTION  dispp--'+ rowObj.EX_EXCEPTION);
                        ccrz.cc_ctrl_hlpr_ShippingOption tempObj = new ccrz.cc_ctrl_hlpr_ShippingOption('SHIP','DefaultSHIP','Standard Ground',null,0);
                        shipList.add(tempObj);
                    }
                }
            else{
                     //condition for Hard Blocking Error
                    ccrz.cc_ctrl_hlpr_ShippingOption tempObj = new ccrz.cc_ctrl_hlpr_ShippingOption('SHIP','HardBlock','Standard Ground',null,0);
                    shipList.add(tempObj); 
                }
            for(SCP_OrderSimulate_Res_Parser.ET_ITEM_DELIVERY_DATES st:etOptionListDD){//IBA-3736 - Start
                    SCP_OrderSimulate_Res_Parser.ET_DelMap ET_DelMapItem = new SCP_OrderSimulate_Res_Parser.ET_DelMap();
                    String sfItemnumber = '';
                    String delDate = '';
                    if(drugsNonExistinSAP.contains(st.ITM_NUMBER)){
                        delDate = 'New Drug - Delivery will be delayed';
                    }
                    else{
                        delDate = changeDateFormat(st.DELIVERY_DATE);
                    }
                    if(st.ITM_NUMBER.length() ==6){
                        sfItemnumber = '00'+st.ITM_NUMBER;
                    }
                    else if(st.ITM_NUMBER.length() ==7){
                        sfItemnumber = '0'+st.ITM_NUMBER;
                    }
                    else{
                        sfItemnumber = st.ITM_NUMBER;    
                    }
                    String keyItem = st.VSBED+'__'+sfItemnumber;
                    ET_DelMapItem.keyId = keyItem;
                    ET_DelMapItem.deldate = delDate;// changeDateFormat(st.DELIVERY_DATE);
                    ET_DelMapItem.item_sku = sfItemnumber;
                    ET_DelMap.add(ET_DelMapItem);
            }                                                                                           //IBA-3736 -- End
    
        }catch( exception e ) {
            system.debug('## exce shipList--'+ e.getmessage()); 
            system.debug('## exe stack trace shiplist--'+e.getStackTraceString());
            ccrz.cc_ctrl_hlpr_ShippingOption tempObj = new ccrz.cc_ctrl_hlpr_ShippingOption('SHIP','ERROR','Standard Ground',null,0);
            shipList.add(tempObj);
        }
        system.debug(shipList);
        outputMap.put('shipList',shipList);
        outputMap.put('tax',tax);
        outputMap.put('ITEMLIST',ITEMLIST); //iba-2669
        outputMap.put('ET_ITEM_DELIVERY_DATES',ET_DelMap); //IBA-3736
        outputMap.put('ShipMethodMap',ShipMethodMap); //IBA-3736
        ccRemoteActionResult.data = outputMap;
        ccRemoteActionResult.success = true; 
        return ccRemoteActionResult ;
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getPayment(ccrz.cc_RemoteActionContext ctx){
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
       string payconfig = [SELECT ccrz__TextValue__c FROM ccrz__E_Configuration__c Where ccrz__ConfigurationMeta__r.Name = 'Payment Types' 
                                             AND ccrz__ConfigurationMeta__r.ccrz__ConfigurationModule__r.Name = 'CyberSource' AND ccrz__Storefront__c = 'OmnicellB2BStore' limit 1].ccrz__TextValue__c;
        List<String> payval = payconfig.split(', ');
        list<ccpgcs__E_paymenttype__c> paylist =[select id,name,ccpgcs__Type__c from ccpgcs__E_paymenttype__c where ccpgcs__Type__c in: payval];
        Map<String,object> outputMap= new Map<String,Object>();
    outputMap.put('paymethod',paylist);
        String cartId = ccrz.cc_CallContext.currCartId;
        system.debug('u '+cartId);
        id usid = [select Id,ccrz__User__c from ccrz__E_Cart__c where ccrz__EncryptedId__c= :cartId  LIMIT 1].ccrz__User__c;
        
        list<ccrz__E_StoredPayment__c> polist = [select id,Name,ccrz__AccountNumber__c from ccrz__E_StoredPayment__c where OwnerId =: usid and ccrz__Storefront__c= 'OmnicellB2BStore'];
        outputMap.put('payPO',polist);
        
        
        ccRemoteActionResult.success = true; 
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult createCreditBillTo (ccrz.cc_RemoteActionContext ctx,String credBillTo){
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        Map<String,object> outputMap= new Map<String,Object>();
        System.debug('***'+credBillTo);
        Map<String,object> credBillToMap = (Map<String, Object>)JSON.deserializeUntyped(credBillTo);
        ccrz__E_ContactAddr__c newcredBillTo = new ccrz__E_ContactAddr__c();
        newcredBillTo.ccrz__FirstName__c = (string)credBillToMap.get('creditfname');
        newcredBillTo.ccrz__LastName__c = (string)credBillToMap.get('creditlname');
        newcredBillTo.ccrz__CompanyName__c = (string)credBillToMap.get('creditcompname');
        newcredBillTo.ccrz__AddressFirstline__c = (string)credBillToMap.get('creditaddress1');
        newcredBillTo.ccrz__AddressSecondline__c = (string)credBillToMap.get('creditaddress2');
        newcredBillTo.ccrz__City__c = (string)credBillToMap.get('creditcity');
        newcredBillTo.ccrz__StateISOCode__c = (string)credBillToMap.get('creditstate');
        newcredBillTo.ccrz__PostalCode__c = (string)credBillToMap.get('creditpostal');
        newcredBillTo.ccrz__CountryISOCode__c = (string)credBillToMap.get('creditcountry');
        try{
            insert newcredBillTo;
            outputMap.put('newbillId',newcredBillTo.Id);
        }
        catch(Exception e){
            System.debug(e);
        }
        System.debug('***'+newcredBillTo.ccrz__FirstName__c);
        ccRemoteActionResult.success = true; 
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    
    /*@RemoteAction
    global static ccrz.cc_RemoteActionResult checkFreePaidItems(ccrz.cc_RemoteActionContext ctx,String minorListItems){
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        Map<String,object> outputMap= new Map<String,Object>();
        ccRemoteActionResult.success = true; 
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }*/
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult reCheckSingleCheckout(ccrz.cc_RemoteActionContext ctx){
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        ccRemoteActionResult.success = false;  
        Map<String,object> outputMap= new Map<String,Object>();
        String currCartEncryptedId = ccrz.cc_CallContext.currCartId;
        ccrz__E_Cart__c cart = [Select Id,ccrz__EffectiveAccountID__c From ccrz__E_Cart__c Where ccrz__EncryptedId__c =:currCartEncryptedId][0];
        try{
            ccRemoteActionResult.success = SCP_reCheckCanisterCassetteItemsPrice.reCheckBillability(cart,false); //IBA-4266
        }
        catch(Exception e){
            System.debug(e);
        }
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    
    public static String changeDateFormat(String dateToChange){//IBA-3736
        List<String> dateSplit = dateToChange.split('-');
        String formattedDate = dateSplit[1]+'/'+dateSplit[2]+'/'+dateSplit[0];
        return formattedDate;
    }
    
    public static void updateCartItemDeliveryDate(Map<String,String> cartItemMap, String cartId){//IBA-3736
        List<ccrz__E_CartItem__c> cartItemList = [Select Id,Name,Estimated_Delivery_Date__c,Estimated_Delivery_DateText__c From ccrz__E_CartItem__c Where ccrz__Cart__r.ccrz__EncryptedId__c =:cartId AND Name IN :cartItemMap.keySet()];
        for(ccrz__E_CartItem__c cItem:cartItemList){
                cItem.Estimated_Delivery_DateText__c = (string)cartItemMap.get(cItem.Name);
                if((string)cartItemMap.get(cItem.Name) != 'New Drug - Delivery will be delayed')
                    cItem.Estimated_Delivery_Date__c = Date.parse((string)cartItemMap.get(cItem.Name));
        }
        try{
            update cartItemList;
        }
        catch(Exception e){
            System.debug('Error'+e);
        }
    }
    //IBA-3827
    @RemoteAction
    global static ccrz.cc_RemoteActionResult checkCC(ccrz.cc_RemoteActionContext ctx){
        ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
        ccRemoteActionResult.success = true;
        CreditCardDisable__c cc = [select IsDisabled__c from CreditCardDisable__c where name = 'Credit' limit 1];
        Map<String,boolean> outputMap= new Map<String,boolean>();
        if(cc.IsDisabled__c == true){
            outputMap.put('disabled',true);
        }else{
            outputMap.put('disabled',false);
        }
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    
}