public class getCasesFromPandora
{
    public static void getCases()
    {
        Map<String,String> resMap = getContactsFromPandoraBatch.calloutPandoraAuth();  
        
        String endPointPath = resMap.get('instance_url')+'/services/data/v60.0/query/?q=select+id,casenumber,status,priority+from+case';
        
        //String jsonResponse = getContactsFromPandoraBatch.calloutPandoraAPI(resMap.get('access_token'),endPointPath);
        Boolean hasMoreRecords = false;        
        String nextBatchPath = '';
        List<Case> insertCases = new List<Case>();
        List<caseWrapper> caseWrapperList = New List<caseWrapper>(); //cannot insert more than 10K records
        List<caseWrapper> caseWrapperNextList = New List<caseWrapper>(); //inserting in future method to avoid DML limit
        
        do
        {
            String jsonResponse;
            if(!hasMoreRecords)
            {
                jsonResponse = getContactsFromPandoraBatch.calloutPandoraAPI(resMap.get('access_token'),endPointPath);
            }
            else
            {
                jsonResponse = getContactsFromPandoraBatch.calloutPandoraAPI(resMap.get('access_token'), resMap.get('instance_url')+''+nextBatchPath);
            }
            
            caseWrapper cls = (caseWrapper) JSON.deserialize(jsonResponse,caseWrapper.Class);
            
            if(cls.nextRecordsUrl <> NULL)
            {
                nextBatchPath = cls.nextRecordsUrl;
                hasMoreRecords = true;
            }
            else
            {
                nextBatchPath = '';
                hasMoreRecords = false;
            }
            if(caseWrapperList.size() < 4)
            {
                caseWrapperList.add(cls);
            }
            else
            {
                caseWrapperNextList.add(cls);
            }
        }
        while(hasMoreRecords);
        system.debug('caseWrapperList-->'+caseWrapperList.size());
        system.debug('caseWrapperList-->'+caseWrapperNextList.size());
        insertMoreCase(JSON.serialize(caseWrapperNextList));
        for (caseWrapper cls : caseWrapperList) 
        {
            for (Records rec : cls.Records) 
            {
                Case newCase = new Case();
                newCase.Legacy_Pandora_Id__c = rec.Id;
                newCase.Legacy_Case_Number__c = rec.CaseNumber;
                newCase.Status = rec.Status;
                newCase.Priority = rec.Priority;
                
                insertCases.add(newCase);
            }
        }
        
        system.debug('insertCases-->'+insertCases.size());
        if(!insertCases.isEmpty())
        {
            insert insertCases;
        }
    }
    
    @future(callout=true)
    public static void insertMoreCase(String caseDetails)
    {
        List<Case> insertCases = new List<Case>();
        List<caseWrapper> caseWrapperList = (List<caseWrapper>) JSON.deserialize(caseDetails,List<caseWrapper>.Class);
        
        for (caseWrapper cls : caseWrapperList) 
        {
            for (Records rec : cls.Records) 
            {
                Case newCase = new Case();
                newCase.Legacy_Pandora_Id__c = rec.Id;
                newCase.Legacy_Case_Number__c = rec.CaseNumber;
                newCase.Status = rec.Status;
                newCase.Priority = rec.Priority;
                
                insertCases.add(newCase);
            }
        }
        
        system.debug('insertCases-->'+insertCases.size());
        if(!insertCases.isEmpty())
        {
            insert insertCases;
        }
    }
    
    public class caseWrapper
    {
        public string nextRecordsUrl;
        public List<Records> records;
    }  
    
    public class Records 
    {
        public String Id;
        public String CaseNumber;
        public String Status;
        public String Priority;
    }
    
    public static void createPandoraProducts()
    {
        String productCode = 'PVI-ANA-001,PVI-ANA-002,PVI-ANA-003,PVI-ANA-004,PVI-ANA-005,PVI-ANA-006,PVI-ANA-007,PVI-ANA-008,PVI-ANA-009,PVI-ANA-010,PVI-ANA-011,PVI-ANA-032,PVI-ANA-012,PVI-ANA-013,PVI-ANA-014,PVI-ANA-015,PVI-ANA-016,PVI-ANA-017,PVI-ANA-018,PVI-ANA-019,PVI-ANA-020,PVI-ANA-021,PVI-ANA-022,PVI-ANA-023,PVI-ANA-024,PVI-ANA-025,PVI-ANA-026,PVI-ANA-027,PVI-ANA-028,PVI-ANA-029,PVI-ANA-030,PVI-ANA-031,PVI-SUB-012,PVI-SUB-013,PVI-SUB-014,PVI-SUB-015,PVI-SUB-016,PVI-SUB-017,PVI-SUB-018,PVI-SUB-019,PVI-SUB-020,PVI-SUB-021,PVI-SUB-022,PVI-SUB-023,PVI-SUB-024,PVI-SUB-025,PVI-SUB-026,PVI-SUB-027,PVI-SUB-028,PVI-SUB-029,PVI-SUB-030,PVI-SUB-031,PVI-SUB-037,PVI-SUB-038,PVI-SUB-039,PVI-SUB-040,PVI-SUB-041,PVI-SUB-042,PVI-SUB-043,PVI-SUB-044,PVI-SUB-045,PVI-SUB-046,PVI-ANA-037,PVI-ANA-038,PVI-ANA-039,PVI-ANA-040,PVI-ANA-041,PVI-ANA-042,PVI-SUB-001,PVI-SUB-002,PVI-SUB-003,PVI-SUB-004,PVI-SUB-005,PVI-SUB-006,PVI-SUB-007,PVI-SUB-008,PVI-SUB-009,PVI-SUB-010,PVI-SUB-011,PVI-SUB-047,PVI-ANA-032-SV,PVI-ANA-039-SV,PVI-ANA-001-SV,PVI-ANA-005-SV,PVI-ANA-003-SV,PVI-ANA-006-SV,PVI-ANA-034-SV,PVI-ANA-034,P-SQL-SV,PVI-ANA-038-SV,PVI-ANA-040-SV,PVI-ANA-037-SV,PVI-ANA-002-SV,PVI-BDL-002,PVI-BDL-013,PVI-ANA-043,PVI-ANA-043-SV,PVI-ANA-033,PVI-ANA-033-SV,PVI-ANA-041-SV,PVI-BDL-001,PVI-ANA-044,PVI-ANA-044-SV,30-9040,30-9041,30-9043,30-9044,30-9045,PVI-LAB-001,PVI-ANA-050,PVI-ANA-050-SV,PVI-SUB-051,PVI-SUB-050,PVI-ANA-045,PVI-ANA-045-SV,PVI-ANA-004-SV,PVI-ANA-046-SV,PVI-ANA-046,33-0015,PVI-SUB-054,PVI-SUB-056,PVI-SUB-059,PVI-SUB-062';
        
        List<Pandora_Product_Codes__c> insertList = New List<Pandora_Product_Codes__c>();
        
        for(String code : productCode.split(','))
        {
            Pandora_Product_Codes__c obj = New Pandora_Product_Codes__c();
            obj.Name = code;
            insertList.add(obj);
        }
        
        if(!insertList.isEmpty())
        {
            insert insertList;
        }
    }
}