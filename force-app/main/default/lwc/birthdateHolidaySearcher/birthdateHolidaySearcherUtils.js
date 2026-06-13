export function validateSouthAfricanIdNumber(idNumber) {
    if (!idNumber) {
        return {
            isValid: false,
            message: ''
        };
    }

    if (!/^\d{13}$/.test(idNumber)) {
        return {
            isValid: false,
            message: 'Invalid ID Number. A South African ID Number must contain exactly 13 digits.'
        };
    }

    const decodedDetails = decodeSouthAfricanIdNumber(idNumber);

    if (!decodedDetails.isValidDateOfBirth) {
        return {
            isValid: false,
            message: 'Invalid ID Number. The date of birth section is not a valid date.'
        };
    }

    if (!decodedDetails.isValidCitizenship) {
        return {
            isValid: false,
            message: 'Invalid ID Number. The citizenship digit must be 0 or 1.'
        };
    }

    if (!isValidChecksum(idNumber)) {
        return {
            isValid: false,
            message: 'Invalid ID Number. The checksum digit is incorrect.'
        };
    }

    return {
        isValid: true,
        message: 'Valid South African ID Number.'
    };
}

export function decodeSouthAfricanIdNumber(idNumber) {
    const year = idNumber.substring(0, 2);
    const month = idNumber.substring(2, 4);
    const day = idNumber.substring(4, 6);
    const genderCode = Number(idNumber.substring(6, 10));
    const citizenshipCode = idNumber.substring(10, 11);

    const fullYear = getFullYear(year);
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

function getFullYear(twoDigitYear) {
    const currentYear = new Date().getFullYear();
    const currentCentury = Math.floor(currentYear / 100) * 100;
    const possibleYear = currentCentury + Number(twoDigitYear);

    return possibleYear > currentYear ? possibleYear - 100 : possibleYear;
}

function isValidChecksum(idNumber) {
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