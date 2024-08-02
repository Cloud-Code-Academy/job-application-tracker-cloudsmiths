/**
 * @description       : Mocks an exception being thrown during the callout to the Jooble API
 * @author            : Riley Meyer
 * @group             : Cloud Smiths
 * @last modified on  : 08-02-2024
 * @last modified by  : Riley Meyer
**/
global class UnauthorizedEndpointResponse implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req) {
        CalloutException e = (CalloutException)CalloutException.class.newInstance();
        e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
        throw e;
    }
}