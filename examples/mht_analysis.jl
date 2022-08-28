using PyPlot;
using Jurvis;
using ToeplitzMatrices


dt = 0.0001;
T_lim = 5;

tt = 0:dt:T_lim;

β = [0.8 + ((t-T_lim)/2/T_lim)^2 for t in tt]
# plot(tt, β); ylim([0, 1.5]);

A_max = 3.1;
env = [A_max*exp(-tt[i]*β[i]) for i in eachindex(tt)]
# plot(tt, env); ylim([0, 4])
f = 280; ω = 2*π*f;
sig = sin.(ω.*tt).*env
plot(tt, sig)
ζ = β./ω
plot(env, ζ); yscale("log"); xscale("log")


using Peaks;

pks, vals = findmaxima(sig)
# scatter(tt[pks], vals, color = "r")
using BasicInterpolators
interp = CubicSplineInterpolator(tt[pks], vals, WeakBoundaries())
inds = 0.0009.<tt.<4.9973
new_tt = tt[inds]
comp_env = interp.(new_tt)
plot(new_tt, comp_env)
new_sig = sig[inds]

imag_part = [sqrt(abs(comp_env[i] ^ 2 - new_sig[i]^2)) for i in eachindex(new_sig)]
plot(imag_part)

begin
imag_part = [sqrt(abs(comp_env[i] ^ 2 - new_sig[i]^2)) for i in eachindex(new_sig)]

mins, _ = findminima(imag_part)
sign = 1;
lower = 1;
b_coefs = [1/4, -4/3, 3, -4, 25/12];
for upper in mins
    for ii in lower:upper
        imag_part[ii] *= sign;
    end
    lower = upper+1;
    sign *= -1;
end
teach_size = 15;
ps = [];
for point in (mins.+1)
    for ii in (point-2:point)

        interp = LinearInterpolator([1,2,3,4], imag_part[ii-4:ii-1], NoBoundaries());
        pr = interp(5);
        if abs(imag_part[ii] - pr) > abs( - imag_part[ii] - pr)
            push!(ps, [ii, pr]);
            imag_part[ii] *=-1;
        end    
    end
end
ps = hcat(ps...)

plot(imag_part[1:endpoint], marker = "."); grid()
scatter(ps[1,:], ps[2,:], marker = ".", color = "r")

end

full = new_sig .+ imag_part*1im
phase = instphase(full);
freq = findiff(phase, dt; order = 4)/2/π
plot(freq)