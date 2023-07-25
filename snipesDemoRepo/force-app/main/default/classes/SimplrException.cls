public class SimplrException extends Exception {
    public Integer statusCode {
        set {statusCode=value;} 
        get {return statusCode;}
    }

    public SimplrException(String message, Integer statusCode) {
        this(message);
        this.statusCode = statusCode;
    }
}