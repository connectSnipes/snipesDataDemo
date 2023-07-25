public class VCordialContactsSchedule implements Schedulable {
    public void execute(SchedulableContext SC) {
        DateTime cutOff = VSettings.settings.LastCordialContactPull__c;

        if(Test.isRunningTest()) {
            cutOff = DateTime.newInstance(Date.newInstance(2010, 1, 1), Time.newInstance(0, 0, 0, 0));
        }
        
        List<VCordialContact> ccList = VCordialAPI.getLatestContacts(cutOff);

        List<Contact> contactList = new List<Contact>();
        for(VCordialContact cc : ccList) {
            Contact con = cc.createContact();

            if(con != null) {
                contactList.add(con);
            }
        }

        if(contactList.size() > 0) {
            VDuplicateService svc = new VDuplicateService();
            List<Contact> dupeProcessedList = svc.processContacts(contactList);

            for(Integer i = 0; i < contactList.size(); i++) {
                Contact con = contactList[i];
                Contact dupeProcessed = dupeProcessedList[i];

                if(dupeProcessed != null && dupeProcessed.Id != null) {
                    con.Id = dupeProcessed.Id;
                }
            }

            VAccountTriggerHandler.DISABLE_CORDIAL_UPDATE = true;
            upsert contactList;
        }

        VCordialUpdateLastPullProcess proc = new VCordialUpdateLastPullProcess(DateTime.now().addMinutes(-1));
        System.enqueueJob(proc);
    }
}