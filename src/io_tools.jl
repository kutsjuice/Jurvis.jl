function readtabular(file_name::String)
    data = open(file_name, "r") do file
        line = readline(file)[2:end-1];
        name = line[:];
        k = 1;
        info = Vector{String}();
        while line != ""
            k += 1;
            push!(info, line);
            line = readline(file);
        end
        df = CSV.read(file, DataFrame);
        xdata = df[!, 1];
        ydata = Matrix(df[!, 2:end]);
        names_ = names(df);
        return MeasuredData(name, xdata, ydata, String(rstrip(names_[1], ' ')), names_[2:end], length(xdata), length(names_)-1, info);
    end
    return data;
end

function readtxt(file_name::String; header::Integer = 1)

    name = split(split(file_name,"\\")[end], ".")[1]
    data = open(file_name, "r") do file
        df = CSV.read(file, DataFrame; header = header);
        xdata = df[!,1];
        ydata = Matrix(df[!, 2:end]);
        names_ = names(df)#["YData_$i" for i in 1:size(ydata,2)];
        info = ["" for i in 1:size(ydata,2)];
        return MeasuredData(name, xdata, ydata, "time", names_[2:end], size(ydata,1), size(ydata,2), info)
    end
    return data;
end

function readjmd(file_name::String)
    data = open(file_name, "r") do file
        name = split(readline(file), " -\t")[2];
        N = parse(Int64, split(readline(file),  "-\t")[2]);
        M = parse(Int64, split(readline(file),  "-\t")[2]);
        xdata_name = split(readline(file),  "-\t")[2];
        dx = parse(Float64, split(readline(file),  "-\t")[2]);
        readline(file);
        df = CSV.read(file, DataFrame; delim = ";\t");
        ydata = Matrix(df[!, 2:end]);
        ydata_names = names(df);
        ydata_info = similar(ydata_names);
        ydata_info .= "";
        return MeasuredData(    String(name), 
                                collect((0:(N-1)) .* dx), 
                                ydata, 
                                String(xdata_name), 
                                ydata_names, 
                                N, 
                                M, 
                                ydata_info);
        # return ydata
    end
    return data;
end



function readdata(file_name::String)
    if isfile(file_name)
        file = splitdir(file_name)[end];
        ext = split(file, ".")[end];
        if ext == "tab"
            return read_tab_file(file_name);
        elseif ext == "txt" 
            return read_txt_file(file_name);
        elseif ext == "jmd"
            return read_jmd_file(file_name);
        end
    end
end

function writedata(file::String, data::MeasuredData)
    open(file, "w") do f
        write(f, "name -\t$(data.name)\n");

        write(f, "N -\t$(data.length)\n");

        write(f, "M -\t$(data.num)\n");

        write(f, "xdata -\t$(data.xdata_name)\n");

        write(f, "dx -\t$(get_step(data))\n");

        write(f, "\n");
        df = DataFrame(data.ydata, :auto);
        rename!(df, data.ydata_names);
        CSV.write(f, df; append = true, writeheader = true, delim = ";\t");
    end
end