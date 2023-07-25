public class AptosErrorHandlingScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        AptosErrorHandling batchJob = new AptosErrorHandling();
        Database.executeBatch(batchJob);
    }
}