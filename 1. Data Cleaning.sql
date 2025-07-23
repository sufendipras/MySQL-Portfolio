-- DATA CLEANING


SELECT * 
FROM layoffs
;

-- 1. Remove Duplicate
-- 2. Standarize Data
-- 3. Null or Blank Values
-- 4. Remove Rows that Irrelevant

-- Create duplicate table from raw data 
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT INTO layoffs_staging
SELECT * 
FROM layoffs;

-- queries to make unique id to check if any duplicate
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, 
total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;


-- make CTE and find if there are any duplicate
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, 
total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1
;


-- Check data the data that is indicated to have duplication
SELECT *
FROM layoffs_staging
WHERE company = 'Better.com'
;

-- create another duplicate table where we will work on and add new row for unique id
-- in this case row_num will be my unique id
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


SELECT *
FROM layoffs_staging2
WHERE row_num > 1
;

-- Inserting the data to our new table
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, 
total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Delete duplicate data
DELETE
FROM layoffs_staging2
WHERE row_num > 1
;

-- Checking the result 
SELECT *
FROM layoffs_staging2
WHERE row_num > 1
;

SELECT *
FROM layoffs_staging2
;


-- Standarizing Data


-- Delete space using TRIM  before and after the word
-- find data that we want to standarized
SELECT company, TRIM(company)
FROM layoffs_staging2
;

-- update the data on 'company' row
UPDATE layoffs_staging2
SET company = TRIM(company)
;


-- Find the data on 'industry' row that we need to work on
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1
;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'
;

-- TRAILING Function to specify what to delete at the end
-- in this case there are some misspeling and we want to correct that
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1
;

-- Updating to new data
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'
;

-- Change data of 'date' from text to date format
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2
;

-- update to the 'date' data to date format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2
ORDER BY 1
;

-- change the data type of 'date'
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;



-- REMOVING BLANK OR NULL DATA

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;


SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
;

-- changing blank data to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- queries to self join to check if we can find same category of data and fill the NULL 
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


-- update the NULL data to new data
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2
;


-- queries to find out if there are still NULL data
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

-- Delete the NULL data
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;


SELECT *
FROM layoffs_staging2;


-- Delete our additional row that we create
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

