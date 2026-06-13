import { LightningElement } from 'lwc';
import recordIdNumberQuery from '@salesforce/apex/BirthdateHolidaySearchController.recordIdNumberQuery';
import {
    validateSouthAfricanIdNumber,
    decodeSouthAfricanIdNumber
} from './birthdateHolidaySearcherUtils';

export default class BirthdateHolidaySearcher extends LightningElement {
    idNumber = '';
    validationMessage = '';
    isValidIdNumber = false;
    decodedIdDetails;
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

    handleIdNumberChange(event) {
        this.idNumber = event.target.value.replace(/\D/g, '');
        this.decodedIdDetails = undefined;
        this.validateIdNumber();
    }

    async handleSearch() {
        if (!this.isValidIdNumber) {
            this.validationMessage = 'Please enter a valid South African ID Number before searching.';
            this.decodedIdDetails = undefined;
            return;
        }

        this.isLoading = true;
        this.validationMessage = '';

        try {
            const decodedDetails = decodeSouthAfricanIdNumber(this.idNumber);

            const response = await recordIdNumberQuery({
                idNumber: this.idNumber,
                dateOfBirth: decodedDetails.dateOfBirth,
                gender: decodedDetails.gender,
                saCitizen: decodedDetails.citizenship === 'South African Citizen'
            });

            this.decodedIdDetails = {
                ...decodedDetails,
                searchCount: response.searchCount
            };

            this.validationMessage = response.message;
        } catch (error) {
            this.decodedIdDetails = undefined;
            this.validationMessage =
                error?.body?.message || 'Something went wrong while recording the ID number query.';
        } finally {
            this.isLoading = false;
        }
    }

    handleClear() {
        this.idNumber = '';
        this.validationMessage = '';
        this.isValidIdNumber = false;
        this.decodedIdDetails = undefined;
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