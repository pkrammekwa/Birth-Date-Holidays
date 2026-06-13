# Birth Date Holidays

Birth Date Holidays is a Salesforce application that allows users to enter a South African ID number, validate and decode it, track how often the ID number is searched, and display South African public holidays for the decoded birth year.

The application highlights any public holiday that matches the user’s date of birth and moves that matching holiday to the top of the holiday list.

---

## Project Description

The goal of this project is to allow an end user to check whether their date of birth falls on a South African public holiday.

The app uses a South African ID number to decode the user’s date of birth, gender, and citizenship status. Valid ID searches are stored in Salesforce, and repeated searches for the same ID number increment a search counter.

Public holidays are retrieved from the Calendarific API using the decoded birth year and South Africa country code.

---

## Features

* South African ID number input page.
* ID number validation before search submission.
* Search button disabled until a valid ID number is entered.
* Invalid ID number prompt/message.
* ID number decoding into:

  * Date of Birth
  * Gender
  * SA Citizen status
* Valid ID searches stored in Salesforce.
* Search counter incremented for repeated ID number searches.
* Calendarific API integration.
* Public holidays retrieved for the decoded birth year.
* Matching birthdate holiday highlighted and moved to the top.
* Apex test coverage for service, controller, HTTP client, and API mock classes.

---

## What Was Implemented

### Birthdate Holiday Search Page

A Lightning Web Component was created to allow users to enter a South African ID number and submit a search.

Implemented:

* Lightning Web Component page.
* South African ID number input field.
* Description section explaining the purpose of the page.
* Search button.
* Search button state controlled by ID number validity.

---

### South African ID Number Validation and Decoding

The application validates the ID number before allowing the user to submit a search.

Implemented:

* South African ID number validation.
* Invalid ID number message.
* Search button disabled until the ID number is valid.
* ID number decoding after search submission.

Decoded information:

* Date of Birth
* Gender
* Citizenship status

---

### ID Search Storage and Search Count Tracking

A custom object was created to store valid ID search records.

Implemented:

* Storage of valid ID number search details.
* ID number used as the unique search reference.
* Decoded ID information stored against the record.
* Search count incremented when the same ID number is searched again.
* Apex service and controller logic.
* Apex test coverage for create and update scenarios.

---

### Calendarific Public Holiday Integration

The application integrates with the Calendarific API to retrieve South African public holidays for the decoded birth year.

Implemented:

* Calendarific API callout.
* Birth year extracted from decoded ID number.
* South Africa country code `ZA` passed to Calendarific.
* Public holidays displayed on the page.
* Matching birthdate holiday highlighted and moved to the top.
* API mock and integration test coverage.

---

### Salesforce App and Metadata Configuration

A Salesforce app and supporting metadata were added to make the application easier to access and deploy.

Implemented:

* Salesforce custom application metadata.
* Named Credential for Calendarific.
* Custom Metadata Type for Calendarific API key configuration.
* Permission Set for required access.
* Custom Object and fields.
* Apex classes and tests.
* Lightning Web Component metadata.

---

## Technical Stack

* Salesforce
* Lightning Web Components
* Apex
* Salesforce DX
* Custom Object
* Custom Metadata Type
* Named Credential
* Permission Set
* Calendarific Holiday API

---

## Main LWC

```text
birthdateHolidaySearcher
```

Purpose:

* Captures the South African ID number.
* Validates the ID number.
* Decodes the ID number.
* Calls Apex to process the search.
* Displays decoded ID details.
* Displays public holidays.
* Highlights the holiday matching the date of birth.

---

## Apex Classes

### `BirthdateHolidaySearchController`

LWC entry point.

Responsibilities:

* Exposes Apex methods to the Lightning Web Component.
* Calls the service layer.
* Returns handled error messages to the LWC.

---

### `BirthdateHolidaySearchService`

Main business logic class.

Responsibilities:

* Validates required decoded ID details.
* Calls the Calendarific holiday service.
* Stores or updates ID search records.
* Increments search count.
* Flags holidays that match the birth date.
* Returns search details and holidays to the LWC.

---

### `CalendarificHolidayService`

Calendarific integration service.

Responsibilities:

* Builds the Calendarific API endpoint.
* Reads the API key from Custom Metadata.
* Calls Calendarific through `HttpClient`.
* Parses the Calendarific response.
* Returns public holiday data.

---

### `HttpClient`

Reusable HTTP utility class.

Responsibilities:

* Sends HTTP GET requests.
* Keeps raw HTTP request logic separate from business logic.

---

### `BirthdateHolidayException`

Custom application exception.

Responsibilities:

* Handles service-level errors across the application.

---

### `CalendarificHolidayApiMock`

Apex HTTP callout mock.

Responsibilities:

* Provides mock Calendarific API responses for test classes.

---

## Test Classes

```text
BirthdateHolidaySearchControllerTest
BirthdateHolidaySearchServiceTest
CalendarificHolidayServiceTest
HttpClientTest
```

Test coverage includes:

* Valid ID search processing.
* New ID tracking record creation.
* Existing ID tracking record updates.
* Search count incrementing.
* Calendarific API response parsing.
* HTTP client callout behavior.
* Matching holiday highlighting.
* Error handling.

---

## Salesforce Metadata

### Custom Application

```text
Birth_Date_Holidays
```

Purpose:

* Provides the Salesforce app entry point for the Birth Date Holidays functionality.

---

### Lightning Web Component

```text
birthdateHolidaySearcher
```

Purpose:

* Main UI for the user to enter an ID number and view results.

---

### Custom Object

```text
ID_Holiday_Search__c
```

Purpose:

