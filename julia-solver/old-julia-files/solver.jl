using NLsolve
using LogExpFunctions
# using Pkg
# Pkg.add("LeastSquaresOptim")
# Pkg.add("Optim")

function f(x)
    [gamma_f*(1-exp(x[3]))*exp(x[1])*K^alpha*Nf^(gamma_f-1) - (gamma_o) * (exp(x[2])) *No^(gamma_o - 1),
    Y - exp(x[1])*K^alpha*Nf^(gamma_f) - (exp(x[2])) *No^(gamma_o),
    exp(x[3])*exp(x[1])*K^alpha*Nf^(gamma_f)/Y - g]
end

K       = 2575677 * 1e6;
No      = 5143.158 * 1e3;
Nf      = 10531.926 * 1e3 - No;
alpha   = .3;
gamma_f = .7;
gamma_o = .95;
g       = .1980484;
Y       = 945250.56 * 1e6;

# @time begin
#     sol = nlsolve(f, [log(0.7*Y/(K^alpha * Nf^gamma_f)), log(0.3*Y/(No^gamma_o)), log(.2)])
# end

@time begin
    sol = nlsolve(f, [log(3000), log(10000), log(.2)])
end
exp.(sol.zero)

theta_f, theta_o, tau = exp.(sol.zero)


using BenchmarkTools
@benchmark LeastSquaresOptim.optimize(f, [log(3000), log(10000), log(.2)], Dogleg())

function res(x)
    a = log((gamma_f*(1-logistic(x[3]))*exp(x[1])*K^alpha*Nf^(gamma_f-1)) / (exp(x[2]))) - log( (gamma_o) *No^(gamma_o - 1))
    b = log(exp(x[1])*K^alpha*Nf^(gamma_f) + (exp(x[2])) *No^(gamma_o)) - log(Y)
    c = log(logistic(x[3])*exp(x[1])*K^alpha*Nf^(gamma_f)/Y) - log(g)
    return a^2+b^2+c^2
end

using Optim

x0 = [0.0, 0.0, 0.0]
x0 = [log(3000), log(10000), -1.5]
results = optimize(res, x0, BFGS())

x1 = results.minimizer

theta_f, theta_o = exp.(x1[1:2])
tau = logistic(x1[3])
tau*theta_f*K^alpha*Nf^(gamma_f)/Y - g
gamma_f*(1-tau)*theta_f*K^alpha*Nf^(gamma_f-1) - (gamma_o) * (theta_o) *No^(gamma_o - 1)
Y - theta_f * K^alpha * Nf^gamma_f - theta_o * No^gamma_o



# function f(x)
#     [exp(x[2])*(1-exp(x[3]))*exp(x[1])*K^alpha*Nf^(exp(x[2])-1) - (exp(x[2])/mu2) * (exp(x[1])/mu1) *No^(exp(x[2])/mu2 - 1),
#     Y - exp(x[1])*K^alpha*Nf^(exp(x[2])) - (exp(x[1])/mu1) *No^(exp(x[2])/mu2),
#     exp(x[3])*exp(x[1])*K^alpha*Nf^(exp(x[2]))/Y - g]
# end

# K     = 2575677 * 1e6;
# No    = 5143.158 * 1e3;
# Nf    = 10531.926 * 1e3 - No;
# alpha = .3;
# mu1   = exp(5.002668)/exp(3.241621);
# mu2   = 1;
# g     = .1980484;
# Y     = 945250.56 * 1e6;

# @time begin
#     sol = nlsolve(f, [log(5.002668), log(1.0), log(.2)])
# end
# exp.(sol.zero)

# theta_f, gamma_f, tau = exp.(sol.zero)
# theta_o = theta_f/mu1
# gamma_o = gamma_f/mu2

# theta_f * K^alpha * Nf^gamma_f
# Y
# theta_o * No^gamma_o
# Y_bis = theta_f * K^alpha * Nf^gamma_f + theta_o * No^gamma_o

# [Y Y_bis]