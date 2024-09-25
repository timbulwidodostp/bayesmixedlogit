{smcl}
{* 19feb2013}{...}
{cmd:help amcmc()}{right: ({browse "http://www.stata-journal.com/article.html?article=st0354":SJ14-3: st0354})}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi:amcmc()} {hline 2}}Mata functions and structures for adaptive Markov chain Monte Carlo sampling from distributions{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 40 2}
{it:real matrix}{bind:        }
{cmd:amcmc(}{it:alginfo}{cmd:,} 
{it:lnf}{cmd:,}    
{it:xinit}{cmd:,} 
{it:Vinit}{cmd:,} 
{it:draws}{cmd:,}
{it:burn}{cmd:,} 
{it:damper}{cmd:,} 
{it:aopt}{cmd:,}
{it:arate}{cmd:,}
{it:vals}{cmd:,}
{it:lambda}{cmd:,}
{it:blocks} [{cmd:,}
{it:M}{cmd:,}
{it:noisy}]{cmd:)}

{p 4 4 2}
where inputs are 

{p2colset 9 33 35 2}{...}
{p2col 7 33 35 2: {it:alginfo}:  {it:string rowvector}}{p_end}
{p2col 11 33 35 2: {it:lnf}:  {it:pointer (real scalar function) scalar lnf}}{p_end}
{p2col 9 33 35 2: {it:xinit}:  {it:real rowvector}}{p_end}
{p2col 9 33 35 2: {it:Vinit}:  {it:real matrix}}{p_end}
{p2col 9 33 35 2: {it:draws}:  {it:real scalar}}{p_end}
{p2col 10 33 35 2: {it:burn}:  {it:real scalar}}{p_end}
{p2col 9 33 35 2: {it:delta}:  {it:real scalar}}{p_end}
{p2col 10 33 35 2: {it:aopt}:  {it:real scalar}}{p_end}
{p2col 9 33 35 2: {it:arate}:  {it:transmorphic}}{p_end}
{p2col 10 33 35 2: {it:vals}:  {it:transmorphic}}{p_end}
{p2col 8 33 35 2: {it:lambda}:  {it:transmorphic}}{p_end}
{p2col 8 33 35 2: {it:blocks}:  {it:real matrix}}{p_end}
{p2col 13 33 35 2: {it:M}:  {it:transmorphic}}{p_end}
{p2col 9 33 35 2: {it:noisy}:  {it:string scalar}}{p_end}


{title:Introduction}

