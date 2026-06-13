import { LightningElement } from 'lwc';

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
        this.validateIdNumber();
    }

    handleSearch() {
        if (!this.isValidIdNumber) {
            this.validationMessage = 'Please enter a valid South African ID Number before searching.';
            return;
        }

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
        this.decodedIdDetails = undefined;

        if (!this.idNumber) {
            return;
        }

        if (!/^\d{13}$/.test(this.idNumber)) {
            this.validationMessage = 'Invalid ID Number. A South African ID Number must contain exactly 13 digits.';
            return;
        }

        const decodedDetails = this.decodeIdNumber(this.idNumber);

        if (!decodedDetails.isValidDateOfBirth) {
            this.validationMessage = 'Invalid ID Number. The date of birth section is not a valid date.';
            return;
        }

        if (!decodedDetails.isValidCitizenship) {
            this.validationMessage = 'Invalid ID Number. The citizenship digit must be 0 or 1.';
            return;
        }

        if (!this.isValidChecksum(this.idNumber)) {
            this.validationMessage = 'Invalid ID Number. The checksum digit is incorrect.';
            return;
        }

        this.isValidIdNumber = true;
        this.decodedIdDetails = {
            dateOfBirth: decodedDetails.dateOfBirth,
            gender: decodedDetails.gender,
            citizenship: decodedDetails.citizenship
        };
        this.validationMessage = 'Valid South African ID Number.';
    }

    decodeIdNumber(idNumber) {
        const year = idNumber.substring(0, 2);
        const month = idNumber.substring(2, 4);
        const day = idNumber.substring(4, 6);
        const genderCode = Number(idNumber.substring(6, 10));
        const citizenshipCode = idNumber.substring(10, 11);

        const fullYear = this.getFullYear(year);
        const dateOfBirth = `${fullYear}-${month}-${day}`;

        const parsedDate = new Date(Number(fullYear), Number(month) - 1, Number(day));

        const isValidDateOfBirth =
            parsedDate.getFullYear() === Number(fullYear) &&
            parsedDate.getMonth() === Number(month) - 1 &&
            parsedDate.getDate() === Number(day);

        const isValidCitizenship = citizenshipCode === '0' || citizenshipCode === '1';

        return {
            dateOfBirth,
            gender: genderCode < 5000 ? 'Female' : 'Male',
            citizenship: citizenshipCode === '0' ? 'South African Citizen' : 'Permanent Resident',
            isValidDateOfBirth,
            isValidCitizenship
        };
    }

    getFullYear(twoDigitYear) {
        const currentYear = new Date().getFullYear();
        const currentCentury = Math.floor(currentYear / 100) * 100;
        const possibleYear = currentCentury + Number(twoDigitYear);

        return possibleYear > currentYear ? possibleYear - 100 : possibleYear;
    }

    isValidChecksum(idNumber) {
        let sum = 0;
        const digits = idNumber.split('').map(Number);

        for (let index = 0; index < digits.length; index += 1) {
            let digit = digits[index];

            if (index % 2 === 1) {
                digit *= 2;

                if (digit > 9) {
                    digit -= 9;
                }
            }

            sum += digit;
        }

        return sum % 10 === 0;
    }
}