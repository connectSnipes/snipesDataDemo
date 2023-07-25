public with sharing class SimplrQueries {
    public static List<EmailMessage> getAllEmailMessagesByCaseId(String caseId) {
        return [
            SELECT Id, ParentId, ActivityId, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, TextBody, HtmlBody, Headers, Subject, FromName, FromAddress, ValidatedFromAddress, ToAddress, CcAddress, BccAddress, Incoming, HasAttachment, Status, MessageDate, IsDeleted, ReplyToEmailMessageId, IsExternallyVisible, MessageIdentifier, ThreadIdentifier, IsClientManaged, IsTracked, IsOpened, FirstOpenedDate, LastOpenedDate, IsBounced, EmailTemplateId
            FROM EmailMessage
            WHERE ParentId = :caseId AND IsDeleted = FALSE
        ];
    }

    public static Case getCaseById(String caseId) {
        return [
            SELECT Id, IsDeleted, CaseNumber, ContactId, AccountId, AssetId, ParentId, SuppliedName, SuppliedEmail, SuppliedPhone, SuppliedCompany, Type, Status, Reason, Origin, Subject, Priority, Description, IsClosed, ClosedDate, IsEscalated, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ContactPhone, ContactMobile, ContactEmail, ContactFax, Comments, LastViewedDate, LastReferencedDate
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];
    }

    public static List<Case> getCasesBySuppliedEmail(String suppliedEmail) {
        return [
            SELECT Id, IsDeleted, CaseNumber, ContactId, AccountId, AssetId, ParentId, SuppliedName, SuppliedEmail, SuppliedPhone, SuppliedCompany, Type, Status, Reason, Origin, Subject, Priority, Description, IsClosed, ClosedDate, IsEscalated, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ContactPhone, ContactMobile, ContactEmail, ContactFax, Comments, LastViewedDate, LastReferencedDate
            FROM Case
            WHERE SuppliedEmail = :suppliedEmail
            ORDER BY LastModifiedDate DESC
            LIMIT 10
        ];
    }

    public static List<CaseFeed> getCaseFeedTextPostsByCaseId(String caseId) {
        return [
            SELECT Id, ParentId, Type, CreatedById, CreatedDate, IsDeleted, LastModifiedDate, SystemModstamp, CommentCount, LikeCount, Title, Body, LinkUrl, IsRichText, RelatedRecordId, InsertedById, BestCommentId
            FROM CaseFeed
            WHERE ParentId = :caseId AND Type = 'TextPost' AND IsDeleted = FALSE
        ];
    }

    public static List<Order> getOrderByOrderId(String orderId) {
        return [
            SELECT Id, AccountId, ContractId, OrderNumber, Name, Status, CreatedDate, Description, Type, OwnerId, TotalAmount, ShippingAddress, BillingAddress
            FROM Order
            WHERE Id = :orderId AND IsDeleted = FALSE
        ];
    }

    public static List<Order> getUserOrders(String userId) {
        return [
            SELECT Id, AccountId, ContractId, OrderNumber, Name, Status, CreatedDate, Description, Type, OwnerId, TotalAmount, ShippingAddress, BillingAddress
            FROM Order
            WHERE OwnerId = :userId AND IsDeleted = FALSE
        ];
    }

    public static List<OrderItem> getOrderItems(String orderId) {
        return [
            SELECT Id, OrderId, Product2Id, OrderItemNumber, Quantity, TotalPrice, ServiceDate, EndDate, Description, CreatedDate
            FROM OrderItem
            WHERE OrderId = :orderId AND IsDeleted = FALSE
        ];
    }

    public static User getUserById(string id) {
        return [
            SELECT Id, Username, Name, Email
            FROM User
            WHERE Id = :id
        ];
    }

    public static List<User> getUserByEmail(String email) {
        return [
            SELECT Id, Username, Name, Email
            FROM User
            WHERE Email = :email
        ];
    }

    public static Account getAccountById(String id) {
        return [
            SELECT Id, Name
            FROM Account
            WHERE Id = :id AND IsDeleted = FALSE
        ];
    }

    public static Contract getContractById(String id) {
        return [
            SELECT Id, ContractNumber
            FROM Contract
            WHERE Id = :id AND IsDeleted = FALSE
        ];
    }

    public static Product2 getProduct2ById(string id) {
        return [
            SELECT Id, Name
            FROM Product2
            WHERE Id = :id AND IsDeleted = FALSE AND IsActive = TRUE
        ];
    }
}