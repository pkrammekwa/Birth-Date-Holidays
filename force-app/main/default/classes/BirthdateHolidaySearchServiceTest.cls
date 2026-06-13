/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : BirthdateHolidaySearchServiceTest
 * Author          : pkrammekwa
 * Created Date    : Jun 13, 2026
 * Last Modified By: pkrammekwa
 * Last Modified On: Jun 13, 2026
 * Description     : This class tests storing decoded South African ID number information, tracking query counts, and returning public holidays with the matching birthdate holiday highlighted.
 *
 * Change History  :
 *  Date          │   Author      │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jun 13, 2026  │ pkrammekwa    │ Initial version
 *  Jun 13, 2026  │ pkrammekwa    │ Updated for USERSTORY-004 to test highlighted matching birthdate holiday
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
     * Description : Tests that a new ID holiday search record is created and all public holidays are returned with the matching holiday first.
     */
    @IsTest
    static void processBirthdateHolidaySearchShouldCreateNewRecordAndReturnHighlightedHolidays() {
        Test.setMock(HttpCalloutMock.class, new CalendarificHolidayApiMock());

        Test.startTest();

        BirthdateHolidaySearchService.SearchResult result =
            BirthdateHolidaySearchService.processBirthdateHolidaySearch(
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

        System.assertNotEquals(null, result.holidays, 'Holidays should be returned.');
        System.assertEquals(2, result.holidays.size(), 'All mocked holidays should be returned.');

        System.assertEquals('New Year\'s Day', result.holidays[0].name, 'Matching holiday should be first.');
        System.assertEquals(true, result.holidays[0].matchesBirthDate, 'First holiday should match the birth date.');

        System.assertEquals('Human Rights Day', result.holidays[1].name, 'Non-matching holiday should follow.');
        System.assertEquals(false, result.holidays[1].matchesBirthDate, 'Second holiday should not match the birth date.');

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
     * Description : Tests that an existing ID holiday search record is updated, incremented, and all public holidays are returned with the matching holiday first.
     */
    @IsTest
    static void processBirthdateHolidaySearchShouldIncrementExistingRecordAndReturnHighlightedHolidays() {
        ID_Holiday_Search__c existingRecord = new ID_Holiday_Search__c(
            ID_Number__c = TEST_ID_NUMBER,
            Date_Of_Birth__c = Date.valueOf(TEST_DATE_OF_BIRTH),
            Gender__c = TEST_GENDER,
            SA_Citizen__c = TEST_SA_CITIZEN,
            Search_Count__c = 1
        );
        insert existingRecord;

        Test.setMock(HttpCalloutMock.class, new CalendarificHolidayApiMock());

        Test.startTest();

        BirthdateHolidaySearchService.SearchResult result =
            BirthdateHolidaySearchService.processBirthdateHolidaySearch(
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

        System.assertEquals(2, result.holidays.size(), 'All mocked holidays should be returned.');
        System.assertEquals('New Year\'s Day', result.holidays[0].name, 'Matching holiday should be first.');
        System.assertEquals(true, result.holidays[0].matchesBirthDate, 'First holiday should match the birth date.');
        System.assertEquals(false, result.holidays[1].matchesBirthDate, 'Second holiday should not match the birth date.');

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
     * Description : Tests that all holidays are returned and none are highlighted when the birth date does not match any public holiday.
     */
    @IsTest
    static void processBirthdateHolidaySearchShouldReturnAllHolidaysWithoutHighlightWhenNoHolidayMatches() {
        Test.setMock(HttpCalloutMock.class, new CalendarificHolidayApiMock());

        Test.startTest();

        BirthdateHolidaySearchService.SearchResult result =
            BirthdateHolidaySearchService.processBirthdateHolidaySearch(
                '9001025009085',
                '1990-01-02',
                TEST_GENDER,
                TEST_SA_CITIZEN
            );

        Test.stopTest();

        System.assertEquals(true, result.success, 'Result should be successful.');
        System.assertEquals(true, result.wasCreated, 'Record should be created.');

        System.assertNotEquals(null, result.holidays, 'Holidays should not be null.');
        System.assertEquals(2, result.holidays.size(), 'All mocked holidays should still be returned.');
        System.assertEquals(false, result.holidays[0].matchesBirthDate, 'First holiday should not match the birth date.');
        System.assertEquals(false, result.holidays[1].matchesBirthDate, 'Second holiday should not match the birth date.');
    }

    /**
     * Author      : pkrammekwa
     * Description : Tests that missing ID number throws a custom exception.
     */
    @IsTest
    static void processBirthdateHolidaySearchShouldThrowErrorWhenIdNumberMissing() {
        try {
            Test.startTest();

            BirthdateHolidaySearchService.processBirthdateHolidaySearch(
                '',
                TEST_DATE_OF_BIRTH,
                TEST_GENDER,
                TEST_SA_CITIZEN
            );

            Test.stopTest();

            System.assert(false, 'Expected a BirthdateHolidayException.');
        } catch (BirthdateHolidayException exceptionMessage) {
            System.assertNotEquals(null, exceptionMessage, 'Exception should be thrown.');
        }
    }

    /**
     * Author      : pkrammekwa
     * Description : Tests that missing date of birth throws a custom exception.
     */
    @IsTest
    static void processBirthdateHolidaySearchShouldThrowErrorWhenDateOfBirthMissing() {
        try {
            Test.startTest();

            BirthdateHolidaySearchService.processBirthdateHolidaySearch(
                TEST_ID_NUMBER,
                '',
                TEST_GENDER,
                TEST_SA_CITIZEN
            );

            Test.stopTest();

            System.assert(false, 'Expected a BirthdateHolidayException.');
        } catch (BirthdateHolidayException exceptionMessage) {
            System.assertNotEquals(null, exceptionMessage, 'Exception should be thrown.');
        }
    }

    /**
     * Author      : pkrammekwa
     * Description : Tests that missing gender throws a custom exception.
     */
    @IsTest
    static void processBirthdateHolidaySearchShouldThrowErrorWhenGenderMissing() {
        try {
            Test.startTest();

            BirthdateHolidaySearchService.processBirthdateHolidaySearch(
                TEST_ID_NUMBER,
                TEST_DATE_OF_BIRTH,
                '',
                TEST_SA_CITIZEN
            );

            Test.stopTest();

            System.assert(false, 'Expected a BirthdateHolidayException.');
        } catch (BirthdateHolidayException exceptionMessage) {
            System.assertNotEquals(null, exceptionMessage, 'Exception should be thrown.');
        }
    }

    /**
     * Author      : pkrammekwa
     * Description : Tests that missing SA citizen value throws a custom exception.
     */
    @IsTest
    static void processBirthdateHolidaySearchShouldThrowErrorWhenSaCitizenMissing() {
        try {
            Test.startTest();

            BirthdateHolidaySearchService.processBirthdateHolidaySearch(
                TEST_ID_NUMBER,
                TEST_DATE_OF_BIRTH,
                TEST_GENDER,
                null
            );

            Test.stopTest();

            System.assert(false, 'Expected a BirthdateHolidayException.');
        } catch (BirthdateHolidayException exceptionMessage) {
            System.assertNotEquals(null, exceptionMessage, 'Exception should be thrown.');
        }
    }
}