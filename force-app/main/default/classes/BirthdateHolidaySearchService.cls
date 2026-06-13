/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : BirthdateHolidaySearchService
 * Author          : pkrammekwa
 * Created Date    : Jun 13, 2026
 * Last Modified By: pkrammekwa
 * Last Modified On: Jun 13, 2026
 * Description     : This class stores decoded South African ID number information and tracks how often an ID number is queried.
 *
 * Change History  :
 *  Date          │   Author      │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jun 13, 2026  │ pkrammekwa    │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */
public with sharing class BirthdateHolidaySearchService {
    public class CounterResult {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public Id recordId;
        @AuraEnabled public Decimal searchCount;
        @AuraEnabled public Boolean wasCreated;

        public CounterResult(
            Boolean success,
            String message,
            Id recordId,
            Decimal searchCount,
            Boolean wasCreated
        ) {
            this.success = success;
            this.message = message;
            this.recordId = recordId;
            this.searchCount = searchCount;
            this.wasCreated = wasCreated;
        }
    }

    /**
     * Author      : pkrammekwa
     * Description : Records a valid South African ID number query and returns the saved tracking result.
     *
     * @param idNumber    The South African ID number submitted from the Lightning Web Component.
     * @param dateOfBirth The decoded date of birth from the ID number.
     * @param gender      The decoded gender from the ID number.
     * @param saCitizen   Indicates whether the ID number belongs to a South African citizen.
     * @return CounterResult
     */
    public static CounterResult recordIdNumberQuery(
        String idNumber,
        String dateOfBirth,
        String gender,
        Boolean saCitizen
    ) {
        validateRequiredDetails(idNumber, dateOfBirth, gender, saCitizen);

        ID_Holiday_Search__c existingSearchRecord = findExistingIdHolidaySearch(idNumber);

        if (existingSearchRecord != null) {
            return updateExistingSearchRecord(
                existingSearchRecord,
                dateOfBirth,
                gender,
                saCitizen
            );
        }

        return createSearchRecord(
            idNumber,
            dateOfBirth,
            gender,
            saCitizen
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
            throw new AuraHandledException('ID Number is required.');
        }

        if (String.isBlank(dateOfBirth)) {
            throw new AuraHandledException('Date of birth is required.');
        }

        if (String.isBlank(gender)) {
            throw new AuraHandledException('Gender is required.');
        }

        if (saCitizen == null) {
            throw new AuraHandledException('SA citizen value is required.');
        }
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
     * @return CounterResult
     */
    private static CounterResult updateExistingSearchRecord(
        ID_Holiday_Search__c existingSearchRecord,
        String dateOfBirth,
        String gender,
        Boolean saCitizen
    ) {
        existingSearchRecord.Date_Of_Birth__c = Date.valueOf(dateOfBirth);
        existingSearchRecord.Gender__c = gender;
        existingSearchRecord.SA_Citizen__c = saCitizen;
        existingSearchRecord.Search_Count__c = incrementSearchCount(existingSearchRecord.Search_Count__c);

        update existingSearchRecord;

        return new CounterResult(
            true,
            'ID number query recorded successfully.',
            existingSearchRecord.Id,
            existingSearchRecord.Search_Count__c,
            false
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
     * @return CounterResult
     */
    private static CounterResult createSearchRecord(
        String idNumber,
        String dateOfBirth,
        String gender,
        Boolean saCitizen
    ) {
        ID_Holiday_Search__c newSearchRecord = new ID_Holiday_Search__c(
            ID_Number__c = idNumber,
            Date_Of_Birth__c = Date.valueOf(dateOfBirth),
            Gender__c = gender,
            SA_Citizen__c = saCitizen,
            Search_Count__c = 1
        );

        insert newSearchRecord;

        return new CounterResult(
            true,
            'ID number query recorded successfully.',
            newSearchRecord.Id,
            newSearchRecord.Search_Count__c,
            true
        );
    }
}