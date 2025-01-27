"""
    gwasprep(
        genomes::Genomes,
        phenomes::Phenomes;
        idx_entries::Union{Nothing,Vector{Int64}} = nothing,
        idx_loci_alleles::Union{Nothing,Vector{Int64}} = nothing,
        idx_trait::Int64 = 1,
        GRM_type::String = ["simple", "ploidy-aware"][1],
        standardise::Bool = true,
        verbose::Bool = false,
    )::Tuple{Matrix{Float64},Vector{Float64},Matrix{Float64},Fit}

Prepare the allele frequency matrix, phenotype vector, genetic relationship matrix and genotype-to-phenotype regression fit struct (G, y, GRM, fit)

# Examples
```jldoctest; setup = :(using GBCore, GBModel, LinearAlgebra)
julia> genomes = GBCore.simulategenomes(verbose=false);

julia> ploidy = 4;

julia> genomes.allele_frequencies = round.(genomes.allele_frequencies .* ploidy) ./ ploidy;

julia> proportion_of_variance = zeros(9, 1); proportion_of_variance[1, 1] = 0.5;

julia> trials, effects = GBCore.simulatetrials(genomes=genomes, n_years=1, n_seasons=1, n_harvests=1, n_sites=1, n_replications=1, f_add_dom_epi=[0.05 0.00 0.00;], proportion_of_variance = proportion_of_variance, verbose=false);;

julia> phenomes = extractphenomes(trials);

julia> G, y, GRM, fit = gwasprep(genomes, phenomes);

julia> sum(abs.(mean(G, dims=1)[1,:]) .< 1e-10) == size(G, 2)
true

julia> sum(abs.(std(G, dims=1)[1,:] .- 1) .< 1e-10) == size(G, 2)
true

julia> (abs(mean(y)) < 1e-10, abs(std(y) - 1) < 1e-10)
(true, true)

julia> size(G, 1) == length(y)
true

julia> (size(G, 1), length(y)) == size(GRM)
true

julia> length(fit.entries) == length(y)
true

julia> length(fit.b_hat) == size(G, 2)
true
```
"""
function gwasprep(
    genomes::Genomes,
    phenomes::Phenomes;
    idx_entries::Union{Nothing,Vector{Int64}} = nothing,
    idx_loci_alleles::Union{Nothing,Vector{Int64}} = nothing,
    idx_trait::Int64 = 1,
    GRM_type::String = ["simple", "ploidy-aware"][1],
    standardise::Bool = true,
    verbose::Bool = false,
)::Tuple{Matrix{Float64},Vector{Float64},Matrix{Float64},Fit}
    # genomes = GBCore.simulategenomes(); ploidy = 4; genomes.allele_frequencies = round.(genomes.allele_frequencies .* ploidy) ./ ploidy
    # proportion_of_variance = zeros(9, 1); proportion_of_variance[1, 1] = 0.5
    # trials, effects = GBCore.simulatetrials(genomes=genomes, n_years=1, n_seasons=1, n_harvests=1, n_sites=1, n_replications=1, f_add_dom_epi=[0.05 0.00 0.00;], proportion_of_variance = proportion_of_variance, verbose=false);
    # phenomes = extractphenomes(trials)
    # idx_entries = nothing; idx_loci_alleles = nothing; idx_trait = 1; GRM_type = "ploidy-aware"; verbose = true
    # Check arguments while extracting the allele frequencies
    G, y, entries, populations, loci_alleles = extractxyetc(
        genomes,
        phenomes,
        idx_entries = idx_entries,
        idx_loci_alleles = idx_loci_alleles,
        idx_trait = idx_trait,
        add_intercept = false,
    )
    if sum(["simple", "ploidy-aware"] .== GRM_type) == 0
        throw(
            ArgumentError(
                "Unrecognised `GRM_type`. Please select from:\n\t‣ " * join(["simple", "ploidy-aware"], "\n\t‣ "),
            ),
        )
    end
    # Standardise G and y and remove fixed loci-alleles
    if var(y) < eps(Float64)
        throw(ArgumentError("No variance in the trait: " * phenomes.traits[idx_trait] * "."))
    end
    v = std(G, dims = 1)[1, :]
    idx_cols = findall((v .> eps(Float64)) .&& .!ismissing.(v) .&& .!isnan.(v) .&& .!isinf.(v))
    G = G[:, idx_cols]
    loci_alleles = loci_alleles[idx_cols]
    # Extract the GRM to correct for population structure
    GRM = if GRM_type == "ploidy-aware"
        # Infer ploidy level
        ploidy = Int(round(1 / minimum(G[G.!=0.0])))
        grmploidyaware(genomes, ploidy = ploidy)
    else
        # Simple GRM
        grmsimple(genomes)
    end
    if standardise
        y = (y .- mean(y)) ./ std(y)
        G = (G .- mean(G, dims = 1)) ./ v[idx_cols]'
        GRM = (GRM .- mean(GRM, dims = 1)) ./ std(GRM, dims = 1)
    end
    # Instantiate output Fit struct
    n, l = size(G)
    fit = Fit(n = n, l = l)
    fit.model = ""
    fit.trait = phenomes.traits[idx_trait]
    fit.b_hat_labels = loci_alleles
    fit.entries = entries
    fit.populations = populations
    fit.metrics = Dict("" => 0.0)
    (G, y, GRM, fit)
