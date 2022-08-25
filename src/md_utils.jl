"""
function returns the `x_step`` of the `data::MeasuredData`` rpovided
"""
function getstep(data::MeasuredData)
    return (data.xdata[2] - data.xdata[1]);
end


function cut(d::MeasuredData, limits::Vector{T}) where T <: Number
    idx = limits[1] .<= d.xdata .<= limits[2];
    xdata = d.xdata[idx];
    ydata = d.ydata[idx, :];
    return MeasuredData(d.name, xdata, ydata, d.xdata_name, d.ydata_names, length(xdata),d.num, d.ydata_info);
end

function cut!(d::MeasuredData, limits::Vector{T}) where T <: Number
    idx = limits[1] .<= d.xdata .<= limits[2];
    d.xdata = d.xdata[idx];
    d.ydata = d.ydata[idx, :];
    d.length = length(d.xdata);
end

function add_data!(d::MeasuredData, ydata::T; ydata_name = "", ydata_info ="") where T <: AbstractVector{Float64}
    @assert length(ydata)==d.length "New data has different size"
    d.num += 1;
    d.ydata = hcat(d.ydata, ydata);
    push!(d.ydata_names, ydata_name=="" ? "YData $(lpad(d.num,3,"0"))" : ydata_name);
    push!(d.ydata_info, ydata_info);

end

function copydata(data::MeasuredData, channels::Vector{T}) where T <: Integer
    return MeasuredData(data.name, data.xdata, data.ydata[:, channels], data.xdata_name, data.ydata_names[channels], data.length, length(channels), data.ydata_info[channels]);
end


function downsample(data::MeasuredData, step::Int64)
    new_xdata = data.xdata[1:step:end];
    new_ydata = data.ydata[1:step:end, :];
    new_len = length(new_xdata);
    return MeasuredData(data.name, 
                        new_xdata,
                        new_ydata, 
                        data.xdata_name,
                        data.ydata_names,
                        new_len,
                        data.num,
                        data.ydata_info,    
                        )
end

function downsample!(data::MeasuredData, step::Int64)
    new_xdata = data.xdata[1:step:end];
    new_ydata = data.ydata[1:step:end, :];
    new_len = length(new_xdata);
    data.xdata = new_xdata;
    data.ydata = new_ydata;
    data.length = new_len;
end