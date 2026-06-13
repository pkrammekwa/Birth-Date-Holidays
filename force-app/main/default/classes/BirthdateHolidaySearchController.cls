/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : BirthdateHolidaySearchController
 * Author          : pkrammekwa
 * Created Date    : Jun 13, 2026
 * Last Modified By: pkrammekwa
 * Last Modified On: Jun 13, 2026
 * Description     : This class exposes Apex methods used by the Birthdate Holiday Searcher Lightning Web Component.
 *
 * Change History  :
 *  Date          │   Author      │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jun 13, 2026  │ pkrammekwa    │ Initial version
 *  Jun 13, 2026  │ pkrammekwa    │ Updated for USERSTORY-004 to process holiday searches through the service layer
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */
public with sharing class BirthdateHolidaySearchController {
    /**
     * Author      : pkrammekwa
     * Description : Processes a valid South African ID number query and returns saved tracking details with public holidays.
     *
     * @param idNumber    The South African ID number submitted from the Lightning Web Component.
     * @param dateOfBirth The decoded date of birth from the ID number.
     * @param gender      The decoded gender from the ID number.
     * @param saCitizen   Indicates whether the ID number belongs to a South African citizen.
     * @return BirthdateHolidaySearchService.SearchResult
     */
    @AuraEnabled
    public static BirthdateHolidaySearchService.SearchResult processBirthdateHolidaySearch(
        String idNumber,
        String dateOfBirth,
        String gender,
        Boolean saCitizen
    ) {
        try {
            return BirthdateHolidaySearchService.processBirthdateHolidaySearch(
                idNumber,
                dateOfBirth,
                gender,
                saCitizen
            );
        } catch (BirthdateHolidayException exceptionMessage) {
            throw new AuraHandledException(exceptionMessage.getMessage());
        } catch (Exception exceptionMessage) {
            throw new AuraHandledException('Something went wrong while processing the birthdate holiday search.');
        }
    }
}