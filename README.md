# cowin-slotavailability
This script will search for available CoVID-19 vaccination slots on CoWIN portal after every few seconds. As soon as a slot is available script will notify using long beep sound.

### How to Run Script
![How to Use Guide](https://github.com/erutkarshh/cowin-slotavailability/blob/main/HowToUseGuide.gif?raw=true)

### Inputs:
1. Date of Slot - This should be mandatorily in **dd-mm-yyyy** format
2. Age Group - This should be either **18** or **45**. Putting any other value might result in invalid data.
3. State Name: Type in your state name.
4. District Name: Type in your district name.
5. Pin Code - There can be 3 inputs as per choice
    - If one wants to monitor any specific pincode then type the pincode and hit enter
    - If one wants to monitor multiple picodes in district then user can type pincodes seperated by comma. E.g. 411005,411045
    - If one wants to monitor all pincodes in district then simply hit enter without typing anything.
6. Vaccine: If a user wants specific vaccine then input as below or else simply press Enter
    - Type **1** for COVAXIN
    - Type **2** for COVISHIELD
    - Enter for ANY
