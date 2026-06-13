/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : HttpClient
 * Author          : pkrammekwa
 * Created Date    : Jun 13, 2026
 * Last Modified By: pkrammekwa
 * Last Modified On: Jun 13, 2026
 * Description     : This class handles reusable HTTP callout execution for external service integrations.
 *
 * Change History  :
 *  Date          │   Author      │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jun 13, 2026  │ pkrammekwa    │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */
public with sharing class HttpClient {
    /**
     * Author      : pkrammekwa
     * Description : Sends an HTTP GET request to the provided endpoint.
     *
     * @param endpoint The endpoint URL or Named Credential callout URL.
     * @return HttpResponse
     */
    public static HttpResponse sendGetRequest(String endpoint) {
        if (String.isBlank(endpoint)) {
            throw new BirthdateHolidayException('Endpoint is required.');
        }

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setTimeout(120000);

        return new Http().send(request);
    }
}