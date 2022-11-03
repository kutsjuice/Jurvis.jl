# using Jurvis;
using PyPlot;
using LinearAlgebra
dt = 0.01;
tₘₐₓ = 10;
tt = -tₘₐₓ/2:dt:tₘₐₓ/2;
xx = sin.(tt)
# plot(tt, xx)

# using AutoGrad

begin


function diff14(vec::AbstractArray{<: Number}, time_step::Number)
    der = similar(vec);
    n = size(vec,1);
    m = size(vec,2)
    print(n,m)
    s_coefs = [1/12, -2/3, 2/3, -1/12];
    f_coefs = [-25/12, 4, -3, 4/3, -1/4];
    b_coefs = [1/4, -4/3, 3, -4, 25/12];
    # almost all points calculates using midpoint scheme
    for i = 3:(length(vec)-2)
        der[i, :] = (vec[i-2,:].*s_coefs[1] + vec[i-1,:].*s_coefs[2] + vec[i+1,:].*s_coefs[3] + vec[i+2,:].*s_coefs[4]) /time_step;
    end
    # first points are calculated using forward scheme of the same order
    for i = 1:2
        der[i,:] = sum(hcat([vec[i+j-1,:].*f_coefs[j] for j in eachindex(f_coefs)]...), dims =2)./time_step;
    end

    for i in 1:m
        for j in n-1:n
            der[j, i] = (vec[j-4:j]'*b_coefs)/time_step;
        end
    end
    return der;
end

cf = rand(-10:0.001:10, 8)
f1(x) = cf[1]*(x - cf[2]) + 1e-1*cf[3]*(x - cf[4])^2 + 1e-2*cf[5]*(x - cf[6])^3 + 1e-3*cf[7]*(x - cf[8])^4
df1(x) = cf[1] + 2e-1*cf[3]*(x - cf[4]) + 3e-2*cf[5]*(x - cf[6])^2 + 4e-3*cf[7]*(x - cf[8])^3
xx = f1.(tt)
order = 4;
dxdt_aprox = diff14(xx, dt)
dxdt_corr = df1.(tt)
plot(dxdt_aprox); plot(dxdt_corr)
norm(dxdt_aprox - dxdt_corr)
# (dt^order)*tₘₐₓ

end




