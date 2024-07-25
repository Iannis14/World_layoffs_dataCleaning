
SELECT * FROM layoffs

--Phase 1: Create a copy 

SELECT TOP 0 *
INTO layoffs_staging
FROM layoffs

INSERT INTO layoffs_staging
SELECT * FROM layoffs

SELECT * FROM layoffs_staging

--Phase 2: Remove Duplicate

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,
'date',stage,country,funds_raised_millions ORDER BY  company)
FROM layoffs_staging


-- CREATING CTEs
;WITH duplicate_cte AS(
SELECT *,

ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,
'date',stage,country,funds_raised_millions ORDER BY  company) AS row_number
FROM layoffs_staging
)
SELECT * FROM duplicate_cte 
WHERE row_number >1

--DELETING 

;WITH duplicate_cte AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,
'date',stage,country,funds_raised_millions ORDER BY  company) AS row_number
FROM layoffs_staging
)
SELECT *  FROM duplicate_cte 
WHERE row_number >1

--phase 3: Standardize

USE [world_layoffs]
GO

/****** Object:  Table [dbo].[layoffs_staging]    Script Date: 7/25/2024 11:05:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[layoffs_staging2](
	[company] [varchar](max) NULL,
	[location] [varchar](max) NULL,
	[industry] [varchar](max) NULL,
	[total_laid_off] [varchar](max) NULL,
	[percentage_laid_off] [varchar](max) NULL,
	[date] [varchar](max) NULL,
	[stage] [varchar](max) NULL,
	[country] [varchar](max) NULL,
	[funds_raised_millions] [varchar](max) NULL,
	[row_number] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


SELECT * FROM layoffs_staging2

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,
'date',stage,country,funds_raised_millions ORDER BY  company) AS row_number
FROM layoffs_staging

SELECT company, TRIM(company)
FROM layoffs_staging2

UPDATE layoffs_staging2
SET company = TRIM(company)

SELECT * FROM layoffs_staging2

SELECT distinct(country),TRIM(TRAILING'.' FROM country) FROM layoffs_staging2

UPDATE layoffs_staging2
SET country = TRIM(TRAILING'.' FROM country)
WHERE country LIKE 'United States%'

-- modify date format
SELECT [date],
TRY_CONVERT(DATE,[date],101)
FROM layoffs_staging2

UPDATE layoffs_staging2
SET [date] = TRY_CONVERT(DATE,[date],101)

--modify date datatype

ALTER TABLE layoffs_staging2
ALTER COLUMN [date] DATE

-- Phase 4: remove null value 

SELECT * FROM layoffs_staging2
WHERE industry = 'NULL' OR industry = ''


-- replace '' by NUll

UPDATE  layoffs_staging2
SET industry = 'NULL'
WHERE industry = ''

SELECT * FROM layoffs_staging2
WHERE industry = 'NULL'

SELECT * from layoffs_staging2
where company like'Airbnb'

-- SELF JOIN

SELECT t1.industry,t2.industry FROM 
layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
AND
t1.location = t2.location
WHERE t1.industry = 'NULL' AND t2.industry != t1.industry

--Update t1

UPDATE t1
SET t1.industry  = t2.industry
FROM 
layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON 
t1.company = t2.company
AND
t1.location = t2.location
WHERE t1.industry = 'NULL' AND t2.industry != t1.industry


SELECT total_laid_off,percentage_laid_off FROM layoffs_staging2
WHERE total_laid_off = 'NULL' OR percentage_laid_off = 'NULL'

DELETE layoffs_staging2
WHERE total_laid_off = 'NULL' OR percentage_laid_off = 'NULL'

SELECT * FROM layoffs_staging2

ALTER TABLE layoffs_staging2
DROP COLUMN row_number











