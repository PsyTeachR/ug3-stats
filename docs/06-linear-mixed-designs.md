# Specifying the predictors



## Learning objectives

* express multi-level designs in model format
* categorical predictors
* understand the basic rules for specifying random effects

## Code your own categorical predictors

Many studies in psychology---especially experimental psychology---involve categorical independent variables. Analyzing data from these studies requires care in specifying the predictors, because the defaults in R are not ideal for experimental situations.

Let's say you have 2x2 designed experiment with factors priming condition (priming vs. no priming) and linguistic structure (noun vs verb). These columns can be represented as type `character` or `factor`; in the latter case, they are implicitly converted to type `factor` before fitting the model, and then R will apply the default numerical coding for factors, which is 'treatment' (0, 1) coding.

If you're used to running ANOVAs, the results that you get from fitting a linear model will *not* match ANOVA output, as we'll see below.  That is because you need to use a different coding scheme to get ANOVA-like output.

First, let's define our little data set, `dat`.


```r
  ## demo for why you should avoid factors
  dat <- tibble(
    subject = factor(1:16),
    priming = rep(c("yes", "no"), each = 8),
    structure = rep(rep(c("noun", "verb"), each = 4), 2),
    RT = rnorm(16, 800, 20))

  dat
```

```
## # A tibble: 16 x 4
##    subject priming structure    RT
##    <fct>   <chr>   <chr>     <dbl>
##  1 1       yes     noun       790.
##  2 2       yes     noun       822.
##  3 3       yes     noun       776.
##  4 4       yes     noun       783.
##  5 5       yes     verb       783.
##  6 6       yes     verb       800.
##  7 7       yes     verb       809.
##  8 8       yes     verb       783.
##  9 9       no      noun       791.
## 10 10      no      noun       806.
## 11 11      no      noun       787.
## 12 12      no      noun       807.
## 13 13      no      verb       820.
## 14 14      no      verb       781.
## 15 15      no      verb       791.
## 16 16      no      verb       824.
```

This is between subjects data, so we can fit a model using `lm()`.  In the model, we include effects of `priming` and `structure` as well as their interaction. Instead of typing `priming + structure + priming:structure` we can simply type the shortcut `priming * structure`.


```r
  ps_mod <- lm(RT ~ priming * structure, dat)

  summary(ps_mod)
```

```
## 
## Call:
## lm(formula = RT ~ priming * structure, data = dat)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -23.250 -10.739  -5.003  10.856  29.414 
## 
## Coefficients:
##                          Estimate Std. Error t value Pr(>|t|)    
## (Intercept)               797.537      8.421  94.713   <2e-16 ***
## primingyes                 -4.785     11.908  -0.402    0.695    
## structureverb               6.450     11.908   0.542    0.598    
## primingyes:structureverb   -5.377     16.841  -0.319    0.755    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 16.84 on 12 degrees of freedom
## Multiple R-squared:  0.08322,	Adjusted R-squared:  -0.146 
## F-statistic: 0.3631 on 3 and 12 DF,  p-value: 0.7808
```

Note that in the output the predictors are shown as `primingyes` and `structureverb`. The value `yes` is a level of `priming`; the level **not shown** is the one chosen as baseline, and in the default treatment coding scheme, the not-shown level (`no`) is coded as 0, and the shown level (`yes`) is coded as 1. Likewise, for `structure`, `noun` is coded as 0 and `verb` is coded as 1.

This is not ideal, for reasons we will discuss further below. But I want to show you a further quirk of using factor variables as predictors.

Let's say we wanted to test the effect of `priming` by itself using model comparison. To do this, we would fit another model where we exclude this effect while keeping the interaction. Despite what you may have heard to the contrary, in a fully randomized, balanced experiment, all factors are orthogonal, and so it is completely legitimate to drop a main effect while leaving an interaction term in the model.


```r
  ps_mod_nopriming <- lm(RT ~ structure + priming:structure, dat)
```

OK, now that we've dropped `priming`, we should have 3 parameter estimates instead of 4. Let's check.


```r
  ## not right!
  coef(ps_mod_nopriming)
```

```
##              (Intercept)            structureverb structurenoun:primingyes 
##               797.537380                 6.450453                -4.785226 
## structureverb:primingyes 
##               -10.162669
```

There are still 4 of them, and we're suddenly getting `primingyes:structureverb`. This is weird and *not at all* what we intended.  If we try to do the model comparison:


```r
  ## nonsense result
  anova(ps_mod_nopriming, ps_mod)
```

```
## Analysis of Variance Table
## 
## Model 1: RT ~ structure + priming:structure
## Model 2: RT ~ priming * structure
##   Res.Df    RSS Df  Sum of Sq F Pr(>F)
## 1     12 3403.5                       
## 2     12 3403.5  0 4.5475e-13
```

we'd get nonsensical results.

Is this a bug? No. It was a (in my view, heavy handed) design choice by the R creators to try to prevent everyone from doing something that at least some of us should be able to do at least some of the time.

