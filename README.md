## Performance Considerations

The application is designed for the current requirement of approximately 10,000 employees while keeping the implementation simple and maintainable.

### Employee Listing

Employee search, filtering, sorting, and pagination are performed at the database level rather than loading the complete employee dataset into application memory.

Pagination uses `LIMIT` and `OFFSET`, with a maximum page size of 100 records to prevent unnecessarily large responses.

The database contains indexes on frequently filtered and sorted fields including employee code, email, country, department, employment status, and annual salary.

### Search

Employee search currently uses PostgreSQL `ILIKE` across employee code, first name, last name, and email.

For the expected dataset of approximately 10,000 employees, this approach provides a simple implementation with acceptable performance.

If the dataset grows significantly, PostgreSQL trigram indexes (`pg_trgm`) could be introduced to optimize partial text searches.

### Salary Insights

Salary statistics are calculated using database aggregation functions such as `COUNT`, `AVG`, `MIN`, and `MAX`.

The median salary is currently calculated by retrieving the ordered salary values and performing the median calculation in Ruby. This is appropriate for the current 10,000-employee dataset.

For significantly larger datasets, the median calculation could be moved to PostgreSQL using `PERCENTILE_CONT`.

### Dashboard

Dashboard metrics use database-level grouping and aggregation rather than loading all employees into application memory.

Salary totals and salary statistics are grouped by currency because employees may be paid in different currencies. The application intentionally does not combine salaries across currencies without an exchange-rate source.

### Database Indexing

Indexes are used for commonly queried attributes. A composite index on `(currency, annual_salary)` supports salary-range queries used by the Salary Explorer.

Indexes will be reviewed as the dataset and query patterns evolve to avoid unnecessary indexing overhead.

### Scalability Considerations

The current implementation is intentionally sized for the assessment requirement of approximately 10,000 employees.

If the dataset grows substantially, potential future improvements include:

- PostgreSQL trigram indexes for text search
- keyset pagination instead of large `OFFSET` values
- database-level median calculations
- optimized grouped dashboard queries
- caching for frequently requested dashboard metrics
- background processing for expensive reporting workloads
