/**
* @description       : IBA-3094: Scheduler to remove permission set
* @author            : Pabitra Tripathy
* @group             : 
* @last modified on  : 09-13-2023
* @last modified by  : Pabitra Tripathy
* Modifications Log 
* Ver   Date         Author             Modification
* 1.0   09-13-2023   Pabitra Tripathy   Initial Version
**/
global class ScheduleLoginAsPermOff implements Schedulable{
    String permissionId;
    String userId; 
    
    public ScheduleLoginAsPermOff(String permId,String uId){
        permissionId=permId;
        userId = uId;
    }
    
    global void execute(SchedulableContext SC) {
        Id jobId=SC.getTriggerId();        
        List<PermissionSetAssignment> pmAsst= [SELECT Id from PermissionSetAssignment WHERE PermissionSetId =: permissionId AND AssigneeId =:userId];
        if (pmAsst.size()>0){
            delete pmAsst;
        }        
        System.abortJob(jobId); 
    }
}