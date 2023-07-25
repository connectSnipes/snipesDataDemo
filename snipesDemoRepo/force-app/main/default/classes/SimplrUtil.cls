global class SimplrUtil {
    /* depends on the code version */
    global static final String SIMPLR_VERSION = '1.0.0';
	public static void setErrorResponse(RestResponse res, String message, Integer statusCode) {
        res.responseBody = Blob.valueOf(message);
        res.statusCode = statusCode;
    }
}