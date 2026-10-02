# ACME Employee Salary Management — Backend

Backend API for ACME's employee salary management application.

The application replaces spreadsheet-based salary management with a centralized system for managing employee information and exploring compensation data across countries and departments.

## Overview

The backend provides APIs for:

- Employee listing with pagination
- Employee search
- Employee filtering
- Employee sorting
- Employee details
- Employee creation
- Employee salary updates
- Organization salary dashboard
- Salary insights and filtering
- Deterministic employee seed data

The system is designed for approximately **10,000 employees** across multiple countries and currencies.

## Tech Stack

- **Ruby:** 3.4.10
- **Rails:** 8.1.3.1
- **Database:** PostgreSQL
- **API:** REST
- **Testing:** RSpec + FactoryBot
- **Seed data:** Faker
- **Frontend:** React + TypeScript + MUI

## Architecture

The application uses a Rails API architecture with PostgreSQL as the primary data store.

```text
React Frontend
      |
      | REST API
      v
Rails API
      |
      +-- Employee API
      +-- Dashboard API
      +-- Salary Insights API
      |
      v
PostgreSQL
```

The backend is intentionally implemented as a modular Rails application rather than multiple services because the current requirement is approximately 10,000 employees and does not justify the operational complexity of a distributed architecture.

Detailed architecture decisions, data model, API design, performance considerations, and scalability options are documented in:

[`docs/architecture.md`](docs/architecture.md)

## Main API Endpoints

### Employees

```text
GET    /api/v1/employees
GET    /api/v1/employees/:id
POST   /api/v1/employees
PATCH  /api/v1/employees/:id
```

The employee listing API supports:

- Search
- Country filtering
- Department filtering
- Employment status filtering
- Currency filtering
- Sorting
- Pagination

Example:

```text
GET /api/v1/employees?page=1&per_page=25&search=john&country=India&sort=annual_salary&direction=desc
```

### Dashboard

```text
GET /api/v1/dashboard
```

Provides organization-level metrics including:

- Total employees
- Employees by status
- Payroll totals by currency
- Salary metrics by currency
- Employees by country
- Employees by department

### Salary Insights

```text
GET /api/v1/salary_insights
```

Supports filtering by:

- Country
- Department
- Currency
- Minimum salary
- Maximum salary

Returns:

- Employee count
- Average salary
- Median salary
- Minimum salary
- Maximum salary

Salary metrics are calculated within the selected currency. The application intentionally does not combine salaries across different currencies without an exchange-rate source.

## Getting Started

### Prerequisites

Make sure the following are installed:

- Ruby 3.4+
- PostgreSQL 16+
- Bundler

### Install dependencies

```bash
bundle install
```

### Configure the database

Create and migrate the database:

```bash
bin/rails db:create
bin/rails db:migrate
```

### Seed employee data

The application includes seed data for approximately 10,000 employees:

```bash
bin/rails db:seed
```

The seed data contains employees across multiple countries, departments, employment statuses, and currencies.

### Start the API

```bash
bin/rails server
```

The API will be available at:

```text
http://localhost:3000
```

## Running Tests

Run the complete test suite with:

```bash
bundle exec rspec
```

The test suite covers:

- Employee model validations
- Employee API endpoints
- Employee creation and validation errors
- Duplicate employee/email handling
- Dashboard metrics
- Salary insights
- Salary filtering
- No-result scenarios

## Performance

The application is designed for approximately 10,000 employees.

- Employee search, filtering, sorting, and pagination are performed at the database level.
- Pagination is bounded to a maximum of 100 records per request.
- Frequently queried employee fields are indexed.
- Salary metrics use database aggregation functions.
- Salary calculations are grouped by currency to avoid invalid cross-currency comparisons.
- A composite `(currency, annual_salary)` index supports Salary Explorer range queries.
- The current median implementation is appropriate for the assessment dataset; PostgreSQL `PERCENTILE_CONT` can be used for larger datasets.
- PostgreSQL `pg_trgm`, keyset pagination, caching, and background reporting are potential future optimizations.

See [`docs/architecture.md`](docs/architecture.md) for detailed performance and scalability considerations.

## Project Documentation

Additional assessment artifacts are available under `docs/`:

- [`requirements.md`](docs/requirements.md) — product scope, requirements, and deliberate exclusions
- [`architecture.md`](docs/architecture.md) — architecture, API design, performance, and scalability
- [`architecture-decisions.md`](docs/architecture-decisions.md) — key technical trade-offs and decisions
- [`ai-development.md`](docs/ai-development.md) — AI-assisted development approach and validation

## Frontend

The React frontend is maintained in a separate repository:

[`employee_salary_management_frontend`](https://github.com/PDudhatra/employee_salary_management_frontend)

## Design Considerations

### Multiple Currencies

Employees may be paid in different currencies.

Because the application does not currently integrate with an exchange-rate provider, salary totals and statistics are grouped by currency rather than combined into a single global monetary value.

### Authentication and Authorization

Authentication and role-based authorization are intentionally outside the MVP scope because the assessment defines a single HR Manager persona.

For a production system, authentication, authorization, audit logging, and appropriate protection of salary information would be required.

### Scalability

The current implementation is intentionally optimized for the assessment requirement of approximately 10,000 employees.

Potential future improvements for substantially larger datasets include:

- PostgreSQL trigram indexes for partial text search
- Keyset pagination
- Database-level median calculations
- More optimized dashboard aggregation queries
- Caching of frequently requested dashboard metrics
- Background processing for expensive reporting operations

## Repository

Backend:

[`employee_salary_management`](https://github.com/PDudhatra/employee_salary_management)

Frontend:

[`employee_salary_management_frontend`](https://github.com/PDudhatra/employee_salary_management_frontend)
