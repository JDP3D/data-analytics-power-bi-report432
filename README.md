## Table of Contents
1.  [Import the Data into Power BI](#import-the-data-into-power-bi)
2.  [Create the Data Model](#create-the-data-model)
3.  [Build the customer details page](#build-the-customer-details-page)
4.  [Create an Executive Summary Page](#create-an-executive-summary-page)
5.  [Create a Product Detail Page](#create-a-product-detail-page)
6.  [Create a Stores Map Page](#create-a-stores-map-page)

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

## Create an Executive Summary Page

Below is a screenshot of the executive summary page.
<p align="center">
      <img src="https://github.com/user-attachments/assets/1ed67971-4d89-4057-a38b-b3ce31d26c0f" alt="[Executive_Summary]"/>
 <p align="center">

The majority of the visuals were created in the same manner as before. There is only one new visual type used, the three KPI's labelled 1. These show current quarter values and targets of 5% growth in each measure compared to the previous quarter. If the targets are not met the current quarter value will be shown in red, otherwise if the target is achieved the text will be green. The measures created for these visuals with the DAX code are as follows:

1. `Previous Quarter Revenue = CALCULATE ([Total Profit], DATEADD(Dates[Date], -1, QUARTER))`
2. `Target Revenue = 1.05 * [Previous Quarter Revenue]`
3. `Previous Quarter Orders = CALCULATE ([Total Orders], DATEADD(Dates[Date], -1, QUARTER))`
4. `Target Orders = 1.05 * [Previous Quarter Orders]`
5. `Previous Quarter Profit = CALCULATE ([Total Profit], DATEADD(Dates[Date], -1, QUARTER))`
6. `Target Profit = 1.05 * [Previous Quarter Profit]`

Each visual is setup in the following manner.

<p align="center">
      <img src="https://github.com/user-attachments/assets/31c27519-c71c-44ba-8085-7ce25334d5ae" alt="[kpi]"/>
 <p align="center">

I have also included a screenshot of the KPI's in different states.

<p align="center">
      <img src="https://github.com/user-attachments/assets/2673c59a-aa06-4c77-a3c1-70a699252ca3" alt="[kpi_states]"/>
 <p align="center">

 ## Create a Product Detail Page

The products detail page contains a couple of new types of visual both of which used existing columns. The visual numbered 3 in the screenshot is an area chart, and number 4 is a scatter chart.

<p align="center">
      <img src="https://github.com/user-attachments/assets/06d46986-f45d-427c-9132-4b42fd5cccfa" alt="[Product_Details_Page]"/>
 <p align="center">

I won't discuss these any further and leave them for you to investigate if interested. I will now just detail the visuals for which I had to create new measures. The two cards next to number 1 show information on any filters applied to the page from the product category or store country. They use the following measures:

- `Category Selection = IF(ISFILTERED(Products[Category]), SELECTEDVALUE(Products[Category], "No Selection"), "No Selection")`
- `Country Selection = IF(ISFILTERED(Stores[Country]), SELECTEDVALUE(Stores[Country],"No Selection"), "No Selection")`

The three visuals in the top right of the page, next to number 2, are gauges that show the current-quarter performance of `Orders`, `Revenue` and `Profit` against a quarterly target. The target is set to be a 10% quarter-on-quarter growth in all three metrics. The measures created for these visuals are

- `Current Quarter Orders = TOTALQTD([Total Orders], 'Dates'[Date])`
- `QoQ Orders Target = TOTALQTD([Total Orders], DATEADD(Dates[Date], -1, QUARTER)) * 1.1`
- `Gap Orders Target = [QoQ Orders Target] - [Current Quarter Orders]`
- `Current Quarter Revenue = TOTALQTD([Total Revenue], 'Dates'[Date])`
- `QoQ Revenue Target = TOTALQTD([Total Revenue], DATEADD(Dates[Date], -1, QUARTER)) * 1.1`
- `Gap Revenue Target = [QoQ Revenue Target] - [Current Quarter Revenue]`
- `Current Quarter Profit = TOTALQTD([Total Profit], 'Dates'[Date])`
- `QoQ Profit Target = TOTALQTD([Total Profit], DATEADD(Dates[Date], -1, QUARTER)) * 1.1`
- `Gap Profit Target = [QoQ Profit Target] - [Current Quarter Profit]`

An example of the setup is shown below.

<p align="center">
      <img src="https://github.com/user-attachments/assets/9ed44f33-009c-4df4-9359-d8326bbf8e9d" alt="[Gauge_setup]"/>
 <p align="center">

The central text will be shown in red if the targets haven't been met, or green if the targets are achieved. This is achieved through setting conditions on the colour in the **Values** section of the **Format** pane using the Gap measures.


<p align="center">
      <img src="https://github.com/user-attachments/assets/c9ab7541-65c1-4e6f-b47e-b9e5d16fd4b1" alt="[Profit_Condition]"/>
 <p align="center">

<p align="center">Condition settings for the Profit Gauge</p>

The page can be filtered by ctrl clicking on the filter icon at the top left of the page. This produces a menu with filter options as shown below.

<p align="center">
      <img src="https://github.com/user-attachments/assets/cb2401b3-d74b-4c15-b7ee-398e4d9499e6" alt="[Filtered_page]"/>
 <p align="center">

 ## Create a Stores Map Page

 <p align="center">
      <img src="https://github.com/user-attachments/assets/9a834d6e-8ddb-4757-9f13-26e02080efde" alt="[Map_page]"/>
 <p align="center">

This page has a slicer on top allowing you to filter the map by country. The map itself is created using a Map visual with the following settings.

<p align="center">
      <img src="https://github.com/user-attachments/assets/cfef6806-832f-4cd2-98f8-17f1be695d4f" alt="[map_settings]"/>
<p align="center">

The Geography Hierarchy we created earlier is used to drill through to different levels of the map. I then created a Drillthrough page that can be reached by right clicking on one of the green bubbles and choosing Drill through from the menu.

<p align="center">
      <img src="https://github.com/user-attachments/assets/ee60e378-3928-4669-962c-d3d2e8ad0e08" alt="[Drill_Through]"/>
<p align="center">

Upon clicking on Drill through you will arrive at the following page.

<p align="center">
      <img src="https://github.com/user-attachments/assets/0ea85454-29d4-47d0-937b-3daaf9588fa8" alt="[Store_DrillPage]"/>
<p align="center">

This page has details for the store you clicked on. The two Gauges to the top right use two new measures.

- `Profit Goal = TOTALYTD([Total Profit], SAMEPERIODLASTYEAR(Dates[Date])) * 1.2`
- `Revenue Goal = TOTALYTD([Total Revenue], SAMEPERIODLASTYEAR(Dates[Date])) * 1.2`

These gauges show the current year-to-date profit and revenue. The black lines are targets of a 20% increase on the previous year's year-to-date profit or revenue at the current point in the year. 

<p align="center">
      <img src="https://github.com/user-attachments/assets/abc32b39-e8be-4a3d-8757-3aa83ad5c204" alt="[YTD_Gauge]"/>
<p align="center">
<p align="center">Settings for the Profit YTD Gauge</p>

The DrilThrough page was set up using the following settings.

<p align="center">
      <img src="https://github.com/user-attachments/assets/617161f9-8816-4ddd-a10b-806717009798" alt="[Setting_DrillThrough]"/>
<p align="center">

The last task of this section is to create a tooltip page. This page just consists of the Profit YTD gauge with a subtitle added for the selected store.

<p align="center">
      <img src="https://github.com/user-attachments/assets/ade96be1-f08f-4dcd-9e38-f3bc8af918b4" alt="[Gauge_Tooltip]"/>
<p align="center">
 
The ToolTip page is set up with the following settings.

<p align="center">
      <img src="https://github.com/user-attachments/assets/106e4968-905a-4ed4-8c54-a7aa759bc4db" alt="[Gauge_Tooltip]"/>
<p align="center">

Finally on the Store Map page we select the Map visual and adjust the following settings.

<p align="center">
      <img src="https://github.com/user-attachments/assets/be34c5b3-e4fe-49bb-a20a-b7ea8051696b" alt="[TooTips_MapPage]"/>
<p align="center">

The result of this is that when we hover over a region on the map with our mouse, we will see the related gauge from the Tooltip page.

<p align="center">
      <img src="https://github.com/user-attachments/assets/80f83f40-70a1-4d7b-b5ca-e9c4737dd4fa" alt="[Tooltip_Example]"/>
<p align="center">
 


