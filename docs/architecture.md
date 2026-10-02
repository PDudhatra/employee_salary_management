## Performance Considerations

The application is designed for the current requirement of approximately 10,000 employees while keeping the implementation simple and maintainable.

### Employee Listing

Employee search, filtering, sorting, and pagination are performed at the database level rather than loading the complete employee dataset into application memory.

Pagination uses `LIMIT` and `OFFSET`, with a maximum page size of 100 records to prevent unnecessarily large API responses.

Indexes are defined on frequently queried fields including employee code, email, country, department, employment status, and annual salary.

### Search

Employee search currently uses PostgreSQL `ILIKE` across employee code, first name, last name, and email.

For approximately 10,000 employees, this approach keeps the implementation simple and is sufficient for the expected dataset.

If the dataset grows significantly, PostgreSQL trigram indexes (`pg_trgm`) could be introduced to improve partial text search performance.

### Salary Insights

Salary statistics use database aggregation functions such as `COUNT`, `AVG`, `MIN`, and `MAX`.

The median salary is currently calculated by retrieving the ordered salary values and calculating the median in Ruby. This is appropriate for the current dataset size.

For significantly larger datasets, the median calculation could be moved to PostgreSQL using `PERCENTILE_CONT`.

### Dashboard

Dashboard metrics use database-level grouping and aggregation rather than loading all employees into application memory.

Salary totals and statistics are grouped by currency because employees may be paid in different currencies. Salaries across different currencies are intentionally not combined without an exchange-rate source.

### Database Indexing

Indexes are used for commonly queried employee attributes.

A composite index on `(currency, annual_salary)` supports salary-range queries used by the Salary Explorer.

Indexes will be reviewed as the dataset and query patterns evolve to avoid unnecessary indexing overhead.

### Scalability Considerations

The current implementation is intentionally sized for approximately 10,000 employees.

If the dataset grows substantially, potential future improvements include:

- PostgreSQL trigram indexes for text search
- Keyset pagination instead of large `OFFSET` values
- Database-level median calculations
- Optimized grouped dashboard queries
- Caching for frequently requested dashboard metrics
- Background processing for expensive reporting workloads
