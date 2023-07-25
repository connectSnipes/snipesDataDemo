public class VCordialSendContactProcess implements Queueable, Database.AllowsCallouts {
    public List<Account> contactList { get; private set; }

    public VCordialSendContactProcess(List<Account> contactList) {
        this.contactList = contactList;
    }

    public void execute(QueueableContext QC) {
        List<VCordialContact> vccList = new List<VCordialContact>();
        List<Account> extraAccountList = new List<Account>();

        for(Account acc : contactList) {
            if(vccList.size() < 50) {
                vccList.add(VCordialContact.createFromContact(acc));
            } else {
                extraAccountList.add(acc);
            }
        }

        Integer idx = 0;
        List<Account> toUpdate = new List<Account>();

        for(VCordialContact vcc : vccList) {
            Account acc = contactList[idx];

            String res = VCordialAPI.pushContact(vcc);

            if(res != null) {
                acc.CordialID__pc = res;
                toUpdate.add(acc);
            }

            idx++;
        }

        VAccountTriggerHandler.DISABLE_CORDIAL_UPDATE = true;

        if(toUpdate.size() > 0) {
            update toUpdate;
        }

        if(extraAccountList.size() > 0) {
            VCordialSendContactProcess proc = new VCordialSendContactProcess(extraAccountList);
            System.enqueueJob(proc);
        }
    }
}