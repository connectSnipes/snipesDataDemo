public class VFlexShipmentNotification {
    public ShipmentOrder order = new ShipmentOrder();
    public List<NotificationChannel> notificationChannels = new List<NotificationChannel>();
    public Shipment shipment = new Shipment();

    public void addNotificationChannel(String name, String email) {
        NotificationChannel chan = new NotificationChannel();
        chan.recipientName = name;
        chan.emailAddress = email;

        notificationChannels.add(chan);
    }

    public class ShipmentOrder {
        public String id;
    }

    public class NotificationChannel {
        public String recipientName;
        public String channelType = 'EMAIL';
        public String emailAddress;
    }

    public class Shipment {
        public String carrier;
        public String trackingNumber;
    }
}