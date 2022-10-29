# Cohort-Retention-Analysis_SQL

In this project I use a public transactions database, clean it, and perfom a cohort retention analysis on it.

## The Dataset
I got this dataset from the machine learning repo website of UCI (https://archive.ics.uci.edu/ml/datasets/Online+Retail). It contains sales data from a UK-based online retail store from 01/12/2010 to 09/12/2011. This store deals mainly with wholesale buyers. It contains information such as what the product is, its price, when it was sold, how much of each product was sold, a unique id for every customer, the country the customer is from, etc.

## Analysis
I decided to perfom a cohort analysis, since the bussiness deals mostly with wholesale buyers, these customers are more likely to buy a lot, in bulk, and semi regularly. SO performing a cohort retention analysis would help the bussiness evaulate what their retention rate is amongst their customers. First I had to clean the data a little bit, mostly take care of null values and some negative "Quantities", refering to items returned. Now onto the cohort analysis. I first had to create a cohort group, then, with it, create a cohort index; which shows the months between a customers first purchase and their next purchases. After tuning this data for distinct customers a cohort table was created.
![image](https://user-images.githubusercontent.com/100732942/198851691-3f9ff5f4-d0ad-4362-822f-8a1d6e2d2a2e.png)

This table gives us the amount of costumers who made their first purchase each month and then tells us the beahviour of these customers in the following months, as in how many of them bought again the next month, and the  next one, and so forth. I did the same table in sql but with percentages. These tables and my process is shown in the code of this repo. Both of these tables were also reproduced in Tableau because the visualization is much more useful and easy to the eye, you can see them [here](https://public.tableau.com/app/profile/jose.lopez4015/viz/Cohort_Retention_Dashboard/Dashboard1).
-Jose Lopez :)
