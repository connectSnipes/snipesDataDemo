trigger CalculateTotalLimeAmount on OrderItem (before insert) {
    for(OrderItem ordItem: Trigger.New){
        ordItem.TotalLineAmount = ordItem.UnitPrice*ordItem.Quantity;
    }
}