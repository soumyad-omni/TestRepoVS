/****************************************************************************
Name:          ContactToCastIroncallqueueableClass
Test Class:    ContactToCastIroncallqueueableClassTest
Purpose:       This class being called from AccountCreateController to send contacts in SAP when Account is Validated.
---------------------------------------------------------------------------
Developer                  Date                Description
-------------------------------------------------------------- -------------
Saptarsha Panthi         08/31/2023            Initial Creation

*****************************************************************************/
public class ContactToCastIroncallqueueableClass implements Queueable{
    Set <Id> accid;
    public ContactToCastIroncallqueueableClass(Set <Id> aid){
        this.accid = aid;
    }
    public void execute(QueueableContext context) {
        List<Contact> conlist = [select id FROM contact WHERE AccountId IN:accid AND SAP_Contact_ID__c=null AND SAP_Contact_GUID__c=null];
        //system.debug('IBA-4679 conlist..'+conlist);
        set<Id> newconIdstosend = new set<Id>();
        if(conlist.size()>0)
        { 
            for(Contact con: conlist)
            {
                newconIdstosend.add(con.id);
            } 
            system.debug('Contact Ids sent to SAP..'+ newconIdstosend);
            OmnicellContactToCastIron_Class.callOutMethodInsert(newconIdstosend);
        }
    }
}