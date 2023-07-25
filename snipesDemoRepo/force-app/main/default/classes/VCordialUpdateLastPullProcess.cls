public class VCordialUpdateLastPullProcess implements Queueable {
    public DateTime dt { get; private set; }

    public VCordialUpdateLastPullProcess(DateTime dt) {
        this.dt = dt;
    }

    public void execute(QueueableContext QC) {
        VSettings.updateLastCordialContactPull(dt);
    }

}