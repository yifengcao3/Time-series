<img width="1500" height="90" alt="image" src="https://github.com/user-attachments/assets/f63e52c7-95b4-4785-919b-eac82bcfa434" />
<img width="683" height="455" alt="ChatGPT Image Aug 14, 2025 at 03_27_40 PM" src="https://github.com/user-attachments/assets/256d8863-e11c-4990-a1ee-9bb53483b5fc" />


## DATA DESCRIPTION AND SUMMARY

- **Average Daily Rate (adr):** Total lodging revenue ÷ total number of nights stayed; used to measure average daily revenue from hotel rooms.
- **reservation status date:** Date when the last status was set.
- **hotel:** Type of hotel; two categories: "City Hotel" and "Resort Hotel".

**Other unused data variables:**  
lead time, arrival date (year, month, week number, day of month), weekend nights, weekday nights, children, babies, meal, country, market segment, distribution channel, is repeated guest, previous cancellations, previous bookings not canceled, reserved room type, assigned room type, booking changes, deposit type, agent, company, days on waiting list, customer type, required car parking spaces, total special requests, reservation status.

*Data source: Hotel Booking Demand Datasets from Kaggle*
## Descriptive statistics

- **Average daily rate (adr):** The average daily rate is about 102, but the standard deviation is large, which indicates that the rate fluctuates.
<img width="1008" height="432" alt="image" src="https://github.com/user-attachments/assets/049870a1-5393-488c-a85f-16e1a03b108b" />

## PREPARATION FOR THE DATASET

### 1. Discontinuous time
- **For the part with excessive missing data:**  
  Filter data, retaining only records from July 1, 2015.
- **For the part with fewer missing data:**  
  Add missing dates and impute missing values in the `adr` column using the column's median (accounting for high standard deviation).

### 2. Multiple `adr` values for the same date
- Group data by reservation status date and hotel type, then calculate the daily average price.