But we can do whatever we please if instead of using factors we define our own numerical predictors. This adds a bit of work but avoids other headaches and mistakes that we might make by using factors. Also, being very explicit about how predictors are defined is probably a good thing.

You'll sometimes need `factor` variables. I often use them to get things to plot in the right way using `ggplot2`, or when I need to tabulating observations and there are some combinations with zero counts. But I recommend against using `factors` in statistical models, especially if your model includes interactions. Use numerical predictors instead.

## Coding schemes for categorical variables

Many experimentalists who are trying to make the leap from ANOVA to linear mixed-effects models (LMEMs) in R struggle with the coding of categorical predictors.  It is unexpectedly complicated, and the defaults provided in R turn out to be wholly inappropriate for factorial experiments.  Indeed, using those defaults with factorial experiments can lead researchers to draw erroneous conclusions from their data.

To keep things simple, we'll start with situations where design factors have no more than two levels before moving on to designs with more than three levels.

### Simple versus main effects

It is important that you understand the difference between a **simple effect** and a **main effect**, and between a **simple interaction** and a **main interaction** in a three-way design.

In an \(A{\times}B\) design, the simple effect of \(A\) is the effect of \(A\) **controlling** for \(B\), while the main effect of \(A\) is the effect of \(A\) **ignoring** \(B\).  Another way of looking at this is to consider the cell means (\(\bar{Y}_{11}\), \(\bar{Y}_{12}\), \(\bar{Y}_{21}\), and \(\bar{Y}_{22}\)) and marginal means (\(\bar{Y}_{1.}\), \(\bar{Y}_{2.}\), \(\bar{Y}_{.1}\), and \(\bar{Y}_{.2}\)) in a factorial design. (The dot subscript tells you to "ignore" the dimension containing the dot; e.g., \(\bar{Y}_{.1}\) tells you to take the mean of the first column ignoring the row variable.) To test the main effect of A is to test the null hypothesis that \(\bar{Y}_{1.}=\bar{Y}_{2.}\).  To test a simple effect of \(A\)—the effect of \(A\) at a particular level of \(B\)—would be, for instance, to test the null hypothesis that \(\bar{Y}_{11}=\bar{Y}_{21}\).

<table class="table" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:center;">  </th>
   <th style="text-align:center;"> \(B_1\) </th>
   <th style="text-align:center;"> \(B_2\) </th>
   <th style="text-align:center;">  </th>
   <th style="text-align:center;">  </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:center;"> \(A_1\) </td>
   <td style="text-align:center;"> $\bar{Y}_{11}$ </td>
   <td style="text-align:center;"> $\bar{Y}_{12}$ </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> $\bar{Y}_{1.}$ </td>
  </tr>
  <tr>
   <td style="text-align:center;"> \(A_2\) </td>
   <td style="text-align:center;"> $\bar{Y}_{21}$ </td>
   <td style="text-align:center;"> $\bar{Y}_{22}$ </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> $\bar{Y}_{2.}$ </td>
  </tr>
  <tr>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> $\bar{Y}_{.1}$ </td>
   <td style="text-align:center;"> $\bar{Y}_{.2}$ </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
  </tr>
</tbody>
</table>

The distinction between **simple interactions** and **main interactions** has the same logic: the simple interaction of \(AB\) in an \(ABC\) design is the interaction of \(AB\) at a particular level of \(C\); the main interaction of \(AB\) is the interaction **ignoring** C.  The latter is what we are usually talking about when we talk about lower-order interactions in a three-way design.  It is also what we are given in the output from standard ANOVA procedures, e.g., the `aov()` function in R, SPSS, SAS, etc.

### The key coding schemes

Generally, the choice of a coding scheme impacts the interpretation of:

1. the intercept term; and
2. the interpretation of the tests for all but the highest-order effects and interactions in a factorial design.

