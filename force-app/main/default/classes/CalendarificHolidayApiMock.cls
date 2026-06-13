/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : CalendarificHolidayApiMock
 * Author          : pkrammekwa
 * Created Date    : Jun 13, 2026
 * Last Modified By: pkrammekwa
 * Last Modified On: Jun 13, 2026
 * Description     : This class mocks the Calendarific API response for Apex callout tests.
 *
 * Change History  :
 *  Date          │   Author      │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jun 13, 2026  │ pkrammekwa    │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */
@IsTest
public class CalendarificHolidayApiMock implements HttpCalloutMock {
    private Integer statusCode;
    private String responseBody;

    /**
     * Author      : pkrammekwa
     * Description : Creates a default successful Calendarific API mock response.
     */
    public CalendarificHolidayApiMock() {
        this.statusCode = 200;
        this.responseBody = getSuccessfulResponseBody();
    }

    /**
     * Author      : pkrammekwa
     * Description : Creates a configurable Calendarific API mock response.
     *
     * @param statusCode   The HTTP status code to return.
     * @param responseBody The response body to return.
     */
    public CalendarificHolidayApiMock(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }

    /**
     * Author      : pkrammekwa
     * Description : Returns the mocked HTTP response.
     *
     * @param request The HTTP request sent by the tested callout.
     * @return HttpResponse
     */
    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(this.statusCode);
        response.setHeader('Content-Type', 'application/json');
        response.setBody(this.responseBody);

        return response;
    }

    /**
     * Author      : pkrammekwa
     * Description : Returns a successful fake Calendarific holidays response body.
     *
     * @return String
     */
    private static String getSuccessfulResponseBody() {
        return '{' +
            '"meta":{"code":200},' +
            '"response":{"holidays":[' +
                '{' +
                    '"name":"New Year\'s Day",' +
                    '"description":"New Year\'s Day is the first day of the year.",' +
                    '"date":{"iso":"1990-01-01"},' +
                    '"type":["National holiday"]' +
                '},' +
                '{' +
                    '"name":"Human Rights Day",' +
                    '"description":"Human Rights Day is a public holiday in South Africa.",' +
                    '"date":{"iso":"1990-03-21"},' +
                    '"type":["National holiday"]' +
                '}' +
            ']}' +
        '}';
    }
}