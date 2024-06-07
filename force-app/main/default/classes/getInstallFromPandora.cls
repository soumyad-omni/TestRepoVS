public class getInstallFromPandora 
{
    @future(callout=true)
    public static void createInstalls()
    {
        Map<String,String> resMap = getContactsFromPandoraBatch.calloutPandoraAuth();  
        String fields = 'Account__c,Active_Directory_Server_Name_IP__c,Additional_Information__c,ADS_Connection_Account_Name__c,ADS_Connection_Account_PW__c,ADS_location__c,AIS_configured_and_operational__c,Anesthesia_Medstations__c,Application_Server_Operating_System__c,App_Server_32_or_64_Bit__c,App_Server_Available_Disk_Space__c,App_Server_CPU__c,App_Server_HostName__c,App_Server_Installation_Drive__c,App_Server_IP__c,App_Server_is_Virtual__c,App_Server_Maintenance__c,App_Server_RAM__c,App_Server_Shared_or_Dedicated__c,Automatic_Update_Active__c,Avg_Transactions_Month__c,Beta_Install__c,Call_Required_for_Remote_Access__c,Client_CPU__c,Client_Deployment__c,Client_Disk_Space_Available__c,Client_Operating_System__c,Client_RAM__c,Client_VPN__c,Current_ADM_Count__c,Current_ADS__c,Current_ADS_Version__c,Database_Host_Available_Disk_Space__c,Server_OS__c,RAM__c,Directory_System__c,Database_Host_Drive_Configuration__c,FOB_Key_Required__c,FOB_Owner__c,Contact__c,Installation_Requirements__c,Installation_Scenario__c,Installation_Type__c,Install_Date__c,Installs__c,Link_to_Client_Installer__c,Migrated_data_into_PSQL__c,Legacy_Version_Acceptable__c,Number_of_Client_Installs__c,Number_of_Facilities_in_System__c,Other_Directory_System__c,Other_Propagation_Methods__c,Other_Pyxis_Archive_Method__c,Pandora_Logon_Account_Password__c,Pandora_Logon_Account_UserName__c,PandoraWD_Location__c,PDS_configured_and_operational__c,Primary_Pandora_Support_Technician__c,Primary_Client_HostName__c,Processing_Speed__c,Processor_Description__c,Product_Installed__c,Product_Version__c,PSQL_Operational__c,PVIA_Install_Info__c,Pyxis_Archive_Method__c,Remote_Access_Point_of_Contact__c,Remote_Connection_Available__c,Remote_Connection_Type__c,Remote_Login_Password__c,Logon_Account__c,Service_Account_Password__c,Service_Account_UserName__c,Services_are_Installed__c,Services_are_Installed_on__c,SMTP_Server_Name_IP__c,Propagation_Method__c,SQL_Account_Password__c,SQL_Account_UserName__c,SQL_Authentication_Method__c,SQL_Server_32_or_64_Bit__c,SQL_Server_CPU__c,SQL_Server_Dedicated_or_Shared__c,SQL_Server_HostName__c,SQL_Server_Instance_Name__c,SQL_Server_IP_Address__c,SQL_Server_is_Clustered__c,SQL_Server_is_Virtual__c,SQL_Server_Maintenance__c,SQL_Server_RAM__c,SQL_Server_SP__c,SQL_Server_Status__c,SQL_Server_Version__c,System_Multi__c,User_Account_Notes__c,VPN_Password__c,VPN_Username__c,Web_VPN__c';
        String endPointPath = resMap.get('instance_url')+'/services/data/v60.0/query/?q=select+'+fields+'+from+Installs__c';
        
        String jsonResponse = getContactsFromPandoraBatch.calloutPandoraAPI(resMap.get('access_token'),endPointPath);
        system.debug('install jsonResponse-->'+jsonResponse);
        installWrapper wrapperList = (installWrapper) JSON.deserialize(jsonResponse,installWrapper.Class);
        system.debug('install wrapperList->'+wrapperList);
        String contactIds = '', accountIds = '', userIds = '';
        for(Installs__c instObj : wrapperList.records)
        {
            system.debug('instObj.Id-->'+instObj.Id);
            if(instObj.Contact__c <> NULL)
            {
                contactIds = contactIds + '\'' + instObj.Contact__c + '\',';
            }
            
            if(instObj.Remote_Access_Point_of_Contact__c <> NULL)
            {
                contactIds = contactIds + '\'' + instObj.Remote_Access_Point_of_Contact__c + '\',';
            }
            
            if(instObj.System_Multi__c <> NULL)
            {
                accountIds = accountIds + '\'' + instObj.System_Multi__c + '\',';
            }
            
            if(instObj.Account__c <> NULL)
            {
                accountIds = accountIds + '\'' + instObj.Account__c + '\',';
            }
            
            if(instObj.Primary_Pandora_Support_Technician__c <> NULL)
            {
                userIds = userIds + '\'' + instObj.Primary_Pandora_Support_Technician__c + '\',';
            }
        }
        
        contactIds = contactIds.removeEnd(',');
        system.debug('contactIds-->'+contactIds);
        
        accountIds = accountIds.removeEnd(',');
        system.debug('accountIds-->'+accountIds);
        
        userIds = userIds.removeEnd(',');
        system.debug('userIds-->'+userIds);
        
        Map<String, String> contactIdMap = getContactDetails(resMap,contactIds);
        Map<String, String> systemMulti = getAccountDetails(resMap,'select+id,CSN__c+from+Account+where+Id+IN+(select+System_Multi__c+from+Installs__c)');
        Map<String, String> masterDetailMap = getAccountDetails(resMap,'select+id,CSN__c+from+Account+where+Id+IN+(select+Account__c+from+Installs__c)');
        Map<String, String> userIdMap = getUserDetails(resMap,userIds);
        
        List<Installs__c> insertInstallList = New List<Installs__c>();
        
        for(Installs__c instObj : wrapperList.records)
        {
            system.debug('instObj.Id-->'+instObj.Id);
            instObj.Legacy_Pandora_Install_Id__c = instObj.Id;
            instObj.Id = NULL;
            instObj.CreatedById = NULL;
            instObj.LastModifiedById = NULL;
            if(instObj.Contact__c <> NULL)
            {
                if(contactIdMap.containsKey(instObj.Contact__c))
                {
                    instObj.Contact__c = contactIdMap.get(instObj.Contact__c);
                }
                else
                {
                    instObj.Contact__c = null;
                }
            }
            
            if(instObj.Remote_Access_Point_of_Contact__c <> NULL)
            {
                if(contactIdMap.containsKey(instObj.Remote_Access_Point_of_Contact__c))
                {
                    instObj.Remote_Access_Point_of_Contact__c = contactIdMap.get(instObj.Remote_Access_Point_of_Contact__c);
                }
                else
                {
                    instObj.Remote_Access_Point_of_Contact__c = null;
                }
            }
            
            if(instObj.System_Multi__c <> NULL)
            {
                if(systemMulti.containsKey(instObj.System_Multi__c))
                {
                    instObj.System_Multi__c = systemMulti.get(instObj.System_Multi__c);
                }
                else
                {
                    instObj.System_Multi__c = null;
                }
            }
            
            if(instObj.Account__c <> NULL)
            {
                if(masterDetailMap.containsKey(instObj.Account__c))
                {
                    instObj.Account__c = masterDetailMap.get(instObj.Account__c);
                }
                else
                {
                    instObj.Account__c = null;
                }
            }
            
            if(instObj.Primary_Pandora_Support_Technician__c <> NULL)
            {
                if(userIdMap.containsKey(instObj.Primary_Pandora_Support_Technician__c))
                {
                    instObj.Primary_Pandora_Support_Technician__c = userIdMap.get(instObj.Primary_Pandora_Support_Technician__c);
                }
                else
                {
                    instObj.Primary_Pandora_Support_Technician__c = null;
                }
            }
            
            if(instObj.Account__c <> NULL)
            {
                insertInstallList.add(instObj);
            }
        }
        
        system.debug('insertInstallList-->'+insertInstallList.size()+':::'+insertInstallList);
        insert insertInstallList;
    }
    
    public static Map<String, String> getContactDetails(Map<String,String> resMap, String contactIds)
    {
        Map<String, String> contactIdMap = New Map<String, String>();

        if(contactIds <> NULL && contactIds <> '')
        {
            String endPointPath = resMap.get('instance_url')+'/services/data/v60.0/query/?q=select+id,name,firstname,lastname,phone,email+from+Contact+where+Id+IN+('+contactIds+')';
            String jsonResponse = getContactsFromPandoraBatch.calloutPandoraAPI(resMap.get('access_token'),endPointPath);
            
            system.debug('contact jsonResponse-->'+jsonResponse);
            contactWrapper wrapperList = (contactWrapper) JSON.deserialize(jsonResponse,contactWrapper.Class);
            system.debug('contact wrapperList->'+wrapperList);
            
            List<String> contactName = New List<String>();
            List<String> contactPhone = New List<String>();
            List<String> contactEmail = New List<String>();
            
            for(Contact con : wrapperList.records)
            {
                if(con.Name <> NULL && con.Name <> '')
                {
                    contactName.add(con.Name);
                }
                
                if(con.Phone <> NULL && con.Phone <> '')
                {
                    contactPhone.add(con.Phone);
                }
                
                if(con.Email <> NULL && con.Email <> '')
                {
                    contactEmail.add(con.Email);
                }
            }
            
            for(Contact omnicellCon : [SELECT Id, Name, Phone, Email FROM Contact
                                       WHERE Name IN :contactName
                                       OR Phone IN :contactPhone
                                       OR Email IN :contactEmail])
            {
                for(Contact pandoraCon : wrapperList.records)
                {
                    if(omnicellCon.Name == pandoraCon.Name || omnicellCon.Phone == pandoraCon.Phone || omnicellCon.Email == pandoraCon.Email || omnicellCon.Email == pandoraCon.Email+'.invalid')
                    {
                        contactIdMap.put(pandoraCon.Id, omnicellCon.Id);
                        break;
                    }
                }
            }
            
        }
        system.debug('contactIdMap-->'+contactIdMap);
        
        return contactIdMap;
    }
    
    public static Map<String, String> getAccountDetails(Map<String,String> resMap, String query)
    {
        Map<String, String> accountIdMap = New Map<String, String>();
        
        String endPointPath = resMap.get('instance_url')+'/services/data/v60.0/query/?q='+query;
        String jsonResponse = getContactsFromPandoraBatch.calloutPandoraAPI(resMap.get('access_token'),endPointPath);
        
        system.debug('Account jsonResponse-->'+jsonResponse);
        jsonResponse = jsonResponse.replace('CSN__c','CSN');
        accountWrapper wrapperList = (accountWrapper) JSON.deserialize(jsonResponse,accountWrapper.Class);
        system.debug('Account wrapperList->'+wrapperList);
        
        Map<String, String> accountCSNMap = New Map<String, String>();
        
        for(records acc : wrapperList.records)
        {
            if(acc.CSN <> NULL)
            {
                accountCSNMap.put(String.valueOf(Integer.valueOf(acc.CSN)), acc.Id);
            }
        }
        
        
        for(Account acc : [SELECT Id, SAP_Customer_Number__c FROM Account
                           WHERE SAP_Customer_Number__c IN :accountCSNMap.keyset()])
        {
            if(accountCSNMap.containsKey(acc.SAP_Customer_Number__c))
            {
                accountIdMap.put(accountCSNMap.get(acc.SAP_Customer_Number__c), acc.Id);
            }
        }
        
        system.debug('accountIdMap-->'+accountIdMap);
        
        return accountIdMap;
    }
    
    public static Map<String, String> getUserDetails(Map<String,String> resMap, String userIds)
    {
        Map<String, String> userIdMap = New Map<String, String>();

        if(userIds <> NULL && userIds <> '')
        {
            String endPointPath = resMap.get('instance_url')+'/services/data/v60.0/query/?q=select+id,name+from+User+where+Id+IN+('+userIds+')';
            String jsonResponse = getContactsFromPandoraBatch.calloutPandoraAPI(resMap.get('access_token'),endPointPath);
            
            system.debug('User jsonResponse-->'+jsonResponse);
            userWrapper wrapperList = (userWrapper) JSON.deserialize(jsonResponse,userWrapper.Class);
            system.debug('User wrapperList->'+wrapperList);
            
            Map<String, String> userNameMap = New Map<String, String>();
            
            for(User usr : wrapperList.records)
            {
                if(usr.Name <> NULL && usr.Name <> '')
                {
                    userNameMap.put(usr.Name, usr.Id);
                }
                
            }
            
            for(User usr : [SELECT Id, Name FROM User
                            WHERE Name IN :userNameMap.keySet()])
            {
                if(userNameMap.containsKey(usr.Name))
                {
                    userIdMap.put(userNameMap.get(usr.Name),usr.Id);
                }
            }
        }
        system.debug('userIdMap-->'+userIdMap);
        
        return userIdMap;
    }
    
    public class installWrapper
    {
        public List<Installs__c> records;
    }  
    
    public class contactWrapper
    {
        public List<Contact> records;
    }
    
    public class accountWrapper
    {
        public List<records> records;
    }
    
    public class records
    {
        public String Id;
        public Double CSN;
    }
    
    public class userWrapper
    {
        public List<User> records;
    }
}