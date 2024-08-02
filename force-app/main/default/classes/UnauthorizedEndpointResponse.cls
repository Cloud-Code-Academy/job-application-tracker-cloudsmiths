/**
 * @description       : 
 * @author            : Riley Meyer
 * @group             : 
 * @last modified on  : 08-01-2024
 * @last modified by  : Riley Meyer
**/
global class UnauthorizedEndpointResponse implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req) {
        CalloutException e = (CalloutException)CalloutException.class.newInstance();
        e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
        throw e;
    }
}