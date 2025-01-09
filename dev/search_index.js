var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = GBModels","category":"page"},{"location":"#GBModels","page":"Home","title":"GBModels","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for GBModels.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [GBModels]","category":"page"},{"location":"#GBModels.PriorBayesB","page":"Home","title":"GBModels.PriorBayesB","text":"Prior distribution for Bayes B model\n\n\n\n\n\n","category":"type"},{"location":"#Base.maximum-Tuple{GBModels.PriorBayesB}","page":"Home","title":"Base.maximum","text":"Maximum value of the PriorBayesB distribution\n\n\n\n\n\n","category":"method"},{"location":"#Base.minimum-Tuple{GBModels.PriorBayesB}","page":"Home","title":"Base.minimum","text":"Minimum value of the PriorBayesB distribution\n\n\n\n\n\n","category":"method"},{"location":"#Base.rand-Tuple{Random.AbstractRNG, GBModels.PriorBayesB}","page":"Home","title":"Base.rand","text":"Sampling method for PriorBayesB\n\nExamples\n\nd = PriorBayesB(0.1, 1.0)\nrand(d)\n\n\n\n\n\n","category":"method"},{"location":"#Distributions.logpdf-Tuple{GBModels.PriorBayesB, Real}","page":"Home","title":"Distributions.logpdf","text":"log(pdf) of PriorBayesB\n\nExamples\n\nd = PriorBayesB(0.1, 1.0)\nlogpdf.(d, [-1.0, 0.0, 1.0])\n\n\n\n\n\n","category":"method"},{"location":"#GBModels.bayesRR-Tuple{}","page":"Home","title":"GBModels.bayesRR","text":"bayesRR(genomes::Genomes, phenomes::Phenomes, trait_idx::Int64=1, verbose::Bool=false)::Fit\n\nFit a Bayesian ridge regression model\n\nExamples\n\njulia> genomes = GBCore.simulategenomes(n=10, l=1_000, verbose=false);\n\njulia> trials, _ = GBCore.simulatetrials(genomes=genomes, n_years=1, n_seasons=1, n_harvests=1, n_sites=1, n_replications=3, f_add_dom_epi=[0.1 0.01 0.01;], verbose=false);\n\njulia> tebv = GBCore.analyse(trials, max_levels=5, max_time_per_model=2, verbose=false);\n\njulia> phenomes = tebv.phenomes[1];\n\njulia> fit = Suppressor.@suppress bayesRR(genomes=genomes, phenomes=phenomes);\n\njulia> fit.metrics[\"cor\"] > 0.5\ntrue\n\n\n\n\n\n","category":"method"},{"location":"#GBModels.lasso-Tuple{}","page":"Home","title":"GBModels.lasso","text":"lasso(genomes::Genomes, phenomes::Phenomes, trait_idx::Int64=1, verbose::Bool=false)::Fit\n\nFit a LASSO (least absolute shrinkage and selection operator; L1) regression model\n\nExamples\n\njulia> genomes = GBCore.simulategenomes(n=10, l=100, verbose=false);\n\njulia> trials, _ = GBCore.simulatetrials(genomes=genomes, n_years=1, n_seasons=1, n_harvests=1, n_sites=1, n_replications=3, f_add_dom_epi=[0.1 0.01 0.01;], verbose=false);\n\njulia> phenomes = Phenomes(n=10, t=1);\n\njulia> phenomes.entries = trials.entries[1:10]; phenomes.populations = trials.populations[1:10]; phenomes.traits = trials.traits; phenomes.phenotypes = trials.phenotypes[1:10, :];\n\njulia> fit = lasso(genomes=genomes, phenomes=phenomes);\n\njulia> fit.model == \"lasso\"\ntrue\n\njulia> fit.metrics[\"cor\"] > 0.0\ntrue\n\n\n\n\n\n","category":"method"},{"location":"#GBModels.ols-Tuple{}","page":"Home","title":"GBModels.ols","text":"ols(genomes::Genomes, phenomes::Phenomes, trait_idx::Int64=1, verbose::Bool=false)::Fit\n\nFit an ordinary least squares model\n\nExamples\n\njulia> genomes = GBCore.simulategenomes(n=10, l=100, verbose=false);\n\njulia> trials, _ = GBCore.simulatetrials(genomes=genomes, n_years=1, n_seasons=1, n_harvests=1, n_sites=1, n_replications=3, f_add_dom_epi=[0.1 0.01 0.01;], verbose=false);\n\njulia> phenomes = Phenomes(n=10, t=1);\n\njulia> phenomes.entries = trials.entries[1:10]; phenomes.populations = trials.populations[1:10]; phenomes.traits = trials.traits; phenomes.phenotypes = trials.phenotypes[1:10, :];\n\njulia> fit = ols(genomes=genomes, phenomes=phenomes);\n\njulia> fit.model == \"ols\"\ntrue\n\njulia> fit.metrics[\"cor\"] > 0.50\ntrue\n\n\n\n\n\n","category":"method"},{"location":"#GBModels.ridge-Tuple{}","page":"Home","title":"GBModels.ridge","text":"ridge(genomes::Genomes, phenomes::Phenomes, trait_idx::Int64=1, verbose::Bool=false)::Fit\n\nFit a ridge (L2) regression model\n\nExamples\n\njulia> genomes = GBCore.simulategenomes(n=10, l=100, verbose=false);\n\njulia> trials, _ = GBCore.simulatetrials(genomes=genomes, n_years=1, n_seasons=1, n_harvests=1, n_sites=1, n_replications=3, f_add_dom_epi=[0.1 0.01 0.01;], verbose=false);\n\njulia> phenomes = Phenomes(n=10, t=1);\n\njulia> phenomes.entries = trials.entries[1:10]; phenomes.populations = trials.populations[1:10]; phenomes.traits = trials.traits; phenomes.phenotypes = trials.phenotypes[1:10, :];\n\njulia> fit = ridge(genomes=genomes, phenomes=phenomes);\n\njulia> fit.model == \"ridge\"\ntrue\n\njulia> fit.metrics[\"cor\"] > 0.50\ntrue\n\n\n\n\n\n","category":"method"},{"location":"#GBModels.turing_bayesA-Tuple{Any, Any}","page":"Home","title":"GBModels.turing_bayesA","text":"Turing specification of Bayes A linear regression\n\nExample usage\n\n# Simulate data\ngenomes = GBCore.simulategenomes(n=10, l=100)\ntrials, _ = GBCore.simulatetrials(genomes=genomes, n_years=1, n_seasons=1, n_harvests=1, n_sites=1, n_replications=3, f_add_dom_epi=[0.9 0.01 0.00;])\ntebv = GBCore.analyse(trials, max_levels = 15, max_time_per_model = 2)\nphenomes = tebv.phenomes[1]\n# Extract genotype and phenotype data\nG::Matrix{Float64} = genomes.allele_frequencies\ny::Vector{Float64} = phenomes.phenotypes[:, trait_idx]\n# Regress for just 200 iterations for demonstration purposes only. Use way way more iterations, e.g. 10,000.\nrng::TaskLocalRNG = Random.seed!(123)\nmodel = turing_bayesA(G, y)\n@time chain = Turing.sample(rng, model, NUTS(), 200, progress=true)\n# Use the mean paramter values after 150 burn-in iterations\nparams = Turing.get_params(chain[150:end, :, :])\nb_hat = vcat(mean(params.intercept), mean(stack(params.coefficients, dims=1)[:, :, 1], dims=2)[:,1])\n# Assess prediction accuracy\ny_pred::Vector{Float64} = hcat(ones(size(G,1)), G) * b_hat\nperformance::Dict{String, Float64} = metrics(y, y_pred)\n\n\n\n\n\n","category":"method"},{"location":"#GBModels.turing_bayesB-Tuple{Any, Any}","page":"Home","title":"GBModels.turing_bayesB","text":"Turing specification of Bayes B linear regression\n\nExample usage\n\n# Simulate data\ngenomes = GBCore.simulategenomes(n=10, l=100)\ntrials, _ = GBCore.simulatetrials(genomes=genomes, n_years=1, n_seasons=1, n_harvests=1, n_sites=1, n_replications=3, f_add_dom_epi=[0.9 0.01 0.00;])\ntebv = GBCore.analyse(trials, max_levels = 15, max_time_per_model = 2)\nphenomes = tebv.phenomes[1]\n# Extract genotype and phenotype data\nG::Matrix{Float64} = genomes.allele_frequencies\ny::Vector{Float64} = phenomes.phenotypes[:, 1]\n# Regress for just 200 iterations for demonstration purposes only. Use way way more iterations, e.g. 10,000.\nrng::TaskLocalRNG = Random.seed!(123)\nmodel = turing_bayesB(G, y)\n@time chain = Turing.sample(rng, model, NUTS(), 200, progress=true)\n# Use the mean paramter values after 150 burn-in iterations\nparams = Turing.get_params(chain[150:end, :, :])\n\nUnicodePlots.scatterplot(stack(params.intercept)[:,1])\nUnicodePlots.scatterplot(stack(params.coefficients, dims=1)[1,:,1])\nUnicodePlots.scatterplot(stack(params.coefficients, dims=1)[2,:,1])\nUnicodePlots.scatterplot(stack(params.coefficients, dims=1)[3,:,1])\n\nb_hat = vcat(mean(params.intercept), mean(stack(params.coefficients, dims=1)[:, :, 1], dims=2)[:,1])\n# Assess prediction accuracy\ny_pred::Vector{Float64} = hcat(ones(size(G,1)), G) * b_hat\nperformance::Dict{String, Float64} = metrics(y, y_pred)\n\n\n\n\n\n","category":"method"},{"location":"#GBModels.turing_bayesLASSO-Tuple{Any, Any}","page":"Home","title":"GBModels.turing_bayesLASSO","text":"Turing specification of Bayesian LASSO regression\n\nExample usage\n\n# Simulate data\ngenomes = GBCore.simulategenomes(n=10, l=100)\ntrials, _ = GBCore.simulatetrials(genomes=genomes, n_years=1, n_seasons=1, n_harvests=1, n_sites=1, n_replications=3, f_add_dom_epi=[0.9 0.01 0.00;])\ntebv = GBCore.analyse(trials, max_levels = 15, max_time_per_model = 2)\nphenomes = tebv.phenomes[1]\n# Extract genotype and phenotype data\nG::Matrix{Float64} = genomes.allele_frequencies\ny::Vector{Float64} = phenomes.phenotypes[:, trait_idx]\n# Regress for just 200 iterations for demonstration purposes only. Use way way more iterations, e.g. 10,000.\nrng::TaskLocalRNG = Random.seed!(123)\nmodel = turing_bayesLASSO(G, y)\n@time chain = Turing.sample(rng, model, NUTS(), 200, progress=true)\n# Use the mean paramter values after 150 burn-in iterations\nparams = Turing.get_params(chain[150:end, :, :])\nb_hat = vcat(mean(params.intercept), mean(stack(params.coefficients, dims=1)[:, :, 1], dims=2)[:,1])\n# Assess prediction accuracy\ny_pred::Vector{Float64} = hcat(ones(size(G,1)), G) * b_hat\nperformance::Dict{String, Float64} = metrics(y, y_pred)\n\n\n\n\n\n","category":"method"},{"location":"#GBModels.turing_bayesRR-Tuple{Any, Any}","page":"Home","title":"GBModels.turing_bayesRR","text":"Turing specification of Bayesian ridge regression\n\nExample usage\n\n# Simulate data\ngenomes = GBCore.simulategenomes(n=10, l=100)\ntrials, _ = GBCore.simulatetrials(genomes=genomes, n_years=1, n_seasons=1, n_harvests=1, n_sites=1, n_replications=3, f_add_dom_epi=[0.9 0.01 0.00;])\ntebv = GBCore.analyse(trials, max_levels = 15, max_time_per_model = 2)\nphenomes = tebv.phenomes[1]\n# Extract genotype and phenotype data\nG::Matrix{Float64} = genomes.allele_frequencies\ny::Vector{Float64} = phenomes.phenotypes[:, 1]\n# Regress for just 200 iterations for demonstration purposes only. Use way way more iterations, e.g. 10,000.\nrng::TaskLocalRNG = Random.seed!(123)\nmodel = turing_bayesRR(G, y)\n# @time chain = Turing.sample(rng, model, NUTS(adtype=AutoReverseDiff(true)), 200, progress=true)\n@time chain = Turing.sample(rng, model, NUTS(100, 0.5, max_depth=10, Δ_max=1000.0, init_ϵ=0.2), 200, progress=true)\n# Use the mean paramter values after 150 burn-in iterations\nparams = Turing.get_params(chain[150:end, :, :])\nb_hat = vcat(mean(params.intercept), mean(stack(params.coefficients, dims=1)[:, :, 1], dims=2)[:,1])\n# Assess prediction accuracy\ny_pred::Vector{Float64} = hcat(ones(size(G,1)), G) * b_hat\nperformance::Dict{String, Float64} = metrics(y, y_pred)\n\n\n\n\n\n","category":"method"}]
}
