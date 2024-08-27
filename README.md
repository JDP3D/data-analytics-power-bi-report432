## Table of Contents
1.  [Import the Data into Power BI](#import-the-data-into-power-bi)
2.  [Create the Data Model](#create-the-data-model)
3.  [Build the customer details page](#build-the-customer-details-page)

## Import the Data into Power BI

The first step was to load the **Orders** table from an Azure SQL database using the **Get Data** function on the Home tab in Power Bi. Once the data was acquired I opened the table in the **Power Query Editor**  and performed the following edits.

- Deleted the column named `[Card Number]` to protect customer data privacy
- Split the `[Order Date]` and `[Shipping Date]` columns into separate columns for date and time using the **Split column by delimiter** function. I then renamed the columns appropriately. I changed the data types to *date* for the date columns and *time* for the time columns.
- Removed rows where the `[Order Date]` column had missing or null values by filtering  the column.

Next I imported the **Products** table from a csv file. I opened the table in the **Power Query Editor** and promoted the headers using the **Use First Row as Headers** function as the column names appeared in the first row rather than as column names. I then changed the columns to the appropriate data types and renamed them to follow the Power BI naming conventions.

The next step was to import the **Stores** table from an Azure Blob Storage. In the **Power Query Editor** I removed an unnecessary column `[Source.Name]` where all rows had the value *Stores.csv*. I  noticed that the column named `[World Region]` had some strange values, eeEurope instead of Europe and eeAmerica instead of America, so I changed these to the correct values using the **Replace Value** function. After this I changed the data types as needed and renamed the columns.

The final step was to create the `[Customers]` table by importing a folder of csv files using the **Combine and Transform** feature of Power BI. In the **Power Query Editor** I removed two unnecessary columns, [Content]  where all rows had the value *binary*, and  `[Source]`, where the rows had the name of the csv file where the data came from. I then used the **Merge Columns** function using space as a separator to combine the first and last names of the customers into one column. I then renamed any columns as required and checked the data types.

## Create the Data Model

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

<p align="center">
   <img src="https://github.com/user-attachments/assets/cfba8309-62f1-4b15-acac-c18fa8dcaadf" alt="[Manage_Relationships]"/>
<p align="center">

Here you can see all the relationships created . Below is a screenshot of the data model.

![model](https://github.com/user-attachments/assets/45db918f-3487-4377-834b-ad62e8c9cc43)

Now that the model has been setup I added a new blank table to act as a container for the measures needed for the project. The initial measures created are shown below with their DAX code.

- `Total Orders = COUNT(Orders[Order Date])`
- `Total Revenue = SUMX(Orders, Orders[Product Quantity] * RELATED(Products[Sale Price]))`
- `Total Profit = SUMX(Orders, Orders[Product Quantity] * (RELATED(Products[Sale Price]) - RELATED(Products[Cost Price])))`
- `Total Customers = DISTINCTCOUNT(Orders[User ID])`
- `Total Quantity = SUM(Orders[Product Quantity])`
- `Profit YTD = TOTALYTD([Total Profit], Dates[Date])`
- `Revenue YTD: Revenue YTD = TOTALYTD([Total Revenue], Dates[Date]`

The final stage of this part was to create date and geography hierarchies. This was achieved by switching to the model view and following the procedure shown in the screenshots.

<p align="center">
   <img src="https://github.com/user-attachments/assets/2643cda7-1ecb-46ba-970b-85271d01c5a4" alt="[heiarchy menu]"/>
   <img src="https://github.com/user-attachments/assets/70e760f4-4ca4-4970-b951-4c7d145ba257" alt="[date_hierarchy]"/>
<p align="center">
<p align="center">
   <img src="https://github.com/user-attachments/assets/aadf151b-8a6e-4855-a166-3aa075eeea9b" alt="[geography_hierarchy]"/>
<p align="center">

## Build the customer details page

Below is a screenshot of the final Customer Details page.

![Customer_Details_Page](https://github.com/user-attachments/assets/f06054d6-3b62-4289-a880-231a6698cc5f)

1. These elements are cards produced with the following measures:

   Unique Customer: `Total Customers = DISTINCTCOUNT(Orders[User ID])`
   Revenue per Customer: `Revenue per Customer = DIVIDE([Total Revenue], [Total Customers])`

2. This is a Donut Chart with Legend set as Country from the Stores table, to filter the values by country, and values set to the Total Customers measure.

3. These three cards display the top customer by revenue, the customer's revenue, and the number of orders the customer made. The measures created for these are:

   `Top Customer = MAXX(TOPN(1, Customers, [Total Revenue], DESC), Customers[Full Name])`

   `Top Customer Revenue = MAXX(TOPN(1, Customers, [Total Revenue], DESC), [Total Revenue])`
   `Top Orders = MAXX(TOPN(1,  Customers,[Total Revenue], DESC), [Total Orders])`

4. This is a line chart with a trend line and a forecast for the next 10 periods with a 95% confidence interval. It shows the total customers over time and uses the date hierarchy we created earlier to allow for viewing the data over different time periods.

   <p align="center">
      <img src="https://github.com/user-attachments/assets/6e6964fa-b79e-434e-9e5d-fc1699b8e446" alt="[Line_Chart]"/>
   <p align="center">
     Line chart settings
   </p>

6. This is a table which displays the top 20 customers filtered by revenue. It has a TOPN filter applied to it.

   <p align="center">
      <img src="https://github.com/user-attachments/assets/a66a655e-b8b7-42e5-a616-77a31425d64b" alt="[TOPN_Filter]"/>
   <p align="center">

8. Here we have a Clustered Column chart with the x-axis set to the product category column of the Products table and the y-axis set to the Total customers measure.
9. This is a slicer set to the between style that allows you to filter the data of a range of years.

For the fine tunings of these visualisations you can check them out in the file by clicking on them and opening the format pane, black arrow in the screenshot below.

<p align="center">
   <img src="https://github.com/user-attachments/assets/660a42a2-47bd-41ad-b7cb-df3d8ec08743" alt="[format]"/>
<p align="center">
    Donut chart settings
</p>
