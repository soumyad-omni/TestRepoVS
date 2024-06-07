/**
* @description       : IBA-3094:Scheduler to remove permission set
* @author            : Pabitra Tripathy
* @group             : 
* @last modified on  : 09-13-2023
* @last modified by  : Pabitra Tripathy
* Modifications Log 
* Ver   Date         Author             Modification
* 1.0   09-13-2023   Pabitra Tripathy   Initial Version
**/

public class LoginAsAccessController {
    
    static String userId=UserInfo.getUserId(); 
    static String userEmailId=UserInfo.getUserEmail();
    static String modifyallPermId=null;
    static{
        List<LoginAsPermission__c> loginasperm = LoginAsPermission__c.getall().values();
        if(loginasperm.size()>0){
            modifyallPermId=loginasperm[0].id__c;
        }
    }
    
    
    @AuraEnabled
    public static boolean isLoginAccessPermAssigned() {
        Boolean retVal=true;      
        if(modifyallPermId!=null){
            List<PermissionSetAssignment> pmAsst= [SELECT Id from PermissionSetAssignment WHERE PermissionSetId =: modifyallPermId AND AssigneeId =:userId];
            if (pmAsst.size()>0){
                retVal=false; // if perm assigned then disable the button
            }else{
                System.debug('LoginAsAccess:Permset isn\'t assigned') ;
            }
        }
        return retVal;        
    }
    
    
    @AuraEnabled
    public static Boolean grantLoginAsAccess() {
        if(modifyallPermId!=null){
            String resetDurationStr=System.Label.LoginAsAccessResetDuration;
            Integer resetDuration=24;//default 24hr
            
            if (resetDurationStr!=null&&resetDurationStr.isNumeric()){
                resetDuration=Integer.valueOf(resetDurationStr);
            }

			Datetime nextResetTime = Datetime.now().addHours(resetDuration);           
            String dayOfWeekString = nextResetTime.format('u'); // 'u' extract day (1-7 for mon-sun)
            Integer dayOfWeek = Integer.valueOf(dayOfWeekString);
            String ss = String.valueOf(nextResetTime.second());
            String min = String.valueOf(nextResetTime.minute());
            String hour = String.valueOf(nextResetTime.hour());
            String day = String.valueOf(nextResetTime.day());
            String month = String.valueOf(nextResetTime.month());
            String year = String.valueOf(nextResetTime.year());			
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month + ' ? '+year;         
            
            assignLoginAsPerm(modifyallPermId,userId);
           // sendEmail(userEmailId);
            //scheduler to remove permission set - modifyall
            ScheduleLoginAsPermOff schLoginAsOff=new ScheduleLoginAsPermOff(modifyallPermId,userId);
            System.schedule('LoginAsRmvPermSetSch'+nextFireTime, nextFireTime, schLoginAsOff);
        }else{
            System.debug('LoginAsAccess:LoginAsPermission isn\'t set');
        }
        
        return false;
    }
    
    @future
    public static void assignLoginAsPerm(string perm,String userId){        
        
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = perm, AssigneeId = userId);
        permissionSetList.add(psa);
        insert permissionSetList;  
    }
    
    public static void sendEmail(String userEmail){
        
        List<LoginAsAccessEmailSettings__c> emailSetting = LoginAsAccessEmailSettings__c.getall().values();
        if(emailSetting.size()>0){	
            List<String> to =emailSetting[0].to__c.split('[,;]');
            String subject = emailSetting[0].subject__c;
            String body = emailSetting[0].body__c;
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setReplyTo(userEmail);
            email.setToAddresses(to);
            email.setSubject(subject+userEmail);
            email.setUseSignature(false); 
            email.setBccSender(false); 
            email.setSaveAsActivity(false);
            email.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }else{
            System.debug('LoginAsAccess:Please update LoginAsAccessEmailSettings');
        }
    }
}