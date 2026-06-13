/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : BirthdateHolidaySearchControllerTest
 * Author          : pkrammekwa
 * Created Date    : Jun 13, 2026
 * Last Modified By: pkrammekwa
 * Last Modified On: Jun 13, 2026
 * Description     : This class tests the Apex controller used by the Birthdate Holiday Searcher Lightning Web Component.
 *
 * Change History  :
 *  Date          │   Author      │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jun 13, 2026  │ pkrammekwa    │ Initial version
 *  Jun 13, 2026  │ pkrammekwa    │ Updated for USERSTORY-004 to test holiday search processing
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */
@IsTest
private class BirthdateHolidaySearchControllerTest {
    /**
     * Author      : pkrammekwa
     * Description : Tests that the controller processes a valid ID number query and returns tracking details with holidays.
     */
    @IsTest
    static void processBirthdateHolidaySearchShouldReturnSearchResult() {
        Test.setMock(HttpCalloutMock.class, new CalendarificHolidayApiMock());

        Test.startTest();

        BirthdateHolidaySearchService.SearchResult result =
            BirthdateHolidaySearchController.processBirthdateHolidaySearch(
                '9001015009086',
                '1990-01-01',
                'Male',
                true
            );

        Test.stopTest();

        System.assertEquals(true, result.success, 'Result should be successful.');
        System.assertEquals(true, result.wasCreated, 'Record should be created.');
        System.assertEquals(1, result.searchCount, 'Search count should be 1.');
        System.assertNotEquals(null, result.recordId, 'Record Id should be returned.');
        System.assertNotEquals(null, result.holidays, 'Holidays should be returned.');
        System.assertEquals(2, result.holidays.size(), 'Two mocked holidays should be returned.');
    }

    /**
     * Author      : pkrammekwa
     * Description : Tests that the controller returns a handled exception when required details are missing.
     */
    @IsTest
    static void processBirthdateHolidaySearchShouldThrowHandledErrorWhenRequiredDetailsMissing() {
        try {
            Test.startTest();

            BirthdateHolidaySearchController.processBirthdateHolidaySearch(
                '',
                '1990-01-01',
                'Male',
                true
            );

            Test.stopTest();

            System.assert(false, 'Expected an AuraHandledException.');
        } catch (AuraHandledException exceptionMessage) {
            System.assertNotEquals(null, exceptionMessage, 'Exception should be thrown.');
        }
    }
}