public class VCordialOrder {
    public String orderID { get; set; }
    public String email { get; set; }
    public DateTime purchaseDate { get; set; }
    public Decimal tax { get; set; }
    public Decimal totalAmount { get; set; }
    public Decimal shippingAndHandling { get; set; }
    public String status { get; set; }
    public String cID { get; set; }

    public List<Item> items { get; set; }
    
    public class Item {
        public String productID { get; set; }
        public String description { get; set; }
        public String sku { get; set; }
        public String category { get; set; }
        public String name { get; set; }
        public String url { get; set; }
        public String productType { get; set; }
        public Boolean taxable { get; set; }
        public String UPCCode { get; set; }
        public Decimal qty { get; set; }
        public Decimal itemPrice { get; set; }
        public Decimal amount { get; set; }
    }

    public static VCordialOrder create(Order ord) {
        VCordialOrder res = new VCordialOrder();
        res.orderID = ord.SnipesOrderNumber__c;
        res.email = ord.Account.PersonEmail;
        res.purchaseDate = ord.OrderDate__c;
        res.tax = ord.OrderTotalTax__c;
        res.shippingAndHandling = ord.OrderTotalShipping__c;
        res.totalAmount = ord.SnipesOrderTotal__c;
        res.status = ord.Status;
        res.items = new List<Item>();

        for(OrderItem item : ord.OrderItems) {
            Item resItem = new Item();
            resItem.productID = item.PricebookEntry.Product2.ProductCode;
            resItem.description = item.PricebookEntry.Product2.Description;
            resItem.sku = item.PricebookEntry.Product2.ProductCode;
            resItem.category = 'Item';
            resItem.name = item.PricebookEntry.Product2.Name;
            resItem.qty = item.Quantity;
            resItem.itemPrice = item.UnitPrice;
            resItem.amount = item.TotalPrice;

            res.items.add(resItem);
        }

        return res;
    }
}