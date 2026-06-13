import { LightningElement } from 'lwc';

export default class BirthdateHolidaySearcher extends LightningElement {
    idNumber = '';
    errorMessage = '';
    successMessage = '';

    handleIdNumberChange(event) {
        this.idNumber = event.target.value;
        this.errorMessage = '';
        this.successMessage = '';
    }

    handleSearch() {
        this.errorMessage = '';
        this.successMessage = '';

        const idInput = this.template.querySelector('lightning-input[name="idNumber"]');

        if (!this.idNumber) {
            this.errorMessage = 'Please enter a South African ID Number before searching.';
            idInput.reportValidity();
            return;
        }

        this.successMessage = 'Search action executed successfully.';
    }

    handleClear() {
        this.idNumber = '';
        this.errorMessage = '';
        this.successMessage = '';
    }
}