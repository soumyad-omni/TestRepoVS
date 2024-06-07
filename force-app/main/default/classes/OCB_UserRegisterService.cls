/***********************************************************************************************************
Name:  OCB_UserRegisterService
Purpose : This class can be called from external system to enable the contact as B2b Register user.
Date : 3-Feb-2021                                                           
*************************************************************************************************************/

@RestResource(urlMapping='/OCB_UserRegisterService/*')
global class OCB_UserRegisterService {
    
    @HttpPost 
    global static String CreateUser(String CSN,String email) {
        try{
            List<Account> Acc = new List<Account>();
            acc= [select id,IsDeleted__c,RecordType.Name from account where Account_Role__c='ZCSN'and SAP_Customer_Number__c=:CSN];
            if(Acc.isEmpty()){
                return 'Account Role type should be Sold To for user enablement';
            }
            else{
                if(Acc[0].IsDeleted__c == TRUE){
                    return 'CSN is Inactive';
                }
                if(Acc[0].RecordType.name != 'US & Canada Customer'){
                    return 'non-US and CA accounts do not get B2B access';
                }
                List<Contact> ConLst =  new list<Contact>();
                ConLst = [SELECT Id,Email,Account.SAP_Customer_Number__c,LastName,FirstName from Contact where Email =:email and Account.SAP_Customer_Number__c=:CSN and Account.Account_Role__c ='ZCSN'];    
                User portalAccountOwner1 = new User();
                if(ConLst.size()>0){
                    Profile profileId = [select Id,name from Profile where Profile.Name =:System.Label.OCB_RegisterUserProfile limit 1];
                    system.debug(profileId.id+'********');
                    List<User> lUsers = [SELECT Id,Contact.Id,Name,Email,ProfileId,IsActive FROM User WHERE Profile.Name = 'Omnicell B2B Storefront Profile' AND ContactId IN :ConLst];
                    System.debug('UserList'+lUsers );
                    
                    if(!lUsers.isEmpty()){
                        
                        if(lUsers[0].Email == email && lUsers[0].IsActive == true){
                            return 'Active User exists';
                        }
                        else if(lUsers[0].Email == email && lUsers[0].IsActive == false){
                            return 'User exists with Inactive status';
                        }
                        //return 'User was created previously';
                        
                    }else{
                        portalAccountOwner1.ProfileId = profileId.id;
                        portalAccountOwner1.Username = ConLst[0].Email + System.now().millisecond();
                        portalAccountOwner1.Alias = 'b2b'+System.now().millisecond();
                        portalAccountOwner1.Email=ConLst[0].Email;
                        portalAccountOwner1.FederationIdentifier=ConLst[0].Email;
                        portalAccountOwner1.EmailEncodingKey='UTF-8';
                        portalAccountOwner1.Firstname=ConLst[0].FirstName;
                        portalAccountOwner1.Lastname=ConLst[0].LastName;
                        portalAccountOwner1.LanguageLocaleKey='en_US';
                        portalAccountOwner1.LocaleSidKey='en_US';
                        portalAccountOwner1.TimeZoneSidKey='America/Chicago';
                        portalAccountOwner1.ContactId=ConLst[0].Id;
                        insert portalAccountOwner1;
                    }
                }   
                return 'User is Created :' +portalAccountOwner1.Id;
            }
        } catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
            return 'User is not enabled';
        }
    }   
}