It also can influence the interpretation/estimation of random effects in a mixed-effects model (see [this blog post](http://talklab.psy.gla.ac.uk/simgen/rsonly.html) for further discussion).  If you have a design with only a single two-level factor, and are using a [maximal random-effects structure](https://www.sciencedirect.com/science/article/pii/S0749596X12001180), the choice of coding scheme doesn't really matter.

There are many possible coding schemes (see `?contr.treatment` for more information).  The most relevant ones are **treatment**, **sum**, and **deviation**.  Sum and deviation coding can be seen as special cases of **effect** coding; by effect coding, people generally mean codes that sum to zero.

For a two-level factor, you would use the following codes:

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Scheme </th>
   <th style="text-align:right;"> \(A_1\) </th>
   <th style="text-align:right;"> \(A_2\) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Treatment (dummy) </td>
   <td style="text-align:right;"> \(0\) </td>
   <td style="text-align:right;"> \(1\) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sum </td>
   <td style="text-align:right;"> \(-1\) </td>
   <td style="text-align:right;"> \(1\) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Deviation </td>
   <td style="text-align:right;"> \(-\frac{1}{2}\) </td>
   <td style="text-align:right;"> \(\frac{1}{2}\) </td>
  </tr>
</tbody>
</table>

The default in R is to use treatment coding for any variable defined as a =factor= in the model (see `?factor` and `?contrasts` for information).  To see why this is not ideal for factorial designs, consider a 2x2x2 factorial design with factors $A$, $B$ and $C$.  We will just consider a fully between-subjects design with only one observation per subject as this allows us to use the simplest possible error structure.  We would fit such a model using `lm()`:

: lm(Y ~ A * B * C)

The figure below spells out the notation for the various cell and marginal means for a 2x2x2 design.

<div class="column" style="float:left; width: 50%">

$$C_1$$

<table class="table" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:center;">  </th>
   <th style="text-align:center;"> \(B_1\) </th>
   <th style="text-align:center;"> \(B_2\) </th>
   <th style="text-align:center;">  </th>
   <th style="text-align:center;">  </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:center;"> \(A_1\) </td>
   <td style="text-align:center;"> $\bar{Y}_{111}$ </td>
   <td style="text-align:center;"> $\bar{Y}_{121}$ </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> $\bar{Y}_{1.1}$ </td>
  </tr>
  <tr>
   <td style="text-align:center;"> \(A_2\) </td>
   <td style="text-align:center;"> $\bar{Y}_{211}$ </td>
   <td style="text-align:center;"> $\bar{Y}_{221}$ </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> $\bar{Y}_{2.1}$ </td>
  </tr>
  <tr>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> $\bar{Y}_{.11}$ </td>
   <td style="text-align:center;"> $\bar{Y}_{.21}$ </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
  </tr>
</tbody>
</table>

</div>

<div class="column" style="float:right; width: 50%">

$$C_2$$

<table class="table" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:center;">  </th>
   <th style="text-align:center;"> \(B_1\) </th>
   <th style="text-align:center;"> \(B_2\) </th>
   <th style="text-align:center;">  </th>
   <th style="text-align:center;">  </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:center;"> \(A_1\) </td>
   <td style="text-align:center;"> $\bar{Y}_{112}$ </td>
   <td style="text-align:center;"> $\bar{Y}_{122}$ </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> $\bar{Y}_{1.2}$ </td>
  </tr>
  <tr>
   <td style="text-align:center;"> \(A_2\) </td>
   <td style="text-align:center;"> $\bar{Y}_{212}$ </td>
   <td style="text-align:center;"> $\bar{Y}_{222}$ </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> $\bar{Y}_{2.2}$ </td>
  </tr>
  <tr>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;"> $\bar{Y}_{.12}$ </td>
   <td style="text-align:center;"> $\bar{Y}_{.22}$ </td>
   <td style="text-align:center;">  </td>
   <td style="text-align:center;">  </td>
  </tr>
</tbody>
</table>

</div>

The table below provides the interpretation for various effects in the model under the three different coding schemes.  Note that $Y$ is the dependent variable, and the dots in the subscript mean to "ignore" the corresponding dimension.  Thus, \(\bar{Y}_{.1.}\) is the mean of B_1 (ignoring factors \(A\) and \(C\)) and \(\bar{Y}_{...}\) is the "grand mean" (ignoring all factors).

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:center;"> term </th>
   <th style="text-align:center;"> treatment </th>
   <th style="text-align:center;"> sum </th>
   <th style="text-align:center;"> deviation </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:center;"> \(\mu\) </td>
   <td style="text-align:center;"> $\bar{Y}_{111}$ </td>
   <td style="text-align:center;"> $\bar{Y}_{...}$ </td>
   <td style="text-align:center;"> $\bar{Y}_{...}$ </td>
  </tr>
  <tr>
   <td style="text-align:center;"> \(A\) </td>
   <td style="text-align:center;"> \(\bar{Y}_{211} - \bar{Y}_{111}\) </td>
   <td style="text-align:center;"> \(\frac{(\bar{Y}_{2..} - \bar{Y}_{1..})}{2}\) </td>
   <td style="text-align:center;"> \(\bar{Y}_{2..} - \bar{Y}_{1..}\) </td>
  </tr>
  <tr>
   <td style="text-align:center;"> \(B\) </td>
   <td style="text-align:center;"> \(\bar{Y}_{121} - \bar{Y}_{111}\) </td>
   <td style="text-align:center;"> \(\frac{(\bar{Y}_{.2.} - \bar{Y}_{.1.})}{2}\) </td>
   <td style="text-align:center;"> \(\bar{Y}_{.2.} - \bar{Y}_{.1.}\) </td>
  </tr>
  <tr>
   <td style="text-align:center;"> \(C\) </td>
   <td style="text-align:center;"> \(\bar{Y}_{112} - \bar{Y}_{111}\) </td>
   <td style="text-align:center;"> \(\frac{(\bar{Y}_{..2} - \bar{Y}_{..1})}{2}\) </td>
   <td style="text-align:center;"> \(\bar{Y}_{..2} - \bar{Y}_{..1}\) </td>
  </tr>
  <tr>
   <td style="text-align:center;"> \(AB\) </td>
   <td style="text-align:center;"> \((\bar{Y}_{221} - \bar{Y}_{121}) - (\bar{Y}_{211} - \bar{Y}_{111})\) </td>
   <td style="text-align:center;"> \(\frac{(\bar{Y}_{22.} - \bar{Y}_{12.}) - (\bar{Y}_{21.} - \bar{Y}_{11.})}{4}\) </td>
   <td style="text-align:center;"> \((\bar{Y}_{22.} - \bar{Y}_{12.}) - (\bar{Y}_{21.} - \bar{Y}_{11.})\) </td>
  </tr>
  <tr>
   <td style="text-align:center;"> \(AC\) </td>
   <td style="text-align:center;"> \((\bar{Y}_{212} - \bar{Y}_{211}) - (\bar{Y}_{112} - \bar{Y}_{111})\) </td>
   <td style="text-align:center;"> \(\frac{(\bar{Y}_{2.2} - \bar{Y}_{1.2}) - (\bar{Y}_{2.1} - \bar{Y}_{1.1})}{4}\) </td>
   <td style="text-align:center;"> \((\bar{Y}_{2.2} - \bar{Y}_{1.2}) - (\bar{Y}_{2.1} - \bar{Y}_{1.1})\) </td>
  </tr>
  <tr>
   <td style="text-align:center;"> \(BC\) </td>
   <td style="text-align:center;"> \((\bar{Y}_{122} - \bar{Y}_{112}) - (\bar{Y}_{121} - \bar{Y}_{111})\) </td>
   <td style="text-align:center;"> \(\frac{(\bar{Y}_{.22} - \bar{Y}_{.12}) - (\bar{Y}_{.21} - \bar{Y}_{.11})}{4}\) </td>
   <td style="text-align:center;"> \((\bar{Y}_{.22} - \bar{Y}_{.12}) - (\bar{Y}_{.21} - \bar{Y}_{.11})\) </td>
  </tr>
</tbody>
</table>

For the three way \(A \times B \times C\) interaction:

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:center;"> scheme </th>
   <th style="text-align:center;"> interpretation </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:center;"> treatment </td>
   <td style="text-align:center;"> \(\displaystyle\left[\displaystyle\left(\bar{Y}_{221} - \bar{Y}_{121}\right) - \displaystyle\left(\bar{Y}_{211} - \bar{Y}_{111}\right)\right] - \displaystyle\left[\displaystyle\left(\bar{Y}_{222} - \bar{Y}_{122}\right) - \displaystyle\left(\bar{Y}_{212} - \bar{Y}_{112}\right)\right]\) </td>
  </tr>
  <tr>
   <td style="text-align:center;"> sum </td>
   <td style="text-align:center;"> \(\frac{\displaystyle\left[\displaystyle\left(\bar{Y}_{221} - \bar{Y}_{121}\right) - \displaystyle\left(\bar{Y}_{211} - \bar{Y}_{111}\right)\right] - \displaystyle\left[\displaystyle\left(\bar{Y}_{222} - \bar{Y}_{122}\right) - \displaystyle\left(\bar{Y}_{212} - \bar{Y}_{112}\right)\right]}{8}\) </td>
  </tr>
  <tr>
   <td style="text-align:center;"> deviation </td>
   <td style="text-align:center;"> \(\displaystyle\left[\displaystyle\left(\bar{Y}_{221} - \bar{Y}_{121}\right) - \displaystyle\left(\bar{Y}_{211} - \bar{Y}_{111}\right)\right] - \displaystyle\left[\displaystyle\left(\bar{Y}_{222} - \bar{Y}_{122}\right) - \displaystyle\left(\bar{Y}_{212} - \bar{Y}_{112}\right)\right]\) </td>
  </tr>
</tbody>
</table>

Note that the inferential tests of $A \times B \times C$ will all have the same outcome, despite the parameter estimate for sum coding being one-eighth of that for the other schemes.  For all lower-order effects, sum and deviation coding will give different parameter estimates but identical inferential outcomes.  Both of these schemes provide identical tests of the canonical main effects and main interactions for a three-way ANOVA.  In contrast, treatment (dummy) coding will provide inferential tests of simple effects and simple interactions.  So, if what you are interested in getting are the "canonical" tests from ANOVA, use sum or deviation coding.

### What about factors with more than two levels?

A factor with \(k\) levels requires \(k-1\) variables. Each predictor contrasts a particular "target" level of the factor with a level that you (arbitrarily) choose as the "baseline" level.  For instance, for a three-level factor \(A\) with \(A1\) chosen as the baseline, you'd have two predictor variables, one of which compares \(A2\) to \(A1\) and the other of which compares \(A3\) to \(A1\).

For treatment (dummy) coding, the target level is set to 1, otherwise 0.

For sum coding, the levels must sum to zero, so for a given predictor, the target level is given the value 1, the baseline level is given the value -1, and any other level is given the value 0.

For deviation coding, the values must also sum to 0. Deviation coding is recommended whenever you are trying to draw ANOVA-style inferences. Under this scheme, the target level gets the value \(\frac{k-1}{k}\) while any non-target level gets the value \(-\frac{1}{k}\).   

**Fun fact**: Mean-centering treatment codes (on balanced data) will give you deviation codes.

### Example: Three-level factor

#### Treatment (Dummy)

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> level </th>
   <th style="text-align:right;"> A2v1 </th>
   <th style="text-align:right;"> A3v1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> A1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> A2 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> A3 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
</tbody>
</table>

#### Sum

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> level </th>
   <th style="text-align:right;"> A2v1 </th>
   <th style="text-align:right;"> A3v1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> A1 </td>
   <td style="text-align:right;"> -1 </td>
   <td style="text-align:right;"> -1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> A2 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> A3 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
</tbody>
</table>

#### Deviation

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> level </th>
   <th style="text-align:right;"> A2v1 </th>
   <th style="text-align:right;"> A3v1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> A1 </td>
   <td style="text-align:right;"> \(-\frac{1}{3}\) </td>
   <td style="text-align:right;"> \(-\frac{1}{3}\) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> A2 </td>
   <td style="text-align:right;"> \(\frac{2}{3}\) </td>
   <td style="text-align:right;"> \(-\frac{1}{3}\) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> A3 </td>
   <td style="text-align:right;"> \(-\frac{1}{3}\) </td>
   <td style="text-align:right;"> \(\frac{2}{3}\) </td>
  </tr>
</tbody>
</table>

#### Example: Five-level factor

#### Treatment (Dummy)

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> level </th>
   <th style="text-align:right;"> A2v1 </th>
   <th style="text-align:right;"> A3v1 </th>
   <th style="text-align:right;"> A4v1 </th>
   <th style="text-align:right;"> A5v1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> A1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> A2 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> A3 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> A4 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> A5 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
</tbody>
</table>

#### Sum


<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> level </th>
   <th style="text-align:right;"> A2v1 </th>
   <th style="text-align:right;"> A3v1 </th>
   <th style="text-align:right;"> A4v1 </th>
   <th style="text-align:right;"> A5v1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> A1 </td>
   <td style="text-align:right;"> -1 </td>
   <td style="text-align:right;"> -1 </td>
   <td style="text-align:right;"> -1 </td>
   <td style="text-align:right;"> -1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> A2 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> A3 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> A4 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> A5 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
</tbody>
</table>

#### Deviation

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> level </th>
   <th style="text-align:right;"> A2v1 </th>
   <th style="text-align:right;"> A3v1 </th>
   <th style="text-align:right;"> A4v1 </th>
   <th style="text-align:right;"> A5v1 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> A1 </td>
   <td style="text-align:right;"> \(-\frac{1}{5}\) </td>
   <td style="text-align:right;"> \(-\frac{1}{5}\) </td>
   <td style="text-align:right;"> \(-\frac{1}{5}\) </td>
   <td style="text-align:right;"> \(-\frac{1}{5}\) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> A2 </td>
   <td style="text-align:right;"> \(\frac{4}{5}\) </td>
   <td style="text-align:right;"> \(-\frac{1}{5}\) </td>
   <td style="text-align:right;"> \(-\frac{1}{5}\) </td>
   <td style="text-align:right;"> \(-\frac{1}{5}\) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> A3 </td>
   <td style="text-align:right;"> \(-\frac{1}{5}\) </td>
   <td style="text-align:right;"> \(\frac{4}{5}\) </td>
   <td style="text-align:right;"> \(-\frac{1}{5}\) </td>
   <td style="text-align:right;"> \(-\frac{1}{5}\) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> A4 </td>
   <td style="text-align:right;"> \(-\frac{1}{5}\) </td>
   <td style="text-align:right;"> \(-\frac{1}{5}\) </td>
   <td style="text-align:right;"> \(\frac{4}{5}\) </td>
   <td style="text-align:right;"> \(-\frac{1}{5}\) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> A5 </td>
   <td style="text-align:right;"> \(-\frac{1}{5}\) </td>
   <td style="text-align:right;"> \(-\frac{1}{5}\) </td>
   <td style="text-align:right;"> \(-\frac{1}{5}\) </td>
   <td style="text-align:right;"> \(\frac{4}{5}\) </td>
  </tr>
</tbody>
</table>

### How to create your own numeric predictors

Let's assume that your data is contained in a table `dat` like the one below.


```r
 ## create your own numeric predictors
 ## make an example table
 dat <- tibble(Y = rnorm(12),
               A = rep(paste0("A", 1:3), each = 4))
```


<div class='solution'><button>Click to view example data</button>


<table class="table" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:right;"> Y </th>
   <th style="text-align:left;"> A </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 0.41 </td>
   <td style="text-align:left;"> A1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -0.25 </td>
   <td style="text-align:left;"> A1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.40 </td>
   <td style="text-align:left;"> A1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -0.64 </td>
   <td style="text-align:left;"> A1 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -0.09 </td>
   <td style="text-align:left;"> A2 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -1.56 </td>
   <td style="text-align:left;"> A2 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1.43 </td>
   <td style="text-align:left;"> A2 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.50 </td>
   <td style="text-align:left;"> A2 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -0.42 </td>
   <td style="text-align:left;"> A3 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.00 </td>
   <td style="text-align:left;"> A3 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -0.46 </td>
   <td style="text-align:left;"> A3 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> -0.67 </td>
   <td style="text-align:left;"> A3 </td>
  </tr>
</tbody>
</table>


</div>


#### The `mutate()` / `if_else()` / `case_when()` approach for a three-level factor

#### Treatment


```r
  ## examples of three level factors
  ## treatment coding
  dat_treat <- dat %>%
    mutate(A2v1 = if_else(A == "A2", 1L, 0L),
	   A3v1 = if_else(A == "A3", 1L, 0L))
```


<div class='solution'><button>Click to view resulting table</button>



```
## # A tibble: 12 x 4
##            Y A      A2v1  A3v1
##        <dbl> <chr> <int> <int>
##  1  0.407    A1        0     0
##  2 -0.248    A1        0     0
##  3  0.404    A1        0     0
##  4 -0.639    A1        0     0
##  5 -0.0853   A2        1     0
##  6 -1.56     A2        1     0
##  7  1.43     A2        1     0
##  8  0.500    A2        1     0
##  9 -0.419    A3        0     1
## 10  0.000205 A3        0     1
## 11 -0.462    A3        0     1
## 12 -0.672    A3        0     1
```


</div>


#### Sum


```r
## sum coding
dat_sum <- dat %>%
  mutate(A2v1 = case_when(A == "A1" ~ -1L, # baseline
                          A == "A2" ~ 1L,  # target
                          TRUE      ~ 0L), # anything else
         A3v1 = case_when(A == "A1" ~ -1L, # baseline
                          A == "A3" ~  1L, # target
                          TRUE      ~ 0L)) # anything else
```


<div class='solution'><button>Click to view resulting table</button>



```
## # A tibble: 12 x 4
##            Y A      A2v1  A3v1
##        <dbl> <chr> <int> <int>
##  1  0.407    A1       -1    -1
##  2 -0.248    A1       -1    -1
##  3  0.404    A1       -1    -1
##  4 -0.639    A1       -1    -1
##  5 -0.0853   A2        1     0
##  6 -1.56     A2        1     0
##  7  1.43     A2        1     0
##  8  0.500    A2        1     0
##  9 -0.419    A3        0     1
## 10  0.000205 A3        0     1
## 11 -0.462    A3        0     1
## 12 -0.672    A3        0     1
```


</div>


#### Deviation


```r
## deviation coding
## baseline A1
dat_dev <- dat %>%
  mutate(A2v1 = if_else(A == "A2", 2/3, -1/3), # target A2
         A3v1 = if_else(A == "A3", 2/3, -1/3)) # target A3
```


<div class='solution'><button>Click to view resulting table</button>



```r
dat_dev
```

```
## # A tibble: 12 x 4
##            Y A       A2v1   A3v1
##        <dbl> <chr>  <dbl>  <dbl>
##  1  0.407    A1    -0.333 -0.333
##  2 -0.248    A1    -0.333 -0.333
##  3  0.404    A1    -0.333 -0.333
##  4 -0.639    A1    -0.333 -0.333
##  5 -0.0853   A2     0.667 -0.333
##  6 -1.56     A2     0.667 -0.333
##  7  1.43     A2     0.667 -0.333
##  8  0.500    A2     0.667 -0.333
##  9 -0.419    A3    -0.333  0.667
## 10  0.000205 A3    -0.333  0.667
## 11 -0.462    A3    -0.333  0.667
## 12 -0.672    A3    -0.333  0.667
```


</div>


### Conclusion

**The interpretation of all but the highest order effect depends on the coding scheme.**

With treatment coding, you are looking at **simple** effects and **simple** interactions, not **main** effects and **main** interactions.

**The parameter estimates for sum coding differs from deviation coding only in the magnitude of the parameter estimates, but have identical interpretations.**

Because it is not subject to the scaling effects seen under sum coding, deviation should be used by default for ANOVA-style designs.

**The default coding scheme for factors is R is "treatment" coding.**

So, anytime you declare a variable as type `factor` and use this variable as a predictor in your regression model, R will automatically create treatment-coded variables.

<div class="warning">

**Take-home message: when analyzing factorial designs in R using regression, to obtain the canonical ANOVA-style interpretations of main effects and interactions use deviation coding and NOT the default treatment coding.**

</div>

## Replacing t-test and ANOVA with linear mixed-effects regression

As we have been emphasizing throughout this course, most data in psychology is multi-level---there are multiple observations on the DV for each subject. 

In the last chapter, we saw how to perform multilevel linear regression with a continuous predictor. In this section, we'll see how a mixed-effects model can be used to replace a wide variety of standard techniques used in psychology for multi-level data with categorical predictors. Indeed, a very simple model with random intercepts can replace the following techniques, if they are used on **multi-level data**:

* one sample t-test
* between-subjects designs
    - independent samples t-test
    - one factor or factorial ANOVA
* within-subjects designs
    - paired samples t-tests
    - one factor repeated measures ANOVA
    - mixed-design ANOVA
    - within-subjects factorial ANOVA

### Example: Independent-samples $t$-test on multi-level data

Let's consider a situation where you are testing the effect of alcohol consumption on simple reaction time (e.g., press a button as fast as you can after a light appears). To keep it simple, let's assume that you have collected data from 14 participants randomly assigned to perform a set of 10 simple RT trials after one of two interventions: drinking a pint of alcohol (treatment condition) or a placebo drink (placebo condition).  You have 7 participants in each of the two groups. Note that you would need more than this for a real study.

The web app below presents simulated data from such a study. Subjects P01-P07 are from the placebo condition, while subjects T01-T07 are from the treatment condition.

<div class="figure" style="text-align: center">
<iframe src="http://shiny.psy.gla.ac.uk/Dale/icc?showcase=0" width="100%" height="620px"></iframe>
<p class="caption">(\#fig:icc-app)Multi-level data from an independent samples design.</p>
</div>

If we were going to run a t-test on these data, we would first need to calculate subject means, because otherwise the observations are not independent. You could do this as follows. (If you want to run the code below, you can download sample data from the web app above and save it as `independent_samples.csv`).


```r
library("tidyverse")

dat <- read_csv("data/independent_samples.csv", col_types = "cci")

subj_means <- dat %>%
  group_by(subject, cond) %>%
  summarise(mean_rt = mean(RT)) %>%
  ungroup()

subj_means
```

```
## # A tibble: 14 x 3
##    subject cond  mean_rt
##    <chr>   <chr>   <dbl>
##  1 P01     P        354 
##  2 P02     P        384.
##  3 P03     P        391.
##  4 P04     P        404.
##  5 P05     P        421.
##  6 P06     P        392 
##  7 P07     P        400.
##  8 T08     T        430.
##  9 T09     T        432.
## 10 T10     T        410.
## 11 T11     T        455.
## 12 T12     T        450.
## 13 T13     T        418.
## 14 T14     T        489.
```

Then, the $t$-test can be run using the "formula" version of `t.test()`.


```r
t.test(mean_rt ~ cond, subj_means)
```

```
## 
## 	Welch Two Sample t-test
## 
## data:  mean_rt by cond
## t = -3.7985, df = 11.32, p-value = 0.002807
## alternative hypothesis: true difference in means is not equal to 0
## 95 percent confidence interval:
##  -76.32580 -20.44563
## sample estimates:
## mean in group P mean in group T 
##        392.3143        440.7000
```

While there is nothing wrong with this analysis, aggregating the data throws away information. we can see in the above web app that there are actually two different sources of variability: trial-by-trial variability in simple RT (represented by $\sigma$) and variability across subjects in terms of their how slow or fast they are relative to the population mean ($\gamma_{00}$).  The Data Generating Process for response time ($Y_{st}$) for subject $s$ on trial $t$ is shown below.

*Level 1:*

\begin{equation}
Y_{st} = \beta_{0s} + \beta_{1} X_{s} + e_{st}
\end{equation}

*Level 2:*

\begin{equation}
\beta_{0s} = \gamma_{00} + S_{0s}
\end{equation}

\begin{equation}
\beta_{1} = \gamma_{10}
\end{equation}

*Variance Components:*

\begin{equation}
S_{0s} \sim N\left(0, {\tau_{00}}^2\right) 
\end{equation}

\begin{equation}
e_{st} \sim N\left(0, \sigma^2\right)
\end{equation}

In the above equation, $X_s$ is a numerical predictor coding which condition the subject $s$ is in; e.g., 0 for placebo, 1 for treatment.

The multi-level equations are somewhat cumbersome for such a simple model; we could just reduce levels 1 and 2 to 

\begin{equation}
Y_{st} = \gamma_{00} + S_{0s} + \gamma_{10} X_s + e_{st},
\end{equation}

but it is worth becoming familiar with the multi-level format for when we encounter more complex designs.

Unlike the `sleepstudy` data seen in the last chapter, we only have one random effect for each subject, $S_{0s}$. There is no random slope. Each subject appears in only one of the two treatment conditions, so it would not be possible to estimate how the effect of placebo versus alcohol varies over subjects.  The mixed-effects model that we would fit to these data, with random intercepts but no random slopes, is known as a **random intercepts model**.

A random-intercepts model would adequately capture the two sources of variability mentioned above: the inter-subject variability in overall mean RT in the parameter ${\tau_{00}}^2$, and the trial-by-trial variability in the parameter $\sigma^2$. We can calculate the proportion of the total variability attributable to individual differences among subjects using the formula below.

$$ICC = \frac{{\tau_{00}}^2}{{\tau_{00}}^2 + \sigma^2}$$

This quantity, known as the **intra-class correlation coefficient**, and tells you how much clustering there is in your data. It ranges from 0 to 1, with 0 indicating that all the variability is due to residual variance, and 1 indicating that all the variability is due to individual differences among subjects.

The lmer syntax for fitting a random intercepts model to the data is `lmer(RT ~ cond + (1 | subject), dat, REML=FALSE)`. Let's create our own numerical predictor first, to make it explicit that we are using dummy coding.


```r
dat2 <- dat %>%
  mutate(cond_d = if_else(cond == "T", 1L, 0L))

distinct(dat2, cond, cond_d)  ## double check
```

```
## # A tibble: 2 x 2
##   cond  cond_d
##   <chr>  <int>
## 1 P          0
## 2 T          1
```

And now, estimate the model.


```r
library("lme4")

mod <- lmer(RT ~ cond_d + (1 | subject), dat2, REML = FALSE)

summary(mod)
```

```
## Linear mixed model fit by maximum likelihood  ['lmerMod']
## Formula: RT ~ cond_d + (1 | subject)
##    Data: dat2
## 
##      AIC      BIC   logLik deviance df.resid 
##   1451.8   1463.5   -721.9   1443.8      136 
## 
## Scaled residuals: 
##      Min       1Q   Median       3Q      Max 
## -2.67117 -0.66677  0.01656  0.75361  2.58447 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev.
##  subject  (Intercept)  329.3   18.15   
##  Residual             1574.7   39.68   
## Number of obs: 140, groups:  subject, 14
## 
## Fixed effects:
##             Estimate Std. Error t value
## (Intercept)  392.314      8.339  47.045
## cond_d        48.386     11.793   4.103
## 
## Correlation of Fixed Effects:
##        (Intr)
## cond_d -0.707
```

Play around with the sliders in the app above and check the lmer output panel until you understand how the output maps onto the model parameters.

### When is a random-intercepts model appropriate?

The random-intercepts model is appropriate for any one-sample or between-subjects data where you have multiple observations per participant. The data **must** be multi-level, because in single-level designs the subject variability is perfectly confounded with residual variability, making it impossible for the estimation algorithm to distinguish the two sources.

A random-intercepts model is **sometimes** appropriate for within-subjects or mixed-design data. For designs where there is at least one within-subjects factor, and where you are performing analyses on subject means, it is generally the case that a random-intercepts model is appropriate.

In a design with a single within-subjects factor, it is **only** appropriate when you have a single observation per subject per level of the within-subject factor. If you have more than one observation per subject per level, you need to enrich your random effects structure with random slopes, as described in the next section. If the reason you have multiple observations per subject per level is because you have each subject reacting to the same set of stimuli, then you might want to consider a mixed-effects model with crossed random effects for subjects and stimuli, as described in the next chapter. If you have sets of individual subject means on which you would normally perform a paired-samples t-test or repeated measures ANOVA, that would be data for which the random-intercepts model would be appropriate. 

The same logic goes for factorial designs in which there is more than one within-subjects factor. In factorial designs, the random-intercepts model is appropriate if you have one observation per subject per **cell** formed by each combination of the within-subjects factors. For instance, if $A$ and $B$ are two two-level within-subject factors, you need to check that you have only one observation for each subject in $A_1B_1$, $A_1B_2$, $A_2B_1$, and $A_2B_2$. If you have more than one observation, you will need to consider including a random slope in your model.

### Rules for choosing random effects

For designs having at least one within-subject factor, it is typically the case that you need to also consider including random slopes for certain factors.  We will go into this in more detail in the next chapter, where we will consider more complex designs, but here are the basic guidelines.

For categorical factor $A$, you need to consider a random slope for $A$ in the model if **both** of the following criteria are met:

1. $A$ is a within-subjects factor;
2. Each subject has multiple observations on the dependent variable for each level of $A$.

You would specify a random slope for $A$ using the following model syntax:

`DV ~ A + (A | subject)`

where `DV` is the name of your dependent variable and `subject` is the name of the variable you use to identify subjects.

What about interactions? If you have a design with three factors, $A$, $B$, and $C$, you have three main effects, three two-way interactions ($AB$, $AC$, and $BC$), and one three-way interaction $ABC$. So there are 7 possible random slopes to consider. Which of these effects would need a random slope? Here are the steps you need to follow to figure it out for each interaction term.

1. If all factors involved in the interaction are between subjects, you don't need a slope.
2. Identify the highest-order combination of within-subject factors included in the interaction. So if $A$ and $B$ are within-subject factors and $C$ is between subjects, then $AB$ is the highest order combination. If $A$ is within subjects and $B$ and $C$ are between subjects, then $A$ is the highest order combination.
3. Check whether each subject has multiple observations on the DV in each cell (or level) resulting from the combination of the within factors you identified in the previous step. If you do, then you need a random slope. If you have only one observation per subject/cell combination, then you don't.
