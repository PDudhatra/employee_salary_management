module Api
  module V1
    class EmployeesController < ApplicationController
      DEFAULT_PER_PAGE = 25
      MAX_PER_PAGE = 100

      SORTABLE_FIELDS = %w[
        employee_code
        first_name
        last_name
        annual_salary
        joining_date
      ].freeze

      def index
        employees = Employee.all

        employees = apply_search(employees)
        employees = apply_filters(employees)
        employees = apply_sorting(employees)

        total_count = employees.count

        page = normalized_page
        per_page = normalized_per_page

        employees = employees
          .offset((page - 1) * per_page)
          .limit(per_page)

        render json: {
          data: employees.as_json(
            only: %i[
              id
              employee_code
              first_name
              last_name
              email
              country
              department
              job_title
              employment_status
              joining_date
              annual_salary
              currency
            ]
          ),
          pagination: {
            page: page,
            per_page: per_page,
            total_count: total_count,
            total_pages: (total_count.to_f / per_page).ceil
          }
        }
      end

      def show
        employee = Employee.find(params[:id])

        render json: {
          data: employee.as_json(
            only: %i[
              id
              employee_code
              first_name
              last_name
              email
              country
              department
              job_title
              employment_status
              joining_date
              annual_salary
              currency
            ]
          )
        }
      end
      def create
        employee = Employee.new(employee_params)

        if employee.save
          render json: {
            data: employee.as_json(
              only: %i[
                id employee_code first_name last_name email country department
                job_title employment_status joining_date annual_salary currency
              ]
            )
          }, status: :created
        else
          render json: {
            errors: employee.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
      
      def update
        employee = Employee.find(params[:id])

        if employee.update(employee_params)
          render json: {
            data: employee.as_json(
              only: %i[
                id
                employee_code
                first_name
                last_name
                email
                country
                department
                job_title
                employment_status
                joining_date
                annual_salary
                currency
              ]
            )
          }
        else
          render json: {
            errors: employee.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def apply_search(scope)
        return scope if params[:search].blank?

        search = "%#{ActiveRecord::Base.sanitize_sql_like(params[:search])}%"

        scope.where(
          "first_name ILIKE :search
           OR last_name ILIKE :search
           OR email ILIKE :search
           OR employee_code ILIKE :search",
          search: search
        )
      end

      def apply_filters(scope)
        scope = scope.where(country: params[:country]) if params[:country].present?
        scope = scope.where(department: params[:department]) if params[:department].present?
        scope = scope.where(employment_status: params[:status]) if params[:status].present?
        scope = scope.where(currency: params[:currency]) if params[:currency].present?

        scope
      end

      def apply_sorting(scope)
        sort = SORTABLE_FIELDS.include?(params[:sort]) ? params[:sort] : "employee_code"
        direction = params[:direction] == "desc" ? :desc : :asc

        scope.order(sort => direction)
      end

      def normalized_page
        [params.fetch(:page, 1).to_i, 1].max
      end

      def normalized_per_page
        requested = params.fetch(:per_page, DEFAULT_PER_PAGE).to_i

        [[requested, 1].max, MAX_PER_PAGE].min
      end

      def employee_params
  params.require(:employee).permit(
    :employee_code,
    :first_name,
    :last_name,
    :email,
    :country,
    :department,
    :job_title,
    :employment_status,
    :joining_date,
    :annual_salary,
    :currency
  )
end
    end
  end
end