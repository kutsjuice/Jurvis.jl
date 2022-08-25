function plotchannel(data::MeasuredData; ch::Int64 = 1)
    h = plt.plot(data.xdata, data.ydata[:,ch], label = data.ydata_names[ch]);
    plt.xlabel( xlabel = data.xdata_name);
    return h;
end

function plotall(data::MeasuredData; skip = [], leg = false)
    h = plt.plot();
    for i in 1:data.num
        if !(i in skip)
            plt.plot(data.xdata, data.ydata[:,i], label = data.ydata_names[i]);
        end
    end
    plt.title(data.name);

    leg && plt.legend()
end

function plotrelation(data::MeasuredData, chX::Int, chY::Int)
    plt.plot(data.ydata[:,chX], data.ydata[:,chY]);
    plt.title("Dependency of $(data.ydata_names[chY]) from $(data.ydata_names[chX])")
end