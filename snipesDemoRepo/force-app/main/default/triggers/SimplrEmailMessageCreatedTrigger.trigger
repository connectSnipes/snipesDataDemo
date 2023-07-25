trigger SimplrEmailMessageCreatedTrigger on EmailMessage (after insert) {
    Integer chunkSize = 10;
    Integer count = 0;
    List<List<EmailMessage>> emailLists = new List<List<EmailMessage>>();
    List<EmailMessage> chunkList = null;
    for (EmailMessage emailMessageObj : Trigger.new) {
        if (count == 0) {
            chunkList = new List<EmailMessage>();
            emailLists.add(chunkList);
        }
        if (String.isBlank(emailMessageObj.ParentId) == false) {
            chunkList.add(emailMessageObj);
        }
        count++;
        if (chunkList.size() == chunkSize) {
            count = 0;
        }
    }
    for (List<EmailMessage> emails: emailLists) {
        if (emails.size() > 0) {
            String content = SimplrWebhook.buildWebhookJSON('email-created', emails);
            SimplrWebhook.callout(content);
        }
    }
}