* Stores valid South African ID number searches.

Fields:

| Field Label   | API Name           | Purpose                                    |
| ------------- | ------------------ | ------------------------------------------ |
| ID Number     | `ID_Number__c`     | Unique ID number reference                 |
| Date Of Birth | `Date_Of_Birth__c` | Decoded date of birth                      |
| Gender        | `Gender__c`        | Decoded gender                             |
| SA Citizen    | `SA_Citizen__c`    | Decoded citizenship status                 |
| Search Count  | `Search_Count__c`  | Number of times the ID number was searched |

---

### Custom Metadata Type

```text
Calendarific_Setting__mdt
```

Purpose:

* Stores Calendarific API configuration.

Field:

```text
Api_Key__c
```

Record:

```text
Calendarific_API_key
```

Important:

The API key value committed to GitHub is intentionally masked.

After deployment, update the custom metadata record with a valid Calendarific API key.

---

### Named Credential

```text
Calendarific
```

Recommended URL:

```text
https://calendarific.com
```

Recommended authentication:

```text
No Authentication
```

The Calendarific API key is read from Custom Metadata and passed as a query parameter.

---

### Permission Set

```text
Birthdate_Holiday_Searcher
```

Purpose:

* Grants required access to the app, Apex classes, object, and fields.

Assign it after deployment:

```bash
sf org assign permset --name Birthdate_Holiday_Searcher
```

---

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd <repository-folder>
```

---

### 2. Authorize Salesforce Org

```bash
sf org login web --alias birthdate-holidays-org
```

---

### 3. Deploy Metadata

```bash
sf project deploy start --manifest manifest/package.xml
```

---

### 4. Update Calendarific API Key

Go to:

```text
Setup → Custom Metadata Types → Calendarific Setting → Manage Records
```

Open:

```text
Calendarific API key
```

Update:

```text
Api Key
```

with a valid Calendarific API key.

The value in GitHub is masked for security.

---

### 5. Assign Permission Set

```bash
sf org assign permset --name Birthdate_Holiday_Searcher
```

---

### 6. Open the App

Open the Salesforce App Launcher and select:

```text
Birth Date Holidays
```

## Deployment Manifest

The project includes a Salesforce deployment manifest at:

```text
manifest/package.xml
---
---

## How to Use

1. Open the Birth Date Holidays app.
2. Enter a valid South African ID number.
3. The Search button becomes enabled after the ID number is valid.
4. Click Search.
5. The app displays:

   * Decoded ID information
   * Search count
   * South African public holidays for the birth year
   * Matching birthdate holiday highlighted at the top

---

## Example Test ID Numbers

### New Year’s Day Match

```text
9001015009086
```

Expected highlighted holiday:

```text
1990-01-01 — New Year's Day
```

---

### Christmas Day Match

```text
9012255009082
```

Expected highlighted holiday:

```text
1990-12-25 — Christmas Day
```

---

## Run Tests

Run all local tests:

```bash
sf apex run test --test-level RunLocalTests --result-format human --wait 10
```

Run project-specific tests:

```bash
sf apex run test --tests BirthdateHolidaySearchControllerTest,BirthdateHolidaySearchServiceTest,CalendarificHolidayServiceTest,HttpClientTest --result-format human --wait 10
```

---

## Project Structure

```text
force-app/
└── main/
    └── default/
        ├── applications/
        ├── classes/
        ├── customMetadata/
        ├── lwc/
        │   └── birthdateHolidaySearcher/
        ├── namedCredentials/
        ├── objects/
        └── permissionsets/

manifest/
└── package.xml
```

---

## Notes

* The real Calendarific API key is not committed to GitHub.
* The committed Custom Metadata API key value is intentionally masked.
* After deployment, replace the masked API key with a valid Calendarific API key.
* If the Calendarific callout fails, check:

  * Named Credential exists.
  * Custom Metadata API key is updated.
  * API key is valid.
  * Permission set is assigned.
* Valid ID searches are stored only after the Calendarific callout succeeds.
* Matching holidays are highlighted by comparing the holiday month/day with the decoded birth date month/day.

---

## Document Tracking

| Description                                                                                 | Author     |         Date | Version |
| ------------------------------------------------------------------------------------------- | ---------- | -----------: | ------: |
| Initial Salesforce project setup                                                            | pkrammekwa | Jun 13, 2026 |     1.0 |
| Added Birthdate Holiday Searcher page                                                       | pkrammekwa | Jun 13, 2026 |     1.1 |
| Added South African ID number validation and decoding                                       | pkrammekwa | Jun 13, 2026 |     1.2 |
| Refactored ID number validation logic and updated decoded details display                   | pkrammekwa | Jun 13, 2026 |     1.3 |
| Added ID query tracking, decoded ID storage, and search count incrementing                  | pkrammekwa | Jun 13, 2026 |     1.4 |
| Added Apex tests for ID query tracking                                                      | pkrammekwa | Jun 13, 2026 |     1.5 |
| Added Calendarific public holiday integration                                               | pkrammekwa | Jun 13, 2026 |     1.6 |
| Added public holiday highlighting for matching birthdate holidays                           | pkrammekwa | Jun 13, 2026 |     1.7 |
| Added Calendarific test coverage and integration metadata                                   | pkrammekwa | Jun 13, 2026 |     1.8 |
| Added missing ID tracking fields, Calendarific metadata, named credential, and app metadata | pkrammekwa | Jun 13, 2026 |     1.9 |
| Add permission set access for Birth Date Holidays                                           | pkrammekwa | Jun 13, 2026 |     2.0 |

---

## Author

```text
pkrammekwa
```
