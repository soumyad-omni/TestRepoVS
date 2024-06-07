/**********************************************************************
Name:  UpdateLockedCheckBox_Class
Copyright © 2018
======================================================
======================================================
Purpose: 
Controller for Lightning Component "Configurator.cmp", 
If SAP Quote Number is present but Quoteline items are not present, it will not allow user to Edit the record.
This class will flag Locked__c checkbox True.
                                                            
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL                     Description
0.1         Amruta Dhumal              30/7/2018      Developed by CG Team        INITIAL DEVELOPMENT
***********************************************************************/
public class UpdateLockedCheckBox_Class{

    /*@AuraEnabled

    public static void updateCheck(Id quoteId){

        List<Quote> quotelist = new List<Quote>([select id,Locked__c from Quote where Id =:quoteId]);
        List<Quote> updatequotelist = new List<Quote>();
        
        for (Quote qte : quotelist)
        {
          Quote q =new Quote();
           q.id = qte.id;
           q.Locked__c = true;
           system.debug('q.Locked__c...'+q.Locked__c);
          
           updatequotelist.add(q);
           
        }
        
        try{
             update updatequotelist;
             system.debug('list....'+updatequotelist);
           }
          catch(Exception e){
              System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
              ErrorLogging.Log(e, 'UpdateLockedCheckBox_Class','App');
            } 
          
         
    }*/
    
    @AuraEnabled
   public static decimal fetchQuoteLine(Id quoteId) {
    
     List<Quote_Line__c> qlList = [select Name, Higher_Level_Item__c, SAP_Line_Number__c,Quote__r.SAP_Last_Line_Number__c from Quote_Line__c where Quote__c =:quoteId order by SAP_Line_Number__c desc ];
     system.debug('qlList...'+qlList);
     decimal higherlevel = 0;
     
     if(qlList.size()>0)
     {
       for(Quote_Line__c ql : qlList)
       {
         system.debug('inside for..');
         if(ql.SAP_Line_Number__c == ql.Quote__r.SAP_Last_Line_Number__c)
        {
           system.debug('inside if...');
            if(ql.Higher_Level_Item__c == null){
                //higherlevel = 200;
                higherlevel  += 200+ql.SAP_Line_Number__c;
                system.debug('higherlevel...'+ql.SAP_Line_Number__c);
            }
            else{
                higherlevel = ql.Higher_Level_Item__c;
                higherlevel +=200;
                 system.debug('higher level..'+higherlevel);
            }
        
         }
     
       }
     }
     
     if(qlList.isEmpty())
     {
       higherlevel = 200;
       system.debug('higher level..'+higherlevel);
     }
     return higherlevel;
      
 }
    
    
    @AuraEnabled
    public static Decimal getNextAvailableQuoteLineSAPNumber(Id quoteId) {
        
        Decimal highestParent, nextAvailableSAPNumber = 0; 
        //Get the highest parent and increment by 200 
        List<aggregateResult> queryHighestParent = 
            [select MAX(SAP_Line_Number__c) max from Quote_Line__c where Quote__c =: quoteId and (Higher_Level_Item__c = 0 or Higher_Level_Item__c = null)];
        if (queryHighestParent.size() > 0) 
            highestParent = queryHighestParent[0].get('max') != null ? (Decimal) queryHighestParent[0].get('max') : 0;  
        nextAvailableSAPNumber = highestParent + 200;
        return nextAvailableSAPNumber; 
        
    }
   
    @AuraEnabled
   public static string baseURL(Id quoteId) {
     
      String baseurl='';
      
      Configurator__c csValue1 = Configurator__c.getInstance('Configurator');
      baseurl = csValue1.CincomBaseURL__c; 
      system.debug('baseurl...'+baseurl);
      return baseurl;
      
 } 
    @AuraEnabled
   public static DateTime legacycreateddate(Id quoteId) {
       Quote q = [select id,Legacy_SAP_Created_Date__c from Quote where id=:quoteId limit 1];
       DateTime legcrdt = q.Legacy_SAP_Created_Date__c;
       return legcrdt;
 } 
    
   @AuraEnabled 
    public static boolean getUser123(){
        User u = [select profile.Name from User where profileid =: UserInfo.getProfileId() limit 1];
        PermissionSetAssignment[] u1 = [SELECT AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'Configurator_Edit'];
        string uu = 'f';
        if (u1!=null && !u1.isEmpty()){
            uu = 't';
        }
        //System.debug('User Profile : '+uu);
        Conga_Print_Output__c sys = [select profile_Name__c from Conga_Print_Output__c where name = 'System Admin'];
        String sysadmin = sys.Profile_Name__c;
        Conga_Print_Output__c bus = [select profile_Name__c from Conga_Print_Output__c where name = 'Business Admin'];
        String busadmin = bus.Profile_Name__c;
        Conga_Print_Output__c dealdesk = [select profile_Name__c from Conga_Print_Output__c where name = 'Deal Desk'];
        String deal = dealdesk.Profile_Name__c;
        Conga_Print_Output__c Bookingprf = [select profile_Name__c from Conga_Print_Output__c where name = 'Booking Team'];
        String booking = Bookingprf.Profile_Name__c;
        
        
        if(u.profile.name == sysadmin || u.profile.name == busadmin || u.profile.name == deal ||u.profile.name == booking || uu == 't'){
            return true;
        }
        return false;
    }
    
    @AuraEnabled 
    public static boolean qstat(Id qid){
        list<Quote_Approval__c> qap = [select id,Status__c from Quote_Approval__c where Quote__c = :qid order by lastmodifieddate desc limit 1];
        string uu = 'f';
        for(Quote_Approval__c qq : qap){
                        if(qq.Status__c == 'Waiting Approval'){
                            uu = 't';
                        }
        }
        if (uu == 't'){
            return true;
        }
        return false;
    }
}