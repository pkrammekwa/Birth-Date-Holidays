/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : CalendarificHolidayServiceTest
 * Author          : pkrammekwa
 * Created Date    : Jun 13, 2026
 * Last Modified By: pkrammekwa
 * Last Modified On: Jun 13, 2026
 * Description     : This class tests retrieving and parsing South African public holidays from the Calendarific API.
 *
 * Change History  :
 *  Date          │   Author      │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jun 13, 2026  │ pkrammekwa    │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */
@IsTest
private class CalendarificHolidayServiceTest {
    /**
     * Author      : pkrammekwa
     * Description : Tests that South African public holidays are returned from a successful mocked Calendarific API response.
     */
    @IsTest
    static void getSouthAfricanPublicHolidaysShouldReturnHolidayList() {
        Test.setMock(HttpCalloutMock.class, new CalendarificHolidayApiMock());

        Test.startTest();

        List<CalendarificHolidayService.Holiday> holidays =
            CalendarificHolidayService.getSouthAfricanPublicHolidays(1990);

        Test.stopTest();

        System.assertEquals(2, holidays.size(), 'Two mocked holidays should be returned.');
        System.assertEquals('New Year\'s Day', holidays[0].name, 'First holiday name should match.');
        System.assertEquals('1990-01-01', holidays[0].dateValue, 'First holiday date should match.');
        System.assertEquals('National holiday', holidays[0].type, 'First holiday type should match.');
        System.assertEquals(false, holidays[0].matchesBirthDate, 'Default match flag should be false.');
    }

    /**
     * Author      : pkrammekwa
     * Description : Tests that a missing year throws a custom exception.
     */
    @IsTest
    static void getSouthAfricanPublicHolidaysShouldThrowErrorWhenYearMissing() {
        try {
            Test.startTest();

            CalendarificHolidayService.getSouthAfricanPublicHolidays(null);

            Test.stopTest();

            System.assert(false, 'Expected a BirthdateHolidayException.');
        } catch (BirthdateHolidayException exceptionMessage) {
            System.assertNotEquals(null, exceptionMessage, 'Exception should be thrown.');
        }
    }

    /**
     * Author      : pkrammekwa
     * Description : Tests that a failed Calendarific API response throws a custom exception.
     */
    @IsTest
    static void getSouthAfricanPublicHolidaysShouldThrowErrorWhenApiFails() {
        Test.setMock(
            HttpCalloutMock.class,
            new CalendarificHolidayApiMock(500, '{"meta":{"code":500},"response":{}}')
        );

        try {
            Test.startTest();

            CalendarificHolidayService.getSouthAfricanPublicHolidays(1990);

            Test.stopTest();

            System.assert(false, 'Expected a BirthdateHolidayException.');
        } catch (BirthdateHolidayException exceptionMessage) {
            System.assertNotEquals(null, exceptionMessage, 'Exception should be thrown.');
        }
    }

    /**
     * Author      : pkrammekwa
     * Description : Tests that an invalid Calendarific API response throws a custom exception.
     */
    @IsTest
    static void getSouthAfricanPublicHolidaysShouldThrowErrorWhenResponseIsInvalid() {
        Test.setMock(
            HttpCalloutMock.class,
            new CalendarificHolidayApiMock(200, '{"meta":{"code":200},"response":{}}')
        );

        try {
            Test.startTest();

            CalendarificHolidayService.getSouthAfricanPublicHolidays(1990);

            Test.stopTest();

            System.assert(false, 'Expected a BirthdateHolidayException.');
        } catch (BirthdateHolidayException exceptionMessage) {
            System.assertNotEquals(null, exceptionMessage, 'Exception should be thrown.');
        }
    }

    /**
     * Author      : pkrammekwa
     * Description : Tests that an empty Calendarific API response throws a custom exception.
     */
    @IsTest
    static void getSouthAfricanPublicHolidaysShouldThrowErrorWhenResponseIsEmpty() {
        Test.setMock(
            HttpCalloutMock.class,
            new CalendarificHolidayApiMock(200, '')
        );

        try {
            Test.startTest();

            CalendarificHolidayService.getSouthAfricanPublicHolidays(1990);

            Test.stopTest();

            System.assert(false, 'Expected a BirthdateHolidayException.');
        } catch (BirthdateHolidayException exceptionMessage) {
            System.assertNotEquals(null, exceptionMessage, 'Exception should be thrown.');
        }
    }
}