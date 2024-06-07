global class BluesightReportSchedule implements Schedulable {
    global void execute(SchedulableContext ctx) {
        BluesightReportController.BluesightReportCallout();  
    }
}