using Jurvis;
using PyPlot;
using CSV
using DataFrames

cm2in(cm) = cm/2.54;

show_plots = false;
file = "examples\\IR_2000_0500.txt";

data = readtxt(file; header = 2)

# plot the time vector
if show_plots
    figure()
    plot(data.xdata)
end
# since data has different time_step before 1s and after, we should cut first second off
cut!(data, [1,Inf])
if show_plots
    figure()
    plot(data.xdata)
end
# next we can plot selected channel
if show_plots
    figure()
    plotchannel(data; ch = 2)
end
# or all channels at once
if show_plots
    figure()
    plotall(data)
    legend()
end
# initial data recorded with frequency, higher than it is need, so we can decreas sampling frequency
downsample!(data, 4) # only each 4th point will be kept

#calculate and plot spectrum of the signal
spec = spectrumall(data)
if show_plots
    figure()
    plotall(spec)
    yscale("log")
    xlim([0,2500])
    legend()
end
## calculation of the mode decomposition using SSA
ch_ind = 2; # working with velocity channel
SSA_win = 10000;

# win_len = SSA_win*getstep(data);

decomposed_data = decomposeSSA(data, ch_ind, 20, SSA_win);

if show_plots
    figure(); 
    plotall(decomposed_data);  
    legend();
end
modes_spec = spectrumall(decomposed_data);

if show_plots
    figure();    
    plotall(modes_spec; leg = true);    
    xlim([1,2000]);    
    yscale("log");
end

# from the plot it is well seeing that first two modes of the initial signal are well described with using [1,2] and [3,4] and one can test it by her-/him- self; 
# but iteratively next groups were selecting

groups = [  [2,3,4,5,8,9],
            [6,7,17],
            ]

gr_data = groupmodes(decomposed_data, groups);

gr_data.ydata_names[1] = "Origin_"*data.ydata_names[ch_ind];
if show_plots
    figure(); 
    plotall(gr_data; leg = true);
end

gr_spec = spectrumall(gr_data);

if show_plots
    figure(); 
    plotall(gr_spec; leg = true); 
    yscale("log"); 
    xlim([0,2000]);
end

## Applying the Hilbert Transform to 1st mode to get damping-amplitude and frequency-amplitude relations
mode1 = copydata(gr_data, [2]);

# calculate full analitical signal of 1st mode
a_sig1 = fullsignal(mode1.ydata[:,1]);

show_plots && plotall(mode1; leg = true);

add_data!(mode1, imag.(a_sig1); ydata_name = "image part for 1st mode");

env1 = envelope(mode1.ydata[:,1]);
# channel 3
add_data!(mode1, env1; ydata_name = "1st mode envelope");

phase1 = instphase(mode1.ydata[:,1]);
# channel 4
add_data!(mode1, phase1; ydata_name = "inst phase of mode 1");

env_modes = decomposeSSA(mode1, 3, 10, 1000);
# channel 5
add_data!(mode1, env_modes.ydata[:, 2]; ydata_name = "filtered envelope of 1st mode");

show_plots && plotall(mode1; leg = true, skip = [4])

#cut initial and end parts of the signal due to computational uncertanties 
cut!(mode1, [1.02, 2.46]); #! <-- here time interval should be specified


##
# calculate damping as env
decay_coeff = instdecaycoeff(mode1.ydata[:,5])


# calculate instantenious frequency
inst_freq = findiff(mode1.ydata[:,4], getstep(mode1); order = 4) / (2*π)
show_plots && plot(inst_freq)

# since data very noizy, we can gen only trend from it
freq_modes = decomposeSSA(inst_freq, 10,1000)
add_data!(mode1, freq_modes[:,1]; ydata_name = "frequency") # channel 6

if show_plots
    figure(); plotchannel(mode1; ch = 6)
end
# calculate damping factor ζ
ζ = instdamping(mode1.ydata[:,5], mode1.ydata[:,6])
add_data!(mode1, ζ; ydata_name = "damping factor") # channel 7

if show_plots
    figure(); plotchannel(mode1; ch = 7)
end
# plot resulting relations 
begin
    h = cm2in(10);
    w = cm2in(17.5);
    figure(figsize = [w,h])
    subplot(1,2,1)
    plotrelation(mode1, 5,7)
    xlim([0.1,maximum(mode1.ydata[:,5])])
    ylim([1e-6, 1e-5])
    yscale("log")
    xscale("log")
    title("Damping-amplitude")
    xlabel("Amplitude, [m/s]")
    ylabel("Damping, [%]")

    subplot(1,2,2)
    plotrelation(mode1, 5,6)
    xlim([0.1,maximum(mode1.ydata[:,5])])
    title("Frequency-amplitude")
    xscale("log")

    ylabel("Frequency, [Hz]")
    xlabel("Amplitude, [m/s]")
    tight_layout()
end
