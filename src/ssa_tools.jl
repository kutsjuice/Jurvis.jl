function decomposeSSA(data::MeasuredData, channel::Int64, mod_numb::Int64, wind_len::Int64)
    dec_data = MeasuredData(    data.ydata_names[channel],
                                data.xdata,
                                data.ydata[:,channel:channel],
                                data.xdata_name,
                                ["origin signal"],
                                data.length,
                                1,
                                data.ydata_info[channel:channel]
                            );
    H = embedd(data.ydata[:,channel], wind_len);
    svd = svds(H; nsv = mod_numb)[1];
    modes = calcmodes(svd);
    for (i, col) in enumerate(eachcol(modes))
        add_data!(dec_data, col; ydata_name = "Mode $i");
    end

    return dec_data;
end

function decomposeSSA(data::Vector{T}, mod_numb::Int64, wind_len::Int64) where T <: Real

    H = embedd(data, wind_len);
    svd = svds(H; nsv = mod_numb)[1];
    modes = calcmodes(svd);
    return modes;
end

function embedd(t_ser::Vector{T}, L::P) where T <: Number where P <: Integer
    return collect(Hankel(t_ser[1:L], t_ser[L:end]));        
end

function calcmode(uᵢ::Vector{T}, sᵢ::P,  vᵀᵢ::Vector{L}) where {T<: Real, P<: Real, L<: Real}
    n = length(uᵢ);
    m = length(vᵀᵢ);
    a = zeros(Float64, n+m-1);
    for i in 1:n
        for j in 1:m
            a[i+j-1] += uᵢ[i] * vᵀᵢ[j] * sᵢ;
        end
    end
    if n<=m
        for i in 1:(n-1)
            a[i] /= i;
            a[end - i+1] /=i;
        end
        for i in n:m
            a[i] /= n;
        end
    else
        for i in 1:(m-1)
            a[i] /= i;
            a[end - i+1] /=i;
        end
        for i in m:n
            a[i] /= n;
        end
    end
    return a;
end

function calcmodes(svd::SVD)
    nsv = length(svd.S)
    n = size(svd.U, 1);
    m  =size(svd.Vt, 2);
    a = Matrix{Float64}(undef, (n+m-1), nsv);
    for i in 1:nsv
        a[:, i] = calcmode(svd.U[:,i], svd.S[i], svd.Vt[i,:]);
    end
    return a;
end

function groupmodes(data::MeasuredData, groups::Vector{Vector{Int64}})
    N = data.length;
    M = length(groups);

    new_data = MeasuredData(data.name,
                            data.xdata,
                            data.ydata[:,1:1],
                            data.xdata_name,
                            ["origin signal"],
                            data.length,
                            1,
                            data.ydata_info[1:1]
                        );
    for (i, ind) in enumerate(groups);
        add_data!(new_data, dropdims(sum(data.ydata[:, ind], dims = 2),dims = 2); ydata_name = "Grouped mode $i");
    end
    return new_data;
end