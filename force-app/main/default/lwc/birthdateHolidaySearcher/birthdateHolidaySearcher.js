import { LightningElement } from 'lwc';
import {
    validateSouthAfricanIdNumber,
    decodeSouthAfricanIdNumber
} from './birthdateHolidaySearcherUtils';

export default class BirthdateHolidaySearcher extends LightningElement {
    idNumber = '';
    validationMessage = '';
    isValidIdNumber = false;
    decodedIdDetails;

    get isSearchDisabled() {
        return !this.isValidIdNumber;
    }

    get validationMessageClass() {
        return this.isValidIdNumber ? 'success-message' : 'error-message';
    }

    handleIdNumberChange(event) {
        this.idNumber = event.target.value.replace(/\D/g, '');
        this.decodedIdDetails = undefined;
        this.validateIdNumber();
    }

    handleSearch() {
        if (!this.isValidIdNumber) {
            this.validationMessage = 'Please enter a valid South African ID Number before searching.';
            this.decodedIdDetails = undefined;
            return;
        }

        this.decodedIdDetails = decodeSouthAfricanIdNumber(this.idNumber);
        this.validationMessage = 'Valid ID Number. Search action executed successfully.';
    }

    handleClear() {
        this.idNumber = '';
        this.validationMessage = '';
        this.isValidIdNumber = false;
        this.decodedIdDetails = undefined;
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