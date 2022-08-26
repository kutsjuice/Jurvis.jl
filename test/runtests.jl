ENV["PYTHON"]=""
using Jurvis
using Test

@testset "Jurvis.jl" begin
    begin
        dt = 0.1;
        N = 1000;
        M = 4;
        xdata = dt*(0:(N-1));
        ydata = randn(N, M);

        xdata_name = "XData";
        ydata_names = Vector{String}(undef, M);
        ydata_info = ["" for i in 1:M];
        for i in 1:M
            ydata_names[i] = "YData_$(lpad(i,3,"0"))";
        end

        md = MeasuredData("", xdata, ydata, xdata_name, ydata_names, N, M, ydata_info);
    end

    @test getstep(md) == dt;

    @test all(cut(md, [0, Inf]).ydata .== md.ydata)

    md_cut = cut(md, [10, 20]);

    @test all(md_cut.xdata .== md.xdata[101:201])

    @test all(md_cut.ydata .== md.ydata[101:201, :])

    @test md_cut.name == md.name

    
end
