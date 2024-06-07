public class importDataFromCSVController {
    public boolean rendermessages{get;set;}
    public boolean disabled{get;set;}
    public String documentName {get;set;}
    public Date startDate { get; set; }
    public Date endDate { get; set; }
    public Blob csvFileBody{get;set;}
    Public UserTerritory2Association ut2a{get;set;}
    public String user{get; set;}
    public String userName{get; set;}
    public String[] accountcsnDataLines {get;set;}
    String accountcsnAsString;
    String accountcsnAsString2;
    public boolean readSuccess {get;set;}
    List<Opportunity> oppListNew = new List<Opportunity>();
    List<Id> oppid = new List<Id>();
    Set<ID> accid = new Set<ID>();
    public importDataFromCSVController(ApexPages.StandardController controller) {
        this.ut2a = (UserTerritory2Association)controller.getRecord();
        documentName = '';
        readSuccess = FALSE;
        accountcsnDataLines = new String[] {};
        disabled = true;
        List<User> u = [select Name,Id from user where Name Like :userName];
        if(u.size()>0)
        userName = u[0].name;
    }
    public void readFromFile(){
        try{
            if(csvFileBody != null){
                System.debug('***NotNull');
                accountcsnAsString = csvFileBody.toString();
                readCSVFile();
            }
            else if(csvFileBody == null){ //if no CSV is uploaded

            List<Opportunity> opplist = [Select id,CloseDate,AccountId,ownerId From Opportunity Where StageName = '6 Closed Won'];

            for(Opportunity op: opplist){
                if(startDate<=op.CloseDate && op.CloseDate<=endDate){
                    oppid.add(op.Id);
                    //oppListNew.add(op);
                }
            }
            if(oppid.size() > 0){
                readSuccess = TRUE;
                System.debug('***Null');
                saveData();
            }
        }
    }
    catch(exception e){
        readSuccess = FALSE;
        rendermessages = true;
        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Error reading CSV file');
        ApexPages.addMessage(errorMessage);
    }
}
public void readCSVFile() {
    accountcsnDataLines = accountcsnAsString.split('\n');
    List<String> accountcsn = new List<String>();

    for(Integer i=1;i<accountcsnDataLines.size();i++)
    {
        System.debug('***'+accountcsnDataLines[i]);
        String st = accountcsnDataLines[i].remove(',');
        accountcsn.add(st.trim());
    }
    for(String stt: accountcsn)
    {
        System.debug('***'+stt);
    }
    System.debug('***'+accountcsn.size());

    List<String> accountcsn2 = accountcsn;
    List<Account> acc = [Select id From Account Where SAP_Customer_Number__c IN :accountcsn];
    For(Account ac: acc)
    {
        accid.add(ac.id);
    }
    System.debug('***'+accid.size()+'***'+accid);

    List<Opportunity> opplist = [Select id,CloseDate,AccountId,ownerId From Opportunity Where AccountId IN :accid AND StageName = '6 Closed Won'];

    for(Opportunity op: opplist){
        if(startDate<=op.CloseDate && op.CloseDate<=endDate){
            oppid.add(op.Id);
            oppListNew.add(op);
        }
    }
    System.debug('***'+oppid);
    if(oppid.size() > 0){
        readSuccess = TRUE;
        saveData();
    }
    else{
        rendermessages = true;
        ApexPages.Message successMessage = new ApexPages.Message(ApexPages.severity.INFO, 'No Opportunity found to Update Opportunity Team');
        ApexPages.addMessage(successMessage);
    }
}
public void saveData() {
    try {
        disabled = false;
        System.debug('***'+oppid.size()+ 'In save');
        importDataFromCSV_Batch createOppTMBatch = new importDataFromCSV_Batch();
        createOppTMBatch.opportunityIds = oppid;
        createOppTMBatch.user_selected = userName;
        createOppTMBatch.role_selected = ut2a.RoleInTerritory2;
        createOppTMBatch.startDate = startDate;//IBA-6127
        createOppTMBatch.endDate = endDate;//IBA-6127
        Database.executeBatch(createOppTMBatch, 1);
        rendermessages = true;
        ApexPages.Message successMessage = new ApexPages.Message(ApexPages.severity.INFO, 'Job to update Opportunity Team Member started successfully for '+oppid.size()+' Opportunities');
        ApexPages.addMessage(successMessage);
        redirectToHome();
    }
    catch (Exception e) {
        rendermessages = true;
        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occured while saving data');
        ApexPages.addMessage(errorMessage);
    }

}
public pagereference redirectToHome(){
    Pagereference  page = new PageReference('/lightning/page/home');
    page.getParameters().put('message', 'Your Message here');
    page.setRedirect(true);
    return page;
}
}