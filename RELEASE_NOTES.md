## Jan 25th, 2016

### Features

* The ranks, requirements and related progress visualizations have been updated to reflect Version 5 of the Comp Plan
* A user can be deleted in the admin under certain conditions (mainly no Leads or Team members)
* Lead "Powur Move" copy can now be edited and added

### Enhancements

* Purchasing certification now accepts Non-US addresses
* TOU changed to "Application and Agreement" and now requires explicit action to accept which will display the A&A for download
* Timestamp is now stored in DB for every A&A acceptance
* Lead detail can now be viewed from Leads Admin page
* A "Source" filter has been added on leads for viewing leads that have come in through the Get Solar landing page
* Lead Summary metrics now default to Personal rather than team
* The sidenav has been enhanced to include Admin links as the Old Admin navigation was unworkable
* The Lead Metrics are now clickable allowing for a quick status filtering on leads
* Updated styling for grid header to include paging controls atop list

### Bugs

* Error message for invalid zip corrected
* Many, many styling fixes for IE, Firefox and Safari

### Infrastructure

* A new aggregates data structure for lead totals broken down by both team legs and months, vastly increases calculation and querying
* PostgreSQL updated to latest version in order for JSONB data type support
* Rails version updated


## Jan 12th, 2016

### Features

* Admins can sign in as another user from the Admin User Detail
* Admins can mark cert purchases as refunded and the system will recognize this in rank/bonus calculations
* Fields now included to Solar City that signify whether or not the prospect has provided consent for a phone call
* Admins can assign a lead owner to another user

### Enhancements

* Removed available invites from Admin as it's no longer relevant
* Updated Headline copy on GetSolar Landing page
* Email is now present in Admin Product Receipts
* Emails are now included with request to NMI for cert purchases
* Leads can now be searched from admin
* Users missing from Mailchimp Email Lists have been added
* Leads has new sorting control
* Purchasing now accepts non-US cards
* "Save & Close" button added to create lead
* Admins can un-terminate a user
* The GetSolar Landing page metrics now allow viewing metrics for the entire team

### Bugs

* Last page button not working when a filter has been applied
* Number inputs on not working on Firefox
* Create grid invite shows new item on bottom of list rather than top
* Various formatting issues with GetSolar link and metrics
* Leads initially inputted by rep but then completed by prospect not properly recording call consent
* Staging using same MailChimp List, causing invalid email addresses to be added
* Invite link incorrect when viewing leads from your team not owned by the logged in user


