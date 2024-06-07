global without sharing class SCP_CartPDFCntrl {  

 public List<ccrz__E_CartItem__c> CartListrecords {get; set;} 
 public List<ccrz__E_Product__c> ProductList{get; set;} 
 public ccrz__E_Cart__c Cartrecords{get;set;}
 public String conFirstName{get;set;}
 public String conLastName{get;set;}
 public String effAccountName{get;set;}
 public List<wrapCartItems> wrapcartItemsList {get; set;}
 set<id> Productids = new set<id>();
 
 
   global SCP_CartPDFCntrl(){  
         wrapcartItemsList = new List<wrapCartItems>();
         Account acc = new Account();
         String recordId = ApexPages.CurrentPage().getParameters().get('recordId');
          System.debug('recordId --------'+recordId );
         //recordId='3cc91204-15d1-43de-9435-f699634ff47b';
         Cartrecords = [select id, Name,ccrz__SubtotalAmount__c,ccrz__EffectiveAccountID__c,ccrz__Contact__r.FirstName,ccrz__Contact__r.LastName,ccrz__Account__r.Name,ccrz__EncryptedId__c from ccrz__E_Cart__c where ccrz__EncryptedId__c=:recordId]; 
         conFirstName = (Cartrecords.ccrz__Contact__r.FirstName!=null || Cartrecords.ccrz__Contact__r.FirstName!= '') ? Cartrecords.ccrz__Contact__r.FirstName : '';
         conLastName = (Cartrecords.ccrz__Contact__r.LastName!=null || Cartrecords.ccrz__Contact__r.LastName!= '') ? Cartrecords.ccrz__Contact__r.LastName: '';
         if(Cartrecords.ccrz__EffectiveAccountID__c!=null || Cartrecords.ccrz__EffectiveAccountID__c!=''){
             acc = [select id,Name from Account where id =: Cartrecords.ccrz__EffectiveAccountID__c];
             effAccountName = acc.Name != null? acc.Name : '';
         }
         CartListrecords  =new list<ccrz__E_CartItem__c>([select id,Name,ccrz__Product__c,ccrz__Cart__c,ccrz__Price__c,ccrz__Quantity__c,ccrz__AbsoluteDiscount__c,
                                                          ccrz__ItemTotal__c,ccrz__Product__r.Name,ccrz__Product__r.ccrz__SKU__c,
                                                          ccrz__Product__r.ccrz__UnitOfMeasure__c from ccrz__E_CartItem__c where
                                                          ccrz__Cart__r.ccrz__EncryptedId__c=:recordId ]);
         try{
             for(ccrz__E_CartItem__c cartItem : CartListrecords ){
                 if(cartItem.ccrz__Product__r.ccrz__UnitOfMeasure__c == null){
                     cartItem.ccrz__Product__r.ccrz__UnitOfMeasure__c = '';
                 }
                 if(cartItem.ccrz__AbsoluteDiscount__c == null){
                     cartItem.ccrz__AbsoluteDiscount__c = 0.0;
                 }
                 wrapcartItemsList.add(new wrapCartItems(cartItem.ccrz__Product__r.Name,String.valueof(cartItem.ccrz__Price__c),String.valueof(cartItem.ccrz__Quantity__c),String.valueof(cartItem.ccrz__AbsoluteDiscount__c),String.valueof(cartItem.ccrz__ItemTotal__c),cartItem.ccrz__Product__r.ccrz__SKU__c,cartItem.ccrz__Product__r.ccrz__UnitOfMeasure__c));
                 system.debug('cartItem ---'+cartItem.ccrz__AbsoluteDiscount__c);
             }
         
         }catch(exception e){
             System.debug(e.getMessage());
         }
         system.debug([select id,name from ccrz__E_Product__c where id=:CartListrecords[0].ccrz__Product__c]);
     }
     
     /*public PageReference send() {
        // Define the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
 
        // Reference the attachment page and pass in the account ID
        PageReference pdf =  null;
              //  PageReference pdf = Page.SCP_EmailCartPDF;
        pdf.getParameters().put('ccrz__EncryptedId__c',(String)Cartrecords.ccrz__EncryptedId__c); 
        pdf.setRedirect(true);
 
        // Take the PDF content
        Blob PdfAttachmentFile = pdf.getContent();
 
        // Create the email attachment
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('Cart.pdf');
        efa.setBody(PdfAttachmentFile );
 
        String mMail;
        mMail = UserInfo.getUserEmail();
        System.debug('user mail id '+mMail);
        List<String> sendTo = new List<String>();
        sendTo.add(mMail);
        
        // Sets the paramaters of the email
        email.setSubject('Your Cart Details');
        email.setToAddresses(sendTo);
        email.setPlainTextBody('Attached is the Cart Details.');
 
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
 
        // Sends the email
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
        
        return null;
    } */
    public class wrapCartItems {
        public String productName {get; set;}
        public String price{get; set;}
        public String qty{get; set;}
        public String discount{get; set;}
        public String total{get; set;}
        public String sku{get; set;}
        public String uom{get; set;}
 
        public wrapCartItems(String a,String b,String c,String d,String e,String f,String g) {
            productName  = a;
            price= b;
            qty= c;
            discount= d;
            productName  = a;
            total= e;
            sku= f;
            uom= g;

        }
    }

     
   }