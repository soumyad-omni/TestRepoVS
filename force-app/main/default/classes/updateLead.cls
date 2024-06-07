global class updateLead {
  @InvocableMethod
  public static void updateleadrecord(List<ID> ids) {
    List<lead> updatel = new List<lead>();
    List<lead> le = [SELECT id,Classification__c,Omnicell_Job_Title__c FROM Lead WHERE Id in :ids];
    List<Job_title_Classification__c> custm = [SELECT name, Classification__c FROM Job_title_Classification__c];
    for (lead l : le) {
      for (Job_title_Classification__c c : custm) {
          if(l.Omnicell_Job_Title__c == c.name){
              l.Classification__c = c.Classification__c;
              updatel.add(l);
          }
          
    }
    }
      system.debug('updatel '+updatel);
    update updatel;
  }
}