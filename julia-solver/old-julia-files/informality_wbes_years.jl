using XLSX, DataFrames, Optim, LogExpFunctions
using BenchmarkTools

# using Pkg
# Pkg.add("LeastSquaresOptim")
# Pkg.add("Optim")

# Load the Excel file
xlsx = XLSX.readxlsx("C:/Users/nicol/Documents/GitHub/Research/H-drive-umn/julia-solver/time_series_wbes_years.xlsx")

sheet = xlsx["Sheet1"]  # or xlsx[1] if it's the first sheet
data = XLSX.gettable(sheet)
df = DataFrame(data)

# Prepare output vector
## sales per worker in equations
## equations residuals
res_a_grid   = Float64[]
res_b_grid   = Float64[]
res_c_grid   = Float64[]
## parameters estimated
theta_f_grid = Float64[]
theta_o_grid = Float64[]
tau_grid     = Float64[]
## informality shares
info_shares  = Float64[]
## value added per worker in equations
res_a_grid_2   = Float64[]
res_b_grid_2   = Float64[]
res_c_grid_2   = Float64[]
## parameters estimated
theta_f_grid_2 = Float64[]
theta_o_grid_2 = Float64[]
tau_grid_2     = Float64[]
## informality shares
info_shares_2  = Float64[]

for row in eachrow(df)
    # Extract macro variables from the row
    K           = row.capital*1e6
    No          = row.employment_info *1e3
    Nf          = row.employment*1e3 - No 
    alpha       = row.beta_k 
    gamma_f     = row.beta_n
    gamma_o     = row.beta_n_info
    # alpha       = row.beta_k 
    # gamma_f     = row.beta_n
    # gamma_o     = row.beta_n_info
    alpha       = .3
    gamma_f     = .6
    gamma_o     = .9
    g           = row.govt_share
    Y           = row.gdp*10e6
    # delta       = row.depreciation
    # cons_growth = row.consumption_growth
    va_f        = row.va_per_worker_form
    va_o        = row.va_per_worker_info
    s_f         = row.sales_per_worker_form
    s_o         = row.sales_per_worker_info

    # Define the residual function
    function res(x)
        a = log(exp(x[1])*K^alpha*Nf^(gamma_f-1)) - log(va_f)
        b = log(exp(x[2])*No^(gamma_o-1)) - log(va_o)
        c = log((logistic(x[3])*exp(x[1])*K^alpha*Nf^(gamma_f))) - log(g*(exp(x[1])*K^alpha*Nf^(gamma_f) + exp(x[2])*No^(gamma_o)))
        return a^2 + b^2 + c^2
    end

    # Initial guess
    x0 = [log(3000), log(10000), -1.5]

    # Solve
    result = optimize(res, x0, BFGS())
    x1     = result.minimizer    

    # Compute info_share
    theta_f, theta_o = exp.(x1[1:2])
    tau              = logistic(x1[3])

    res_a = 100*(theta_f*K^alpha*Nf^(gamma_f-1))/(va_f)
    res_b = 100*(theta_o*No^(gamma_o-1))/(va_o)
    res_c = 100*(tau*theta_f*K^alpha*Nf^(gamma_f))/(g*(theta_f*K^alpha*Nf^(gamma_f) + theta_o*No^(gamma_o)))

    info_share = theta_o*No^(gamma_o) / (theta_f*K^alpha*Nf^(gamma_f) + theta_o*No^(gamma_o))

    push!(info_shares, info_share)
    push!(theta_f_grid,theta_f)
    push!(theta_o_grid,theta_o)
    push!(tau_grid,tau)
    push!(res_a_grid,res_a)
    push!(res_b_grid,res_b)
    push!(res_c_grid,res_c)

    # Define the residual function
    function res_2(x)
        a = log(exp(x[1])*K^alpha*Nf^(gamma_f-1)) - log(s_f)
        b = log(exp(x[2])*No^(gamma_o-1)) - log(s_o)
        c = log((logistic(x[3])*exp(x[1])*K^alpha*Nf^(gamma_f))) - log(g*(exp(x[1])*K^alpha*Nf^(gamma_f) + exp(x[2])*No^(gamma_o)))
        return a^2 + b^2 + c^2
    end

    # Initial guess
    x0 = [log(3000), log(10000), -1.5]

    # Solve
    result = optimize(res_2, x0, BFGS())
    x1     = result.minimizer    

    # Compute info_share
    theta_f_2, theta_o_2 = exp.(x1[1:2])
    tau_2                = logistic(x1[3])

    res_a_2 = 100*(theta_f_2*K^alpha*Nf^(gamma_f-1))/(s_f)
    res_b_2 = 100*(theta_o_2*No^(gamma_o-1))/(s_o)
    res_c_2 = 100*(tau_2*theta_f_2*K^alpha*Nf^(gamma_f))/(g*(theta_f_2*K^alpha*Nf^(gamma_f) + theta_o_2*No^(gamma_o)))

    info_share_2 = theta_o_2*No^(gamma_o) / (theta_f_2*K^alpha*Nf^(gamma_f) + theta_o_2*No^(gamma_o))

    push!(info_shares_2, info_share_2)
    push!(theta_f_grid_2,theta_f_2)
    push!(theta_o_grid_2,theta_o_2)
    push!(tau_grid_2,tau_2)
    push!(res_a_grid_2,res_a_2)
    push!(res_b_grid_2,res_b_2)
    push!(res_c_grid_2,res_c_2)

end

# Add new columns to DataFrame
df.info_share = info_shares
df.theta_f    = theta_f_grid
df.theta_o    = theta_o_grid
df.tau        = tau_grid
df.res_a      = res_a_grid
df.res_b      = res_b_grid
df.res_c      = res_c_grid
df.info_share_2 = info_shares_2
df.theta_f_2    = theta_f_grid_2
df.theta_o_2    = theta_o_grid_2
df.tau_2        = tau_grid_2
df.res_a_2      = res_a_grid_2
df.res_b_2      = res_b_grid_2
df.res_c_2      = res_c_grid_2

output_path = "C:/Users/nicol/Documents/GitHub/Research/H-drive-umn/julia-solver/informality_wbes.xlsx"

# Delete the file if it exists
if isfile(output_path)
    rm(output_path)
end
# Save to an Excel file
XLSX.writetable(output_path, df)

