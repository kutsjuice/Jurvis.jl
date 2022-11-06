using Jurvis
using PyPlot
dt = 0.01;
tt = 0:dt:10


xx = exp.(tt)

dxdt_t = exp.(tt)
order_ = 4;
dxdt_n = findiff(xx, dt; order = order_);

plot(tt, dxdt_t-dxdt_n)
# plot(tt, dxdt_n)

using LinearAlgebra

norm(dxdt_t-dxdt_n)/(norm(xx)*dt^order_)