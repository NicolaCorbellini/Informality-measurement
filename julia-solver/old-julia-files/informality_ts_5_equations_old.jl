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
## equations residuals
res_a_grid   = Float64[]
res_b_grid   = Float64[]
res_c_grid   = Float64[]
res_d_grid   = Float64[]
res_e_grid   = Float64[]
## parameters estimated
theta_f_grid = Float64[]
theta_o_grid = Float64[]
tau_grid     = Float64[]
gamma_f_grid = Float64[]
gamma_o_grid = Float64[]
## informality shares
info_shares  = Float64[]

for row in eachrow(df)
    # Extract macro variables from the row
    K     = row.capital*10e6
    No    = row.employment_info *10e3
    Nf    = row.employment*10e3 - No 
    # alpha = row.beta_k 
    alpha = 0.3
    g     = row.govt_share
    Y     = row.gdp*10e6
    # delta = row.depreciation
    spw_f = row.sales_per_worker_form
    spw_o = row.sales_per_worker_info

    function res(x)
        a = log((exp(x[4])*(1-logistic(x[3]))*exp(x[1])*K^alpha*Nf^(exp(x[4])-1)) / (exp(x[2]))) - log((exp(x[5]))*No^(exp(x[5]) - 1))
        b = log(exp(x[1])*K^alpha*Nf^(exp(x[4])) + (exp(x[2])) *No^(exp(x[5]))) - log(Y)
        c = log((logistic(x[3])*exp(x[1])*K^alpha*Nf^(exp(x[4])))/Y) - log(g)
        d = log(exp(x[1])*K^alpha*Nf^(exp(x[4])-1)) - log(spw_f)
        e = log(exp(x[2])*No^(exp(x[5])-1)) - log(spw_o)
        return a^2 + b^2 + c^2 + d^2 + e^2
    end

    # Initial guess
    x0 = [log(3000), log(10000), -1.5, 0.0, 0.0]

    # Solve
    result = optimize(res, x0, BFGS())
    x1 = result.minimizer    

    # Compute info_share
    theta_f, theta_o      = exp.(x1[1:2])
    tau, gamma_f, gamma_o = logistic.(x1[3:5])

    res_a = 100*(gamma_f*(1-tau)*theta_f*Nf^(gamma_f-1) - (gamma_o) * (theta_o) *No^(gamma_o - 1))/((gamma_o) * (theta_o) *No^(gamma_o - 1))
    res_b = 100*(Y - theta_f * Nf^gamma_f - theta_o * No^gamma_o)/(theta_f * Nf^gamma_f - theta_o * No^gamma_o)
    res_c = 100*(tau*theta_f*Nf^(gamma_f)/Y - g)/g
    res_d = 100*(theta_f*K^alpha*Nf^(gamma_f-1) - spw_f) / spw_f
    res_e = 100*(theta_o*No^(gamma_o-1) - spw_o) / spw_o
    info_share = theta_o * No^gamma_o / Y

    push!(info_shares, info_share)

    push!(theta_f_grid,theta_f)
    push!(theta_o_grid,theta_o)
    push!(tau_grid,tau)
    push!(gamma_f_grid,gamma_f)
    push!(gamma_o_grid,gamma_o)
    
    push!(res_a_grid,res_a)
    push!(res_b_grid,res_b)
    push!(res_c_grid,res_c)
    push!(res_d_grid,res_d)
    push!(res_e_grid,res_e)
end

# Add new columns to DataFrame
df.info_share = info_shares

df.theta_f    = theta_f_grid
df.theta_o    = theta_o_grid
df.tau        = tau_grid
df.gamma_f    = gamma_f_grid
df.gamma_o    = gamma_o_grid

df.res_a      = res_a_grid
df.res_b      = res_b_grid
df.res_c      = res_c_grid
df.res_d      = res_d_grid
df.res_e      = res_e_grid

output_path = "C:/Users/nicol/Documents/GitHub/Research/H-drive-umn/julia-solver/informality_wbes.xlsx"

# Delete the file if it exists
if isfile(output_path)
    rm(output_path)
end
# Save to an Excel file
XLSX.writetable(output_path, df)

