/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 07-06-2020
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   07-06-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class RenderCreateContractController {
    @AuraEnabled
    public static List<String> getContract(Id conId){
        Contracts__c c = [select id,GPOCheck__c,Type__c,status__c,name,Customer_Number__c,Account__r.Name,Conga_Template_Id__c,Conga_Email_Template_Id__c ,Conga_Session_Id__c from Contracts__c where id=:conId];
        List<Conga_Email_Template_Contract__c> emailList = [select id,Name,Email_Template_Id__c from Conga_Email_Template_Contract__c where Name='Contract Email Template' limit 1];
        List<Conga_Contract_GPO_Check__c> templateid =  [select id, name ,Template_Id__c  from Conga_Contract_GPO_Check__c]; 
        //if(c.Status__c == 'Approved')
        system.debug('contract '+c);
        system.debug('emailList '+emailList);
        List<String> cList = new List<String>();
        cList.add(c.Status__c);
        cList.add(c.Name);
        if(c.GPOCheck__c == true && c.Type__c == 'Boilerplate Master Agreement'){
            system.debug('gpo check');
            cList.add(templateid[0].Template_Id__c);
        }
        else
            cList.add(c.Conga_Template_Id__c);
        cList.add(c.Conga_Session_Id__c);
        cList.add(emailList[0].Email_Template_Id__c);
        User u = [select profile.Name,email from User where id=:userinfo.getuserid() limit 1];
        cList.add(u.Email);
        
        if(u.profile.name == 'System Administrator' || u.profile.name == 'Booking Team' || u.profile.name == 'Business Administrator'
           || u.profile.name == 'International Sales Ops'){
               cList.add('Valid User');
           }
        else {
            cList.add('Invalid User');
        }
        
        cList.add(c.Customer_Number__c);
        cList.add(c.Account__r.Name);
        system.debug('cList  '+cList);
        return cList;
        
        
        
        //else
        //return 'Not_Approved';
    }
    
    
    @AuraEnabled
    public static List<String> getQuoteApproval(Id qaId){
        List<Quote_Approval__c> q = [select id,Next_Version__c,Version__c,Name,Conga_Session_Id__c,Account_Name__c,SAP_Quote_Number__c from Quote_Approval__c where id=:qaId]; //soumyad sf-bug-1021 added new fields to query
        List<String> cList = new List<String>();
        if(q.size()>0){
            List<Conga_Summary_Smartsheet__c> summaryList = [Select id,Smartsheet_Id__c from Conga_Summary_Smartsheet__c limit 1];
            string qname = q[0].Name + ' QT ' + q[0].SAP_Quote_Number__c + ' ' + q[0].Account_Name__c + '.SummarySheet'; //IBA-6018
            //if(c.Status__c == 'Approved')
            
            //cList.add(c.Status__c);
            cList.add(qname); //soumyad sf-bug-1021
            //cList.add(c.Conga_Template_Id__c);
            cList.add(q[0].Conga_Session_Id__c);
            cList.add(summaryList[0].Smartsheet_Id__c);
            
            cList.add(String.valueof(q[0].Next_Version__c));
            if(q[0].Version__c == null)
                cList.add('');
            else
                cList.add(String.valueof(q[0].Version__c));
            System.debug('Version : '+q[0].Version__c);
            //User u = [select profile.Name,email from User where id=:userinfo.getuserid() limit 1];
            //cList.add(u.Email);
        }else {
            cList.add('noquoteapproval');
        }
        
        return cList;
        
        
        
        //else
        //return 'Not_Approved';
    }
    
    @AuraEnabled
    public static List<String> getQuote(Id conId){
        List<Conga_Email_Template_Contract__c> emailList = [select id,Name,Email_Template_Id__c from Conga_Email_Template_Contract__c where Name='QuoteSignatureTemplate' limit 1];
        System.debug('emailList : '+emailList[0]);
        Quote c = [select id,status from Quote where id=:conId];
        List<Quote_Approval__c> qa = [select id,recordtypeid from quote_approval__c where quote__c = :conId order by createddate desc limit 1];
        List<String> cList = new List<String>();
        if(qa.size()>0){
            System.debug('QA : '+qa);
            String recordtype = Schema.getGlobalDescribe().get('Quote_Approval__c').getDescribe().getRecordTypeInfosById().get(qa[0].RecordTypeId).getName();
            //List<Conga_Contract_GPO_Check__c> templateid =  [select id, name ,Template_Id__c  from Conga_Contract_GPO_Check__c]; 
            //if(c.Status__c == 'Approved')
            
            //cList.add(c.Status);
            if(c.status == 'E0021' || c.status == 'E0009')
                cList.add(emailList[0].Email_Template_Id__c);
            else
                cList.add('NotApproved');
            if(recordtype != 'NAA Supplement Quote'){
                cList.add('NotSupplementQuote');
            }
        }else{
            cList.add('NoQuoteApproval');
        }
        return cList;
        
        
        
        //else
        //return 'Not_Approved';
    }
    
    
    
    @AuraEnabled 
    public static String getUser(){
        User u = [select profile.Name from User where profileid =: UserInfo.getProfileId() limit 1];
        System.debug('User Profile : '+u.profile.name);
        Conga_Print_Output__c sys = [select profile_Name__c from Conga_Print_Output__c where name = 'System Admin'];
        String sysadmin = sys.Profile_Name__c;
        Conga_Print_Output__c bus = [select profile_Name__c from Conga_Print_Output__c where name = 'Business Admin'];
        String busadmin = bus.Profile_Name__c;
        Conga_Print_Output__c dealdesk = [select profile_Name__c from Conga_Print_Output__c where name = 'Booking Team'];
        String deal = dealdesk.Profile_Name__c;
        
        if(u.profile.name == 'System Administrator' || u.profile.name == 'Booking Team' || u.profile.name == 'Business Administrator' 
           || u.profile.name == 'International Sales Ops'){
               return 'true';
           }
        return 'false';
    }
    
    @AuraEnabled 
    public static String getUserBooking(){
        User u = [select profile.Name from User where profileid =: UserInfo.getProfileId() limit 1];
        System.debug('User Profile : '+u.profile.name);
        Conga_Print_Output__c sys = [select profile_Name__c from Conga_Print_Output__c where name = 'System Admin'];
        String sysadmin = sys.Profile_Name__c;
        Conga_Print_Output__c bus = [select profile_Name__c from Conga_Print_Output__c where name = 'Business Admin'];
        String busadmin = bus.Profile_Name__c;
        Conga_Print_Output__c bookingteam = [select profile_Name__c from Conga_Print_Output__c where name = 'Booking Team'];
        String booking = bookingteam.Profile_Name__c;
        Conga_Print_Output__c dealdesk = [select profile_Name__c from Conga_Print_Output__c where name = 'Deal Desk'];
        String deal = dealdesk.Profile_Name__c;
        
        //if(quote.Conga_Loggedin_User__c != busadmin && u.profile.name != sysadmin && u.profile.name != deal){
        // return 'Error';    
        //}
        Conga_Print_Output__c internationalP= [select profile_Name__c from Conga_Print_Output__c where name = 'International Sales Ops'];
        String international= internationalP.Profile_Name__c;
        
        if(u.profile.name == sysadmin || u.profile.name == busadmin || u.profile.name == booking || u.profile.name == deal
           ||u.profile.name==international){
               return 'true';
           }
        return 'false';
    }
    @AuraEnabled
    public static List<String> getContractWf3(Id conId){
        Contracts__c c = [select id,Booking_team_Approved_WF3__c,Workflow_3_check__c,GPOCheck__c,Type__c,status__c,name,Customer_Number__c,Account__r.Name,Conga_Template_Id__c,Conga_Email_Template_Id__c ,Conga_Session_Id__c from Contracts__c where id=:conId];
        List<Conga_Email_Template_Contract__c> emailList = [select id,Name,Email_Template_Id__c from Conga_Email_Template_Contract__c where Name='ConractSignatureTemplate' limit 1];
        List<echosign_dev1__SIGN_Agreement__c> aglist = [SELECT Id,echosign_dev1__Status__c FROM echosign_dev1__SIGN_Agreement__c where contracts__c =:c.id order by lastmodifieddate desc limit 1];
        List<String> cList = new List<String>();
        System.debug('emailList : '+emailList[0]);
        if(c.Booking_team_Approved_WF3__c != true){ 
            //|| agList[0].echosign_dev1__Status__c != 'Signed'){
            cList.add('true');
        }
        else
            cList.add('false');
        cList.add(emailList[0].Email_Template_Id__c);
        return cList;        
        
    }
    @AuraEnabled
    public static String contractsignaturecheck(Id conId){
        Contracts__c c = [select id,Booking_team_Approved_WF3__c,Workflow_3_check__c,GPOCheck__c,Type__c,status__c,name,Customer_Number__c,Account__r.Name,Conga_Template_Id__c,Conga_Email_Template_Id__c ,Conga_Session_Id__c from Contracts__c where id=:conId];
        List<echosign_dev1__SIGN_Agreement__c> aglist = [SELECT Id,echosign_dev1__Status__c FROM echosign_dev1__SIGN_Agreement__c where contracts__c =:c.id order by lastmodifieddate desc limit 1];
        list<ProcessInstance> existingApprovals = [SELECT Id, TargetObjectId
                                                   FROM ProcessInstance 
                                                   WHERE TargetObjectId =:c.id
                                                   AND Status = 'Pending'];
        if(existingApprovals.size()>0){
            return 'false';
        }
        else if(agList.size()>0){ 
            if((agList[0].echosign_dev1__Status__c != 'Signed' && agList[0].echosign_dev1__Status__c != 'Draft' &&
                agList[0].echosign_dev1__Status__c != 'Pre-Send' && agList[0].echosign_dev1__Status__c != 'Approved' && 
                agList[0].echosign_dev1__Status__c != 'Cancelled / Declined' && 
                agList[0].echosign_dev1__Status__c != 'Out for Approval' && 
                agList[0].echosign_dev1__Status__c != 'Expired' && 
                agList[0].echosign_dev1__Status__c != 'Created') || c.Booking_team_Approved_WF3__c != true){
                    return 'alreadysubmitted';
                }
            else{
                return 'true';
            }
        }
        else if(c.Booking_team_Approved_WF3__c == false){
            return 'false';
        }
        else{
            return 'true';
        }
        
    }
    /* Added by Pavan Kumar for launching the Adobe sign url 
        IBA-1266
    */
    @AuraEnabled(cacheable=true)
    public static string getAdobeSignUrl(String recordId, String templateId){
        Pagereference pg = Page.echosign_dev1__AgreementTemplateProcess;
        pg.getParameters().put('masterid',recordId);
        pg.getParameters().put('templateId',templateId);
        return pg.getUrl();
    }
}