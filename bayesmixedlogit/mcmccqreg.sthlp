{smcl}
{* 29May2013}{...}
{cmd:help mcmccqreg}{right: ({browse "http://www.stata-journal.com/article.html?article=st0354":SJ14-3: st0354})}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{cmd:mcmccqreg} {hline 2}}Powell's MCMC-simulated censored quantile regression{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:mcmccqreg}
{depvar}
[{indepvars}] {ifin}
[{cmd:,} {opth censor:var(varname)}
 {opt tau(#)}
 {opt draw:s(#)}
 {opt burn(#)}
 {opt thin(#)}
 {opt arate(#)}
 {opt sampler(string)}
 {opt dampparm(#)}
 {opt from(rowvector)}
 {opt fromv:ariance(matrix)}
 {opt jumble}
 {opt noisy}
 {opt saving(filename)}
 {opt replace}
 {cmd:append}
 {opt median}]


{title:Description}

{pstd}
{cmd:mcmccqreg} can be used to fit Powell's (1984, 1986) censored
median regression model or, in more general terms, censored quantile
models by using adaptive Markov chain Monte Carlo (MCMC) sampling from the
conditional parameter distribution.  The basis for the method is
discussed in detail in Chernozhukov and Hong (2003), and an
intuitive, low-level sketch is given in Baker (2014).

{pstd}
{cmd:mcmccqreg} allows construction of what Chernozhukov and Hong (2003)
call a Laplacian estimator of the censored quantile regression
model.  The joint distribution of the parameters is simulated using
adaptive MCMC methods through application of
the mata package {cmd: amcmc()} ({helpb mf_amcmc:mf_amcmc} or 
{helpb mata amcmc():mata amcmc()} from within the Mata system, if
installed).  {cmd:mcmccqreg} produces parameter estimates, but these
"estimates" are in fact summary statistics from draws from the
distribution.  Detailed analysis of the draws remains in the hands of
the user.

{pstd}
{cmd:mcmccqreg} is invoked in the usual way -- the command name,
followed by the dependent variable, followed by the independent
variables.  No further information need be specified, but users will usually
want to change default settings for the adaptive
MCMC draws -- for example, information pertaining to the number
of draws, how frequently draws are accepted, and which draws are to be
retained upon completion of the algorithm.  Default values are
described below.


{title:Options}

{phang}
{opt censorvar(varname)} specifies the name of the left-censoring
variable.  The censoring variable can vary by observation.  If this option
is not specified, it is assumed that the censoring point for all
observations is zero.

{phang}
{opt tau(#)} specifies the quantile of interest and should be between
zero and one.  In the event that the user chooses a value of {opt tau(#)}
that is too low, in the sense that all observations at this quantile are
censored, a cautioning message is produced, but drawing nonetheless
proceeds.  The mnemonic {cmd:tau()} is used in analogy to the ancillary
argument of the check function used to define the objective function in
Chernozhukov and Hong (2003).

{phang}
{opt draws(#)} specifies the number of draws that are to be taken from
the joint parameter distribution implied by the model.  The default is
{cmd:draws(1000)}.

{phang}
{opt burn(#)} specifies the length of the burn-in period; the first {it:#} draws are discarded upon completion 
of the algorithm and before further results
are computed.  The default is {cmd:burn(0)}.

{phang}
{opt thin(#)} specifies that only every {it:#}th draw is to be retained, so
if {cmd:thin(3)} is specified, only every third draw is retained.  This
option can be used to ease autocorrelation in the resulting draws, as
can the option {opt jumble}, which randomly mixes draws.  Both options
may be applied.

{phang}
{opt arate(#)} specifies the desired acceptance rate of the adaptive
MCMC drawing.  It should be a number between zero and one, but it is
typically in the range 0.234 to 0.4 -- see Baker (2014) for details.  The
default is {cmd:arate(.234)}.

{phang}
{opt sampler(string)} specifies the type of sampler used.  It may be set
to either {cmd:global} or {cmd:mwg}.  The default is
{cmd:sampler(global)}, which means that proposed draws are drawn all at
once; if {cmd:mwg} -- an acronym for "Metropolis within Gibbs" -- is
instead chosen, each random parameter is drawn separately as an
independent step conditional on other random parameters in a nested
Gibbs step.  The default is {cmd:sampler(global)}, but {cmd:mwg} might
be useful when initial values are poorly scaled.  These options are described in greater detail in Baker
(2014).

{phang}
{opt dampparm(#)} is a parameter that controls how aggressively the
proposal distribution is adapted as the adaptive MCMC drawing continues.
If set close to one, adaptation is aggressive in its early phases in
trying to achieve the acceptance rate specified in {opt arate(#)}.  If
set closer to zero, adaptation is more gradual.

{phang}
{opt from(rowvector)} specifies a row vector of starting values for
parameters in order.  If these are not specified, starting
values are obtained via linear regression (see {manhelp regress R}).

{phang}
{opt fromvariance(matrix)} specifies a covariance matrix for the draws.
{opt from(string)} can be specified without this, in which case a
covariance matrix scaled to initial regression parameters is used.

{phang}
{cmd:jumble} specifies randomly mix draws.

{phang}
{opt noisy} specifies that a dot be produced every time a complete pass
through the algorithm is finished.  After 50 iterations, a function
value ln_fc(p) will be produced, which gives the joint log of the
value of the posterior choice probabilities evaluated at the latest
parameters.  While ln_fc(p) is not an objective function per se, 
drift in the value of this function indicates that the algorithm
has not yet converged or that there are other problems.

{phang}
{opt saving(filename)} specifies a location to store the draws from the
distribution.  The file will contain only the draws after any burn-in
period or thinning of values is applied.  

{phang}
{opt replace} specifies that an existing file is to be overwritten.

{phang}
{opt append} specifies that an existing file is to be appended, which
might be useful if the user wishes to combine results from multiple runs
from different starting points.

{phang}
{opt median} specifies that the criterion function described in Powell
(1984) be used instead of the more general form described in
Chernozhukov and Hong (2003).  Results are the same as if {cmd:tau(.5)}
had been specified and the more complex objective function had been
multiplied by a factor of two.


{title:Examples}

{pstd}
Estimating a censored quantile model at the 60% quantile.  The censoring
value defaults to 0, 20,000 draws are taken, the first 999 draws are
dropped, results are jumbled, and every 5th draw is kept.  The first
1,000 draws are dropped, and then every fifth draw is retained.  Draws are
saved as {cmd:draws.dta}.{p_end}
{phang2}
{cmd:. webuse laborsub}{p_end}
{phang2}
{cmd:. mcmccqreg whrs kl6 k618, tau(.6) saving(draws) replace thin(5) burn(999) draws(20000) jumble}

{pstd}
Same as above, using a Metropolis-within-Gibbs sampler with an explicit
censoring variable:{p_end}
{phang2}
{cmd:. webuse laborsub, clear}{p_end}
{phang2}{cmd:. generate c=0}{p_end}
{phang2}{cmd:. mcmccqreg whrs kl6 k618, tau(.6) sampler("mwg") censorvar(c) saving(draws) replace thin(5) burn(999) draws(20000) jumble}
	 
{pstd}
Powell's (1984) median estimator:{p_end}
{phang2}
{cmd:. webuse laborsub, clear}{p_end}
{phang2}
{cmd:. mcmccqreg whrs kl6 k618, median sampler("mwg") censorvar(c) saving(draws) replace thin(5) burn(999) draws(20000) jumble}

{pstd}
As a last example, it is sometimes useful to estimate a preliminary
model by using Metropolis-within-Gibbs sampling, which can often find the
right range for parameters from mediocre starting values,
and then by using a global sampler, which can be much faster.  These
general ideas are sketched in Baker (2014).{p_end}
{phang2}
{cmd:. webuse laborsub, clear}{p_end}
{phang2}
{cmd:. quietly mcmccqreg whrs kl6 k618, median sampler("mwg") saving(draws) replace thin(5) burn(999) draws(20000) jumble}{p_end}
{phang2}{cmd:. mat beta=e(b)}{p_end}
{phang2}{cmd:. mat V=e(V)}{p_end}
{phang2}{cmd:. mcmccqreg whrs kl6 k618, median from(beta) fromvariance(V) sampler("global") saving(draws) replace thin(5) burn(999) draws(20000) jumble}
	 

{title:Stored results}

{pstd}
{cmd:mcmccqreg} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(df_r)}}residual degrees of freedom{p_end}
{synopt:{cmd:e(draws)}}number of draws{p_end}
{synopt:{cmd:e(burn)}}burn-in observations{p_end}
{synopt:{cmd:e(thin)}}thinning parameter{p_end}
{synopt:{cmd:e(damper)}}damping parameter{p_end}
{synopt:{cmd:e(opt_arate)}}desired acceptance rate{p_end}
{synopt:{cmd:e(f_mean)}}average value of objective function (for retained draws){p_end}
{synopt:{cmd:e(f_max)}}maximum objective function value{p_end}
{synopt:{cmd:e(f_min)}}minimum objective function value{p_end}
{synopt:{cmd:e(draws_retained)}}draws retained after burn-in and thinning{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:mcmccqreg}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(indepvars)}}independent variables{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(saving)}}file containing results{p_end}
{synopt:{cmd:e(sampler)}}sampler type{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}mean parameter values{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of parameters{p_end}
{synopt:{cmd:e(V_init)}}initial variance-covariance matrix of random parameters{p_end}
{synopt:{cmd:e(b_init)}}initial mean vector of random parameters{p_end}
{synopt:{cmd:e(arates)}}row vector of acceptance rates of fixed parameters{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:Comments}

{pstd}
The basic algorithms used in drawing are described in detail in
Baker (2014).  The user might gain a fuller understanding of the options
{opt arate}, {opt damper}, {opt draws}, {opt burn}, and other options
controlling adaptation of the proposal distribution by reading 
this document.

{pstd}
{cmd:mcmccqreg} requires that the package of Mata functions {cmd:amcmc()} and
Ben Jann's {cmd:moremata} set of extended Mata functions be installed.

{pstd}
Caution -- While summary statistics of the results of a
drawing are presented in the usual Stata format, {cmd:mcmccqreg}
provides no guidance as to how one should actually go about selecting
the number of draws, how one should process the draws, how one should monitor
convergence of the algorithm, or how one should present and interpret results.
Even though the methods are technically not Bayesian, one would do well
to consult a good source on Bayesian methods such as Gelman et al. (2009) concerning the practical aspects of processing results from
draws.  Of course, Stata provides a wealth of tools for summarizing and
plotting the results of a drawing.


{title:References}

{phang}
Baker, M. J. 2014.
{browse "http://www.stata-journal.com/article.html?article=st0354":Adaptive Markov chain Monte Carlo sampling and estimation in Mata}.
{it:Stata Journal} 14: 623-661.

{phang}
Chernozhukov, V., and H. Hong. 2003. An MCMC approach to classical
estimation. {it:Journal of Econometrics} 115: 293-346.

{phang}
Gelman, A., J. B. Carlin, H. S. Stern, and D. B. Rubin. 2009.
{it:Bayesian Data Analysis}. 2nd ed. Boca Raton, FL: Chapman & Hall/CRC. 

{phang}
Powell, J. L. 1984. Least absolute deviations estimation for the
censored regression model.  {it:Journal of Econometrics} 25: 303-325.

{phang}
------. 1986. Censored regression quantiles. {it:Journal of Econometrics} 32:
143-155.


{title:Author}

{pstd}Matthew J. Baker{p_end}
{pstd}Hunter College and the Graduate Center, CUNY{p_end}
{pstd}New York, NY{p_end}
{pstd}matthew.baker@hunter.cuny.edu{p_end}

{pstd}
Comments, criticisms, and suggestions for improvement are welcome.{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 14, number 3: {browse "http://www.stata-journal.com/article.html?article=st0354":st0354}

{p 5 14 2}Manual:  {manlink R qreg}, {manlink R diagnostic plots} 

{p 7 14 2}Help:  {helpb mf_amcmc:amcmc()}, {helpb moremata}
(if installed){p_end}
