Public with sharing class SCP_OrderTriggerHandler{


    Public Static void beforeInsertEvent(List<ccrz__E_Order__c> TriggerNewList){
         List<String> contactAddressIdList = new List<String>{TriggerNewList[0].ccrz__BillTo__c,TriggerNewList[0].ccrz__ShipTo__c};
         List<ccrz__E_ContactAddr__c>  contactAddressList = [select ccrz__CompanyName__c,Id,NewFirstName__c,SAP_Customer_Number__c,Company_Name_2__c,SAP_Contact_ID__c,ccrz__StateISOCode__c,ccrz__State__c 
                                                                from ccrz__E_ContactAddr__c
                                                                   where id in:contactAddressIdList  ]; 
        System.debug(contactAddressList);
        Set<id> originatedCartIdFromOrder= new Set<id>();
        Id currentUserProfileId = UserInfo.getProfileId();//IBA-4361
        String profileName = [SELECT Name FROM Profile WHERE Id =: currentUserProfileId].Name;//IBA-4361
        
        for(ccrz__E_Order__c order:TriggerNewList){
            if(order.ccrz__OriginatedCart__c!=null){
                originatedCartIdFromOrder.add(order.ccrz__OriginatedCart__c);  
                
            }
            
            if(order.ccrz__OriginatedCart__c == null && order.ccrz__EffectiveAccountID__c == null && profileName == 'API Only' ){//IBA-4361
                order.ccrz__EffectiveAccountID__c = order.ccrz__Account__c;
                System.debug(order.ccrz__EffectiveAccountID__c);
                order.ccrz__ShipTo__c = createCCAdd(order.SAP_Shipping_Customer_Number__c);
                order.ccrz__BillTo__c = createCCAdd(order.SAP_Billing_Customer_Number__c);
            } 
        }
        
        if(!originatedCartIdFromOrder.isEmpty()){
            Map<id,ccrz__E_Cart__c> originatedCartMap=new Map<id,ccrz__E_Cart__c>([SELECT id,Reference_Number__c,SHIP_COND__c FROM ccrz__E_Cart__c WHERE id=:originatedCartIdFromOrder]);
            if(!originatedCartMap.isEmpty()){
                for(ccrz__E_Order__c orderRecord:TriggerNewList){
                    if(originatedCartMap.ContainsKey(orderRecord.ccrz__OriginatedCart__c)){
                       //orderRecord.Reference_Number__c=originatedCartMap.get(orderRecord.ccrz__OriginatedCart__c).Reference_Number__c;
                       orderRecord.SHIP_COND__c=originatedCartMap.get(orderRecord.ccrz__OriginatedCart__c).SHIP_COND__c;
                    }
                }
            }
        }
    }
    
     /*** 
    Purpose - This method is to map SAP CONTACT ID, SAP CUSTOMER NUMBER field from parent subscription order to child subscription order
    Developer - Sanjana K.R
    ***/
    
    Public Static void mapFieldsToChildOrder(List<ccrz__E_Order__c> TriggerNewList){
           
        try{
            set<id> originatedOrder = new set<id>();
            set<id> originatedCart= new set<id>();
            set<Id> conAddIds = new set<Id>();
            for(ccrz__E_Order__c order:TriggerNewList){ 
                    if(order.ccrz__Order__c != null)
                        originatedOrder.add(order.ccrz__Order__c); //parent order Id when its subscription child
                    else
                        originatedCart.add(order.ccrz__OriginatedCart__c);//originated cart Id when its non-subscription order and subscription parent
                    conAddIds.add(order.ccrz__BillTo__c);
                    conAddIds.add(order.ccrz__ShipTo__c);                     
                
            }
            system.debug('originatedOrder-->'+originatedOrder);
            Map<id,ccrz__E_ContactAddr__c> newContAddMap = new Map<id,ccrz__E_ContactAddr__c>([select id,SAP_Contact_ID__c,SAP_Customer_Number__c from ccrz__E_ContactAddr__c where id IN: conAddIds]);
            List<ccrz__E_ContactAddr__c> updateBillTo = new List<ccrz__E_ContactAddr__c>();
            ccrz__E_ContactAddr__c  billTo,shipTo;            
            //This is for subscription orders
            if(!originatedOrder.isEmpty()){
                Map<id,ccrz__E_Order__c> ordsMap = new Map<id,ccrz__E_Order__c>([select id,OwnerId,ccrz__Contact__r.SAP_Contact_ID__c,ccrz__OriginatedCart__r.SAP_SOLD_TO__c,
                                                                                 ccrz__OriginatedCart__r.SAP_Billing_Customer_Number__c,ccrz__OriginatedCart__c, 
                                                                                 ccrz__OriginatedCart__r.SAP_Shipping_Customer_Number__c,ccrz__OriginatedCart__r.SAP_CONTACT_ID__c,
                                                                                 ccrz__OriginatedCart__r.ccrz__ShipTo__r.SAP_Customer_Number__c,SHIP_COND__c,ccrz__ShipMethod__c,
                                                                                 ccrz__OriginatedCart__r.ccrz__ShipTo__r.SAP_Contact_ID__c ,
                                                                                 ccrz__OriginatedCart__r.ccrz__BillTo__r.SAP_Customer_Number__c,
                                                                                 ccrz__OriginatedCart__r.ccrz__BillTo__r.SAP_Contact_ID__c,ccrz__BuyerFirstName__c,ccrz__BuyerLastName__c,ccrz__BuyerPhone__c,ccrz__BuyerEmail__c from ccrz__E_Order__c 
                                                                                 where id IN: originatedOrder]);  
                
                system.debug('parent Order-->'+ordsMap);
                if(!ordsMap.isEmpty()){
                    for(ccrz__E_Order__c newOrdRec : TriggerNewList){
                        billTo = new ccrz__E_ContactAddr__c(id=newOrdRec.ccrz__BillTo__c);
                        String sapContID;
                        billTo.SAP_Contact_ID__c = ordsMap.get(newOrdRec.ccrz__Order__c).ccrz__OriginatedCart__r.ccrz__BillTo__r.SAP_Contact_ID__c;
                        billTo.SAP_Customer_Number__c = ordsMap.get(newOrdRec.ccrz__Order__c).ccrz__OriginatedCart__r.ccrz__BillTo__r.SAP_Customer_Number__c;
                        updateBillTo.add(billTo);
                        shipTo = new ccrz__E_ContactAddr__c(id=newOrdRec.ccrz__ShipTo__c);
                        shipTo.SAP_Contact_ID__c = ordsMap.get(newOrdRec.ccrz__Order__c).ccrz__OriginatedCart__r.ccrz__ShipTo__r.SAP_Contact_ID__c;
                        shipTo.SAP_Customer_Number__c = ordsMap.get(newOrdRec.ccrz__Order__c).ccrz__OriginatedCart__r.ccrz__ShipTo__r.SAP_Customer_Number__c;
                        updateBillTo.add(shipTo);
                        newOrdRec.SAP_SOLD_TO__c = ordsMap.get(newOrdRec.ccrz__Order__c).ccrz__OriginatedCart__r.SAP_SOLD_TO__c;
                        newOrdRec.SAP_Billing_Customer_Number__c = ordsMap.get(newOrdRec.ccrz__Order__c).ccrz__OriginatedCart__r.SAP_Billing_Customer_Number__c;
                        newOrdRec.SAP_Shipping_Customer_Number__c = ordsMap.get(newOrdRec.ccrz__Order__c).ccrz__OriginatedCart__r.SAP_Shipping_Customer_Number__c;
                        if(ordsMap.get(newOrdRec.ccrz__Order__c).ccrz__OriginatedCart__r.SAP_CONTACT_ID__c != null){
                            sapContID = ordsMap.get(newOrdRec.ccrz__Order__c).ccrz__OriginatedCart__r.SAP_CONTACT_ID__c;
                        }else{
                            //sapContID = ordsMap.get(newOrdRec.ccrz__Order__c).ccrz__Contact__r.SAP_Contact_ID__c != null? ordsMap.get(newOrdRec.ccrz__Order__c).ccrz__Contact__r.SAP_Contact_ID__c : '';//Commented out for SCP-850
                            if(ordsMap.get(newOrdRec.ccrz__Order__c).ccrz__Contact__r.SAP_Contact_ID__c != null){//SCP-850 Start
                                System.debug('***'+ordsMap.get(newOrdRec.ccrz__Order__c).ccrz__Contact__r.SAP_Contact_ID__c);
                                sapContID = ordsMap.get(newOrdRec.ccrz__Order__c).ccrz__Contact__r.SAP_Contact_ID__c;
                            }
                            else{
                                sapContID = '';
                            } //SCP-850 End
                        }
                            
                        newOrdRec.SAP_CONTACT_ID__c = sapContID;
                        newOrdRec.Process_OrderSimulate__c = true ;
                        newOrdRec.ccrz__OriginatedCart__c = ordsMap.get(newOrdRec.ccrz__Order__c).ccrz__OriginatedCart__c ;
                        newOrdRec.SHIP_COND__c = ordsMap.get(newOrdRec.ccrz__Order__c).SHIP_COND__c ; 
                        newOrdRec.ccrz__ShipMethod__c = ordsMap.get(newOrdRec.ccrz__Order__c).ccrz__ShipMethod__c;
                        newOrdRec.ccrz__BuyerFirstName__c = ordsMap.get(newOrdRec.ccrz__Order__c).ccrz__BuyerFirstName__c;
                        newOrdRec.ccrz__BuyerLastName__c = ordsMap.get(newOrdRec.ccrz__Order__c).ccrz__BuyerLastName__c;
                        newOrdRec.ccrz__BuyerPhone__c = ordsMap.get(newOrdRec.ccrz__Order__c).ccrz__BuyerPhone__c;
                        newOrdRec.ccrz__BuyerEmail__c = ordsMap.get(newOrdRec.ccrz__Order__c).ccrz__BuyerEmail__c;
                        newOrdRec.OwnerId = ordsMap.get(newOrdRec.ccrz__Order__c).OwnerId;
                        
                    }
                    update updateBillTo;
                }
            }
            //This is for non-subscription orders and subscription parent
            if(!originatedCart.isEmpty()){
                Map<id,ccrz__E_Cart__c> cartMap = new Map<id,ccrz__E_Cart__c>([select id,ccrz__Contact__r.SAP_Contact_ID__c,SAP_SOLD_TO__c,SAP_Billing_Customer_Number__c,SAP_Shipping_Customer_Number__c,SAP_CONTACT_ID__c,ccrz__ShipTo__r.SAP_Customer_Number__c,ccrz__ShipTo__r.SAP_Contact_ID__c ,ccrz__BillTo__r.SAP_Customer_Number__c,ccrz__BillTo__r.SAP_Contact_ID__c from ccrz__E_Cart__c where id IN:originatedCart ]);
                system.debug('carts-->'+cartMap);
                if(!cartMap.isEmpty()){
                    for(ccrz__E_Order__c newOrdRec : TriggerNewList){
                        billTo = new ccrz__E_ContactAddr__c(id=newOrdRec.ccrz__BillTo__c);
                        String sapContID;
                        billTo.SAP_Contact_ID__c = cartMap.get(newOrdRec.ccrz__OriginatedCart__c).ccrz__BillTo__r.SAP_Contact_ID__c;
                        billTo.SAP_Customer_Number__c = cartMap.get(newOrdRec.ccrz__OriginatedCart__c).ccrz__BillTo__r.SAP_Customer_Number__c;
                        updateBillTo.add(billTo);
                        shipTo = new ccrz__E_ContactAddr__c(id=newOrdRec.ccrz__ShipTo__c);
                        shipTo.SAP_Contact_ID__c = cartMap.get(newOrdRec.ccrz__OriginatedCart__c).ccrz__ShipTo__r.SAP_Contact_ID__c;
                        shipTo.SAP_Customer_Number__c = cartMap.get(newOrdRec.ccrz__OriginatedCart__c).ccrz__ShipTo__r.SAP_Customer_Number__c;
                        updateBillTo.add(shipTo);
                        newOrdRec.SAP_SOLD_TO__c = cartMap.get(newOrdRec.ccrz__OriginatedCart__c).SAP_SOLD_TO__c;
                        newOrdRec.SAP_Billing_Customer_Number__c = cartMap.get(newOrdRec.ccrz__OriginatedCart__c).SAP_Billing_Customer_Number__c;
                        newOrdRec.SAP_Shipping_Customer_Number__c = cartMap.get(newOrdRec.ccrz__OriginatedCart__c).SAP_Shipping_Customer_Number__c;
                        if(cartMap.get(newOrdRec.ccrz__OriginatedCart__c).SAP_CONTACT_ID__c != null){
                            sapContID = cartMap.get(newOrdRec.ccrz__OriginatedCart__c).SAP_CONTACT_ID__c;
                        }else{                            
                            if(cartMap.get(newOrdRec.ccrz__OriginatedCart__c).ccrz__Contact__r.SAP_Contact_ID__c != null){//SCP-850 Start
                                System.debug('***'+cartMap.get(newOrdRec.ccrz__OriginatedCart__c).ccrz__Contact__r.SAP_Contact_ID__c);
                                sapContID = cartMap.get(newOrdRec.ccrz__OriginatedCart__c).ccrz__Contact__r.SAP_Contact_ID__c;
                            }
                            else{
                                sapContID = '';
                            } //SCP-850 End
                            //sapContID = cartMap.get(newOrdRec.ccrz__OriginatedCart__c).ccrz__Contact__r.SAP_Contact_ID__c != null? cartMap.get(newOrdRec.ccrz__Order__c).ccrz__Contact__r.SAP_Contact_ID__c : ''; //Commented out for SCP-850
                        }
                        newOrdRec.SAP_CONTACT_ID__c = sapContID;
                        
                    }
                    update updateBillTo;
                }
            }
        }Catch(Exception ex){
            System.debug('mapFieldsToChildOrder exception-->'+ex );
        }
    }
    
    Public Static void NotificationOnOrderFail(Map<Id, ccrz__E_Order__c> newMap, Map<Id, ccrz__E_Order__c> oldMap){
       List<ccrz__E_Order__c> orderLst = new List<ccrz__E_Order__c>();
       try{
            
                List<ccrz__E_Order__c> NewOrderLst = newMap.values(); 
                
               // Map<Id,ccrz__E_OrderItem__c> orderItemMap = new Map<Id,ccrz__E_OrderItem__c>();
               OrgWideEmailAddress[] owea = [select Id,displayName from OrgWideEmailAddress where displayName = 'Do Not Reply'];
              // String domainUrl = URL.getSalesforceBaseUrl().toExternalForm();
                for(ccrz__E_Order__c order : NewOrderLst){
                    if(order.Integration_Status__c != oldMap.get(order.Id).Integration_Status__c && order.Integration_Status__c == 'Error'){
                       orderLst.add(order);
                    }
                }
                 Map<Id,List<ccrz__E_OrderItem__c>> orderItemMap = new Map<Id,List<ccrz__E_OrderItem__c>>();
                for(ccrz__E_OrderItem__c orderItem : [Select Name,ccrz__Quantity__c,id,ccrz__Order__c from ccrz__E_OrderItem__c where ccrz__Order__c in :orderLst]){
                   if(!orderItemMap.containsKey(orderItem.ccrz__Order__c)){
                               orderItemMap.put(orderItem.ccrz__Order__c, new List<ccrz__E_OrderItem__c>());
              }
               orderItemMap.get(orderItem.ccrz__Order__c).add(orderItem);
             }
                
               List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
                for(ccrz__E_Order__c order : [Select Name,SAP_Order_Number__c,ccrz__Order__c,ccrz__TotalAmount__c,Id,ccrz__OriginatedCart__r.Name,ccrz__User__r.Name,ccrz__Account__r.Name,Account_City__c,Account_CSN__c,Account_State__c from ccrz__E_Order__c where id in: orderLst]){
                     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                     List<String> sendTo = new List<String>();
                     List<ccrz__E_OrderItem__c> orderItem = new List<ccrz__E_OrderItem__c>();
                   /*  for(ccrz__E_OrderItem__c line :[select Name,id from ccrz__E_OrderItem__c where id in :orderItemMap.get(order.Id)]){
                         orderItem.add(line);
                       }*/
                    String tab = '<table border="1" style="border-collapse: collapse"><caption>Onder Line Item Summary Data</caption><tr><th>Order Item Number</th><th>Product Name</th><th>Price</th></th><th>Quantity</th></tr>';
                    for(ccrz__E_OrderItem__c l :[select Name,ccrz__Quantity__c,id,ccrz__Price__c,ccrz__Product__r.Name from ccrz__E_OrderItem__c where id in :orderItemMap.get(order.Id)]){

                    String OrderLineNumber = l.Name; 
                    String ProductName = l.ccrz__Product__r.Name; 
                    Decimal Price = l.ccrz__Price__c;
                    Decimal Quantity = l.ccrz__Quantity__c;
            
            
                    tab += '<tr><td>' + OrderLineNumber + '</td><td>' + ProductName +  '</td><td>' + Price  + '</td><td>' + Quantity +'</td></tr>';

                   }
                     //sendTo.add(order.ccrz__Contact__r.email);
                     String Toadd = Label.ProductionSupportTeam;
                     sendTo.add(Toadd);
                     mail.setToAddresses(sendTo);
                     mail.setSubject('Order Failed :'+ order.Name);
                     mail.setOrgWideEmailAddressId(owea.get(0).Id);
                     String body = 'Hi Team, <br/><br/>This is to inform you that a new Order is not created in Salesforce.<br/> <br/> Below is the Order record Detail :<br/><br/> ' +
                                    'SAP Order Number :' + order.SAP_Order_Number__c +
                                    //'<br/>Order Number :'+ '<href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+ order.Id+'">'+ order.Name+ '</a>'+
                                    '<br/>Order Number :'+'<a href="'+Label.OmnicellDomainName+'/'+ order.Id+'">'+ order.Name+'</a>'+
                                    '<br/> Cart ID : '+ order.ccrz__OriginatedCart__r.Name +
                                    '<br/> Total Amount  : '+ order.ccrz__TotalAmount__c +
                                    '<br/> Registered User  : '+ order.ccrz__User__r.Name+
                                    '<br/> Account Name : '+ order.ccrz__Account__r.Name+
                                    '<br/> Account CSN # : '+ order.Account_CSN__c+
                                    '<br/> Account City : '+ order.Account_City__c+
                                    '<br/> Account State : '+ order.Account_State__c+
                                    '<br/> <br/>'+ tab +'</table><br/>'+
                                    '<br/> Best Regards,<br/> Omnicell Inc';                                                       
                    mail.setHtmlBody(body);
                    if((!System.isBatch() && order.ccrz__Order__c==null) || order.ccrz__Order__c!=null)
                        mails.add(mail);
                }
                 
                 
                 Messaging.sendEmail(mails);
                
            
       }catch(Exception e){
            new SCP_ApexDebugLog().CreateLog(new SCP_ApexDebugLog.Error('SCP_OrderTriggerHandler','NotificationOnOrderFail',string.valueof(orderLst),null,string.valueof(e.getMessage()),string.valueof(e.getStackTraceString()),e));
       }
    }
    /*** 
    Purpose - Clone the Transaction Payment Record from Parent Order to Child subscription order. 
    ***/
    Public Static void CloneTPtoChildOrder(List<ccrz__E_Order__c> TriggerNewList){
           list<id> currentOrder = new list<id>(); // SCP-769
            list<id> originatedCartIdFromOrder = new list<id>(); // SCP-769
        try{
            Id currentUserProfileId = UserInfo.getProfileId();//IBA-4361
            String profileName = [SELECT Name FROM Profile WHERE Id =: currentUserProfileId].Name;//IBA-4361
            Set<id> ParentOrderIdSet= new Set<id>();
            Set<id> newTransPayIDs= new Set<id>();
            Set<id> contid = new Set<id>();//IBA-4361
             for(ccrz__E_Order__c order:TriggerNewList){
                 if(order.ccrz__OriginatedCart__c == null && profileName == 'API Only' ){//IBA-4361
                    contid.add(order.ccrz__Contact__c);
                 }
                 if(order.ccrz__Order__c!=Null){
                ParentOrderIdSet.add(order.ccrz__Order__c);
                 }
                 currentOrder.add(order.id); // SCP-769
                 originatedCartIdFromOrder.add(order.ccrz__OriginatedCart__c); // SCP-769
            system.debug(currentOrder);
                }
            map<id,contact> contactM = new map<id,contact>();//IBA-4361
            if(contid.size()>0){//IBA-4361
                for(contact objCS : [select id,email from contact where id =:contid]){
                    contactM.put(objCS.id, objCS);
                }
        
            }
            
            map<id,ccrz__E_TransactionPayment__c> maporderTPValues = new map<id,ccrz__E_TransactionPayment__c>();
            list<ccrz__E_Order__c> ord = new list<ccrz__E_Order__c>();//IBA-4361
            for(ccrz__E_Order__c order:TriggerNewList){
                 
                 if(order.ccrz__OriginatedCart__c == null && profileName == 'API Only' && contactM.containskey(order.ccrz__Contact__c) ){//IBA-4361
                     //contact c = contactM.get(order.ccrz__Contact__c);
                     //messages.add(sendECCorderNotification(order,c));
                     ord.add(order);
                 } 
             }
            if(ord.size()>0){//IBA-4361
                String hour = String.valueOf(Datetime.now().hour());
                String min = String.valueOf(Datetime.now().minute() + 1); 
                String ss = String.valueOf(Datetime.now().second());
                String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                confrimationEmailECC sch = new confrimationEmailECC(ord,contactM);
                System.schedule('Ecc order confirmation email', nextFireTime ,sch);
            }
            if(!ParentOrderIdSet.isEmpty())
            {
             List<ccrz__E_TransactionPayment__c> paymentTransactionList=[SELECT id,ccrz__Account__c,OwnerId,ccrz__AccountNumber__c,ccrz__AccountType__c,ccrz__Address__c,ccpgcs__Address__c,ccrz__Amount__c,ccrz__BillTo__c,ccrz__CCOrder__c,ccrz__CCSubscription__c,ccrz__Comments__c,ccrz__Contact__c,ccrz__CurrencyISOCode__c,ccrz__ExpirationMonth__c,ccrz__ExpirationYear__c,ccrz__InvoiceAppliedFor__c,ccrz__InvoiceAppliedTo__c,ccrz__ParentTransactionPayment__c,ccpgcs__PayerAuthenticationCavv__c,ccpgcs__PayerAuthenticationEci__c,ccpgcs__PayerAuthenticationReasonCode__c,ccpgcs__PayerAuthenticationTransactionId__c ,ccpgcs__PayerAuthenticationXid__c,ccrz__PaymentType__c,ccrz__RequestAmount__c,ccrz__SoldTo__c,ccrz__SourceTransactionPayment__c,ccrz__StoredPayment__c,ccrz__Storefront__c,ccrz__SubAccountNumber__c ,ccrz__Token__c,ccpgcs__TokenInstrumentIdentifier__c,ccrz__TransactionCode__c,ccrz__TransactionSubcode__c,ccrz__TransactionTS__c,ccrz__TransactionType__c,ccrz__User__c,ccrz__VerificationCode__c  FROM ccrz__E_TransactionPayment__c WHERE ccrz__CCOrder__c=:ParentOrderIdSet];
             
             for(ccrz__E_TransactionPayment__c transPay:paymentTransactionList){
                 maporderTPValues.put(transPay.ccrz__CCOrder__c,transPay);
             }
             
            ccrz__E_TransactionPayment__c paymentTransaction;
            
            List<ccrz__E_TransactionPayment__c> newTranPay = new List<ccrz__E_TransactionPayment__c>();
            
            
             for(ccrz__E_Order__c order:TriggerNewList){
                if(order.ccrz__Order__c!=Null){
                    if(maporderTPValues.get(order.ccrz__Order__c).ccrz__AccountType__c=='po' /*|| (maporderTPValues.get(order.ccrz__Order__c).ccrz__AccountType__c=='sopcc' && maporderTPValues.get(order.ccrz__Order__c).ccrz__TransactionType__c.contains('authorization'))*/){
                        paymentTransaction = maporderTPValues.get(order.ccrz__Order__c).Clone(false,true);
                        
                        system.debug('child order amount-->'+order.ccrz__SubtotalAmount__c);
                        
                        paymentTransaction.ccrz__CCSubscription__c = order.ccrz__CCSubscription__c;
                        //if(maporderTPValues.get(order.ccrz__Order__c).ccrz__AccountType__c=='po')
                        paymentTransaction.OwnerId = order.OwnerId;
                        paymentTransaction.ccrz__Amount__c = 0;
                        paymentTransaction.ccrz__CCOrder__c = order.id;
                        newTranPay.add(paymentTransaction);
                    }
                }               
             }
             insert newTranPay;
              /*for(ccrz__E_TransactionPayment__c tp : newTranPay){
                  newTransPayIDs.add(tp.id);
              }
              if(!newTransPayIDs.isEmpty())
                 updateTPAmount(newTransPayIDs);*/
        }
    }
    Catch(Exception ex){
            System.debug('CloneTPtoChildOrder exception-->'+ex );
    }
   
        // SCP-769 start
        id acct = originatedCartIdFromOrder[0];
        if(acct != null) {
            list<Attachment> attachments = [SELECT Id, Body, name 
                                        FROM Attachment 
                                        WHERE parentId =: acct];
                if(!attachments.isEmpty()) {
                    Attachment att = new Attachment();
                    String newBody = '';
                    if(att.Body != null) {
                        newBody = EncodingUtil.base64Encode(att.Body);
                    }
                    newBody += attachments[0].body;
                    att.Body = attachments[0].body;
                    att.Name = attachments[0].name;
                    att.parentId = currentOrder[0];
                    
                    upsert att;
                    //TriggerNewList[0].Attachment_id__c = att.id;
                } 
            }
        
        // SCP-769 end
  }
  
  /*@future 
      public Static void updateTPAmount(set<id> newTranPayIDs){
            
            Set<id> orderIds = new Set<id>();
            List<ccrz__E_TransactionPayment__c> updateTranPay = new List<ccrz__E_TransactionPayment__c>();
            
            for(ccrz__E_TransactionPayment__c transPay:[select id,ccrz__CCOrder__c from ccrz__E_TransactionPayment__c where id IN:newTranPayIDs]){
                orderIds.add(transPay.ccrz__CCOrder__c);
            }
            system.debug('check orderIds-->'+orderIds);
            Map<Id,ccrz__E_Order__c> orderMap = new Map<Id,ccrz__E_Order__c>([select id,ccrz__TotalAmount__c from ccrz__E_Order__c where id IN: orderIds]);
            system.debug('check orderMap -->'+orderMap);
            for(ccrz__E_TransactionPayment__c transPay:[select id,ccrz__CCOrder__c,ccrz__Amount__c  from ccrz__E_TransactionPayment__c where id IN:newTranPayIDs]){
                  
                  transPay.ccrz__Amount__c = orderMap.get(transPay.ccrz__CCOrder__c).ccrz__TotalAmount__c;
                  updateTranPay.add(transPay);
            }
            
            if(!updateTranPay.isEmpty())
                update updateTranPay;
      }*/
    public Static void updateTransactionAmount(Map<Id, ccrz__E_Order__c> newMap, Map<Id, ccrz__E_Order__c> oldMap){
        List<ccrz__E_Order__c> orderLst = new List<ccrz__E_Order__c>();
         List<ccrz__E_TransactionPayment__c> updateTranPay = new List<ccrz__E_TransactionPayment__c>();
        try{
            List<ccrz__E_Order__c> NewOrderLst = newMap.values(); 
            for(ccrz__E_Order__c order : NewOrderLst){
                if(order.ccrz__TotalAmount__c != oldMap.get(order.Id).ccrz__TotalAmount__c ){
                   orderLst.add(order);
                }
            }
            if(!Test.isRunningTest()){
                for(ccrz__E_TransactionPayment__c transPay:[select id,ccrz__CCOrder__c from ccrz__E_TransactionPayment__c where ccrz__CCOrder__c IN:orderLst]){
                    transPay.ccrz__Amount__c = newMap.get(transPay.ccrz__CCOrder__c).ccrz__TotalAmount__c;
                    updateTranPay.add(transPay);
                }
                if(!updateTranPay.isEmpty())
                    update updateTranPay;
            }
    
        }Catch(Exception ex){
            System.debug('mapFieldsToChildOrder exception-->'+ex );
        }
    }
    

/* The below method sends email to different team in case the drug code is not configured in SAP */ 
    public Static void sendMailForMissingDrugCode(Map<Id, ccrz__E_Order__c> newMap, Map<Id, ccrz__E_Order__c> oldMap){
        
        List<ccrz__E_Order__c> newOrders= newMap.values();
        Set<String> oIDList = new Set<String>();
        Set<String> oItemIDList = new Set<String>();
        Boolean atLeastOneNewCanister = FALSE;
        Messaging.SingleEmailMessage message2;  
        
        for (Id recordId : newMap.keyset()){
            if (oldMap.get(recordId).SAP_Order_Number__c != newMap.get(recordId).SAP_Order_Number__c){
                oIDList.add(recordId);
            }
        }
        if (oIDList.size()>0){
            List<ccrz__E_Order__c> orderToProcess = [SELECT id
                                                            //, ccrz__Account__r.SAP_Customer_Number__c
                                                            , ccrz__Account__r.Name
                                                            , ccrz__Contact__r.id
                                                            , ccrz__Contact__r.Email
                                                            , (SELECT id
                                                               , ccrz__Quantity__c
                                                               , DrugCodes__r.DrugCodes__c
                                                               , DrugCodes__r.Generic_Drug_Name__c
                                                               , DrugCodes__r.Brand_Name__c
                                                               , DrugCodes__r.Manufacturer_Name__c
                                                               , DrugCodes__r.Drug_Strength__c
                                                               , DrugCodes__r.Drug_Forms__c
                                                               , Machines__r.Machine_Id__c
                                                               , Machines__r.Machine_Type_Capacity__c
                                                               , Drug_Code_Exists_in_SAP__c
                                                               FROM ccrz__E_OrderItems__r
                                                               WHERE Machine_Type__c = 'Canister')
                                                               //AND Drug_Code_Exists_in_SAP__c != TRUE)
                                                            FROM ccrz__E_Order__c WHERE id IN :oIDList];
            
            for (ccrz__E_Order__c ord : orderToProcess) {
                if (ord.ccrz__E_OrderItems__r.size() > 0) {
                    String subject = 'Order submitted for Canisters - please refer to attachment for the details';
                    String body = 'Dear Team, \nOrder submitted for Canisters - please refer to the attachment for the details. \n Thanks.';
                    
                    String str1 = ord.ccrz__E_OrderItems__r[0].Machines__r.Machine_Id__c != NULL ? String.valueOf(ord.ccrz__E_OrderItems__r[0].Machines__r.Machine_Id__c) : '';
                    String str2 = ord.ccrz__E_OrderItems__r[0].Machines__r.Machine_Type_Capacity__c != NULL ? String.valueOf(ord.ccrz__E_OrderItems__r[0].Machines__r.Machine_Type_Capacity__c) : '';
                    String finalstr = ord.ccrz__Account__r.Name + '\n'
                                    + str1 + '\n' + '1 \n 1 \n';
                    finalstr = finalstr + str2 + '\n3\n\n';
                    for (ccrz__E_OrderItem__c ordItem : ord.ccrz__E_OrderItems__r) {
                        String str3 = ordItem.DrugCodes__r.DrugCodes__c != NULL ? ordItem.DrugCodes__r.DrugCodes__c : '';
                        String str4 = ordItem.DrugCodes__r.Generic_Drug_Name__c != NULL ? ordItem.DrugCodes__r.Generic_Drug_Name__c : '';
                        String str5 = ordItem.DrugCodes__r.Brand_Name__c != NULL ? ordItem.DrugCodes__r.Brand_Name__c : '';
                        String str6 = ordItem.DrugCodes__r.Manufacturer_Name__c != NULL ? ordItem.DrugCodes__r.Manufacturer_Name__c : '';
                        String str7 = ordItem.DrugCodes__r.Drug_Strength__c != NULL ? ordItem.DrugCodes__r.Drug_Strength__c : '';
                        String str8 = ordItem.DrugCodes__r.Drug_Forms__c != NULL ? ordItem.DrugCodes__r.Drug_Forms__c : '';
                        String str9 = ordItem.Drug_Code_Exists_in_SAP__c != TRUE ? '~**NEW DRUG**~~' : '~~~';
                        
                        finalstr = finalstr + str3 + '~' + str4 + '~' + str5 + '~' + str6 + '~' + str7 + str9 + str8 + '~~~~~~~\n';
                        
                        if (ordItem.Drug_Code_Exists_in_SAP__c != TRUE)
                            atLeastOneNewCanister = TRUE;
                    }

                    String attName = 'New Drug Codes ' + ord.ccrz__Account__r.Name + '.txt'; 

                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(attName);
                    efa.setBody(Blob.valueOf(finalstr));

                    email.setSubject(subject);
                    email.setToAddresses(System.Label.Omnicell_Canister_Team.split('[,;]'));
                    email.setPlainTextBody(body);
 
                    email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

                    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
                    
                    if (atLeastOneNewCanister == TRUE) {
                        message2 = new Messaging.SingleEmailMessage();
                        message2.setTargetObjectId(ord.ccrz__Contact__r.id); 
                        message2.setSenderDisplayName('Omnicell - new cansiter request '); 
                        message2.setReplyTo('no-reply@company.com');
                        message2.setUseSignature(false); 
                        message2.setBccSender(false); 
                        message2.setSaveAsActivity(false); 
                        EmailTemplate emailTemplate = [SELECT Id,
                                                       Subject,
                                                       Description,
                                                       HtmlValue,
                                                       DeveloperName,
                                                       Body 
                                                       FROM EmailTemplate 
                                                       WHERE name = 'New Canister Sample Request'];
                        message2.setTemplateID(emailTemplate.Id); 
                        message2.setWhatId(ord.Id); //This is important for the merge fields in template to work
                        message2.toAddresses = new String[] {ord.ccrz__Contact__r.Email};
                        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message2};
                        if(!Test.isRunningTest()) {
                            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
         
                            if (results[0].success) {
                                System.debug('The sample canister notification was sent successfully.');
                            } else {
                                System.debug('The sample canister notification failed to send: ' +  results[0].errors[0].message);
                            }
                        }
                    }
                }
            }
            
            List<ccrz__E_Order__c> orderToProcess2 = [SELECT Id
                                                     , ccrz__Contact__r.Id
                                                     , ccrz__Contact__r.Email
                                                     , (SELECT Id
                                                        FROM ccrz__E_OrderItems__r
                                                        WHERE Material__c IN ('CASS_VC_BASE', 'CASS_VC_CB', 'CASS_VC_VBM', 'CASS_VC_RFID')
                                                        AND Drug_Code_Exists_in_SAP__c != TRUE)
                                                     FROM ccrz__E_Order__c WHERE id IN :oIDList];
                           
            for (ccrz__E_Order__c ord2 : orderToProcess2) {
                if (ord2.ccrz__E_OrderItems__r.size() > 0) {
                    message2 = new Messaging.SingleEmailMessage();
                    message2.setTargetObjectId(ord2.ccrz__Contact__r.id); 
                    message2.setSenderDisplayName('Omnicell cassette order '); 
                    message2.setReplyTo('no-reply@omnicell.com');
                    message2.setUseSignature(false); 
                    message2.setBccSender(false); 
                    message2.setSaveAsActivity(false); 
                    EmailTemplate emailTemplate = [SELECT Id,
                                                   Subject,
                                                   Description,
                                                   HtmlValue,
                                                   DeveloperName,
                                                   Body 
                                                   FROM EmailTemplate 
                                                   WHERE name = 'Cassette Lab Notification'];
                    message2.setTemplateID(emailTemplate.Id); 
                    message2.setWhatId(ord2.Id); //This is important for the merge fields in template to work
                    message2.toAddresses = System.Label.Omnicell_Cassette_Lab.split('[,;]');
                    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message2};
                    if (!Test.isRunningTest()) {
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
     
                        if (results[0].success) {
                            System.debug('The email was sent successfully.');
                        } else {
                            System.debug('The email failed to send: ' +  results[0].errors[0].message);
                        }
                    }
                }
            }
        }
        
    }
    
    Public static string createCCAdd(string acct){//IBA-4361
        string contAdd=' ';
        try{
            ccrz__E_ContactAddr__c accRel = new ccrz__E_ContactAddr__c();
            account acc = [select id,Name,BillingStreet,BillingCity,Transportation_Zone_Country__c,BillingPostalCode,BillingCountry,BillingState,
                           SAP_Customer_Number__c,BillingStateCode,PO_BOX__c from account where SAP_Account_ID__c =: acct or SAP_Customer_Number__c =: acct limit 1];
            accRel.ccrz__CompanyName__c = acc.Name;
            accRel.AccountId__c = acc.Id;
            accRel.ccrz__AddressFirstline__c = acc.BillingStreet;
            accRel.ccrz__City__c = acc.BillingCity;
            accRel.ccrz__CountryISOCode__c = acc.Transportation_Zone_Country__c;
            accRel.ccrz__PostalCode__c = acc.BillingPostalCode;
            accRel.ccrz__Country__c = acc.BillingCountry;
            accRel.ccrz__State__c = acc.BillingState;
            accRel.SAP_Customer_Number__c = acc.SAP_Customer_Number__c;   
            accRel.ccrz__StateISOCode__c = acc.BillingStateCode;
            accRel.ccrz__AddressThirdline__c = acc.PO_BOX__c;
            insert accRel;
            contAdd = accRel.id;
        }Catch(Exception ex){
            System.debug('cc address exception-->'+ex );
        }
        return contAdd;
    }
    
    

}