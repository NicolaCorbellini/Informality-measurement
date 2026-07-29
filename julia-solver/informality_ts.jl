using XLSX, DataFrames, Optim, LogExpFunctions
using BenchmarkTools
using Plots

# using Pkg
# Pkg.add("LeastSquaresOptim")
# Pkg.add("Optim")

# Load the Excel file
xlsx = XLSX.readxlsx("C:/Users/nicol/Documents/GitHub/Research/Informality-measurement/julia-solver/time_series.xlsx")

sheet = xlsx["Sheet1"]  # or xlsx[1] if it's the first sheet
data = XLSX.gettable(sheet)
df = DataFrame(data)

# Prepare output vector
## sales per worker in equations
theta_f_grid   = Vector{Union{Missing, Float64}}()
theta_o_grid   = Vector{Union{Missing, Float64}}()
info_shares    = Vector{Union{Missing, Float64}}()
## value added per worker in equations
theta_f_grid_2 = Vector{Union{Missing, Float64}}()
theta_o_grid_2 = Vector{Union{Missing, Float64}}()
info_shares_2  = Vector{Union{Missing, Float64}}()

for row in eachrow(df)
    
    # Skip rows where sales_per_worker_form is missing
    if ismissing(row.va_per_worker_form)
        push!(info_shares, missing)
        push!(theta_f_grid, missing)
        push!(theta_o_grid, missing)
        push!(info_shares_2, missing)
        push!(theta_f_grid_2, missing)
        push!(theta_o_grid_2, missing)
        continue
    end

    # Extract macro variables from the row
    K           = row.capital*1e6
    No          = row.employment_info *1e3
    Nf          = row.employment*1e3 - No 
    alpha       = row.beta_k 
    gamma_f     = row.beta_n
    gamma_o     = row.beta_n_info
    # gdp_growth  = row.gdp_growth
    va_f        = row.va_per_worker_form
    va_o        = row.va_per_worker_info
    s_f         = row.sales_per_worker_form
    s_o         = row.sales_per_worker_info

    theta_f   = s_f/(K^alpha*Nf^(gamma_f-1))
    theta_o   = s_o/(No^(gamma_o-1))
    theta_f_2 = va_f/(K^alpha*Nf^(gamma_f-1))
    theta_o_2 = va_o/(No^(gamma_o-1))


    info_share   = theta_o*No^(gamma_o) / (theta_f*K^alpha*Nf^(gamma_f) + theta_o*No^(gamma_o))
    info_share_2 = theta_o_2*No^(gamma_o) / (theta_f_2*K^alpha*Nf^(gamma_f) + theta_o_2*No^(gamma_o))

    push!(info_shares, info_share)
    push!(theta_f_grid,theta_f)
    push!(theta_o_grid,theta_o)
    push!(info_shares_2, info_share_2)
    push!(theta_f_grid_2,theta_f_2)
    push!(theta_o_grid_2,theta_o_2)

end

# Add new columns to DataFrame
df.info_share   = info_shares
df.theta_f      = theta_f_grid
df.theta_o      = theta_o_grid
df.info_share_2 = info_shares_2
df.theta_f_2    = theta_f_grid_2
df.theta_o_2    = theta_o_grid_2

output_path = "C:/Users/nicol/Documents/GitHub/Research/Informality-measurement/julia-solver/informality_series.xlsx"

# Delete the file if it exists
if isfile(output_path)
    rm(output_path)
end
# Save to an Excel file
XLSX.writetable(output_path, df)


function backward_fill!(df::DataFrame)
    sort!(df, [:country, :year])  # Ensure data is sorted

    for country in unique(df.country)
        subdf = df[df.country .== country, :]
        idxs = findall(.!ismissing.(subdf.theta_f) .& .!ismissing.(subdf.theta_o) .& .!ismissing.(subdf.info_share))

        ## constant parameters
        alpha   = subdf.beta_k[1]
        gamma_f = subdf.beta_n[1]
        gamma_o = subdf.beta_n_info[1]

        if length(idxs) == 1
            start_idx = idxs[1]

            for i in (start_idx - 1):-1:1

                K           = subdf.capital[i + 1]*1e6
                No          = subdf.employment_info[i + 1]*1e3
                Nf          = subdf.employment[i + 1]*1e3 - No 
                K_prev      = subdf.capital[i]*1e6
                No_prev     = subdf.employment_info[i]*1e3
                Nf_prev     = subdf.employment[i]*1e3 - No_prev 
                gdp_growth  = subdf.gdp_growth[i]
                theta_f     = subdf.theta_f[i + 1]
                theta_o     = subdf.theta_o[i + 1]
                theta_f_2   = subdf.theta_f_2[i + 1]
                theta_o_2   = subdf.theta_o_2[i + 1]

                ## sales per worker
                y_curr = theta_f * K^alpha * Nf^gamma_f + theta_o * No^gamma_o
                y_prev = theta_f * K_prev^alpha * Nf_prev^gamma_f + theta_o * No_prev^gamma_o
                x = y_curr/((1+gdp_growth)*y_prev) 
                
                subdf.theta_f[i] = x*theta_f
                subdf.theta_o[i] = x*theta_o
                subdf.info_share[i] = x*theta_o* No_prev^gamma_o/(x*theta_f * K_prev^alpha * Nf_prev^gamma_f + x*theta_o * No_prev^gamma_o)   
                
                ## value added per worker
                y_curr_2 = theta_f_2 * K^alpha * Nf^gamma_f + theta_o_2 * No^gamma_o
                y_prev_2 = theta_f_2 * K_prev^alpha * Nf_prev^gamma_f + theta_o_2 * No_prev^gamma_o
                x_2 = y_curr_2/((1+gdp_growth)*y_prev_2) 
                
                subdf.theta_f_2[i] = x_2*theta_f_2
                subdf.theta_o_2[i] = x_2*theta_o_2
                subdf.info_share_2[i] = x_2*theta_o_2* No_prev^gamma_o/(x_2*theta_f_2 * K_prev^alpha * Nf_prev^gamma_f + x_2*theta_o_2 * No_prev^gamma_o) 
            end

            # Update the original DataFrame
            df[df.country .== country, :] .= subdf
        end
    end
