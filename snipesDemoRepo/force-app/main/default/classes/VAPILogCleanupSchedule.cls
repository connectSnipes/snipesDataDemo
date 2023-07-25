public class VAPILogCleanupSchedule implements Schedulable {
    public void execute(SchedulableContext SC) {
        VAPILogCleanupBatch b = new VAPILogCleanupBatch();
        Database.executeBatch(b, 2000);
    }
}