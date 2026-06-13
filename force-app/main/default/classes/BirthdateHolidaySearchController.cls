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
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */
public with sharing class BirthdateHolidaySearchController {
    /**
     * Author      : pkrammekwa
     * Description : Records a valid South African ID number query and returns the saved tracking result.
     *
     * @param idNumber    The South African ID number submitted from the Lightning Web Component.
     * @param dateOfBirth The decoded date of birth from the ID number.
     * @param gender      The decoded gender from the ID number.
     * @param saCitizen   Indicates whether the ID number belongs to a South African citizen.
     * @return BirthdateHolidaySearchService.CounterResult
     */
    @AuraEnabled
    public static BirthdateHolidaySearchService.CounterResult recordIdNumberQuery(
        String idNumber,
        String dateOfBirth,
        String gender,
        Boolean saCitizen
    ) {
        return BirthdateHolidaySearchService.recordIdNumberQuery(
            idNumber,
            dateOfBirth,
            gender,
            saCitizen
        );
    }
}