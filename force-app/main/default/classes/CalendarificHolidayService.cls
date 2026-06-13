/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : CalendarificHolidayService
 * Author          : pkrammekwa
 * Created Date    : Jun 13, 2026
 * Last Modified By: pkrammekwa
 * Last Modified On: Jun 13, 2026
 * Description     : This class retrieves South African public holidays from the Calendarific API.
 *
 * Change History  :
 *  Date          │   Author      │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jun 13, 2026  │ pkrammekwa    │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */
public with sharing class CalendarificHolidayService {
    private static final String NAMED_CREDENTIAL = 'callout:Calendarific';
    private static final String COUNTRY_CODE = 'ZA';
    private static final String API_KEY_RECORD_NAME = 'Calendarific_API_key';

    /**
     * Author      : pkrammekwa
     * Description : Retrieves South African public holidays for the provided year.
     *
     * @param yearValue The year extracted from the South African ID number.
     * @return List<Holiday>
     */
    public static List<Holiday> getSouthAfricanPublicHolidays(Integer yearValue) {
        if (yearValue == null) {
            throw new BirthdateHolidayException('Year is required.');
        }

        HttpResponse response = HttpClient.sendGetRequest(buildHolidayEndpoint(yearValue));

        if (response.getStatusCode() != 200) {
            throw new BirthdateHolidayException('Calendarific API call failed.');
        }

        return parseHolidayResponse(response.getBody());
    }

    /**
     * Author      : pkrammekwa
     * Description : Builds the Calendarific holidays endpoint.
     *
     * @param yearValue The year extracted from the South African ID number.
     * @return String
     */
    private static String buildHolidayEndpoint(Integer yearValue) {
        return NAMED_CREDENTIAL +
            '/api/v2/holidays' +
            '?api_key=' + EncodingUtil.urlEncode(getApiKey(), 'UTF-8') +
            '&country=' + COUNTRY_CODE +
            '&year=' + String.valueOf(yearValue);
    }

    /**
     * Author      : pkrammekwa
     * Description : Retrieves the Calendarific API key from custom metadata.
     *
     * @return String
     */
    private static String getApiKey() {
        Calendarific_Setting__mdt setting =
            Calendarific_Setting__mdt.getInstance(API_KEY_RECORD_NAME);

        if (setting == null || String.isBlank(setting.Api_Key__c)) {
            throw new BirthdateHolidayException('Calendarific API key is missing.');
        }

        return setting.Api_Key__c;
    }

    /**
     * Author      : pkrammekwa
     * Description : Parses the Calendarific API response into holiday items.
     *
     * @param responseBody The raw JSON response returned by Calendarific.
     * @return List<Holiday>
     */
    private static List<Holiday> parseHolidayResponse(String responseBody) {
        if (String.isBlank(responseBody)) {
            throw new BirthdateHolidayException('Calendarific API returned an empty response.');
        }

        Map<String, Object> responseMap =
            (Map<String, Object>) JSON.deserializeUntyped(responseBody);

        Map<String, Object> responseData =
            (Map<String, Object>) responseMap.get('response');

        if (responseData == null || !responseData.containsKey('holidays')) {
            throw new BirthdateHolidayException('Calendarific API returned an invalid response.');
        }

        List<Object> holidayItems = (List<Object>) responseData.get('holidays');
        List<Holiday> holidays = new List<Holiday>();

        for (Object holidayItem : holidayItems) {
            Map<String, Object> holidayMap = (Map<String, Object>) holidayItem;
            Map<String, Object> dateMap = (Map<String, Object>) holidayMap.get('date');

            holidays.add(
                new Holiday(
                    String.valueOf(holidayMap.get('name')),
                    String.valueOf(holidayMap.get('description')),
                    dateMap == null ? null : String.valueOf(dateMap.get('iso')),
                    getHolidayType(holidayMap)
                )
            );
        }

        return holidays;
    }

    /**
     * Author      : pkrammekwa
     * Description : Reads the first holiday type value from a Calendarific holiday item.
     *
     * @param holidayMap The holiday item map returned from Calendarific.
     * @return String
     */
    private static String getHolidayType(Map<String, Object> holidayMap) {
        List<Object> types = (List<Object>) holidayMap.get('type');

        if (types == null || types.isEmpty()) {
            return null;
        }

        return String.valueOf(types[0]);
    }

    public class Holiday {
        @AuraEnabled public String name;
        @AuraEnabled public String description;
        @AuraEnabled public String dateValue;
        @AuraEnabled public String type;

        /**
         * Author      : pkrammekwa
         * Description : Creates a holiday response item for the Lightning Web Component.
         *
         * @param name        The holiday name.
         * @param description The holiday description.
         * @param dateValue   The holiday date value.
         * @param type        The holiday type.
         */
        public Holiday(
            String name,
            String description,
            String dateValue,
            String type
        ) {
            this.name = name;
            this.description = description;
            this.dateValue = dateValue;
            this.type = type;
        }
    }
}