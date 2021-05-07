# cowin-slotavailability
This script will search for available CoVID-19 vaccination slots on CoWIN portal after every few seconds. As soon as a slot is available script will notify using long beep sound.

### Pre-Requisites:
Deistrict Id, for which the slots to be searched. Script takes default value of Pune. Use below urls to get details of other districts as required.
1. https://cdn-api.co-vin.in/api/v2/admin/location/states
2. https://cdn-api.co-vin.in/api/v2/admin/location/districts/{state_id}
