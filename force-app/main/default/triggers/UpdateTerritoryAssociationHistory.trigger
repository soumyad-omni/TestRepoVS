trigger UpdateTerritoryAssociationHistory on UserTerritory2Association (after delete) 
{
 if(trigger.isDelete && trigger.isAfter)
 {
        CreateTerritoryAssignmentHistory job = new CreateTerritoryAssignmentHistory() ;
        job.lstToDelete = trigger.old;
        System.enqueueJob(job);
 }
}