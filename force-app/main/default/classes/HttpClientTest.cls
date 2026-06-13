/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : HttpClientTest
 * Author          : pkrammekwa
 * Created Date    : Jun 13, 2026
 * Last Modified By: pkrammekwa
 * Last Modified On: Jun 13, 2026
 * Description     : This class tests reusable HTTP callout execution.
 *
 * Change History  :
 *  Date          │   Author      │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jun 13, 2026  │ pkrammekwa    │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */
@IsTest
private class HttpClientTest {
    /**
     * Author      : pkrammekwa
     * Description : Tests that the HTTP client sends a GET request and returns the mocked response.
     */
    @IsTest
    static void sendGetRequestShouldReturnHttpResponse() {
        Test.setMock(HttpCalloutMock.class, new CalendarificHolidayApiMock());

        Test.startTest();

        HttpResponse response = HttpClient.sendGetRequest(
            'callout:Calendarific/api/v2/holidays?country=ZA&year=1990'
        );

        Test.stopTest();

        System.assertEquals(200, response.getStatusCode(), 'Status code should be 200.');
        System.assertNotEquals(null, response.getBody(), 'Response body should not be null.');
        System.assert(response.getBody().contains('New Year'), 'Response body should contain mocked holiday data.');
    }

    /**
     * Author      : pkrammekwa
     * Description : Tests that the HTTP client throws a custom exception when the endpoint is missing.
     */
    @IsTest
    static void sendGetRequestShouldThrowErrorWhenEndpointMissing() {
        try {
            Test.startTest();

            HttpClient.sendGetRequest('');

            Test.stopTest();

            System.assert(false, 'Expected a BirthdateHolidayException.');
        } catch (BirthdateHolidayException exceptionMessage) {
            System.assertNotEquals(null, exceptionMessage, 'Exception should be thrown.');
        }
    }
}