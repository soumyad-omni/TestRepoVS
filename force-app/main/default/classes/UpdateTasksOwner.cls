public class UpdateTasksOwner {
    public static void updateTask(){
        Set<Id> conIdSet = new Set<Id>();
        Set<Id> ldIdSet = new Set<Id>();
        String user340BId;
        String userEnlivenHealthId;
        for(User usr: [Select Id, Name from User where Name = 'Breanna Reeves' OR Name = 'Eric Reese']){
            if(usr.Name == 'Breanna Reeves'){
                user340BId = usr.Id;
            }else if(usr.Name == 'Eric Reese'){
                userEnlivenHealthId = usr.Id;
            }
        }
        Set<String> acuteFacilityTypeSet = new Set<String>{'Short-term Acute Care Hospital', 'Children\'s Hospital', 'Critical Access', 'Department of Defense', 'Health System', 'VA Hospital', 'GPO'};
        Set<String> norUseForUSAndCanadaAccFacilityTypeSet = new Set<String>{'Distributor', 'Non Acute International', 'Hospital International'};
            for(Task  tsk: [SELECT Id, WhoId, Facility_Type__c, Owner.Name, Owner.Username, Who.Type  from Task where (Status = 'Not Started' OR Status = 'In Progress') AND Activity_SubType__c = 'Follow-up on Marketing Campaign Contact/Lead' AND Facility_Type__c  != null]){
                //System.debug('tsk--------> ' + tsk);
                if(tsk.Who.Type == 'Contact'){
                    conIdSet.add(tsk.WhoId);
                }else{
                    ldIdSet.add(tsk.WhoId);
                }
            }

        Map<Id, Contact> idConMap = new Map<Id, Contact>([Select Id,Recent_Conversion_Campaign__c,Marketing_Portfolio_Segment__c, MailingState, Lead_Status__c from Contact where Score_Threshold_Met__c = true AND Id IN :conIdSet]);
        Map<Id, Lead> idLdnMap = new Map<Id, Lead>([Select Id,Recent_Conversion_Campaign__c,Marketing_Portfolio_Segment__c, State, Status from Lead where Score_Threshold_Met__c = true AND Id IN :ldIdSet]);
        Map<String, String> stateVsUserIdMapAcute = new Map<String, String>{'Alabama' => '0053l00000FzaLYAAZ','Alaska' => '0053l00000FzoTgAAJ','Arizona' => '0053l00000FzoTgAAJ','Arkansas' => '0053l00000FzcTPAAZ','California' => '0053l00000FzoTgAAJ','Colorado' => '0053l00000FzcTPAAZ','Connecticut' => '0053l00000Fzj6mAAB','District of Columbia' => '0053l00000FzaLYAAZ','Delaware' => '0053l00000FzaLYAAZ','Florida' => '0053l00000FzcTFAAZ','Georgia' => '0053l00000FzcTFAAZ','Hawaii' => '0053l00000FzoTgAAJ','Idaho' => '0053l00000FzoTgAAJ','Illinois' => '0053l00000Fzj6XAAR','Indiana' => '0053l00000FzaLYAAZ','Iowa' => '0053l00000Fzj6XAAR','Kansas' => '0053l00000FzcTPAAZ','Kentucky' => '0053l00000FzaLYAAZ','Louisiana' => '0053l00000FzcTFAAZ','Maine' => '0053l00000Fzj6mAAB','Maryland' => '0053l00000FzaLYAAZ','Massachusetts' => '0053l00000Fzj6mAAB','Michigan' => '0053l00000Fzj6XAAR','Minnesota' => '0053l00000Fzj6XAAR','Mississippi' => '0053l00000FzcTFAAZ','Missouri' => '0053l00000Fzj6XAAR','Montana' => '0053l00000FzoTgAAJ','Nebraska' => '0053l00000Fzj6XAAR','Nevada' => '0053l00000FzoTgAAJ','New Hampshire' => '0053l00000Fzj6mAAB','New Jersey' => '0053l00000Fzj6mAAB','New Mexico' => '0053l00000FzcTPAAZ','New York' => '0053l00000Fzj6mAAB','North Carolina' => '0053l00000FzaLYAAZ','North Dakota' => '0053l00000Fzj6XAAR','Ohio' => '0053l00000FzaLYAAZ','Oklahoma' => '0053l00000FzcTPAAZ','Oregon' => '0053l00000FzoTgAAJ','Pennsylvania' => '0053l00000Fzj6mAAB','Rhode Island' => '0053l00000Fzj6mAAB','South Carolina' => '0053l00000FzcTFAAZ','South Dakota' => '0053l00000FzoTgAAJ','Tennessee' => '0053l00000FzaLYAAZ','Texas' => '0053l00000FzcTPAAZ','Utah' => '0053l00000FzcTPAAZ','Vermont' => '0053l00000Fzj6mAAB','Virginia' => '0053l00000FzaLYAAZ','Washington' => '0053l00000FzoTgAAJ','West Virginia' => '0053l00000Fzj6mAAB','Wisconsin' => '0053l00000Fzj6XAAR','Wyoming' => '0053l00000FzoTgAAJ','Puerto Rico' => '0053l00000FzcTFAAZ','Virgin Islands' => '0053l00000FzcTFAAZ','Jamaica' => '0053l00000FzcTFAAZ','Bermuda ' => '0053l00000FzcTFAAZ','Quebec' => '0051N000007EGLlQAO','New Brunswick' => '0051N000007EGLlQAO'};
        Map<String, String> stateVsUserIdMapNonAcute = new Map<String, String>{'Delaware' => '0051N000007IZE6QAO','District of Columbia' => '0051N000007IZE6QAO','Indiana' => '0051N000007IZE6QAO','Kentucky' => '0051N000007IZE6QAO','Ohio' => '0051N000007IZE6QAO','Virginia' => '0051N000007IZE6QAO','Illinois' => '0051N000007IZK2QAO','Iowa' => '0051N000007IZK2QAO','Michigan' => '0051N000007IZK2QAO','Minnesota' => '0051N000007IZK2QAO','Missouri' => '0051N000007IZK2QAO','Nebraska' => '0051N000007IZK2QAO','North Dakota' => '0051N000007IZK2QAO','South Dakota' => '0051N000007IZK2QAO','Wisconsin' => '0051N000007IZK2QAO','Connecticut' => '0051N000007IZE6QAO','Maine' => '0051N000007IZE6QAO','Maryland' => '0051N000007IZE6QAO','Massachusetts' => '0051N000007IZE6QAO','New Hampshire' => '0051N000007IZE6QAO','New Jersey' => '0051N000007IZE6QAO','New York' => '0051N000007IZE6QAO','Pennsylvania' => '0051N000007IZE6QAO','Rhode Island' => '0051N000007IZE6QAO','Vermont' => '0051N000007IZE6QAO','West Virginia' => '0051N000007IZE6QAO','Alaska' => '0051N000007IZK2QAO','Arizona' => '0051N000007IZK2QAO','California' => '0051N000007IZK2QAO','Hawaii' => '0051N000007IZK2QAO','Idaho' => '0051N000007IZK2QAO','Montana' => '0051N000007IZK2QAO','Nevada' => '0051N000007IZK2QAO','Oregon' => '0051N000007IZK2QAO','Washington' => '0051N000007IZK2QAO','Wyoming' => '0051N000007IZK2QAO','Alabama' => '0051N000007199QQAQ','Florida' => '0051N000007199QQAQ','Georgia' => '0051N000007199QQAQ','Louisiana' => '0051N000007199QQAQ','Mississippi' => '0051N000007199QQAQ','North Carolina' => '0051N000007199QQAQ','South Carolina' => '0051N000007199QQAQ','Tennessee' => '0051N000007199QQAQ','Arkansas' => '0051N000007199QQAQ','Colorado' => '0051N000007199QQAQ','Kansas' => '0051N000007199QQAQ','New Mexico' => '0051N000007199QQAQ','Oklahoma' => '0051N000007199QQAQ','Texas' => '0051N000007199QQAQ','Utah' => '0051N000007199QQAQ'};
                
        List<Task> tsk2UpdateList = new List<Task>();
        for(Task  tsk: [SELECT Id, WhoId, Facility_Type__c, Owner.Name, Owner.Username, Who.Type  from Task where (Status = 'Not Started' OR Status = 'In Progress') AND Activity_SubType__c = 'Follow-up on Marketing Campaign Contact/Lead' AND Facility_Type__c  != null]){
            Task tsk2Update = new Task(Id = tsk.Id);
            if(tsk.Who.Type == 'Contact' && idConMap.get(tsk.WhoId) != null){
                Contact con = idConMap.get(tsk.WhoId);
                System.debug('tsk.Facility_Type__c-----------> ' + tsk.Facility_Type__c);
                if((con.Lead_Status__c != null && con.Lead_Status__c != 'Rejected') && ((con.Recent_Conversion_Campaign__c != null && con.Recent_Conversion_Campaign__c.contains('340B')) || (con.Marketing_Portfolio_Segment__c != null && con.Marketing_Portfolio_Segment__c.contains('Omnicell 340B')))){
               //IBA-4524       tsk2Update.New_Owner__c = user340BId;
                }else if((con.Lead_Status__c != null && con.Lead_Status__c != 'Rejected') && ((con.Recent_Conversion_Campaign__c != null && con.Recent_Conversion_Campaign__c.contains('EnlivenHealth')) || (con.Marketing_Portfolio_Segment__c != null && (con.Marketing_Portfolio_Segment__c.contains('Patient Engagement') || con.Marketing_Portfolio_Segment__c.contains('Patient Communications'))))){
                   //IBA-4524   tsk2Update.New_Owner__c = userEnlivenHealthId;
                }else if(acuteFacilityTypeSet.contains(tsk.Facility_Type__c)){
                  //IBA-4524    tsk2Update.New_Owner__c = stateVsUserIdMapAcute.get(con.MailingState);
                }else if(!norUseForUSAndCanadaAccFacilityTypeSet.contains(tsk.Facility_Type__c)){
                  //IBA-4524    tsk2Update.New_Owner__c = stateVsUserIdMapNonAcute.get(con.MailingState);
                }
            }else if(tsk.Who.Type == 'Lead' && idLdnMap.get(tsk.WhoId) != null){
                Lead ld = idLdnMap.get(tsk.WhoId);
                if((ld.Status != null && ld.Status != 'Rejected') && ((ld.Recent_Conversion_Campaign__c != null && ld.Recent_Conversion_Campaign__c.contains('340B')) || (ld.Marketing_Portfolio_Segment__c != null && ld.Marketing_Portfolio_Segment__c.contains('Omnicell 340B')))){
                   //IBA-4524  tsk2Update.New_Owner__c = user340BId;
                }else if((ld.Status != null && ld.Status != 'Rejected') && ((ld.Recent_Conversion_Campaign__c != null && ld.Recent_Conversion_Campaign__c.contains('EnlivenHealth')) || (ld.Marketing_Portfolio_Segment__c != null && (ld.Marketing_Portfolio_Segment__c.contains('Patient Engagement') || ld.Marketing_Portfolio_Segment__c.contains('Patient Communications'))))){
                   //IBA-4524   tsk2Update.New_Owner__c = userEnlivenHealthId;
                }else if(acuteFacilityTypeSet.contains(tsk.Facility_Type__c)){
                 //IBA-4524     tsk2Update.New_Owner__c = stateVsUserIdMapAcute.get(ld.State);
                }else if(!norUseForUSAndCanadaAccFacilityTypeSet.contains(tsk.Facility_Type__c)){
                    //IBA-4524  tsk2Update.New_Owner__c = stateVsUserIdMapNonAcute.get(ld.State);
                }
            }
          /*  if(tsk2Update.New_Owner__c!=null){
                tsk2UpdateList.add(tsk2Update);
            }  IBA-4524*/
            tsk2UpdateList.add(tsk2Update);   //IBA-4524
        }
        System.debug('tsk2UpdateList ----> ' + tsk2UpdateList);
        if(tsk2UpdateList.size() > 0){
            update tsk2UpdateList;
        }
    }
    
    public static void updateLeadOwner(){
        String user340BId;
        String userEnlivenHealthId;
        for(User usr: [Select Id, Name from User where Name = 'Breanna Reeves' OR Name = 'Eric Reese']){
            if(usr.Name == 'Breanna Reeves'){
                user340BId = usr.Id;
            }else if(usr.Name == 'Eric Reese'){
                userEnlivenHealthId = usr.Id;
            }
        }
        List<Lead> lead2UpdateList = new List<Lead>();
        for(Lead ld: [Select Id, Recent_Conversion_Campaign__c, Marketing_Portfolio_Segment__c from Lead where (Recent_Conversion_Campaign__c like '%340B%' OR Recent_Conversion_Campaign__c like '%EnlivenHealth%' OR Marketing_Portfolio_Segment__c includes('Patient Engagement', 'Patient Communications','Omnicell 340B')) and Status != 'Rejected']){
            Lead lead2Update = new Lead(Id = ld.Id);
            if((ld.Marketing_Portfolio_Segment__c != null && ld.Marketing_Portfolio_Segment__c.Contains('Omnicell 340B')) || (ld.Recent_Conversion_Campaign__c != null && ld.Recent_Conversion_Campaign__c.contains('340B'))){
                lead2Update.OwnerId = user340BId;
            }else if(((ld.Recent_Conversion_Campaign__c != null && ld.Recent_Conversion_Campaign__c.contains('EnlivenHealth')) || (ld.Marketing_Portfolio_Segment__c != null && (ld.Marketing_Portfolio_Segment__c.contains('Patient Engagement') || ld.Marketing_Portfolio_Segment__c.contains('Patient Communications'))))){
                lead2Update.OwnerId = userEnlivenHealthId;
            }
            lead2UpdateList.add(lead2Update);
        }
        
        if(lead2UpdateList.size() > 0){
            update lead2UpdateList;
        }
    }
}