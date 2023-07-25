@RestResource(UrlMapping='/simplr/sendmessage')
global with sharing class SimplrSendMessageAction {
    private static final String BR = '<br/>';
    private static final String SIGNATURE_SEPARATOR = '--';
    private static final String HTML_EMAIL_SEPARATOR = BR + BR + SIGNATURE_SEPARATOR + BR + BR;
    private static final String TEXT_EMAIL_SEPARATOR = '\n\n';

    private static final String EMAIL_MESSAGE_SENDER = 'Simplr Agent';

    @HttpPost
    global static EmailMessage action(String caseId, String messageHTML, String messageText) {
        RestResponse res = RestContext.response;
        try {
            Case caseObj = SimplrSendMessageAction.fetchCaseByCaseId(caseId);
            System.debug(caseObj);

            // Find all messages in case
            List<EmailMessage> msgIdentifiers = [
                SELECT Id, IsDeleted, IsExternallyVisible, ParentId, MessageIdentifier, ThreadIdentifier
                FROM EmailMessage
                WHERE ParentId = :caseObj.Id AND IsExternallyVisible = TRUE AND IsDeleted = FALSE
                ORDER BY MessageDate DESC
            ];

            // Simplr_Use_Header_Threading should be set based on the following article:
            // https://help.salesforce.com/s/articleView?id=sf.support_email_to_case_threading.htm&type=5
            Boolean useHeaderThreading = Label.Simplr_Use_Header_Threading == 'true' ? True : False;

            // Thread ref is a string by which salesforce knows to which Case to attach inbound message
            String threadRef = SimplrSendMessageAction.determineThreadReference(
                caseObj,
                useHeaderThreading
            );

            String emailText = null;
            String emailHTML = null;
            if (useHeaderThreading) {
                emailText = messageText;
                emailHTML = messageHTML;
            } else {
                emailText = messageText + TEXT_EMAIL_SEPARATOR + threadRef;
                emailHTML = messageHTML + HTML_EMAIL_SEPARATOR + threadRef;
            }

            String emailSubject = caseObj.Subject;
            String customerEmail = caseObj.SuppliedEmail;
            String serviceAddress = SimplrSendMessageAction.fetchToAddressFromIncomingMessages(caseId);
            
            System.debug(serviceAddress);

            // Create and send SingleEmailMessage (cannot be attached to Case)
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setCharset('UTF-8');
            email.setSubject(emailSubject);
            email.setReplyTo(serviceAddress);
            email.setHtmlBody(emailHTML);
            email.setPlainTextBody(emailText);
            email.setToAddresses(new List<String> { customerEmail });
            email.setWhatId(caseObj.Id);
    


            // This should be the email-to-case scenario where we have a message and messageIdentifier. We'll default
            // to the new messageIdentifier if the lastTaggedMessage.MessageIdentifier happens to not be set for
            // some reason.
            EmailMessage lastTaggedMessage = SimplrSendMessageAction.pluckLastTaggedMessageWithIdentifier(msgIdentifiers);
            if (lastTaggedMessage != null) {
              String messageIdentifier = lastTaggedMessage.MessageIdentifier;

              // Only set setInReplyTo if there was an incoming message we're replying to
              email.setInReplyTo(messageIdentifier);
            }

            // set email header references
            // Reference headers should contain all message ids from all messages on the thread
            // MessageIdentifier is from incoming messages
            // ThreadIdentifier is from outgoing messages
            List<String> referenceList = SimplrSendMessageAction.generateUniqueEmailReferenceList(
                msgIdentifiers,
                useHeaderThreading,
                threadRef
            );

            String references = !referenceList.isEmpty() ? string.join(referenceList, ' ') : null;
            System.debug(references);

            email.setReferences(references);
            
            System.debug(email.references);
            System.debug(email.getReferences());

            // sendEmail is async
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new List<Messaging.Email> { email });
            
            // Return the saved email message we sent above and return it so simplr-server can run message
            // reconciliation
			List<EmailMessage> recentlySentMessage = [
                SELECT Id, IsDeleted, IsExternallyVisible, ParentId, MessageIdentifier, ThreadIdentifier, htmlBody, TextBody, ToAddress, FromAddress
                FROM EmailMessage
                WHERE ParentId = :caseObj.Id AND IsExternallyVisible = TRUE AND IsDeleted = FALSE AND Incoming = FALSE
                ORDER BY MessageDate DESC
                LIMIT 1
            ];
            
            System.debug(recentlySentMessage);
            
            return recentlySentMessage[0];
         } catch (SimplrException e) {
            System.debug(e.getMessage());
            SimplrUtil.setErrorResponse(res, e.getMessage(), e.statusCode !=null ?e.statusCode:500);
            return null;
        } catch (Exception e) {
            System.debug(e.getMessage());
            SimplrUtil.setErrorResponse(res, e.getMessage(), 400);
            return null;
        } 
    }

    private static Case fetchCaseByCaseId(String caseId) {
        Case caseObj = [SELECT Id, Subject, SuppliedEmail FROM Case WHERE Id = :caseId LIMIT 1];

        if (caseObj.SuppliedEmail == null) {
            throw new SimplrException('Don\'t have customer email. Aborting', 400);
        }

        return caseObj;
    }

    // Really fragile logic here, that is discovered by hand
    private static String computeThreadRef(String caseId) {
        String orgId = UserInfo.getOrganizationId();
        return 'ref:_' + orgId.left(5) + orgId.mid(10, 5) + '._' + caseId.left(5) + caseId.mid(9, 6) + ':ref';
    }

    private static String fetchToAddressFromIncomingMessages(String caseId) {
        List<EmailMessage> messages = [
            Select ToAddress from EmailMessage where ParentId = :caseId and Incoming = true order by CreatedDate ASC
        ];

        if (messages.isEmpty()) {
            return Label.Simplr_Default_Service_Email;
        }

        String serviceAddress = (String) messages[0].get('ToAddress');

        if (serviceAddress == null || serviceAddress.indexOf(';') != -1) {
            serviceAddress = Label.Simplr_Default_Service_Email;
        }

        return serviceAddress;
    }

    private static EmailMessage pluckLastTaggedMessageWithIdentifier(List<EmailMessage> msgIdentifiers) {
        for (EmailMessage msg: msgIdentifiers) {
            if (msg.MessageIdentifier != null) {
                return msg;
            }
        }

        return null;
    }

    private static List<String> generateUniqueEmailReferenceList(
        List<EmailMessage> msgIdentifiers,
        Boolean useHeaderThreading,
        String mostRecentThreadReference
    ) {
        List<String> referenceList = new List<String>();

        if (useHeaderThreading) {
            referenceList.add(mostRecentThreadReference);
        }

        for (EmailMessage msg: msgIdentifiers) {
            String msgId = msg.MessageIdentifier;
            String threadId = msg.ThreadIdentifier;

            if (msgId != null && !referenceList.contains(msgId)) {
                referenceList.add(msgId);
            }

            // Some legacy threadIds did not have the right format with <>
            // also threadIds from string-based threads won't have <>
            Boolean isNotLegacyThreadId = threadId != null && threadId.startsWith('<') && threadId.endsWith('>');

            if (isNotLegacyThreadId && !referenceList.contains(threadId)) {
                referenceList.add(threadId);
            }
        }

        return referenceList;
    }

    private static String determineThreadReference(
        Case caseObj,
        Boolean useHeaderThreading
    ) {
        if (useHeaderThreading) {
            return Cases.generateThreadingMessageId(caseObj.Id);
        }

        return SimplrSendMessageAction.computeThreadRef(caseObj.Id);
    }
}