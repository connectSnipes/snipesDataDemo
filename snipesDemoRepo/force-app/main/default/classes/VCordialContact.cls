public class VCordialContact {
    public Attributes attributes { get; set; }
    public Channels channels { get; set; }

    public class Attributes {
        public String ID { get; set; }
        public String source { get; set; }
        public String first_name { get; set; }
        public String last_name { get; set; }
        public String sfcc_phone { get; set; }
        public String brand_origin { get; set; }
        public String current_brand { get; set; }
        public Geo sf_address { get; set; }
        public DateTime lastModified { get; set; }
        public Decimal number_of_ecomm_orders { get; set; }
        public Decimal number_of_in_store_orders { get; set; }
        public Decimal number_of_all_orders { get; set; }
        public Decimal days_since_last_purchase { get; set; }
        public DateTime last_purchase_date { get; set; }
        public String retention { get; set; }
        public void setRetention(Boolean ret) {
            this.retention = ret ? 'Yes' : 'No';
        }
        public Decimal total_ecomm_orders { get; set; }
        public Decimal total_in_store_orders { get; set; }
        public Decimal total_all_orders { get; set; }
        public Decimal aov { get; set; }
        public String purchase_channels { get; set; }
    }

    public class Channels {
        public ChannelEmail email { get; set; }
        public ChannelPush push { get; set; }
    }

    public class ChannelEmail {
        public String address { get; set; }
        public String subscribeStatus { get; set; }
    }

    public class ChannelPush {
        public List<PushAddress> address { get; set; }
    }

    public class PushAddress {
        public String app { get; set; }
        public Boolean pushEnabled { get; set; }
    }

    public class Loc {
        public String lat { get; set; }
        public String lon { get; set; }
    }

    public class Geo {
        public String street_address { get; set; }
        public String city { get; set; }
        public String state { get; set; }
        public String postal_code { get; set; }
        public Loc loc { get; set; }

        private transient String mCountry;

        public String country {
            get {
                return mCountry;
            } set {
                mCountry = value;

                if(mCountry == 'US') {
                    mCountry = 'United States of America';
                }
            }
        }
    }

    public static VCordialContact createFromContact(Account con) {
        VCordialContact res = new VCordialContact();
        res.attributes = new Attributes();
        res.channels = new Channels();

        res.attributes.first_name = con.FirstName;
        res.attributes.last_name = con.LastName;
        res.attributes.sfcc_phone = con.Phone;
        res.attributes.number_of_ecomm_orders = con.num_of_Ecomm_Orders__c;
        res.attributes.number_of_in_store_orders = con.Num_of_In_Store_Orders__c;
        res.attributes.number_of_all_orders = con.num_of_All_Orders__c;
        res.attributes.days_since_last_purchase = con.Days_since_Last_Purchase__c;
        res.attributes.last_purchase_date = con.Last_Purchase_Date__c;
        res.attributes.setRetention(con.Retention__c);
        res.attributes.total_ecomm_orders = con.Total_Ecomm_Orders_Value__c;
        res.attributes.total_in_store_orders = con.Total_In_Store_Orders_Value__c;
        res.attributes.total_all_orders = con.Total_All_Orders__c;
        res.attributes.aov = con.Avg_Order_Amt__c;
        res.attributes.purchase_channels = con.Purchase_Channels__c;

        res.attributes.sf_address = new Geo();

        if(con.PersonMailingStreet != null) {
            res.attributes.sf_address.street_address = con.PersonMailingStreet;
            res.attributes.sf_address.city = con.PersonMailingCity;
            res.attributes.sf_address.state = con.PersonMailingStateCode;
            res.attributes.sf_address.postal_code = con.PersonMailingPostalCode;
            res.attributes.sf_address.country = con.PersonMailingCountryCode;
        }
        
        res.attributes.brand_origin = con.Brand_Origin__c;
        res.attributes.current_brand = con.Brand__c;
        res.channels.email = new ChannelEmail();
        res.channels.email.address = con.PersonEmail;
        res.channels.email.subscribeStatus = con.PersonHasOptedOutOfEmail ? 'unsubscribed' : 'subscribed';

        return res;
    }

    public Contact createContact() {
        Contact res = null;

        if(attributes != null && attributes.first_name != null && attributes.last_name != null) {
            res = new Contact(
                FirstName = attributes.first_name,
                LastName = attributes.last_name,
                Phone = attributes.sfcc_phone,
                CordialID__c = attributes.ID
            );

            if(res.LastName == null) {
                res.LastName = res.FirstName;
                res.FirstName = null;
            }

            if(channels.email != null) {
                res.Email = channels.email.address;
                res.HasOptedOutOfEmail = channels.email.subscribeStatus != 'subscribed';
            }

            if(attributes.sf_address != null && attributes.sf_address.loc != null) {
                if(String.isNotBlank(attributes.sf_address.loc.lat)) {
                    res.MailingLatitude = Decimal.valueOf(attributes.sf_address.loc.lat);
                    res.MailingLongitude = Decimal.valueOf(attributes.sf_address.loc.lon);
                }
            }
        }

        return res;
    }
}