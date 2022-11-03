function diff14(vec::AbstractVector{<: Number}, time_step::Number)
    der = similar(vec);
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
    # last points are calculated using bacckward scheme of the same order
    for i = (length(vec)-1):length(vec)
        der[i,:] = -sum(hcat([vec[i-j+1,:].*b_coefs[j] for j in eachindex(f_coefs)]...), dims =2)./time_step;
    end
    return der;
end

function diff14!(der::AbstractVector{<: Number}, vec::AbstractVector{<: Number}, time_step::Number)
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
    # last points are calculated using bacckward scheme of the same order
    for i = (length(vec)-1):length(vec)
        der[i,:] = -sum(hcat([vec[i-j+1,:].*b_coefs[j] for j in eachindex(f_coefs)]...), dims =2)./time_step;
    end
end

function diff12(vec::AbstractVector{<: Number}, time_step::Number)
    der = similar(vec);
    s_coefs = [-0.5, 0.5];
    f_coefs = [-3/2, 2, -1/2];
    b_coefs = [1/2, -2, 3/2];
    # almost all points calculates using midpoint scheme
    for i = 2:(length(vec)-1)
        der[i, :] = (vec[i-1,:].*s_coefs[1] + vec[i+1,:].*s_coefs[2]) /time_step;
    end
    # first point are calculated using forward scheme of the same order
    der[1,:] = sum(hcat([vec[j,:].*f_coefs[j] for j in eachindex(f_coefs)]...), dims =2)./time_step;

    # last points are calculated using bacckward scheme of the same order
    der[end,:] = sum(hcat([vec[length(der) - length(f_coefs) + j,:].*b_coefs[j] for j in eachindex(f_coefs)]...), dims =2)./time_step;
    return der;
end

function diff12!(der::AbstractVector{<: Number},vec::AbstractVector{<: Number}, time_step::Number)
    s_coefs = [-0.5, 0.5];
    f_coefs = [-3/2, 2, -1/2];
    b_coefs = [1/2, -2, 3/2];
    # almost all points calculates using midpoint scheme
    for i = 2:(length(vec)-1)
        der[i, :] = (vec[i-1,:].*s_coefs[1] + vec[i+1,:].*s_coefs[2]) /time_step;
    end
    # first point are calculated using forward scheme of the same order
    der[1,:] = sum(hcat([vec[j,:].*f_coefs[j] for j in eachindex(f_coefs)]...), dims =2)./time_step;

    # last points are calculated using bacckward scheme of the same order
    der[end,:] = sum(hcat([vec[length(der) - length(f_coefs) + j,:].*b_coefs[j] for j in eachindex(f_coefs)]...), dims =2)./time_step;
end
function diff11(vec::AbstractVector{<: Number}, time_step::Number)
    der = similar(vec); 
    der[1:end-1] = (vec[2:end] - vec[1:end-1])./time_step; 
    der[end] = der[end-1];
    return der;
end

function findiff(vec::AbstractVector{<: Number}, time_step::Number; order = 1)
    if order == 1
        return diff11(vec, time_step);
    elseif order == 2
        return diff12(vec, time_step);
    elseif order == 4
        return diff14(vec, time_step);
    else
        throw(error("Wrong accuracy order"));
    end
end