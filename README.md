# data_cleaning
SQL queries for data cleaning

# SQL Data Cleaning Project – Layoffs Dataset

This project demonstrates a complete SQL-based data cleaning process using a dataset of company layoffs. The goal is to clean, standardize, and prepare the data for further analysis.

# Tools Used

- SQL (Tested in MySQL)
- GitHub for version control


# Cleaning Steps Performed

1. **Remove Duplicates**
   - Used `ROW_NUMBER()` to identify duplicate rows.
   - Removed rows where row number > 1.

2. **Standardize the Data**
   - Trimmed whitespace from `company`, `country`, etc.
   - Standardized inconsistent values (e.g. "Crypto", "United States").
   - Converted date strings to proper `DATE` format.

3. **Handle Null or Blank Values**
   - Replaced empty strings with `NULL`.
   - Filled missing `industry` values based on known company data.
   - Removed rows with no useful layoff information.

4. **Remove Unnecessary Columns**
   - Dropped temporary helper columns (`row_num`).
   - Deleted rows that had no layoff data.



# Author

**Dhruv**
SQL & Data Analytics Enthusiast  
Feel free to fork, star ⭐, or reach out if you found it useful!

