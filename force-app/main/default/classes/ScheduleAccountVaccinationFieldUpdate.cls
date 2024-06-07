global class ScheduleAccountVaccinationFieldUpdate implements Schedulable{
    global void execute(SchedulableContext SC) {
        updateAccountVaccinationFieldValue a = new updateAccountVaccinationFieldValue();
        database.executeBatch(a,200);
    }
}