{p 4 4 2}
{cmd:amcmc()} refers to a collection of Mata tools for performing
adaptive Markov chain Monte Carlo (MCMC) sampling from distributions.
Algorithms are described in Baker (2014) and rely on MCMC sampling using
a continually adapted multivariate normal proposal distribution.  With
the commands and functions, one can perform adaptive MCMC either by using
the function {cmd:amcmc()} or by setting up an adaptive MCMC problem
with the suite of functions {cmd:amcmc_}{it:*}{cmd:()}.  Setting up a
structured object for performing {cmd:amcmc_}{it:*}{cmd:()} is discussed
under the heading 
{it:{help mf_amcmc##amcmc_struct:Using amcmc_*() functions}}.


{title:Description}

{p 4 4 2}
{cmd:amcmc()} performs adaptive MCMC sampling by using a multivariate
normal proposal distribution.  MCMC methods work through
acceptance-rejection sampling; an MCMC algorithm with adaptation is
continually tuned as the algorithm runs so as to achieve a targeted
acceptance rate.  The degree of tuning recedes as the algorithm proceeds
so as to achieve a stationary proposal distribution.  For a
full description of the Mata implementation, see Baker (2014), who
follows the more detailed descriptions of adaptive MCMC algorithms in
Andrieu and Thoms (2008).  The draws from the target distribution are
returned as a matrix, with each row representing a draw.

{p 4 4 2} 
Discussion of {it:alginfo}, the first argument, is postponed until other arguments have been discussed.

{p 4 4 2}
The pointer function {it:lnf} specifies the target distribution from which the
user wishes to draw.  The function describing the target distribution must be
written in log form so that the (often scalar) log-value of the distribution
is returned by the function.

{p 4 4 2}
The initial values used in drawing are specified in the argument
{it:xinit}, and an initial covariance matrix for the proposal
distribution is specified in {it:Vinit}.  {it:draws} tells the algorithm
how many draws to perform, while {it:burn} instructs {cmd:amcmc()} to
drop the first {it:burn} draws as a burn-in period; accordingly,
{cmd:amcmc()} returns only the last {it:draws-burn} draws from the
distribution {it:lnf}.

{p 4 4 2}
{it:delta} is an adjustment parameter that tells the algorithm how
aggressively or conservatively to adapt the proposal distribution to achieve
the acceptance rate specified by the user in {it:aopt}.  {it:delta} should lie
between zero and one, with values closer to zero corresponding to slower
adaptation and values closer to one corresponding to faster adaptation to the
proposal history.  {it:aopt} is the acceptance rate desired by the user. It
typically lies in the range 0.2 to 0.44 because optimal acceptance rates for
univariate problems are around 0.44, while optimal rates for large-dimensional
problems are around 0.234.  See Andrieu and Thoms (2008) for further
discussion.

{p 4 4 2}
{it:arate}, {it:vals}, and {it:lambda} are arguments that can be
initialized as missing or as anything else by the user because they are
overwritten.  {it:arate} is overwritten with acceptance rates of the
algorithm.  {it:vals} is overwritten with the values of the target
distribution corresponding to each draw.  {it:lambda} is a set of scaling
parameters that is tuned as the algorithm proceeds.  These parameters
scale the proposal covariance matrix to direct the algorithm toward the
desired acceptance rate, with aggressiveness captured by {it:delta}.  In
global, all-at-once sampling, {it:lambda} is returned as a scalar.  If
Metropolis-within-Gibbs sampling is specified (so that each component of
the target distribution is drawn sequentially), {it:lambda} returns a
vector of lambda values equal in dimension to the target distribution.
Finally, if block sampling is specified, {it:lambda} returns a vector of
lambda values equal in dimension to the number of blocks.  For further
description of how different types are specified, see the description of
{it:alginfo} below and the examples.  In block sampling or in
Metropolis-within-Gibbs sampling, the dimension of {it:arate} matches
that of the sampler.

{p 4 4 2}
{it:blocks} is a matrix of zeros and ones that describes how the
algorithm is to proceed if the user wishes to draw from the target
distribution not all-at-once but in a sequence of (Gibbs) steps.  Values
that are to be drawn together are marked by rows of {it:blocks}
containing ones and zeros elsewhere.

{p 4 4 2}
{it:M} can be used to relay additional information to the algorithm.  If a
user has assembled a model statement using {helpb mf_moptimize:moptimize()} or
{helpb mf_optimize:optimize()}, this model can be passed to {cmd:amcmc()}
using {it:M}.  The idea is to prevent the user from needing to respecify things such
as missing values, arguments of the function embedded in the model, etc., when
switching or using {cmd:amcmc()}.  If a user does not have a model but
has a function requiring additional arguments, {it:M} can be a pointer
holding additional arguments of the target distribution; up to 10
additional arguments can be passed to {cmd:amcmc()} in this fashion.
For example, if the target distribution is characterized by some
function {cmd:lnf(}{it:x}{cmd:,}{it:Y}{cmd:,}{it:Z}{cmd:)}, where {it:x}
are to be drawn but {it:Y} and {it:Z} are also arguments, the user would
define a pointer {it:M} containing {it:Y} and {it:Z}.  {it:M} is
optional and does not require specification.

{p 4 4 2}
{it:noisy} is a string scalar that can be specified as {cmd:"noisy"} or
as something else.  If {it:noisy=}{cmd:"noisy"}, the algorithm produces
feedback.  Each time the target distribution is evaluated, it produces
a {cmd:.} as output, while after 50 calls, it produces the value of the
target distribution after the last call of {it:lnf}.

{p 4 4 2}
Finally, the first argument of the function is {it:alginfo},
which is a string scalar specifying the drawing scheme desired by the
user, what sort of target distribution evaluator the user has passed to
the function when the target is part of a previously specified model
statement, and perhaps some other things about how the algorithm is to
be executed.  While the examples present more details, a user may
assemble a string row vector composed of one entry from each of the
following:

{col 5}Sampling information{...}
{col 36}{cmd:mwg}, {cmd:global}, {cmd:block}
{col 5}Model definition{...}
{col 36}{cmd:moptimize}, {cmd:optimize}, {cmd:standalone}
{col 5}Model evaluator type{...}
{col 36}{cmd:d*}, {cmd:q*}, {cmd:e*}, {cmd:g*}, {cmd:v*}
{col 5}Other information{...}
{col 36}{cmd:fast}

{p 4 4 2}
Thus, if the user wishes to perform Metropolis-within-Gibbs sampling
(each component of {it:lnf} sampled alone and in order) and has
previously modeled the target distribution as part of a structure by using
{helpb mf_moptimize:moptimize()} and a type {cmd:d0} evaluator, the
user would specify (in any order)
{it:alginfo=}{cmd:"moptimize","d0","mwg"}.  Note that each component of
{it:alginfo} should be a separate string entry in a string row vector,
so {it:alginfo=}{cmd:"moptimize,d0,mwg"} will not work.  The final
option, {cmd:"fast"}, is somewhat experimental and should be used with
caution.  In large problems, global, all-at-once samplers require
Cholesky decomposition of the proposal covariance matrix.  This can be
slow and time consuming.  The option {cmd:"fast"} avoids Cholesky
decomposition by working with a diagonal-proposal covariance matrix that
is continually adjusted as the algorithm proceeds.  {cmd:"fast"}
sometimes works if the target distribution has many independent random
variates and if the proposal distribution is close to the target
distribution.  See the examples for other possibilities.

{p 4 4 2}
If the user wishes to use a block sampler (which is somewhere between a
one-at-a-time Metropolis-within-Gibbs sampler), the user must also
submit a block matrix to communicate to {cmd:amcmc()} which values are
to be drawn together.


{title:Further options}

{p 4 4 2}
While the function {cmd:amcmc()} is designed to perform adaptive MCMC,
adaptation can be turned off by the user.  This feature is often useful
if a previous set of draws from a target distribution has already been
performed and the distribution is well-tuned.  In this case, the user can
set {it:damper} equal to missing (that is, {it:damper=.}), and no
adaptation will occur.  In this case, the user must also specify a set of
conformable values for {it:lambda}.


{title:Examples}

{pstd}
Example 1: Sampling from a univariate normal mixture with probability
1/2, the mean is -1 or 1 with standard deviation 1 in each case.  While
this is probably not the most efficient way to sample from a mixture
distribution, it illustrates basic ideas.  Initial values for
drawing are set to zero, with the initial variance matrix for proposals set at
one.  The number of draws taken is 1,000, with the first 100 discarded.  A value of 
{it:delta}=1/2 is a fairly conservative choice.  Sampler type has not
been specified, which means a global sampler will be used as a default.

	: {cmd:real scalar mixnorm(X)}
	> {cmd:{c -(}}
	>         {cmd:val=1/2*normalden(x,1,1)+1/2*normalden(x,-1,1)}
	>         {cmd:return(ln(val))}
	> {cmd:{c )-}}

	: {cmd:alginfo="standalone"}

	: {cmd:X=amcmc(alginfo,&mixnorm(),0,1,1000,100,1/2,.44,arate=.,vals=.,lambda=.,.)}

{pstd}
Example 2: Sampling from a bivariate normal mixture with dimension 2,
where the mean is {it:m} for probability {it:p}, and with probability
{it:p}, the mean is -{it:m}.  {it:p}, {it:m}, and {it:Sig} -- the covariance
matrix of the distribution -- are passed to {cmd:amcmc()} as additional
arguments of the function.  A vector of zeros and an identity matrix are
used as the starting values for the proposal distribution.

	: {cmd:real scalar mixnorm2(x,p,m1,m2,Sig)}
	> {cmd:{c -(}}
	>         {cmd:dSig=1/sqrt(det(Sig))}
	>         {cmd:Siginv=invsym(Sig)}
	>         {cmd:val1=1/2*dSig*exp(-(x-m1)*Siginv*(x-m1)')}
	>         {cmd:val2=1/2*dSig*exp(-(x-m2)*Siginv*(x-m2)')}
	>         {cmd:return(ln(p*val1+(1-p)*val2))}
	> {cmd:{c )-}}
	
	: {cmd:p=1/2}

	: {cmd:m1=1,1}

	: {cmd:m2=-1,-1}

	: {cmd:Sig=I(2):+.1}
	
	: {cmd:Args=J(4,1,NULL)}
	
	: {cmd:Args[1]=&p}
	
	: {cmd:Args[2]=&m1}
	
	: {cmd:Args[3]=&m2}
	
	: {cmd:Args[4]=&Sig}
	
	: {cmd:alginfo="standalone","global"}

	: {cmd:X=amcmc(alginfo,&mixnorm2(),J(1,2,0),I(2),100000,10000,1,.34,arate=.,vals=.,lambda=.,.,Args)}

{pstd}
Example 3: "Fitting" a negative-binomial count model by simulation.
The premise behind the example is that one can view a likelihood
function as a distribution for parameters conditional on data.  The idea
is superficially Bayesian; the model is isomorphic to a typical Bayesian
analysis with uninformative prior distributions for parameters but can
be applied more generally; see Chernozukov and Hong (2003).  Sampling
from the parameters' distribution is a sometimes useful method for
analyzing models applied to small samples because results do not depend upon
asymptotics, as they do in the typical Bayesian analysis.  While in a more
complete analysis, one might "thin" the resulting draws out, check for
convergence, etc., this is not done in the example, which is used
to illustrate how a model statement is passed to {cmd:amcmc()}.  The
results can be contrasted with those obtained from estimation via
application of {helpb nbreg}.

	: {cmd:use http://www.stata-press.com/data/lf2/couart2, clear}
	(Academic Biochemists / S Long)

	: {cmd:set seed 5150}
	
	: {cmd:mata:}
	{hline 20} mata (type {cmd:end} to exit) {hline 20}
	: {cmd:void nb_d0(M,todo,b,lnf,g,H)}
	> {cmd:{c -(}}
	>         {cmd:y=moptimize_util_depvar(M,1)}
	>         {cmd:mu=exp(moptimize_util_xb(M,b,1))}
	>         {cmd:a=exp(moptimize_util_xb(M,b,2))}
	>         {cmd:lnfi=lngamma(y:+1/a):-lngamma(1/a):-}
	>         {cmd:    lnfactorial(y):-(y:+1/a):*ln(1:+a*mu):+}
	>         {cmd:    y*ln(a):+y:*ln(mu)}
	>         {cmd:lnf=colsum(lnfi)}
	> {cmd:{c )-}}
	
	: {cmd:M=moptimize_init()}
	
	: {cmd:moptimize_init_evaluator(M,&nb_d0())}
	
	: {cmd:moptimize_init_evaluatortype(M,"d0")}
	
	: {cmd:moptimize_init_depvar(M,1,"art")}
	
	: {cmd:moptimize_init_eq_indepvars(M,1,"fem mar kid5 phd ment")}
	
	: {cmd:moptimize_init_eq_indepvars(M,2,"")}
	
	: {cmd:moptimize_evaluate(M)}
	
	: {cmd:alginfo="global","moptimize","d0"}
	
	: {cmd:X=amcmc(alginfo,&nb_d0(),J(1,7,0),I(7),20000,10000,3/4,.234,arate=.,vals=.,lambda=.,.,M)}
	
	: {cmd:mean(X)'}
	                        1      
		  {c   TLC}{hline 15}{c TRC}
		1 {c |}  -.2200206506 {c |}  
		2 {c |}    .148970965 {c |}
		3 {c |}  -.1774053762 {c |}  
		4 {c |}   .0173632397 {c |}
		5 {c |}   .0290353224 {c |}  
		6 {c |}    .253103149 {c |}
		7 {c |}  -.7998843153 {c |}  
		  {c   BLC}{hline 15}{c BRC}
	{txt}


{marker amcmc_struct}{...}
{title:Using amcmc_*() functions}

{title:Syntax}

{p 4 4 2}
Syntax is discussed in three steps:

        {help mf_amcmc##syn_step1:Step 1:  Initialization}
        {help mf_amcmc##syn_step2:Step 2:  Problem definition}
        {help mf_amcmc##syn_step3:Step 3:  Obtaining results}


{marker syn_step1}{...}
    {title:Step 1:  Initialization}

{p 4 4 2}
To initialize a problem, the user first issues an initialize function,
	
{p2col 7 33 35 2: {it:A = }    {cmd:amcmc_init()}}{p_end}

{p 4 4 2} 
{cmd:amcmc_init()} sets up an adaptive MCMC problem with the following
defaults:  the number of draws is set to one, the burn-in period is set to
zero, and the optimal acceptance rate is set to 0.234.

{marker syn_step2}{...}
    {title:Step 2: Problem definition}

{p 4 4 2}
Problem definition fills in the arguments described under 
{it:{help mf_amcmc##amcmc_fun:Syntax}}, so it might first help the
user to peruse that material in addition to reading Baker
(2014) and Andrieu and Thoms (2008).  The user has to relay
information about the target distribution, the initial values, the number of
draws desired, any additional information on the function or how
drawing should go, and how adaptation of the proposal should occur.

{p 8 40 2}
{cmd:amcmc_lnf(}{it:A}{cmd:,} {it:pointer (real scalar function) scalar lnf}{cmd:)}

{p 12 12 2}
Use: sets the target distribution as the function {it:lnf}.  Note that {it:lnf} must be in log form.

{p 8 40 2}
{cmd:amcmc_args(}{it:A}{cmd:,} {it:pointer matrix Z}{cmd:)}

{p 12 12 2}
Use: sets any additional arguments of the function {it:lnf}.  Note that
this option can be used only with a stand-alone target distribution.
That is, if the user is sampling from a problem with details constructed
using {helpb mf_moptimize:moptimize()} or {helpb mf_optimize:optimize()}, the user should pass any arguments of the
function {it:lnf} through those routines.

{p 8 40 2}
{cmd:amcmc_xinit(}{it:A}{cmd:,} {it:real rowvector xinit}{cmd:)}

{p 12 12 2}
Use: sets initial values for the proposal distribution.

{p 8 40 2}
{cmd:amcmc_Vinit(}{it:A}{cmd:,} {it:real matrix Vinit}{cmd:)}

{p 12 12 2}
Use: sets initial values of the proposal covariance matrix.  If the
matrix submitted is not positive definite, the default is to use a conformable
identity matrix.

{p 8 40 2}
{cmd:amcmc_aopt(}{it:A}{cmd:,} {it:real scalar aopt}{cmd:)}

{p 12 12 2}
Use: sets desired acceptance rate, typically in the range of 0.234 to 0.45
or so.

{p 8 40 2}
{cmd:amcmc_damper(}{it:A}{cmd:,} {it:real scalar delta}{cmd:)}

{p 12 12 2}
Use: Specifies the parameter that determines how tuning of the
algorithm is to occur; the value should be between zero and one.  Values
close to zero mean less aggressive tuning of the proposal distribution,
while values closer to one mean more aggressive tuning.  One can also
specify a missing value for {it:damper} here; that is,
{cmd:amcmc_damper(A,.)}.  In this case, no adaptation of the proposal
distribution occurs, and the user must specify scaling parameters using
the function {cmd:amcmc_lambda(}{it:A}{cmd:,} {it:real rowvector lambda}{cmd:)}.

{p 8 40 2}
{cmd:amcmc_lambda(}{it:A}{cmd:,} {it:real rowvector lambda}{cmd:)}

{p 12 12 2}
Use: Specifies the scaling parameters for the proposal covariance
matrix.  That is, when a draw is performed using covariance matrix
{it:W}, draws use {it:lambda*W} to make the draws.  This option should
be set only if {it:damper} (discussed under the heading
{cmd:amcmc_damper(}{it:A}{cmd:,)}) is set to missing so that no
adaptation of the proposal distribution is to occur.

{p 8 40 2}
{cmd:amcmc_burn(}{it:A}{cmd:,} {it:real scalar burn}{cmd:)}

{p 12 12 2}
Use: sets the length of the burn-in period, for which information about
draws is discarded.

{p 8 12 2}
{cmd:amcmc_draws(}{it:A}{cmd:,} {it:real scalar draws}{cmd:)}

{p 12 40 2}
Use: specifies the number of draws to be performed.

{p 8 40 2}
{cmd:amcmc_noisy(}{it:A}{cmd:,} {it:string scalar noisy}{cmd:)}

{p 12 12 2}
Use: produces a dot each time {it:lnf} is called if {it:noisy}={cmd:"noisy"}; every 50 calls, the function value at the last draw is also
produced.

{p 8 40 2}
{cmd:amcmc_model(}{it:A}{cmd:,} {it:transmorphic M}{cmd:)}

{p 12 12 2}
Use: appends the drawing problem with a previously assembled model statement 
formulated using either {helpb mf_moptimize:moptimize()} or {helpb mf_optimize:optimize()}.

{p 8 40 2}
{cmd:amcmc_blocks(}{it:A}{cmd:,} {it:real matrix blocks}{cmd:)}

{p 12 12 2}
Use: In conjunction with block samplers.  The matrix {it:blocks}
contains information about the sequence of draws.

{p 8 40 2}
{cmd:amcmc_alginfo(}{it:A}{cmd:,} {it:string rowvector alginfo}{cmd:)}

{p 12 12 2}
Use: contains information in a sequence of strings about how drawing is to proceed, what type of sampler is to be used, if and how models are to be specified,
etc.  Available options are the following:

{col 13}Sampling information{...}
{col 36}{cmd:mwg}, {cmd:global}, {cmd:block}
{col 13}Model definition{...}
{col 36}{cmd:moptimize}, {cmd:optimize}, {cmd:standalone}
{col 13}Model evaluator type{...}
{col 36}{cmd:d*}, {cmd:q*}, {cmd:e*}, {cmd:g*}, {cmd:v*}
{col 13}Other information{...}
{col 36}{cmd:fast}

{p 12 12 2}
Thus, if the user is sampling from a previously formed model statement
using optimize with a type {cmd:d0} evaluator and wished to sample in
blocks, the user would specify
{cmd:amcmc_alginfo(A,("block","optimize","d0"))}

{p 8 40 2}
{cmd:amcmc_draw(}{it:A}{cmd:)}

{p 12 12 2}
Use: executes the sampler.
	
{p 4 4 2}
Setting up a problem as a structured object has advantages when the user wants
to execute adaptive MCMC as a step in a larger algorithm or when the user must
set up a sequence of similar adaptive MCMC problems (or both).  An additional
set of functions that do not directly analogize with the use of the function
{cmd:amcmc()} follows:

{p 8 40 2}
{cmd:amcmc_append(}{it:A}{cmd:,} {it:string scalar append}{cmd:)}

{p 12 12 2}
Use: attaches the results to the information on previous calls of
{cmd:amcmc_draw(A)} in the event that the user executes the function
{cmd:amcmc_draw(A)} multiple times in sequence by specifying
{it:append}={cmd:"append"}.  Acceptance rates, the proposal distribution,
etc., are all updated accordingly.  This is the default setting; unless the
user specifies {it:append}={cmd:"overwrite"}, all information about previous
draws will be retained.  Specifying {it:append}={cmd:"overwrite"} does not
restart the draw; everything is updated using past draws, but only the most
recent set of draws is retained.  This is useful in large problems in which a
sampler is used as a step in a larger sampling algorithm.

{p 8 40 2}
{cmd:amcmc_reeval(}{it:A}{cmd:,} {it:string scalar reeval}{cmd:)}

{p 12 12 2}
Use: reevaluates the function using the last drawn values with the new
parameter values before proceeding if the parameters passed to the problem
change when the user executes the function {cmd:amcmc_draw(A)} as a step in a
larger algorithm. If the user wishes to do this, the
user may simply set {it:reeval}={cmd:"reeval"}.

{marker syn_step3}{...}
    {title:Step 3:  Results}

{p 4 4 2}
Once a run has been executed using {cmd:amcmc_draw()}, the user can
access information about the draws and recover some information
about initial settings.

{p 8 40 2}
{it:real matrix}        {cmd:amcmc_results_draws(}{it:A}{cmd:)}

{p 12 12 2}
Use: returns the draws in a matrix form; each row represents a draw.

{p 8 40 2}
{it:real colvector}     {cmd:amcmc_results_vals(}{it:A}{cmd:)}

{p 12 12 2}
Use: returns the values of the proposal distribution corresponding with each draw.

{p 8 40 2}
{it:real rowvector}     {cmd:amcmc_results_arate(}{it:A}{cmd:)}

{p 12 12 2}
Use: returns acceptance rates.  If a global scheme is used, this is a
single value.  Otherwise, acceptance rates conform with the number of
blocks (for a block sampler) or the dimension of the target distribution
(for a Metropolis-within-Gibbs sampler).

{p 8 40 2}
{it:real scalar}        {cmd:amcmc_results_passes(}{it:A}{cmd:)}

{p 12 12 2}
Use: returns the number of times the {cmd:amcmc_draw()} function has been
issued.

{p 8 40 2}
{it:real scalar}     {cmd:amcmc_results_totaldraws(}{it:A}{cmd:)}

{p 12 12 2}
Use: returns the total number of draws.

{p 8 40 2}
{it:real colvector}     {cmd:amcmc_results_vals(}{it:A}{cmd:)}

{p 12 12 2}
Use: returns the values of the proposal distribution corresponding with each draw.
 
{p 8 40 2}
{it:real matrix}     {cmd:amcmc_results_acceptances(}{it:A}{cmd:)}

{p 12 12 2}
Use: returns a matrix of zeros and ones conformable with the sampling
scheme, where a one indicates that a particular draw was accepted,
and a zero indicates that a draw was rejected.  In short, the
function returns the acceptance history of the draw.

{p 8 40 2}
{it:real rowvector}     {cmd:amcmc_results_propmean(}{it:A}{cmd:)}

{p 12 12 2}
Use: returns the mean of the proposal distribution at the end of the
run.

{p 8 40 2}
{it:real matrix}     {cmd:amcmc_results_propvar(}{it:A}{cmd:)}

{p 12 12 2}
Use: returns the covariance matrix of the proposal distribution at the
end of the run.

{p 8 40 2}
{it:real rowvector}     {cmd:amcmc_results_lastdraw(}{it:A}{cmd:)}

{p 12 12 2}
Use: returns only the last draw.

{p 8 40 2}
{it:void}     {cmd:amcmc_results_report(}{it:A}{cmd:)}

{p 12 12 2}
Use: produces a quick summary of a run, including the total passes,
draws per pass, the total number of draws, the average value of the
target distribution, the last value of the target distribution, the
average acceptance rate, and the burn-in period.

{p 4 4 2}
Additionally, one can obtain the values that the user specified by using
{cmd:amcmc_results_}{it:*}{cmd:()}, where {it:*} can be
{cmd:alginfo}, {cmd:noisy}, {cmd:blocks}, {cmd:damper}, {cmd:xinit},
{cmd:Vinit}, or {cmd:lambda}.


{title:Examples}

{pstd}
Example 1: This example recasts example 2 above.  To recap, the interest
lies in sampling from a multivariate normal mixture with dimension 2,
where with probability {it:p}, the mean is {it:m}, and with probability
{it:p}, the mean is {it:-m}.  {it:p}, {it:m}, and {it:Sigma} -- the
covariance matrix of the distribution -- are passed as additional
arguments of the function.  A vector of zeros and an identity matrix are
used as the starting values for the proposal distribution.

	{cmd:real scalar mixnorm2(x,p,m1,m2,Sig)}
	> {cmd:{c -(}}
	>         {cmd:dSig=1/sqrt(det(Sig))}
	>         {cmd:Siginv=invsym(Sig)}
	>         {cmd:val1=1/2*dSig*exp(-(x-m1)*Siginv*(x-m1)')}
	>         {cmd:val2=1/2*dSig*exp(-(x-m2)*Siginv*(x-m2)')}
	>         {cmd:return(ln(p*val1+(1-p)*val2))}
	> {cmd:{c )-}}
	
	: {cmd:p=1/2}

	: {cmd:m1=1,1}

	: {cmd:m2=-1,-1}
	
	: {cmd:Sig=I(2):+.1}
	
	: {cmd:Args=J(4,1,NULL)}
	
	: {cmd:Args[1]=&p}
	
	: {cmd:Args[2]=&m1}
	
	: {cmd:Args[3]=&m2}
	
	: {cmd:Args[4]=&Sig}
	
	: {cmd:alginfo="standalone","global"}
	
	: {cmd:A=amcmc_init()}
	
	: {cmd:amcmc_alginfo(A,alginfo)}
	
	: {cmd:amcmc_lnf(A,&mixnorm2())}
	
	: {cmd:amcmc_draws(A,100000)}
	
	: {cmd:amcmc_burn(A,10000)}
	
	: {cmd:amcmc_args(A,Args)}
	
	: {cmd:amcmc_xinit(A,J(1,2,0))}
	
	: {cmd:amcmc_Vinit(A,I(2))}
	
	: {cmd:amcmc_aopt(A,.34)}
	
	: {cmd:amcmc_damper(A,1)}
	
	: {cmd:amcmc_draw(A)}

{pstd}
Example 2: Bayesian estimation of a mixed logit model.  The ideas behind
this example follow chapter 12 of Train (2009).  The user is interested
in fitting a logit model where parameters vary about a
distribution at some group level.  There are three set of parameters: 1)
beta_n, the values of the group parameters for each group; 2) b, the
mean of the group level parameters across groups; and 3) W, the
covariance matrix of the group-level parameters.

{pstd}
Following the setup described in Train (2009), we will suppose that the prior
distribution for b is normal with arbitrarily large variance and that the
prior on W is an inverted Wishart with K (the dimension of b) degrees of
freedom and identity scale matrix.  Under these conditions, we obtain the
following:

{p 4 7 2}
1. The distribution of b given beta_n and W is normal with
mean=mean(beta_n), and covariance matrix W/N, where N is the number of
groups.

{p 4 7 2}
2. The distribution of W given b and beta_n is an inverted Wishart.

{p 4 7 2}
3. The distribution of beta_n given b and W is the product of a normal
density capturing the likelihood of the group's parameters given the
mean and variance of group parameters across the sample and the
likelihood of the individual's choices given beta_n.

{pstd}
The example begins by setting up the data, which is {cmd:bangladesh.dta}.
The dataset has information on the use of contraceptives for
individuals in different districts.  The user posits that the
coefficients vary randomly by district in accordance with the model.
Reading data into Mata, we obtain the following:

	: {cmd:clear all}
	
	: {cmd:webuse bangladesh}
	(NLS Women 14-24 in 1968)

	: {cmd:set seed 90210}

	: {cmd:mata: }
	{hline 20} mata (type {cmd:end} to exit) {hline 20}
	: {cmd:st_view(X=.,.,"urban age child1 child2 child3")}

	: {cmd:st_view(y=.,.,"c_use")}
	
	: {cmd:st_view(id=.,.,"district")}
	
	: {cmd:X=X,J(rows(X),1,1)}
	
	: {cmd:m=panelsetup(id,1)}

{pstd}
Mata now contains contraceptive use information in the vector {it:y},
explanatory variables and a constant in the vector {it:X}, and an id
code that is organized into a panel using 
{helpb mf_panelsetup:panelsetup()}.  The next step is to code the functions
following Train's (2009) descriptions.  For steps 1 and 2, a function
producing draws from the respective distributions is needed.  Step 3 will
be set up to work with {cmd:amcmc_}{it:*}{cmd:()}, so this function does not produce
draws but instead returns the log value of the parameter density
conditional on data, choices, b, and W.  The notational convention in
the necessary functions are that the mean and variance of group-level
parameters are denoted by {cmd:b} and {cmd:W}, and the matrix of group-level
parameters is denoted {cmd:beta}, while a set (a rowvector) of
group-level parameters is denoted by {cmd:beta_n}.  The three required
functions are

        : {cmd:real matrix drawb_betaW(beta,W)}
	> {cmd:{c -(}}
	>         {cmd:return(mean(beta)+rnormal(1,cols(beta),0,1)*cholesky(W)')}
	> {cmd:{c )-}}

	: {cmd:real matrix drawW_bbeta(beta,b)}
	> {cmd:{c -(}}
	>         {cmd:v=rnormal(cols(b)+rows(beta),cols(b),0,1)}
	>         {cmd:S1=variance(beta:-b)}
	>         {cmd:S=invsym((cols(b)*I(cols(b))+rows(beta)*S1)/(cols(b)+rows(beta)))}
	>         {cmd:L=cholesky(S)}
	>         {cmd:R=(L*v')*(L*v')'/(cols(b)+rows(beta))}
	>         {cmd:return(invsym(R))}
	> {cmd:{c )-}}

	: {cmd:real scalar lnchoiceprob(beta_n,b,W,yn,Xn)}
	> {cmd:{c -(}}
	>         {cmd:mus=rowsum(Xn:*beta_n)}
	>         {cmd:lnp=yn:*mus:-ln(1:+exp(mus))}
	>         {cmd:lnprior=-1/2*(beta_n-b)*invsym(W)*(beta_n-b)'-}
	>         {cmd:        1/2*ln(det(W))-cols(b)/2*ln(2*pi())}
	>         {cmd:return(sum(lnp)+lnprior)}
	> {cmd:{c )-}}

{pstd}
The next step is to set up a series of adaptive MCMC problems -- one
for each by using {cmd:amcmc_}{it:*}{cmd:()} and Mata's 
{helpb mata J():J()} function, which allows easy duplication of one
problem.

	: {cmd:Ap=amcmc_init()}
	
	: {cmd:amcmc_damper(Ap,1)}
	
	: {cmd:amcmc_arate(Ap,.4)}
	
	: {cmd:amcmc_alginfo(Ap,("standalone","global"))}
	
	: {cmd:amcmc_lnf(Ap,&lnchoiceprob())}
	
	: {cmd:amcmc_draws(Ap,1)}
	
	: {cmd:amcmc_append(Ap,"overwrite")}
	
	: {cmd:amcmc_reeval(Ap,"reeval")}
	
	: {cmd:A=J(rows(m),1,Ap)}
	
{pstd}
Each problem is set up as a global drawing problem, where one draw is
taken.  In passing, the author's experience is that it is sometimes
helpful to let each individual problem run awhile by specifying, say, 5 or 10
draws in this step for better mixing in the early stages of the
algorithm.  The option {cmd:"overwrite"} specifies that information on
each draw is not to be stored as the algorithm proceeds.  The option
{cmd:"reeval"} specifies to reevaluate the function
because the two arguments {cmd:b} and {cmd:W} are changed as the algorithm
proceeds.  After some poor starting values are specified, an
initial draw of the individual-level parameters is taken.  A loop can
now be run to fill in the arguments.  This is done by setting up a
pointer matrix, each row of which points to explanatory values and the
mean and variance of the distribution.  Now initial values for
parameters are specified, and all the separate {cmd:amcmc()} problems
are initiated in a loop.

	: {cmd:b=J(1,6,0)}
	
	: {cmd:W=I(6)*6}
	
	: {cmd:eta=b:+rnormal(rows(m),cols(X),0,1)*cholesky(W)'}
	
	: {cmd:Args=J(rows(m),4,NULL)}
	
	: {cmd:for (i=1;i<=rows(m);i++)}
	> {cmd:{c -(}}
	>         {cmd:Args[i,1]=&b}
	>         {cmd:Args[i,2]=&W}
	>         {cmd:Args[i,3]=&panelsubmatrix(y,i,m)}
	>         {cmd:Args[i,4]=&panelsubmatrix(X,i,m)}
	>         {cmd:amcmc_args(A[i],Args[i,])}
	>         {cmd:amcmc_xinit(A[i],b)}
	>         {cmd:amcmc_Vinit(A[i],W)}
	> {cmd:{c )-}}
	
{pstd}
The algorithm is now implemented as follows, with 10,000 total draws and
an initial value of individual-level parameters taken as a draw from the
normal distribution.  The matrices {cmd:bvals} and {cmd:Wvals} are used
to hold the draws of the mean and the covariance matrix:

	: {cmd:its=10000}
	
	: {cmd:bvals=J(0,cols(beta),.)}

	: {cmd:Wvals=J(0,cols(rowshape(W,1)),.)}

	: {cmd:for (i=1;i<=its;i++)}
	> {cmd:{c -(}}
	>         {cmd:b=drawb_betaW(beta,W/rows(m))}
	>         {cmd:W=drawW_bbeta(beta,b)}
	>         {cmd:bvals=bvals\b}
	>         {cmd:Wvals=Wvals\rowshape(W,1)}
	>         {cmd:for (j=1;j<=rows(m);j++)} 
	>         {cmd:{c -(}}
	>                  {cmd:amcmc_draw(A[j])}
	>                  {cmd:beta[j,]=amcmc_results_lastdraw(A[j])}
	>         {cmd:{c )-}}
	> {cmd:{c )-}}

{pstd}
In a typical application, one usually discards some initial values and thins
results to eliminate the autocorrelation inherent in MCMC sampling.  However,
here we just summarize the draws for the mean of the parameter vector and the
covariance matrix.

	: {cmd:mean(bvals)'}
	       {txt}              1      
		  {c   TLC}{hline 15}{c TRC}
		1 {c |}   .9653859143 {c |}  
		2 {c |}  -.0363394328 {c |}
		3 {c |}   1.399463261 {c |}  
		4 {c |}   1.696209143 {c |}
		5 {c |}   1.656005711 {c |}
		6 {c |}  -2.121194287 {c |}
		  {c BLC}{hline 15}{c BRC}
	
	: {cmd:rowshape(mean(Wvals),6)}
	{txt}[symmetric]
	      {txt}         1              2              3             4             5            6
	  {c TLC}{hline 85}{c TRC}{txt}
	1 {c |}  1.692919191                                                                        {c |}{txt}
	2 {c |} -.0236467397    .1201797953                                                         {c |}{txt}
	3 {c |}  .7638987195   -.0098907509    1.356704652                                          {c |}{txt}
	4 {c |}  .5181705857   -.0080073073    .6239961521   1.122827391                            {c |}{txt}
	5 {c |}  1.087957638   -.0416998767    1.023219879   .6940770407   1.978052313              {c |}{txt}
	6 {c |} -1.317031389    .0337024609   -1.044189251   -.812652926  -1.535208409  2.077123236 {c |}{txt}
	  {c BLC}{hline 85}{c BRC}
 
{pstd}
The example is a fairly complete description of how the
user-written command {cmd:bayesmixedlogit} works.  For more information, see
{helpb bayesmixedlogit}.  Further examples can be found in Baker (2014).


{title:Additional notes}

{pstd}
{cmd:amcmc()} or {cmd:amcmc_}{it:*}{cmd:()} requires that the user
install Ben Jann's {cmd:moremata} package.


{title:References}

{phang}
Andrieu, C., and J. Thoms. 2008. A tutorial on adaptive MCMC.
{it:Statistics and Computing} 18: 343-373.

{phang}
Baker, M. J. 2014.
{browse "http://www.stata-journal.com/article.html?article=st0354":Adaptive Markov chain Monte Carlo sampling and estimation in Mata}.
{it:Stata Journal} 14: 623-661.
	
{phang}
Chernozukov, V., and H. Hong. 2003. An MCMC approach to classical estimation.
{it:Journal of Econometrics} 115: 293-346.
	
{phang}
Train, K. E. 2009. {it:Discrete Choice Methods with Simulation}. 2nd ed.
Cambridge: Cambridge University Press.


{title:Author}

{pstd}Matthew J. Baker{p_end}
{pstd}Hunter College and the Graduate Center, CUNY{p_end}
{pstd}New York, NY{p_end}
{pstd}matthew.baker@hunter.cuny.edu{p_end}

{pstd}Comments and suggestions are appreciated.


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 14, number 3: {browse "http://www.stata-journal.com/article.html?article=st0354":st0354}

{p 7 14 2}Help:  {manhelp mata M-0}{p_end}
