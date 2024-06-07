global class ScheduleReportingManagerUpdateOnUserJob implements Schedulable{
   
    global void execute(SchedulableContext ctx) {
        ReportingManagerUpdateOnUserBatch reportingManagerBatch = new ReportingManagerUpdateOnUserBatch();
        Database.executeBatch(reportingManagerBatch);
    }
}