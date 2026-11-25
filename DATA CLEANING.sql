-- DATA CLEANING FULL PROJECT


SELECT * FROM layoffs;

-- STAGES
-- 1. REMOVE DUPLICATES
-- 2. STANDARDIZE THE DATA
-- 3. NULL VALUES OR BLANK VALUES
-- 4.. REMOVE UNNECESARY COLUMNS

-- I MAKE A NEW TABLE layoffs_staging ACT AS OUR WORKPLACE SO WE CAN HAVE THE RAW DATA UNTOUCH JUST INCASE WE WANNA BACK INTO IT
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- STAGE 1

-- I NEED TO PARTITION SAME ROW VALUES AND ROW THEM SO WHEN SAME ROW SHOW UP THE ROW NUMBER WILL GO UP
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

-- CTE TO SELECT THE ROW NUMBER HIGHER THAN 1, IT MEAN ITS A DUPLICATE
WITH duplicate_cte AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- CHEKING IF IT REALLY DUPLICATE
SELECT *
FROM layoffs
WHERE company = 'casper';

-- I CANT DELETE ROW INSIDE CTE THATS WHY WERE MAKING NEW TABLE WITH ROW_NUM ON IT
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- WE INSERT THE DATA WITH ROW_NUM COLUMN I CREATE EARLIER
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;
-- CHECKING BEFORE DELETING THE ROW
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;
-- DELETE DUPLICATE
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- STAGE 2
-- I SAW UNNECCESARY SPACES ON DATA
SELECT company, TRIM(company)
FROM layoffs_staging2;
-- I UPDATE IT AND REMOVE THOSE
UPDATE layoffs_staging2
SET company = TRIM(company);
-- HERE I KNOW INDUSTRY SHOULD BE DISTINCT AND SAME DATA WITH SMALL DIFFERENT IS DIFFERENT DATA
-- ITS IMPORTANT TO FIX THEM SO WHEN WE GROUP THEM THEY WILL BE SHOW AS 1
SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY 1;
-- HERE I SAW CRYPTO AND SOME CRYPTO CURRENCY
-- I KNOW THEY ARE JUST THE SAME SO I FIX THEM
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'crypto%';

UPDATE layoffs_staging2
SET industry = 'crypto'
WHERE industry LIKE 'crypto%';

SELECT DISTINCT(location)
FROM layoffs_staging2
ORDER BY 1;

-- SAME HERE I NOTICE A . ON END OF UNITED STATES AND THAT IS INPUT ERROR 
SELECT DISTINCT(country)
FROM layoffs_staging2
ORDER BY 1;
-- SO I FIX IT
UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';
-- OTHER METHOD THAT I MIGHT USE IN THE FUTURE BUT I WILL STAY ON MY QUERY EARLIER
SELECT DISTINCT(country), TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';
-- I WANNA MAKE THE DATE COLUMN IN PROPER DATE STRUCTURE FOR FUTURE EASY USED OF DATA AND FILTERING
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;
-- HERE I MAKE THE DATA TYPE OF DATE AS DATE FROM BEING A TEXT
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- STAGE 3

SELECT *
FROM layoffs_staging2;
-- HERE I NOTICE NULLS AND BLANKS IN IMPORTANT COLUMN BECAUSE THIS DATASET IS ABOUT LAYOFF SO ITS NON SENSE IF LAYOFFS COLUMNS ARE NULL
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- I MAKE THE BLANKS NULL TO MAKE IT SAME EASY TO QUERY LATER
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- I ALSO CHECK THE NULLS IN INDUSTRY, SINCE ITS STANDARD WE CAN POPULATE THEM IF THEY HAVE SAME DATA
SELECT *
FROM layoffs_staging2
WHERE company = 'airbnb';

-- HERE WE CHECK IF THERE A SAME ROW THAT HAS NULL INDUSTRY AND WITH INDUSTRY AT THE SAME TIME
-- THIS WHY WE CAN JUST PLACE THE EXISTING INDUSTRY TO BLANK
-- IF airbnb HAS 2 ROW 1 HAS INDUSTRY AND 1 HAS NULL INDUSTRY WE CAN JUST PLACE COPY THE INDUSTRY TO THE NULL
SELECT st1.industry, st2.industry
FROM layoffs_staging2 AS st1
JOIN layoffs_staging2 AS st2
	ON st1.company = st2.company
    AND st1.location = st2.location
WHERE (st1.industry IS  NULL)
AND st2.industry IS NOT NULL; 
-- HERE WE PLACE THE INDUSTRY TO NULLS
UPDATE layoffs_staging2 AS st1
JOIN layoffs_staging2 AS st2
	ON st1.company = st2.company
    AND st1.location = st2.location
SET st1.industry = st2.industry
WHERE st1.industry IS NULL
AND st2.industry IS NOT NULL;

-- STAGE 4
-- HERE I JUST DELETE THE COLUMN THAT ARENT NEEDED
SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
-- I DECIDED TO DELETE THEM SINCE THIS ROWS CANT BE USE IN ANALYSIS IF THEY DONT HAVE THE DATA WE NEED
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;