end

"""
    gwasols(
        genomes::Genomes,
        phenomes::Phenomes;
        idx_entries::Union{Nothing,Vector{Int64}} = nothing,
        idx_loci_alleles::Union{Nothing,Vector{Int64}} = nothing,
        idx_trait::Int64 = 1,
        GRM_type::String = ["simple", "ploidy-aware"][1],
        verbose::Bool = false,
    )::Fit

Genome-association analysis via ordinary least squares using a genetic relationship matrix covariate to account for population structure.

# Examples
```jldoctest; setup = :(using GBCore, GBModel, LinearAlgebra)
julia> genomes = GBCore.simulategenomes(verbose=false);

julia> ploidy = 4;

julia> genomes.allele_frequencies = round.(genomes.allele_frequencies .* ploidy) ./ ploidy;

julia> proportion_of_variance = zeros(9, 1); proportion_of_variance[1, 1] = 0.5;

julia> trials, effects = GBCore.simulatetrials(genomes=genomes, n_years=1, n_seasons=1, n_harvests=1, n_sites=1, n_replications=1, f_add_dom_epi=[0.05 0.00 0.00;], proportion_of_variance = proportion_of_variance, verbose=false);;

julia> phenomes = extractphenomes(trials);

julia> fit_1 = gwasols(genomes, phenomes, GRM_type="simple");

julia> fit_1.model
"GWAS_OLS"

julia> findall(fit_1.b_hat .== maximum(fit_1.b_hat))[1]
6828
```
"""
function gwasols(
    genomes::Genomes,
    phenomes::Phenomes;
    idx_entries::Union{Nothing,Vector{Int64}} = nothing,
    idx_loci_alleles::Union{Nothing,Vector{Int64}} = nothing,
    idx_trait::Int64 = 1,
    GRM_type::String = ["simple", "ploidy-aware"][1],
    verbose::Bool = false,
)::Fit
    # genomes = GBCore.simulategenomes(); ploidy = 4; genomes.allele_frequencies = round.(genomes.allele_frequencies .* ploidy) ./ ploidy
    # proportion_of_variance = zeros(9, 1); proportion_of_variance[1, 1] = 0.5
    # trials, effects = GBCore.simulatetrials(genomes=genomes, n_years=1, n_seasons=1, n_harvests=1, n_sites=1, n_replications=1, f_add_dom_epi=[0.05 0.00 0.00;], proportion_of_variance = proportion_of_variance, verbose=false);
    # phenomes = extractphenomes(trials)
    # idx_entries = nothing; idx_loci_alleles = nothing; idx_trait = 1; GRM_type = "ploidy-aware"; verbose = true
    # Check arguments while preparing the G, y, GRM, and Fit struct, vector and matrices
    G, y, GRM, fit = gwasprep(
        genomes,
        phenomes,
        idx_entries = idx_entries,
        idx_loci_alleles = idx_loci_alleles,
        idx_trait = idx_trait,
        GRM_type = GRM_type,
        standardise = true,
        verbose = false,
    )
    fit.model = "GWAS_OLS"
    # Iterative GWAS
    n, l = size(G)
    X = hcat(ones(n), GRM, G[:, 1])
    if verbose
        pb = ProgressMeter.Progress(l; desc = "GWAS via OLS using " * GRM_type * " GRM:")
    end
    for j = 1:l
        # j = 1
        X[:, end] = G[:, j]
        Vinv = pinv(X' * X)
        b = Vinv * X' * y
        fit.b_hat[j] = b[end] / sqrt(Vinv[end, end])
        if verbose
            ProgressMeter.next!(pb)
        end
    end
    if verbose
        ProgressMeter.finish!(pb)
        # Histogram of t-values
        UnicodePlots.histogram(fit.b_hat, title = "Distribution of t-values")
        # Manhattan plot
        tdist = Distributions.TDist(n - 1)
        pval = 1 .- cdf.(tdist, abs.(fit.b_hat))
        lod = -log10.(pval)
        threshold = -log10(0.05 / l)
        p1 = UnicodePlots.scatterplot(lod, title = "Manhattan plot", xlabel = "Loci-alleles", ylabel = "-log10(pval)")
        UnicodePlots.lineplot!(p1, [0, l], [threshold, threshold])
        @show p1
        # QQ plot
        lod_expected = reverse(-log10.(collect(range(0, 1, l))))
        p2 = UnicodePlots.scatterplot(sort(lod), lod_expected, xlabel = "Observed LOD", ylabel = "Expected LOD")
        UnicodePlots.lineplot!(p2, [0, lod_expected[end-1]], [0, lod_expected[end-1]])
        @show p2
    end
    # Output
    if !checkdims(fit)
        throw(ErrorException("Error performing GWAS via OLS using the " * GRM_type * " GRM."))
    end
    fit
end

# GWAS via LMM using the first PC of the GRM and an unstructure covariance matrix of the genotype effects
function gwaslmm(
    genomes::Genomes,
    phenomes::Phenomes;
    idx_entries::Union{Nothing,Vector{Int64}} = nothing,
    idx_loci_alleles::Union{Nothing,Vector{Int64}} = nothing,
    idx_trait::Int64 = 1,
    GRM_type::String = ["simple", "ploidy-aware"][1],
    verbose::Bool = false,
)::Fit
    # genomes = GBCore.simulategenomes(); ploidy = 4; genomes.allele_frequencies = round.(genomes.allele_frequencies .* ploidy) ./ ploidy
    # proportion_of_variance = zeros(9, 1); proportion_of_variance[1, 1] = 0.5
    # trials, effects = GBCore.simulatetrials(genomes=genomes, n_years=1, n_seasons=1, n_harvests=1, n_sites=1, n_replications=1, f_add_dom_epi=[0.05 0.00 0.00;], proportion_of_variance = proportion_of_variance, verbose=false);
    # phenomes = extractphenomes(trials)
    # idx_entries = nothing; idx_loci_alleles = nothing; idx_trait = 1; GRM_type = "ploidy-aware"; verbose = true
    # Check arguments while preparing the G, y, GRM, and Fit struct, vector and matrices
    G, y, GRM, fit = gwasprep(
        genomes,
        phenomes,
        idx_entries = idx_entries,
        idx_loci_alleles = idx_loci_alleles,
        idx_trait = idx_trait,
        GRM_type = GRM_type,
        standardise = true,
        verbose = false,
    )
    fit.model = "GWAS_LMM"
    # Iterative GWAS
    n, l = size(G)
    df = DataFrames.DataFrame(entries=fit.entries, y=y, x = G[:, 1])
    E = MultivariateStats.fit(PCA, GRM; maxoutdim = 1)
    df.PC1 = E.proj[:, 1]
    formula = string("y ~ 1 + PC1 + x + (1|entries)")
    if verbose
        pb = ProgressMeter.Progress(l; desc = "GWAS via LMM using the first PC of the" * GRM_type * " GRM:")
    end
    for j = 1:l
        # j = 1
        df.x = G[:, j]
        f = @eval(@string2formula $(formula))
        model = try
            MixedModel(f, df)
        catch
            continue
        end
        model.optsum.REML = true
        model.optsum.maxtime = 60
        try
            fit!(model, progress = false)
        catch
            try
                fit!(model, progress = false)
            catch
                continue
            end
        end
        model
        df_BLUEs = DataFrame(coeftable(model))
        fit.b_hat[j] = df_BLUEs.z[end]
        if verbose
            ProgressMeter.next!(pb)
        end
    end
    if verbose
        ProgressMeter.finish!(pb)
        # Histogram of t-values
        UnicodePlots.histogram(fit.b_hat, title = "Distribution of z-values")
        # Manhattan plot
        ndist = Distributions.Normal(0, 1)
        pval = 1 .- cdf.(ndist, abs.(fit.b_hat))
        lod = -log10.(pval)
        threshold = -log10(0.05 / l)
        p1 = UnicodePlots.scatterplot(lod, title = "Manhattan plot", xlabel = "Loci-alleles", ylabel = "-log10(pval)")
        UnicodePlots.lineplot!(p1, [0, l], [threshold, threshold])
        @show p1
        # QQ plot
        lod_expected = reverse(-log10.(collect(range(0, 1, l))))
        p2 = UnicodePlots.scatterplot(sort(lod), lod_expected, xlabel = "Observed LOD", ylabel = "Expected LOD")
        UnicodePlots.lineplot!(p2, [0, lod_expected[end-1]], [0, lod_expected[end-1]])
        @show p2
    end
    # Output
    if !checkdims(fit)
        throw(ErrorException("Error performing GWAS via LMM using the " * GRM_type * " GRM."))
    end
    fit
end






# REML log-likelihood function
# y = Xb + Zu + e; where Xb=fixed and Zu=random ~ N(0.0, GRMvg)
function loglikreml(θ::Vector{Float64}, data::Tuple{Vector{Float64}, Matrix{Float64}, Matrix{Float64}})::Float64
    # genomes = GBCore.simulategenomes(); ploidy = 4; genomes.allele_frequencies = round.(genomes.allele_frequencies .* ploidy) ./ ploidy
    # proportion_of_variance = zeros(9, 1); proportion_of_variance[1, 1] = 0.5
    # trials, effects = GBCore.simulatetrials(genomes=genomes, n_years=1, n_seasons=1, n_harvests=1, n_sites=1, n_replications=1, f_add_dom_epi=[0.05 0.00 0.00;], proportion_of_variance = proportion_of_variance, verbose=false);
    # phenomes = extractphenomes(trials)
    # G, y, GRM, _ = gwasprep(genomes, phenomes)
    # X = hcat(ones(length(y)), G[:, 1])
    # θ = [0.01, 0.02]
    # Data
    y = data[1]
    X = data[2]
    GRM = data[3]
    # Note that the incidence matrix random genotype effects, Z is I
    # Residual variance-covariance matrix (assuming homoscedasticity)
	σ²_e = θ[1]
	R = σ²_e * I
    # Variance-covariance matrix of the other random effects, i.e. individual genotype effects
	σ²_u = θ[2]
    D = σ²_u * GRM
    # Total variance, i.e. variance of y
	# Since Z = I, V = (Z * D * Z') + R simply becomes:
	V = D + R
	V_inv = pinv(V)
    # REML transformation of y, i.e. find P where E[Py] = 0.0
    P = V_inv - (V_inv * X * inv(X' * V_inv * X) * X' * V_inv)
    y_REML = P * y 
    # Log-likelihood
    loglik = try
        0.5 * log(det(V)) + (y' * y_REML) + log(det(X' * V_inv * X))
    catch
        Inf
    end
    loglik
end

function gwasreml(
    genomes::Genomes,
    phenomes::Phenomes;
    idx_entries::Union{Nothing,Vector{Int64}} = nothing,
    idx_loci_alleles::Union{Nothing,Vector{Int64}} = nothing,
    idx_trait::Int64 = 1,
    GRM_type::String = ["simple", "ploidy-aware"][1],
    verbose::Bool = false,
)::Fit
    # genomes = GBCore.simulategenomes(l=1_000, verbose=false); ploidy = 4; genomes.allele_frequencies = round.(genomes.allele_frequencies .* ploidy) ./ ploidy
    # proportion_of_variance = zeros(9, 1); proportion_of_variance[1, 1] = 0.5
    # trials, effects = GBCore.simulatetrials(genomes=genomes, n_years=1, n_seasons=1, n_harvests=1, n_sites=1, n_replications=1, f_add_dom_epi=[0.05 0.00 0.00;], proportion_of_variance = proportion_of_variance, verbose=false);
    # phenomes = extractphenomes(trials)
    # idx_entries = nothing; idx_loci_alleles = nothing; idx_trait = 1; GRM_type = "ploidy-aware"; verbose = true
    # Check arguments while preparing the G, y, GRM, and Fit struct, vector and matrices
    G, y, GRM, fit = gwasprep(
        genomes,
        phenomes,
        idx_entries = idx_entries,
        idx_loci_alleles = idx_loci_alleles,
        idx_trait = idx_trait,
        GRM_type = GRM_type,
        standardise = true,
        verbose = false,
    )
    fit.model = "GWAS_REML"
    # Iterative GWAS
    # Initialise the common optimisation function and the common initial parameters
    optimreml = OptimizationFunction(loglikreml, Optimization.AutoZygote())
    θ_init = [0.5, 0.5]
    n, l = size(G)
    X = hcat(ones(n), G[:,1])
    if verbose
        pb = ProgressMeter.Progress(l; desc = "GWAS via OLS using " * GRM_type * " GRM:")
    end
    for j = 1:l
        # j = 1
        X[:, 2] = G[:, j]
        # Define the optimisation problem where we set the limits of the error and genotype variances to be between 0 and 1 as all data are standard normalised
        prob = OptimizationProblem(optimreml, θ_init, (y, X, GRM), lb = [eps(Float64), eps(Float64)], ub = [1.0, 1.0])
        # Optimise, i.e. REML estimation (uses the BFGS optimiser with a larger (2x) than default absolute tolerance in the gradient (Default g_tol=1e-8) for faster convergence)
        sol = solve(prob, BFGS(), g_tol=1e-4)
        R = sol.u[1] * I
        D = sol.u[2] * GRM
        # Since Z = I, V = (Z * D * Z') + R simply becomes:
        V = D + R
        V_inv = pinv(V)
        b = pinv(X' * V_inv * X) * (X' * V_inv * y)
        σ²_b = inv(X' * V_inv * X)
        fit.b_hat[j] = b[end] / sqrt(σ²_b[end])
        if verbose
            ProgressMeter.next!(pb)
        end
    end
    if verbose
        ProgressMeter.finish!(pb)
        # Histogram of t-values
        UnicodePlots.histogram(fit.b_hat, title = "Distribution of z-values")
        # Manhattan plot
        ndist = Distributions.Normal(0, 1)
        pval = 1 .- cdf.(ndist, abs.(fit.b_hat))
        lod = -log10.(pval)
        threshold = -log10(0.05 / l)
        p1 = UnicodePlots.scatterplot(lod, title = "Manhattan plot", xlabel = "Loci-alleles", ylabel = "-log10(pval)")
        UnicodePlots.lineplot!(p1, [0, l], [threshold, threshold])
        @show p1
        # QQ plot
        lod_expected = reverse(-log10.(collect(range(0, 1, l))))
        p2 = UnicodePlots.scatterplot(sort(lod), lod_expected, xlabel = "Observed LOD", ylabel = "Expected LOD")
        UnicodePlots.lineplot!(p2, [0, lod_expected[end-1]], [0, lod_expected[end-1]])
        @show p2
    end
    # Output
    if !checkdims(fit)
        throw(ErrorException("Error performing GWAS via REML using the " * GRM_type * " GRM."))
    end
    fit
end
