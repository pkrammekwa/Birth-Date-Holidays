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
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */
@IsTest
private class BirthdateHolidaySearchControllerTest {
    /**
     * Author      : pkrammekwa
     * Description : Tests that the controller records a valid ID number query through the service layer.
     */
    @IsTest
    static void recordIdNumberQueryShouldReturnCounterResult() {
        Test.startTest();

        BirthdateHolidaySearchService.CounterResult result =
            BirthdateHolidaySearchController.recordIdNumberQuery(
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
    }
}