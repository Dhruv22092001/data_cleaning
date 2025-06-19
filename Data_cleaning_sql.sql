-- Data Cleaning Project 

-- View the original data
SELECT * FROM layoffs;

-- Steps:
-- 1. Remove Duplicates
-- 2. Standardize the data
-- 3. Remove Null values or blank values
-- 4. Remove unnecessary columns

-- ---------------------------
-- 1. Remove Duplicates
-- ---------------------------

-- Create a copy of the original table structure
CREATE TABLE layoffs_copy
LIKE layoffs;

-- View the empty copied table
SELECT * FROM layoffs_copy;

-- Insert data from original table into the copy
INSERT layoffs_copy
SELECT * FROM layoffs;

-- Check for potential duplicates by assigning a row number to each duplicate group
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_copy;

-- Use a CTE to select duplicate rows (where row_num > 1)
WITH duplicate_cte AS (
    SELECT *,
    ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
    FROM layoffs_copy
)
SELECT * FROM duplicate_cte
WHERE row_num > 1;

-- Create a new working table with a row number column for duplicate removal
CREATE TABLE `layoffs_copy_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- View the new working table
SELECT * FROM layoffs_copy_2;

-- Insert data from the previous table, including the row numbers
INSERT INTO layoffs_copy_2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_copy;

-- Disable safe updates to allow deleting rows without a WHERE clause using primary key
SET SQL_SAFE_UPDATES = 0;

-- Delete duplicate rows (only keep row_num = 1)
DELETE FROM layoffs_copy_2
WHERE row_num > 1;

-- Re-enable safe updates
SET SQL_SAFE_UPDATES = 1;

-- Confirm that all duplicates have been removed
SELECT * FROM layoffs_copy_2
WHERE row_num > 1;


-- ---------------------------
-- 2. Standardizing the Data
-- ---------------------------

-- View the data
SELECT * FROM layoffs_copy_2;

-- Check for inconsistent company name spacing
SELECT company FROM layoffs_copy_2;
SELECT DISTINCT(company) FROM layoffs_copy_2;
SELECT company, TRIM(company) FROM layoffs_copy_2;

-- Remove leading/trailing whitespace from company names
UPDATE layoffs_copy_2
SET company = TRIM(company);

-- Check for variations in location values
SELECT location FROM layoffs_copy_2;

-- Find unique industry values
SELECT DISTINCT(industry) FROM layoffs_copy_2;

-- Find inconsistent "Crypto" industry values (e.g., 'Crypto Currency', 'Crypto Inc')
SELECT DISTINCT(industry)
FROM layoffs_copy_2
WHERE industry LIKE 'Crypto%';

-- Standardize all industry values starting with 'Crypto' to just 'Crypto'
UPDATE layoffs_copy_2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Check for inconsistent country names
SELECT country FROM layoffs_copy_2;

-- Find entries with trailing dots (e.g., 'United States.')
SELECT country
FROM layoffs_copy_2
WHERE country LIKE 'United States%';

-- View cleaned country values
SELECT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_copy_2;

-- Remove trailing dot from country names
UPDATE layoffs_copy_2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Check current format of date column
SELECT `date` FROM layoffs_copy_2;

-- Convert string dates to proper date format
SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_copy_2;

-- Update the date column with formatted values
UPDATE layoffs_copy_2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Modify the column type to DATE
ALTER TABLE layoffs_copy_2
MODIFY COLUMN `date` DATE;


-- --------------------------------------------
-- 3. Remove Null Values or Blank Values
-- --------------------------------------------

-- View all records
SELECT * FROM layoffs_copy_2;

-- Replace blank strings in 'industry' with NULL
UPDATE layoffs_copy_2
SET industry = NULL
WHERE industry = '';

-- Find rows where both total_laid_off and percentage_laid_off are NULL
SELECT * 
FROM layoffs_copy_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Find rows with missing or blank industry values
SELECT * 
FROM layoffs_copy_2
WHERE industry IS NULL
OR industry = '';

-- Inspect data for a specific company
SELECT * 
FROM layoffs_copy_2
WHERE company = 'Airbnb';

-- Compare industry values across duplicates to backfill missing industry info
SELECT t1.industry, t2.industry
FROM layoffs_copy_2 t1
JOIN layoffs_copy_2 t2
ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Update missing industry values by joining on the same company
UPDATE layoffs_copy_2 t1
JOIN layoffs_copy_2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


-- -------------------------------
-- 4. Remove Unnecessary Columns
-- -------------------------------

-- Review the table before cleanup
SELECT * FROM layoffs_copy_2;

-- Reconfirm which rows have null values for layoff info
SELECT * 
FROM layoffs_copy_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Drop the row_num column since it's no longer needed
ALTER TABLE layoffs_copy_2
DROP COLUMN row_num;

-- Delete rows that have no layoff data (fully NULL)
DELETE FROM layoffs_copy_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