end

backward_fill!(df)

function forward_fill!(df::DataFrame)
    sort!(df, [:country, :year])  # Ensure data is sorted

    for country in unique(df.country)
        subdf     = df[df.country .== country, :]
        start_idx = sum(.!ismissing.(subdf.theta_f) .& .!ismissing.(subdf.theta_o) .& .!ismissing.(subdf.info_share))
        end_idx   = start_idx + sum(ismissing.(subdf.theta_f) .& ismissing.(subdf.theta_o) .& ismissing.(subdf.info_share))

        ## constant parameters
        alpha   = subdf.beta_k[1]
        gamma_f = subdf.beta_n[1]
        gamma_o = subdf.beta_n_info[1]

        for i in start_idx:1:(end_idx-1)

            K           = subdf.capital[i + 1]*1e6
            No          = subdf.employment_info[i + 1]*1e3
            Nf          = subdf.employment[i + 1]*1e3 - No 
            K_prev      = subdf.capital[i]*1e6
            No_prev     = subdf.employment_info[i]*1e3
            Nf_prev     = subdf.employment[i]*1e3 - No_prev 
            gdp_growth  = subdf.gdp_growth[i+1]
            theta_f     = subdf.theta_f[i]
            theta_o     = subdf.theta_o[i]
            theta_f_2   = subdf.theta_f_2[i]
            theta_o_2   = subdf.theta_o_2[i]

            ## sales per worker
            y_curr = theta_f * K^alpha * Nf^gamma_f + theta_o * No^gamma_o
            y_prev = theta_f * K_prev^alpha * Nf_prev^gamma_f + theta_o * No_prev^gamma_o
            x      = ((1+gdp_growth)*y_prev)/y_curr 
                
            subdf.theta_f[i+1]    = x*theta_f
            subdf.theta_o[i+1]    = x*theta_o
            subdf.info_share[i+1] = x*theta_o* No^gamma_o/(x*theta_f * K^alpha * Nf^gamma_f + x*theta_o * No^gamma_o)                

            ## value added per worker
            y_curr_2 = theta_f_2 * K^alpha * Nf^gamma_f + theta_o_2 * No^gamma_o
            y_prev_2 = theta_f_2 * K_prev^alpha * Nf_prev^gamma_f + theta_o_2 * No_prev^gamma_o
            x_2      = ((1+gdp_growth)*y_prev_2)/y_curr_2 
                
            subdf.theta_f_2[i+1]    = x_2*theta_f_2
            subdf.theta_o_2[i+1]    = x_2*theta_o_2
            subdf.info_share_2[i+1] = x_2*theta_o_2* No^gamma_o/(x_2*theta_f_2 * K^alpha * Nf^gamma_f + x_2*theta_o_2 * No^gamma_o)                

            # Update the original DataFrame
            df[df.country .== country, :] .= subdf
        end
    end
end

forward_fill!(df)

output_path = "C:/Users/nicol/Documents/GitHub/Research/Informality-measurement/julia-solver/informality_series.xlsx"

# Delete the file if it exists
if isfile(output_path)
    rm(output_path)
end
# Save to an Excel file
XLSX.writetable(output_path, df)

## charts
sort!(df, [:country, :year])  
figpath = "C:/Users/nicol/Documents/GitHub/Research/Informality-measurement/"

for country in unique(df.country)
    subdf = df[df.country .== country, :]
    years = unique(subdf.year)
    tick_interval = max(1, Int(floor(length(years) / 6)))
    xtick_vals = years[1:tick_interval:end]

    plot(subdf.year, subdf.out_share,lc=:black,lw=2,ls=:solid,xlabel="Year",ylabel="Share",
    label="Informal Employment",
    title = "Informality in $country",
    legend = :outerbottom,
    xticks = xtick_vals)
    plot!(subdf.year, subdf.info_share,lc=:blue,lw=2,ls=:dash,
    label="Informal GDP (sales-based)")
    plot!(subdf.year, subdf.info_share_2,lc=:red,lw=2,ls=:dot,
    label="Informal GDP (va-based)",
    ylims=(0.0,1.0))
    mask = subdf.info_emp_interpolated .== 0
    scatter!(subdf.year[mask], subdf.info_share[mask],
    marker=:diamond, ms=6, mc=:blue, label="ILO data available")
    scatter!(subdf.year[mask], subdf.info_share_2[mask],
    marker=:diamond, ms=6, mc=:red, label="")

    savefig(figpath*"$country")
end



