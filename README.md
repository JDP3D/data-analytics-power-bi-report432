## Table of Contents
1.  [Import the Data into Power BI](#import-the-data-into-power-bi)
2.  [Create the Data Model](#create-the-data-model)

### Import the Data into Power BI

The first step was to load the **Orders** table from an Azure SQL database using the **Get Data** function on the Home tab in Power Bi. Once the data was acquired I opened the table in the **Power Query Editor**  and performed the following edits.

- Deleted the column named `[Card Number]` to protect customer data privacy
- Split the `[Order Date]` and `[Shipping Date]` columns into separate columns for date and time using the **Split column by delimiter** function. I then renamed the columns appropriately. I changed the data types to *date* for the date columns and *time* for the time columns.
- Removed rows where the `[Order Date]` column had missing or null values by filtering  the column.

Next I imported the **Products** table from a csv file. I opened the table in the **Power Query Editor** and promoted the headers using the **Use First Row as Headers** function as the column names appeared in the first row rather than as column names. I then changed the columns to the appropriate data types and renamed them to follow the Power BI naming conventions.

The next step was to import the **Stores** table from an Azure Blob Storage. In the **Power Query Editor** I removed an unnecessary column `[Source.Name]` where all rows had the value *Stores.csv*. I  noticed that the column named `[World Region]` had some strange values, eeEurope instead of Europe and eeAmerica instead of America, so I changed these to the correct values using the **Replace Value** function. After this I changed the data types as needed and renamed the columns.

The final step was to create the `[Customers]` table by importing a folder of csv files using the **Combine and Transform** feature of Power BI. In the **Power Query Editor** I removed two unnecessary columns, [Content]  where all rows had the value *binary*, and  `[Source]`, where the rows had the name of the csv file where the data came from. I then used the **Merge Columns** function using space as a separator to combine the first and last names of the customers into one column. I then renamed any columns as required and checked the data types.

### Create the Data Model

The first task is to create a date table. To achieve this I changed to the Table view in Power Bi and used the **NEW Table** function with the DAX code
 `Dates = CALENDAR(DATE(2010,1,1), MAX(Orders[Shipping Date]))`. I then added the columns shown below with the DAX code as follows

- `Day of Week` :   `Day of Week = WEEKDAY(Dates[Date])`
- `Month Number`:   `Month Number = MONTH(Dates[Date])`
- `Month Name`:    `Month Name = FORMAT(Dates[Date],"mmmm")`
- `Quarter`:   `Quarter = QUARTER(Dates[Date])`
- `Year`:   `Year = YEAR(Dates[Date])`
- `Start of Year`:   `Start of Year = STARTOFYEAR(Dates[Date])`
- `Start of Quarter`:   `Start of Quarter = STARTOFQUARTER(Dates[Date])`
- `Start of Month`:   `Start of Month = STARTOFMONTH(Dates[Date])`
- `Start of Week`:   `Start of Week = Dates[Date] - WEEKDAY(Dates[Date],2) + 1` 

Next we need to create relationships between the tables, although Power BI has already created most of what is needed automatically by matching the column names. To create the remaining relationships I changed to the Model view and clicked on the  **Manage Relationships** button in the ribbon which gives you an interface as shown below.



![Manage_Relationships](https://github.com/user-attachments/assets/cfba8309-62f1-4b15-acac-c18fa8dcaadf)


Here you can see all the relationships created for the model.
