class SalaryInsightsService
  def initialize(params = {})
    @params = params
  end

  def call
    employees = filtered_employees

    {
      employee_count: employees.count,
      average_salary: employees.average(:annual_salary)&.to_f,
      minimum_salary: employees.minimum(:annual_salary)&.to_f,
      maximum_salary: employees.maximum(:annual_salary)&.to_f,
      median_salary: median_salary(employees)
    }
  end

  private

  attr_reader :params

  def filtered_employees
    scope = Employee.all

    scope = scope.where(country: params[:country]) if params[:country].present?
    scope = scope.where(department: params[:department]) if params[:department].present?
    scope = scope.where(currency: params[:currency]) if params[:currency].present?

    if params[:min_salary].present?
      scope = scope.where("annual_salary >= ?", params[:min_salary])
    end

    if params[:max_salary].present?
      scope = scope.where("annual_salary <= ?", params[:max_salary])
    end

    scope
  end

  def median_salary(scope)
    salaries = scope.order(:annual_salary).pluck(:annual_salary)

    return nil if salaries.empty?

    middle = salaries.length / 2

    if salaries.length.odd?
      salaries[middle].to_f
    else
      (salaries[middle - 1].to_f + salaries[middle].to_f) / 2
    end
  end
end