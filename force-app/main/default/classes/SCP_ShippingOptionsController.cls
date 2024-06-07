global class SCP_ShippingOptionsController{
    @RemoteAction
    global static ccrz.cc_RemoteActionResult updateReferenceNumber(ccrz.cc_RemoteActionContext ctx,String referenceNumber){
         ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
         ccRemoteActionResult.success = false;  
         Map<String,object> outputMap= new Map<String,Object>();
         outputMap.put('isUpdated',false);
         String cartId = ccrz.cc_CallContext.currCartId; 
         outputMap.put('currentCart',cartId ); 
        try{
            ccrz__E_Cart__c cartObj= [select Id,Reference_Number__c,Order_attempt__c from ccrz__E_Cart__c where ccrz__EncryptedId__c= :cartId  LIMIT 1];
            cartObj.Order_attempt__c = true;
            cartObj.Reference_Number__c = referenceNumber;
            update cartObj;
            ccRemoteActionResult.success = true; 
            outputMap.put('isUpdated',true); 
        }
        catch(Exception e) {
            ccRemoteActionResult.success = false; 
        }
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    @RemoteAction
    global static ccrz.cc_RemoteActionResult updateCCContactAddress(ccrz.cc_RemoteActionContext ctx,String shippingContactAddressId,String billingContactAddressId,String contactData){
         ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
         ccRemoteActionResult.success = false;  
         Map<String,object> outputMap= new Map<String,Object>();
         Map<String,object> contactDataMap = (Map<String, Object>)JSON.deserializeUntyped(contactData);
         String CFname = (string)contactDataMap.get('ConFname');//SCP-850 start
         String CLname = (string)contactDataMap.get('ConLname');
         String CPhone = (string)contactDataMap.get('ConPhone');//SCP-850 End
         String CComName1 = (string)contactDataMap.get('ConComName1'); //SCP-860
         
         String buyerFname = (string)contactDataMap.get('buyerFname');
         String buyerLname = (string)contactDataMap.get('buyerLname');
         String buyerPhone = (string)contactDataMap.get('buyerPhone');
         String buyerEmail = (string)contactDataMap.get('buyerEmail');
       /*  Date shippingDt = new Date();
         if((string)contactDataMap.get('shippingDt') != 'Delivery will be delayed/undefined/New Drug')
         	shippingDt = Date.parse((string)contactDataMap.get('shippingDt'));
        */
         outputMap.put('isUpdated',false);
         String cartId = ccrz.cc_CallContext.currCartId; 
         outputMap.put('currentCart',cartId ); 
        try{
            ccrz__E_Cart__c cartObj= [select Id,New_Cart__c,ccrz__BuyerFirstName__c,ccrz__BuyerEmail__c,ccrz__RequestDate__c,ccrz__BuyerLastName__c,ccrz__BuyerPhone__c,ownerid,ccrz__Contact__r.firstname,ccrz__Contact__r.lastname  , ccrz__Account__r.Name,ccrz__BillTo__c,SAP_Shipping_Customer_Number__c,ccrz__ShipTo__c,SAP_Billing_Customer_Number__c,SAP_CONTACT_ID__c, 
                                      SAP_Billing_Company_Name2__c, Shipping_Company_Name2__c from ccrz__E_Cart__c where ccrz__EncryptedId__c= :cartId  LIMIT 1];
            system.debug('##contactDataMap--'+contactDataMap);
            system.debug('##cartObj--'+cartObj);
             cartObj.ccrz__BuyerFirstName__c = buyerFname;
             cartObj.ccrz__BuyerLastName__c = buyerLname;
             cartObj.ccrz__BuyerPhone__c = buyerPhone;
             cartObj.ccrz__BuyerEmail__c = buyerEmail;
            /*if(!((string)(contactDataMap.get('shippingDt'))).contains('Delivery will be delayed/undefined/New Drug')){
                System.debug('*##'+(string)(contactDataMap.get('shippingDt')));
             	cartObj.ccrz__RequestDate__c = Date.parse((string)contactDataMap.get('shippingDt'));
            }*/ //IBA-3736
             
            List<String> contactAddressIdList = new List<String>{cartObj.ccrz__BillTo__c,cartObj.ccrz__ShipTo__c};
            List<ccrz__E_ContactAddr__c>  contactAddressList = [select ccrz__CompanyName__c,Id,NewFirstName__c,SAP_Customer_Number__c,Company_Name_2__c,SAP_Contact_ID__c,ccrz__StateISOCode__c,ccrz__State__c 
                                                                from ccrz__E_ContactAddr__c
                                                                   where id in:contactAddressIdList  ]; 
            List<contact>  contactShipList = [select ccrz__CompanyName__c,Id, firstname,lastname,account.name from contact 
                                                                   where SAP_CONTACT_ID__c  =: cartObj.SAP_Contact_ID__c or SAP_Contact_Number__c   =: cartObj.SAP_Contact_ID__c ];
             system.debug('##contactAddressList--'+contactAddressList);
             system.debug('##contactShipList--'+contactShipList);
            List<ccrz__E_ContactAddr__c>  updateableAddressList = new List<ccrz__E_ContactAddr__c>();
            for(ccrz__E_ContactAddr__c contactAddressIdObj :contactAddressList){
                if(contactAddressIdObj.Id == cartObj.ccrz__ShipTo__c){
                    contactAddressIdObj.SAP_Contact_ID__c = cartObj.SAP_Contact_ID__c  ;
                     contactAddressIdObj.SAP_Customer_Number__c =  cartObj.SAP_Shipping_Customer_Number__c; 
                     contactAddressIdObj.Company_Name_2__c= cartObj.Shipping_Company_Name2__c ; 
                    contactAddressIdObj.ccrz__FirstName__c   = CFname;//contactShipList[0].firstname;
                    contactAddressIdObj.ccrz__LastName__c  = CLname;//contactShipList[0].lastname;  
                    contactAddressIdObj.ccrz__CompanyName__c=CComName1;//contactShipList[0].account.name; 
                    
                    account acc = [select id, BillingCity, BillingState, BillingPostalCode,Transportation_Zone_Country__c,
       									BillingCountry from account where SAP_Customer_Number__c=:cartObj.SAP_Shipping_Customer_Number__c or SAP_Account_Id__c =:cartObj.SAP_Shipping_Customer_Number__c limit 1];
                    contactAddressIdObj.ccrz__AddressFirstline__c =(string)contactDataMap.get('shipaddress1');
                    contactAddressIdObj.ccrz__AddressSecondline__c =(string)contactDataMap.get('shipaddress2');
                    contactAddressIdObj.ccrz__AddressThirdline__c =(string)contactDataMap.get('shipaddress3');
                    contactAddressIdObj.ccrz__CountryISOCode__c =acc.Transportation_Zone_Country__c;
                    contactAddressIdObj.ccrz__City__c =acc.BillingCity;
                    contactAddressIdObj.ccrz__PostalCode__c =acc.BillingPostalCode;
                    contactAddressIdObj.ccrz__Country__c =acc.BillingCountry;
                    contactAddressIdObj.ccrz__State__c = acc.BillingState;
                    contactAddressIdObj.ccrz__HomePhone__c = CPhone;//SCP-850
                    contactAddressIdObj.OwnerId = cartObj.ownerid;  
                    outputMap.put('shipFirstName',CFname); 
                    outputMap.put('shiplastName',CLname);
                }else{
                    contactAddressIdObj.SAP_Customer_Number__c = cartObj.SAP_Billing_Customer_Number__c ; 
                    contactAddressIdObj.Company_Name_2__c= cartObj.SAP_Billing_Company_Name2__c;
                   // contactAddressIdObj.ccrz__FirstName__c= UserInfo.getFirstname();
                   // contactAddressIdObj.ccrz__LastName__c= Userinfo.getLastName();
                   
                     contactAddressIdObj.ccrz__FirstName__c= cartObj.ccrz__Contact__r.firstname;
                    contactAddressIdObj.ccrz__LastName__c= cartObj.ccrz__Contact__r.lastname ;
                    
                    system.debug('### print contactAddressIdObj--'+contactAddressIdObj);
                    contactAddressIdObj.OwnerId = cartObj.ownerid; 
                    /*if(contactAddressIdObj.ccrz__State__c != null )
                    contactAddressIdObj.ccrz__StateISOCode__c=contactAddressIdObj.ccrz__State__c; 
                    */
                    account acc = [select id, BillingCity, BillingState, BillingPostalCode,BillingStateCode,Transportation_Zone_Country__c ,Name,
       									BillingCountry from account where SAP_Customer_Number__c=:cartObj.SAP_Billing_Customer_Number__c or SAP_Account_Id__c =:cartObj.SAP_Billing_Customer_Number__c limit 1];
                    contactAddressIdObj.ccrz__CompanyName__c=acc.Name;
                    contactAddressIdObj.ccrz__AddressFirstline__c =(string)contactDataMap.get('billAddress1');
                    contactAddressIdObj.ccrz__AddressSecondline__c =(string)contactDataMap.get('billAddress2');
                    contactAddressIdObj.ccrz__AddressThirdline__c =(string)contactDataMap.get('billAddress2');
                    contactAddressIdObj.ccrz__CountryISOCode__c =acc.Transportation_Zone_Country__c;
                    contactAddressIdObj.ccrz__City__c =acc.BillingCity;
                    contactAddressIdObj.ccrz__PostalCode__c =acc.BillingPostalCode;
                    contactAddressIdObj.ccrz__Country__c =acc.BillingCountry;
                    contactAddressIdObj.ccrz__StateISOCode__c=acc.BillingStateCode;
                    contactAddressIdObj.ccrz__State__c = acc.BillingState;
                    outputMap.put('billFirstName', cartObj.ccrz__Contact__r.firstname );
                    outputMap.put('billlastName', cartObj.ccrz__Contact__r.lastname );
               }
               updateableAddressList.add(contactAddressIdObj);
            }
             system.debug('##updateableAddressList --'+updateableAddressList);
            update updateableAddressList ;
            cartObj.New_Cart__c  = false;
            update cartObj;
            ccRemoteActionResult.success = true; 
            outputMap.put('isUpdated',true); 
        }
        catch(Exception e) {
            ccRemoteActionResult.success = false; 
            sendErrroMail(e.getMessage()); //added for debug
        }
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }

    global string accountName2{get;set;}
      global string accountName3{get;set;}
    
    global SCP_ShippingOptionsController(){
        OmniCellBillingAddressController newTest = new OmniCellBillingAddressController();
        accountName2 = newTest.accountName2;
        accountName3 = newTest.accountName3;  
    }
    //B2B-90 start
    @RemoteAction
    global static ccrz.cc_RemoteActionResult sendEmail(ccrz.cc_RemoteActionContext ctx,String emailData){
         ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
         ccRemoteActionResult.success = false;  
         Map<String,object> outputMap= new Map<String,Object>();
         Map<String,object> emailDataMap = (Map<String, Object>)JSON.deserializeUntyped(emailData);
        try{
            system.debug('## emailData--'+emailData);
            system.debug('## ctx--'+ctx);
            
            String email_to = String.valueOf(emailDataMap.get('email_to'));
            String email_cc = String.valueOf(emailDataMap.get('email_cc'));
            String subject = String.valueOf(emailDataMap.get('subject'));
            String description  = String.valueOf(emailDataMap.get('description'));
            String tax = String.valueOf(emailDataMap.get('tax'));
            PageReference pdfPage = Page.SCP_OrderReviewEmailCart;
            system.debug('** '+tax);
            pdfPage.getParameters().put('recordId',ccrz.cc_CallContext.currCartId);
            Blob pagePdf;
            try {
                if(Test.isRunningTest()){
                    pagePdf = Blob.valueOf('Test');
                }else{
                    pagePdf = pdfPage.getContentAsPDF();
                }
            }catch(Exception e){
                
            }
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
    
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName('Cart.pdf');
            efa.setBody(pagePdf );
            List<String> sendTo = new List<String>();
            sendTo.add(email_to);
            system.debug('cc '+email_cc);
            // Sets the paramaters of the email
            email.setSubject(subject);
            email.setToAddresses(sendTo);
            email.setPlainTextBody(description);
            if(String.isNotBlank(email_cc)){
                email.setCcAddresses(new List<String>{email_cc});
            }

     
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
     
            // Sends the email
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
            ccRemoteActionResult.success = true; 
            for(Messaging.SendEmailResult o : r){
                System.debug('result is---'+o);
            }
              ccrz.ccLog.log(System.LoggingLevel.DEBUG,'SendEmailResult','worked');
         }
        catch(Exception e) {
            ccRemoteActionResult.success = false; 
        }
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
    //B2B-90 end
    
    public static void sendErrroMail(String errorMessage){              
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         String[] toAddresses = new String[] {'sourav.das@omnicell.com'};
         mail.setToAddresses(toAddresses); 
         mail.setSenderDisplayName('Apex error message Shipping Update');
         mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
         mail.setPlainTextBody(errorMessage);
         Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}