# Global Tech Layoffs: MySQL Data Cleaning & Exploratory Data Analysis

> **Project Overview:** An end to end SQL data analysis project transforming raw global layoff records (`2020–2023`) into a standardized, analysis ready dataset in **MySQL** and uncovering workforce reduction trends across companies, industries, countries, and funding stages.

---

### 📂 Repository Files
- **`layoffs.csv`:** Raw global layoff dataset (`2,361` records) sourced from public layoff tracking reports (`March 2020 – March 2023`).
- **`DATA CLEANING.sql`:** Four stage MySQL data cleaning pipeline (`staging tables`, duplicate removal via `ROW_NUMBER()`, text standardization, `DATE` type conversion, self join `NULL` imputation, and incomplete record pruning).
- **`EXPLANATORY DATA ANALYSIS.sql`:** Exploratory SQL queries covering aggregate distributions, monthly rolling totals (`SUM() OVER()`), yearly top company leaderboards (`CTEs` + `DENSE_RANK()`), capital burn shutdown audits, and annual industry rankings.

---

### 🧹 Data Cleaning Pipeline (`DATA CLEANING.sql`)
To preserve raw data integrity, all transformations were executed on staged copies (`layoffs_staging` and `layoffs_staging2`):
1. **Duplicate Removal (`2,361` → `2,356` rows):** Partitioned records across all 9 attributes using `ROW_NUMBER() OVER(PARTITION BY ...)` inside a CTE and deleted `5` exact duplicate entries.
2. **Text & Date Standardization:**
   - Trimmed leading and trailing whitespace from company names (`TRIM()`).
   - Consolidated inconsistent industry labels (`Crypto Currency` → `crypto`) and stripped trailing punctuation from country names (`United States.` → `United States`).
   - Parsed text dates (`%m/%d/%Y`) using `STR_TO_DATE()` and altered the column schema to a native MySQL `DATE` type.
3. **Missing Value Imputation:** Converted blank strings (`''`) to `NULL` and populated missing `industry` values via a self join matching on `company` and `location`.
4. **Incomplete Record Pruning (`2,356` → `1,995` clean rows):** Removed `361` records missing both `total_laid_off` and `percentage_laid_off`, as they provided no measurable workforce impact.

---

### 📊 Key Exploratory Findings (`EXPLANATORY DATA ANALYSIS.sql`)
- **Overall Scale (`March 11, 2020 – March 6, 2023`):** Across **`1,995` cleaned records**, companies reported **`383,659` total layoffs**, with the largest single day layoff reaching **`12,000` employees** (Google).
- **Year Over Year Trajectory:**
  - **2020 (`80,998` layoffs):** Driven heavily by pandemic lockdowns, with **Transportation (`14,656`)** and **Travel (`13,983`)** ranking as the two hardest hit sectors.
  - **2021 (`15,823` layoffs):** Sharp contraction in layoffs as tech and consumer markets rebounded.
  - **2022 (`160,661` layoffs):** Peak full year wave led by **Retail (`20,914`)** and **Consumer (`19,856`)**.
  - **2023 (`125,677` layoffs in ~2 months):** Rapid acceleration reaching **78.2%** of 2022's entire total within the first nine weeks of the year.
- **Top 5 Companies by Cumulative Layoffs:** Amazon (`18,150`), Google (`12,000`), Meta (`11,000`), Salesforce (`10,090`), and Microsoft (`10,000`).
- **Geographic & Stage Concentration:** The **United States** accounted for **`256,559` layoffs (`66.9%`)**, while **Post IPO** enterprises represented **`204,132` layoffs (`53.2%`)**.
- **High Funding Complete Shutdowns:** **6 companies** that raised over **$500M** in venture or private funding still laid off **100%** of their workforce—led by **Britishvolt (`$2,400M`)**, **Quibi (`$1,800M`)**, **Deliveroo Australia (`$1,700M`)**, and **Katerra (`$1,600M`)**.

---

### 🛠️ Tools & SQL Techniques Used
- **Database:** MySQL / MySQL Workbench
- **SQL Capabilities:** Common Table Expressions (`CTEs`), Window Functions (`ROW_NUMBER`, `DENSE_RANK`, Rolling `SUM`), Self Joins, Date Parsing (`STR_TO_DATE`), String Standardization (`TRIM`, `SUBSTRING`, `LIKE`), and Schema Modification (`ALTER TABLE`).
