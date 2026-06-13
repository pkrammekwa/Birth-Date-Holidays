/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : BirthdateHolidaySearchService
 * Author          : pkrammekwa
 * Created Date    : Jun 13, 2026
 * Last Modified By: pkrammekwa
 * Last Modified On: Jun 13, 2026
 * Description     : This class stores decoded South African ID number information, tracks query counts, and retrieves public holidays.
 *
 * Change History  :
 *  Date          │   Author      │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jun 13, 2026  │ pkrammekwa    │ Initial version
 *  Jun 13, 2026  │ pkrammekwa    │ Updated for USERSTORY-004 to retrieve, flag, and return public holidays
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */
public with sharing class BirthdateHolidaySearchService {
    public class SearchResult {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public Id recordId;
        @AuraEnabled public Decimal searchCount;
        @AuraEnabled public Boolean wasCreated;
        @AuraEnabled public List<CalendarificHolidayService.Holiday> holidays;

        public SearchResult(
            Boolean success,
            String message,
            Id recordId,
            Decimal searchCount,
            Boolean wasCreated,
            List<CalendarificHolidayService.Holiday> holidays
        ) {
            this.success = success;
            this.message = message;
            this.recordId = recordId;
            this.searchCount = searchCount;
            this.wasCreated = wasCreated;
            this.holidays = holidays;
        }
    }

    /**
     * Author      : pkrammekwa
     * Description : Processes the full birthdate holiday search by retrieving holidays first, flagging matching holidays, then saving or updating the ID query record.
     *
     * @param idNumber    The South African ID number submitted from the Lightning Web Component.
     * @param dateOfBirth The decoded date of birth from the ID number.
     * @param gender      The decoded gender from the ID number.
     * @param saCitizen   Indicates whether the ID number belongs to a South African citizen.
     * @return SearchResult
     */
    public static SearchResult processBirthdateHolidaySearch(
        String idNumber,
        String dateOfBirth,
        String gender,
        Boolean saCitizen
    ) {
        validateRequiredDetails(idNumber, dateOfBirth, gender, saCitizen);

        Date birthDate = getBirthDate(dateOfBirth);
        Integer yearValue = birthDate.year();

        List<CalendarificHolidayService.Holiday> holidays =
            CalendarificHolidayService.getSouthAfricanPublicHolidays(yearValue);

        List<CalendarificHolidayService.Holiday> flaggedHolidays =
            flagAndSortHolidaysByBirthDate(holidays, birthDate);

        ID_Holiday_Search__c existingSearchRecord = findExistingIdHolidaySearch(idNumber);

        if (existingSearchRecord != null) {
            return updateExistingSearchRecord(
                existingSearchRecord,
                dateOfBirth,
                gender,
                saCitizen,
                flaggedHolidays
            );
        }

        return createSearchRecord(
            idNumber,
            dateOfBirth,
            gender,
            saCitizen,
            flaggedHolidays
        );
    }

    /**
     * Author      : pkrammekwa
     * Description : Validates that all required details are provided.
     *
     * @param idNumber    The South African ID number submitted from the Lightning Web Component.
     * @param dateOfBirth The decoded date of birth from the ID number.
     * @param gender      The decoded gender from the ID number.
     * @param saCitizen   Indicates whether the ID number belongs to a South African citizen.
     */
    private static void validateRequiredDetails(
        String idNumber,
        String dateOfBirth,
        String gender,
        Boolean saCitizen
    ) {
        if (String.isBlank(idNumber)) {
            throw new BirthdateHolidayException('ID Number is required.');
        }

        if (String.isBlank(dateOfBirth)) {
            throw new BirthdateHolidayException('Date of birth is required.');
        }

        if (String.isBlank(gender)) {
            throw new BirthdateHolidayException('Gender is required.');
        }

        if (saCitizen == null) {
            throw new BirthdateHolidayException('SA citizen value is required.');
        }
    }

    /**
     * Author      : pkrammekwa
     * Description : Converts the decoded date of birth string into a Date value.
     *
     * @param dateOfBirth The decoded date of birth from the ID number.
     * @return Date
     */
    private static Date getBirthDate(String dateOfBirth) {
        try {
            return Date.valueOf(dateOfBirth);
        } catch (Exception exceptionMessage) {
            throw new BirthdateHolidayException('Date of birth is invalid.');
        }
    }

    /**
     * Author      : pkrammekwa
     * Description : Flags holidays matching the birth date month and day, then moves matching holidays to the top.
     *
     * @param holidays  The public holidays returned from Calendarific.
     * @param birthDate The decoded birth date from the South African ID number.
     * @return List<CalendarificHolidayService.Holiday>
     */
    private static List<CalendarificHolidayService.Holiday> flagAndSortHolidaysByBirthDate(
        List<CalendarificHolidayService.Holiday> holidays,
        Date birthDate
    ) {
        List<CalendarificHolidayService.Holiday> matchingHolidays =
            new List<CalendarificHolidayService.Holiday>();
        List<CalendarificHolidayService.Holiday> otherHolidays =
            new List<CalendarificHolidayService.Holiday>();

        if (holidays == null || birthDate == null) {
            return new List<CalendarificHolidayService.Holiday>();
        }

        for (CalendarificHolidayService.Holiday holiday : holidays) {
            holiday.matchesBirthDate = false;

            if (!String.isBlank(holiday.dateValue)) {
                Date holidayDate = Date.valueOf(holiday.dateValue);

                holiday.matchesBirthDate =
                    holidayDate.month() == birthDate.month() &&
                    holidayDate.day() == birthDate.day();
            }

            if (holiday.matchesBirthDate) {
                matchingHolidays.add(holiday);
            } else {
                otherHolidays.add(holiday);
            }
        }

        matchingHolidays.addAll(otherHolidays);
        return matchingHolidays;
    }

    /**
     * Author      : pkrammekwa
     * Description : Finds an existing ID holiday search record by South African ID number.
     *
     * @param idNumber The South African ID number submitted from the Lightning Web Component.
     * @return ID_Holiday_Search__c
     */
    private static ID_Holiday_Search__c findExistingIdHolidaySearch(String idNumber) {
        List<ID_Holiday_Search__c> existingSearchRecords = [
            SELECT Id, Search_Count__c
            FROM ID_Holiday_Search__c
            WHERE ID_Number__c = :idNumber
            LIMIT 1
        ];

        return existingSearchRecords.isEmpty() ? null : existingSearchRecords[0];
    }

    /**
     * Author      : pkrammekwa
     * Description : Increments the search count value.
     *
     * @param currentSearchCount The current search count stored on the record.
     * @return Decimal
     */
    private static Decimal incrementSearchCount(Decimal currentSearchCount) {
        return currentSearchCount == null ? 1 : currentSearchCount + 1;
    }

    /**
     * Author      : pkrammekwa
     * Description : Updates an existing ID holiday search record with decoded information and the latest search count.
     *
     * @param existingSearchRecord The existing ID_Holiday_Search__c record.
     * @param dateOfBirth          The decoded date of birth from the ID number.
     * @param gender               The decoded gender from the ID number.
     * @param saCitizen            Indicates whether the ID number belongs to a South African citizen.
     * @param holidays             The public holidays returned from Calendarific.
     * @return SearchResult
     */
    private static SearchResult updateExistingSearchRecord(
        ID_Holiday_Search__c existingSearchRecord,
        String dateOfBirth,
        String gender,
        Boolean saCitizen,
        List<CalendarificHolidayService.Holiday> holidays
    ) {
        existingSearchRecord.Date_Of_Birth__c = Date.valueOf(dateOfBirth);
        existingSearchRecord.Gender__c = gender;
        existingSearchRecord.SA_Citizen__c = saCitizen;
        existingSearchRecord.Search_Count__c = incrementSearchCount(existingSearchRecord.Search_Count__c);

        update existingSearchRecord;

        return new SearchResult(
            true,
            'ID number query recorded successfully.',
            existingSearchRecord.Id,
            existingSearchRecord.Search_Count__c,
            false,
            holidays
        );
    }

    /**
     * Author      : pkrammekwa
     * Description : Creates a new ID holiday search record with decoded information.
     *
     * @param idNumber    The South African ID number submitted from the Lightning Web Component.
     * @param dateOfBirth The decoded date of birth from the ID number.
     * @param gender      The decoded gender from the ID number.
     * @param saCitizen   Indicates whether the ID number belongs to a South African citizen.
     * @param holidays    The public holidays returned from Calendarific.
     * @return SearchResult
     */
    private static SearchResult createSearchRecord(
        String idNumber,
        String dateOfBirth,
        String gender,
        Boolean saCitizen,
        List<CalendarificHolidayService.Holiday> holidays
    ) {
        ID_Holiday_Search__c newSearchRecord = new ID_Holiday_Search__c(
            ID_Number__c = idNumber,
            Date_Of_Birth__c = Date.valueOf(dateOfBirth),
            Gender__c = gender,
            SA_Citizen__c = saCitizen,
            Search_Count__c = 1
        );

        insert newSearchRecord;

        return new SearchResult(
            true,
            'ID number query recorded successfully.',
            newSearchRecord.Id,
            newSearchRecord.Search_Count__c,
            true,
            holidays
        );
    }
}