-- Explore data

SELECT *
FROM layoffs_staging2
;

-- Find out the earliest and latest of our data
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2
;

-- Check total for each year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC
;


-- Find company that have the highest percentage laid off
SELECT company, percentage_laid_off 
FROM layoffs_staging2
ORDER BY 2 DESC
;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
;

-- Find what industry that have the highest total laid off
SELECT industry, SUM(total_laid_off) AS Total
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC
;

-- Find which country have highest total laid off
SELECT country, SUM(total_laid_off) AS Total
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC
;

-- Find what stage that have highest laid off
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC
;

-- Grouping total laid off every month
SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1
;

-- Make CTE to see the sum of layoff from earliest to latest

WITH rolling_total AS
(
SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off) AS total
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1
)
SELECT `Month`, total, SUM(total) OVER(ORDER BY `Month`) AS rolling
FROM rolling_total
;


-- Find top three company that have highest layoff every year

SELECT YEAR(`date`) AS `year`, company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `year`, company
ORDER BY 3 DESC
;

WITH company_year AS
(
SELECT company, YEAR(`date`) AS years, SUM(total_laid_off) AS total
FROM layoffs_staging2
GROUP BY years, company
), company_rank AS 
(
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT *
FROM company_rank
WHERE ranking <=3
;



