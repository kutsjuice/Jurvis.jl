"""
Calculate spectrum of the signal
Fs - Sampling rate           
"""
function easyspectrum(signal::Vector{T}; dt = NaN, Fs = NaN) where T <: Number
    if isnan(dt)&&isnan(Fs) 
        return throw(ArgumentError( "Sampling rate or sampling period should be defined"))
    elseif (!isnan(dt)) && (!isnan(Fs))
        if (Fs == 1/dt) 
            return throw(ArgumentError("Specified sampling rate does not corresspond to the specified sampling period"))
        end
    elseif !isnan(dt)
        Fs = 1/dt;
    end
    L = length(signal);
    Y = fft(signal);
    
    spectrum = 2/L*abs.(Y[1:(L÷2+1)]);
    freqs = Fs*(0:(L÷2))/L;
    return (freqs, spectrum);
end

function spectrumall(time_data::MeasuredData)
    freqs, amps = easyspectrum(time_data.ydata[:,1]; dt = getstep(time_data));
    spectrum = MeasuredData("Spectrum of $(time_data.name)",collect(freqs), reshape(amps, length(amps),1), "Frequncy, [Hz]", time_data.ydata_names[1:1], length(freqs), 1,[""]); 
    for i in 1:time_data.num-1
        freqs, amps = easyspectrum(time_data.ydata[:,i+1]; dt = getstep(time_data));
        add_data!(spectrum, amps; ydata_name = time_data.ydata_names[i+1]);
    end
    return spectrum
end