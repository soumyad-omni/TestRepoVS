public class NewCampaignOverrideController {
	@AuraEnabled 
    public static Profile fetchUser(){
       Profile p = [select id,Name FROM Profile where id =: userInfo.getProfileId() ];
       return p;
    }
}