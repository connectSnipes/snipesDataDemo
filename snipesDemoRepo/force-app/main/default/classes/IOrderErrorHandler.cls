public interface IOrderErrorHandler {
    void handleError(String orderNumber, String errorMessage);
}