import { LightningElement } from 'lwc';
import processBirthdateHolidaySearch from '@salesforce/apex/BirthdateHolidaySearchController.processBirthdateHolidaySearch';
import {
    validateSouthAfricanIdNumber,
    decodeSouthAfricanIdNumber
} from './birthdateHolidaySearcherUtils';

export default class BirthdateHolidaySearcher extends LightningElement {
    idNumber = '';
    validationMessage = '';
    isValidIdNumber = false;
    decodedIdDetails;
    holidays = [];
    isLoading = false;

    get isSearchDisabled() {
        return !this.isValidIdNumber || this.isLoading;
    }

    get validationMessageClass() {
        return this.isValidIdNumber ? 'success-message' : 'error-message';
    }

    get searchButtonLabel() {
        return this.isLoading ? 'Searching...' : 'Search';
    }

    get hasHolidays() {
        return this.holidays.length > 0;
    }

    handleIdNumberChange(event) {
        this.idNumber = event.target.value.replace(/\D/g, '');
        this.decodedIdDetails = undefined;
        this.holidays = [];
        this.validateIdNumber();
    }

    async handleSearch() {
        if (!this.isValidIdNumber) {
            this.validationMessage = 'Please enter a valid South African ID Number before searching.';
            this.decodedIdDetails = undefined;
            this.holidays = [];
            return;
        }

        this.isLoading = true;
        this.validationMessage = '';
        this.holidays = [];

        try {
            const decodedDetails = decodeSouthAfricanIdNumber(this.idNumber);

            const response = await processBirthdateHolidaySearch({
                idNumber: this.idNumber,
                dateOfBirth: decodedDetails.dateOfBirth,
                gender: decodedDetails.gender,
                saCitizen: decodedDetails.citizenship === 'South African Citizen'
            });

            this.decodedIdDetails = {
                ...decodedDetails,
                searchCount: response.searchCount
            };

            this.holidays = (response.holidays || []).map((holiday) => ({
                ...holiday,
                cardClass: holiday.matchesBirthDate
                    ? 'holiday-card matching-holiday-card'
                    : 'holiday-card',
                matchLabel: holiday.matchesBirthDate ? 'Matches date of birth' : ''
            }));

            this.validationMessage = response.message;
        } catch (error) {
            this.decodedIdDetails = undefined;
            this.holidays = [];
            this.validationMessage =
                error?.body?.message || 'Something went wrong while processing the birthdate holiday search.';
        } finally {
            this.isLoading = false;
        }
    }

    handleClear() {
        this.idNumber = '';
        this.validationMessage = '';
        this.isValidIdNumber = false;
        this.decodedIdDetails = undefined;
        this.holidays = [];
        this.isLoading = false;
    }

    validateIdNumber() {
        this.validationMessage = '';
        this.isValidIdNumber = false;

        const validationResult = validateSouthAfricanIdNumber(this.idNumber);

        if (!validationResult.isValid) {
            this.validationMessage = validationResult.message;
            return;
        }

        this.isValidIdNumber = true;
        this.validationMessage = 'Valid South African ID Number.';
    }
}