@istest
public class SCP_CartEmailController_Test {
    
    @istest
    Public static void SCP_CartEmailController_Test_Method(){
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        String emailData='{"email_to":"test@test.com","email_cc":"test1.test.com","subject":"Test mail","description":"Desc"}';
        SCP_CartEmailController.sendEmail(ctx,emailData);
        //ctrl.sendEmail();
    }

}