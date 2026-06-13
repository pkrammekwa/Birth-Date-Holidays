/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : BirthdateHolidaySearchServiceTest
 * Author          : pkrammekwa
 * Created Date    : Jun 13, 2026
 * Last Modified By: pkrammekwa
 * Last Modified On: Jun 13, 2026
 * Description     : This class tests storing decoded South African ID number information and tracking query counts.
 *
 * Change History  :
 *  Date          │   Author      │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jun 13, 2026  │ pkrammekwa    │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */
@IsTest
private class BirthdateHolidaySearchServiceTest {
    private static final String TEST_ID_NUMBER = '9001015009086';
    private static final String TEST_DATE_OF_BIRTH = '1990-01-01';
    private static final String TEST_GENDER = 'Male';
    private static final Boolean TEST_SA_CITIZEN = true;

    /**
     * Author      : pkrammekwa
     * Description : Tests that a new ID holiday search record is created when the ID number does not exist.
     */
    @IsTest
    static void recordIdNumberQueryShouldCreateNewRecord() {
        Test.startTest();

        BirthdateHolidaySearchService.CounterResult result =
            BirthdateHolidaySearchService.recordIdNumberQuery(
                TEST_ID_NUMBER,
                TEST_DATE_OF_BIRTH,
                TEST_GENDER,
                TEST_SA_CITIZEN
            );

        Test.stopTest();

        System.assertEquals(true, result.success, 'Result should be successful.');
        System.assertEquals(true, result.wasCreated, 'Record should be created.');
        System.assertEquals(1, result.searchCount, 'Search count should start at 1.');
        System.assertNotEquals(null, result.recordId, 'Record Id should be returned.');

        ID_Holiday_Search__c savedRecord = [
            SELECT ID_Number__c, Date_Of_Birth__c, Gender__c, SA_Citizen__c, Search_Count__c
            FROM ID_Holiday_Search__c
            WHERE Id = :result.recordId
            LIMIT 1
        ];

        System.assertEquals(TEST_ID_NUMBER, savedRecord.ID_Number__c, 'ID number should be saved.');
        System.assertEquals(Date.valueOf(TEST_DATE_OF_BIRTH), savedRecord.Date_Of_Birth__c, 'Date of birth should be saved.');
        System.assertEquals(TEST_GENDER, savedRecord.Gender__c, 'Gender should be saved.');
        System.assertEquals(TEST_SA_CITIZEN, savedRecord.SA_Citizen__c, 'SA citizen value should be saved.');
        System.assertEquals(1, savedRecord.Search_Count__c, 'Search count should be saved as 1.');
    }

    /**
     * Author      : pkrammekwa
     * Description : Tests that an existing ID holiday search record is updated and the search count is incremented.
     */
    @IsTest
    static void recordIdNumberQueryShouldIncrementExistingRecord() {
        ID_Holiday_Search__c existingRecord = new ID_Holiday_Search__c(
            ID_Number__c = TEST_ID_NUMBER,
            Date_Of_Birth__c = Date.valueOf(TEST_DATE_OF_BIRTH),
            Gender__c = TEST_GENDER,
            SA_Citizen__c = TEST_SA_CITIZEN,
            Search_Count__c = 1
        );
        insert existingRecord;

        Test.startTest();

        BirthdateHolidaySearchService.CounterResult result =
            BirthdateHolidaySearchService.recordIdNumberQuery(
                TEST_ID_NUMBER,
                TEST_DATE_OF_BIRTH,
                TEST_GENDER,
                TEST_SA_CITIZEN
            );

        Test.stopTest();

        System.assertEquals(true, result.success, 'Result should be successful.');
        System.assertEquals(false, result.wasCreated, 'Record should not be created again.');
        System.assertEquals(existingRecord.Id, result.recordId, 'Existing record Id should be returned.');
        System.assertEquals(2, result.searchCount, 'Search count should increment to 2.');

        ID_Holiday_Search__c updatedRecord = [
            SELECT Search_Count__c
            FROM ID_Holiday_Search__c
            WHERE Id = :existingRecord.Id
            LIMIT 1
        ];

        System.assertEquals(2, updatedRecord.Search_Count__c, 'Saved search count should be 2.');
    }

    /**
     * Author      : pkrammekwa
     * Description : Tests that missing ID number throws a handled exception.
     */
    @IsTest
    static void recordIdNumberQueryShouldThrowErrorWhenIdNumberMissing() {
        try {
            Test.startTest();

            BirthdateHolidaySearchService.recordIdNumberQuery(
                '',
                TEST_DATE_OF_BIRTH,
                TEST_GENDER,
                TEST_SA_CITIZEN
            );

            Test.stopTest();

            System.assert(false, 'Expected an AuraHandledException.');
        } catch (AuraHandledException exceptionMessage) {
            System.assertNotEquals(null, exceptionMessage, 'Exception should be thrown.');
        }
    }

    /**
     * Author      : pkrammekwa
     * Description : Tests that missing date of birth throws a handled exception.
     */
    @IsTest
    static void recordIdNumberQueryShouldThrowErrorWhenDateOfBirthMissing() {
        try {
            Test.startTest();

            BirthdateHolidaySearchService.recordIdNumberQuery(
                TEST_ID_NUMBER,
                '',
                TEST_GENDER,
                TEST_SA_CITIZEN
            );

            Test.stopTest();

            System.assert(false, 'Expected an AuraHandledException.');
        } catch (AuraHandledException exceptionMessage) {
            System.assertNotEquals(null, exceptionMessage, 'Exception should be thrown.');
        }
    }

    /**
     * Author      : pkrammekwa
     * Description : Tests that missing gender throws a handled exception.
     */
    @IsTest
    static void recordIdNumberQueryShouldThrowErrorWhenGenderMissing() {
        try {
            Test.startTest();

            BirthdateHolidaySearchService.recordIdNumberQuery(
                TEST_ID_NUMBER,
                TEST_DATE_OF_BIRTH,
                '',
                TEST_SA_CITIZEN
            );

            Test.stopTest();

            System.assert(false, 'Expected an AuraHandledException.');
        } catch (AuraHandledException exceptionMessage) {
            System.assertNotEquals(null, exceptionMessage, 'Exception should be thrown.');
        }
    }

    /**
     * Author      : pkrammekwa
     * Description : Tests that missing SA citizen value throws a handled exception.
     */
    @IsTest
    static void recordIdNumberQueryShouldThrowErrorWhenSaCitizenMissing() {
        try {
            Test.startTest();

            BirthdateHolidaySearchService.recordIdNumberQuery(
                TEST_ID_NUMBER,
                TEST_DATE_OF_BIRTH,
                TEST_GENDER,
                null
            );

            Test.stopTest();

            System.assert(false, 'Expected an AuraHandledException.');
        } catch (AuraHandledException exceptionMessage) {
            System.assertNotEquals(null, exceptionMessage, 'Exception should be thrown.');
        }
    }
}