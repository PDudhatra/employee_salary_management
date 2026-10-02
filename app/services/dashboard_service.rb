class DashboardService
  def call
    {
      total_employees: Employee.count,
      employees_by_status: employees_by_status,
      payroll_by_currency: payroll_by_currency,
      salary_metrics_by_currency: salary_metrics_by_currency,
      employees_by_country: employees_by_country,
      employees_by_department: employees_by_department
    }
  end

  private

  def employees_by_status
    Employee.group(:employment_status).count
  end

  def payroll_by_currency
    Employee
      .group(:currency)
      .sum(:annual_salary)
      .transform_values(&:to_f)
  end

  def salary_metrics_by_currency
    currencies = Employee.distinct.pluck(:currency)

    currencies.each_with_object({}) do |currency, result|
      scope = Employee.where(currency: currency)

      result[currency] = {
        average: scope.average(:annual_salary)&.to_f,
        minimum: scope.minimum(:annual_salary)&.to_f,
        maximum: scope.maximum(:annual_salary)&.to_f
      }
    end
  end

  def employees_by_country
    Employee.group(:country).count
  end

  def employees_by_department
    Employee.group(:department).count
  end
end