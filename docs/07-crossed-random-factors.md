# Linear mixed-effects models with crossed random factors

## Learning objectives

* simulate data for a design with crossed random factors of subjects and stimuli
* estimate parameters for linear mixed-effects models with crossed random factors

## Web app

- [Demo of crossed random effects](https://shiny.psy.gla.ac.uk/Dale/crossed)

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




## Specifying random effects

We'll start out with some interactive tasks where you are given data to examine and asked to specify the maximal random effects structure. The data are stored in [this zip file](data/rfx_data.zip). The archive includes four R binary files (`.rds`), which you can load in using the `readRDS()` function. Extract it and set your working directory to where the resulting subdirectory `rfx_data/` is located. 

Use the code below to load them in.




```r
ds1 <- readRDS("rfx_data/dataset1.rds")
ds2 <- readRDS("rfx_data/dataset2.rds")
ds3 <- readRDS("rfx_data/dataset3.rds")
ds4 <- readRDS("rfx_data/dataset4.rds")
```

Each object has data from a hypothetical study with a factorial design. Your task is to specify the design formula for the mixed-effects model you would fit to the data. To determine the appropriate design, you will need to inspect each dataset carefully. You want to treat subjects and stimuli as random factors. If the dataset does not include one of the random factors you can omit it from the formula.

Each dataset may have some or all of the following variables:

| Variable  | Description                                 |
|-----------+---------------------------------------------|
| `subj_id` | subject identifier                          |
| `item_id` | stimulus identifier                         |
| `A`       | a categorical factor (independent variable) |
| `B`       | a categorical factor (independent variable) |
| `C`       | a categorical factor (independent variable) |
| `DV`      | the dependent variable                      |

Your task is to determine the appropriate mixed-effects model specification including the maximal random-effects structure, and write the `formula` part of the `lme4::lmer()` model as your answer.  For all of the models, the variable `DV` should appear on the left-hand side of the formula; i.e., it should be of the form `DV ~ A + ...`.  If a given dataset includes both `subj_id` and `item_id`, you need to specify random effects for both of them; if not, only specify the random effects for the one that appear in the data.  Likewise, any IV that does not appear in the dataset should not be included anywhere in the formula.

For instance, had one of these datasets been the `lme4::sleepstudy` data, you would have replaced `ss_form <- NULL` with:


```r
ss_form <- Reaction ~ Days + (Days | Subject)
```

In other words: __all you need is the formula, NOT the call to `lme4::lmer()`; you are not actually fitting any model to the data.__

#### Dataset 1

Investigate the experimental design for `dataset1` and type the appropriate model formula.


<div class='solution'><button>Solution</button>


`DV ~ A * B * C + (A * B | subj_id)`


```r
ds1 %>% count(subj_id, A, B, C) %>% filter(subj_id == 1L)
```

```
## # A tibble: 4 x 5
##   subj_id A     B     C         n
##     <int> <chr> <chr> <chr> <int>
## 1       1 A1    B1    C2        4
## 2       1 A1    B2    C2        4
## 3       1 A2    B1    C2        4
## 4       1 A2    B2    C2        4
```


</div>


#### Dataset 2

Investigate the experimental design for `dataset2` and type the appropriate model formula.


<div class='solution'><button>Solution</button>


```
DV ~ A * B * C + (A + B + C + A:B + A:C + B:C | subj_id) +
                 (A * B * C | item_id)
```


```r
ds2 %>% count(subj_id, A, B, C) %>% filter(subj_id == 1L)
```

```
## # A tibble: 8 x 5
##   subj_id A     B     C         n
##     <int> <chr> <chr> <chr> <int>
## 1       1 A1    B1    C1        1
## 2       1 A1    B1    C2        1
## 3       1 A1    B2    C1        1
## 4       1 A1    B2    C2        1
## 5       1 A2    B1    C1        1
## 6       1 A2    B1    C2        1
## 7       1 A2    B2    C1        1
## 8       1 A2    B2    C2        1
```

#### Dataset 3

Investigate the experimental design for `dataset3` and type the appropriate model formula.


<div class='solution'><button>Solution</button>


`DV ~ A * B + (A | subj_id) + (B | item_id)`


```r
ds3 %>% count(subj_id, A, B) %>% filter(subj_id == 1L)
```

```
## # A tibble: 2 x 4
##   subj_id A     B         n
##     <int> <chr> <chr> <int>
## 1       1 A1    B2        4
## 2       1 A2    B2        4
```


```r
ds3 %>% count(item_id, A, B) %>% filter(item_id == 1L)
```

```
## # A tibble: 2 x 4
##   item_id A     B         n
##     <int> <chr> <chr> <int>
## 1       1 A1    B1        4
## 2       1 A1    B2        4
```


</div>


#### Dataset 4

Investigate the experimental design for `dataset4` and type the appropriate model formula.


<div class='solution'><button>Solution</button>


`DV ~ A * B + (1 | subj_id) + (A * B | item_id)`


```r
ds4 %>% count(subj_id, A, B) %>% filter(subj_id == 1L)
```

```
## # A tibble: 1 x 4
##   subj_id A     B         n
##     <int> <chr> <chr> <int>
## 1       1 A1    B1       16
```


```r
ds4 %>% count(item_id, A, B) %>% filter(item_id == 1L)
```

```
## # A tibble: 4 x 4
##   item_id A     B         n
##     <int> <chr> <chr> <int>
## 1       1 A1    B1        4
## 2       1 A1    B2        4
## 3       1 A2    B1        4
## 4       1 A2    B2        4
```


</div>


## Simulating data with crossed random factors

For this first set of exercises, we will generate simulated data corresponding to an experiment with a single, two-level factor (independent variable) that is within-subjects and between-items.  Let's imagine that the experiment involves lexical decisions to a set of words (e.g., is "PINT" a word or nonword?), and the dependent variable is response time (in milliseconds), and the independent variable is word type (noun vs verb).  We want to treat both subjects and words as random factors (so that we can generalize to the population of events where subjects encounter words).  You can play around with the web app below (or [click here to open it in a new window](https://shiny.psy.gla.ac.uk/Dale/crossed){target="_blank"}), which allows you to manipulate the data-generating parameters and see their effect on the data.

<div class="figure" style="text-align: center">
<iframe src="https://shiny.psy.gla.ac.uk/Dale/crossed?showcase=0" width="100%" height="600px"></iframe>
<p class="caption">(\#fig:webapp)*Web app for crossed random effects.*</p>
</div>

Here is the DGP for response time $Y_{si}$ for subject $s$ and item $i$:

*Level 1:*

\begin{equation}
Y_{si} = \beta_{0s} + \beta_{1} X_{i} + e_{si}
\end{equation}

*Level 2:*

\begin{equation}
\beta_{0s} = \gamma_{00} + S_{0s} + I_{0i}
\end{equation}

\begin{equation}
\beta_{1} = \gamma_{10} + S_{1s}
\end{equation}

*Variance Components:*

\begin{equation}
\langle S_{0s}, S_{1s} \rangle \sim N\left(0, \mathbf{\Sigma}\right) 
\end{equation}

\begin{equation}
\mathbf{\Sigma} = \left(\begin{array}{cc}{\tau_{00}}^2 & \rho\tau_{00}\tau_{11} \\
         \rho\tau_{00}\tau_{11} & {\tau_{11}}^2 \\
         \end{array}\right) 
\end{equation}

\begin{equation}
I_{0s} \sim N\left(0, {\omega_{00}}^2\right) 
\end{equation}

\begin{equation}
e_{si} \sim N\left(0, \sigma^2\right)
\end{equation}

In the above equation, $X_i$ is a numerical predictor coding which condition the item $i$ is in; e.g., -.5 for noun, .5 for verb.

We could just reduce levels 1 and 2 to 

$$Y_{si} = \beta_0 + S_{0s} + I_{0i} + (\beta_1 + S_{1s})X_{i} + e_{si}$$

where:

|Parameter    | Symbol| Description                                       |
|:------------|:------|:--------------------------------------------------|
| \(Y_{si}\)  | `Y`   | RT for subject \(s\) responding to item \(i\);    |
| \(\beta_0\) | `b0`  | grand mean;                                       |
| \(S_{0s}\)  | `S_0s` | random intercept for subject \(s\);               |
| \(I_{0i}\)  | `I_0i` | random intercept for item \(i\);                  |
| \(\beta_1\) | `b1` | fixed effect of word type (slope);                |
| \(S_{1s}\)  | `S_1s` | by-subject random slope;                          |
| \(X_{i}\)   | `cond` | deviation-coded predictor variable for word type; |
| \(\tau_{00}\) | `tau_00` | by-subject random intercept standard deviation |
| \(\tau_{11}\) | `tau_11` | by-subject random slope standard deviation |
| \(\rho\)    | `rho` | correlation between random intercept and slope |
| \(\omega_{00}\) | `omega_00` | by-item random intercept standard deviation |
| \(e_{si}\)  | `err` | residual error                                   |
| \(\sigma\)  | `sig` | residual error standard deviation                 |

### Set up the environment and define the parameters for the DGP

If you want to get the same results as everyone else for this exercise, then we all should seed the random number generator with the same value.  While we're at it, let's load in the packages we need.


```r
library("lme4")
library("tidyverse")

set.seed(11709)  
```

Now let's define the parameters for the DGP (data generating process).


```r
nsubj <- 100 # number of subjects
nitem <- 50  # must be an even number

b0 <- 800 # grand mean
b1 <- 80 # 80 ms difference
effc <- c(-.5, .5) # deviation codes

omega_00 <- 80 # by-item random intercept sd (omega_00)

## for the by-subjects variance-covariance matrix
tau_00 <- 100 # by-subject random intercept sd
tau_11 <- 40 # by-subject random slope sd
rho <- .2 # correlation between intercept and slope

sig <- 200 # residual (standard deviation)
```

You'll create three tables:

| Name       | Description                                                          |
|:-----------|:---------------------------------------------------------------------|
| `subjects` | table of subject data including `subj_id` and subject random effects |
| `items`    | table of stimulus data including `item_id` and item random effect    |
| `trials`   | table of trials enumerating encounters between subjects/stimuli      |

Then you will merge together the information in the three tables, and calculate the response variable according to the model formula above.

** Generate a sample of stimuli

Let's randomly generate our 50 items. Create a tibble called `item` like the one below, where `iri` are the by-item random intercepts (drawn from a normal distribution with variance \(\omega_{00}^2\) ` `iri_sd^2`).  Half of the words are of type NOUN (`cond` ` -.5) and half of type VERB (`cond` ` .5).


```r
items <- tibble(item_id = 1:nitem,
                cond = rep(c(-.5, .5), times = nitem / 2),
                I_0i = rnorm(nitem, 0, sd = omega_00))
```


```r
items
```

```
## # A tibble: 50 x 3
##    item_id  cond  I_0i
##      <int> <dbl> <dbl>
##  1       1  -0.5  14.9
##  2       2   0.5 -86.3
##  3       3  -0.5 -12.8
##  4       4   0.5 -13.9
##  5       5  -0.5  55.6
##  6       6   0.5 -45.9
##  7       7  -0.5 -42.0
##  8       8   0.5 -87.6
##  9       9  -0.5 -97.4
## 10      10   0.5 -85.2
## # … with 40 more rows
```


<div class='solution'><button>Hint for making cond</button>


`rep()`


</div>



<div class='solution'><button>Hint for making item random effects</button>


`rnorm()`


</div>



<div class='solution'><button>Solution</button>



```r
items <- tibble(item_id = 1:nitem,
                cond = rep(c(-.5, .5), times = nitem / 2),
                I_0i = rnorm(nitem, 0, sd = omega_00))

items
```


```
## # A tibble: 50 x 3
##    item_id  cond  I_0i
##      <int> <dbl> <dbl>
##  1       1  -0.5  14.9
##  2       2   0.5 -86.3
##  3       3  -0.5 -12.8
##  4       4   0.5 -13.9
##  5       5  -0.5  55.6
##  6       6   0.5 -45.9
##  7       7  -0.5 -42.0
##  8       8   0.5 -87.6
##  9       9  -0.5 -97.4
## 10      10   0.5 -85.2
## # … with 40 more rows
```


</div>


### Generate a sample of subjects

To generate the by-subject random effects, you will need to generate data from a *bivariate normal distribution*.  To do this, we will use the function `MASS::mvrnorm`.  

<div class="warning">

REMEMBER: do not run `library("MASS")` just to get this one function, because `MASS` has a function `select()` that will overwrite the tidyverse version. Since all we want from MASS is the `mvrnorm()` function, we can just access it directly by the `pkgname::function` syntax, i.e., `MASS::mvrnorm()`.

</div>

Your subjects table should look like this:


<div class='solution'><button>Click to reveal full table</button>



```
## # A tibble: 100 x 3
##     subj_id      S_0s     S_1s
##       <int>     <dbl>    <dbl>
##   1       1  -80.0      -0.763
##   2       2   44.6      54.5  
##   3       3    8.74    -20.4  
##   4       4  -38.6     -23.8  
##   5       5  -83.3      29.2  
##   6       6  -70.9     -13.8  
##   7       7  -21.4      46.0  
##   8       8    2.33      8.39 
##   9       9   62.3     -58.2  
##  10      10  238.        7.72 
##  11      11  -92.5       2.14 
##  12      12   58.5     -65.8  
##  13      13 -204.      -38.8  
##  14      14  -91.6       5.46 
##  15      15   51.1     -38.8  
##  16      16  142.      -12.9  
##  17      17   46.0       6.60 
##  18      18  -56.7     -54.8  
##  19      19  -10.1      62.1  
##  20      20 -226.      -19.3  
##  21      21 -158.      -18.5  
##  22      22  102.        8.99 
##  23      23  -12.7     -70.6  
##  24      24  135.       -9.50 
##  25      25   62.0     -52.5  
##  26      26    0.0653   32.8  
##  27      27 -117.       70.8  
##  28      28 -232.        3.43 
##  29      29   70.9      50.8  
##  30      30 -123.       22.8  
##  31      31  268.       30.0  
##  32      32  -18.7     -25.0  
##  33      33   50.8     -31.0  
##  34      34  -43.1     -28.9  
##  35      35  -10.1      28.3  
##  36      36   65.6      18.2  
##  37      37 -123.       -4.63 
##  38      38  -94.8      10.3  
##  39      39   77.7     -22.5  
##  40      40  -59.1      52.4  
##  41      41  -91.2    -103.   
##  42      42  -66.6      -2.14 
##  43      43   -4.40      0.305
##  44      44   69.7      10.2  
##  45      45  -77.5     -10.4  
##  46      46  -17.8     -48.2  
##  47      47 -103.       47.0  
##  48      48   22.8     -39.3  
##  49      49  -31.1     -34.9  
##  50      50  -26.4      40.0  
##  51      51   47.8      26.0  
##  52      52  -93.2     -42.7  
##  53      53   28.9      51.4  
##  54      54  -19.3      11.5  
##  55      55   53.6      21.5  
##  56      56  -27.4     -21.4  
##  57      57  -67.7     -32.1  
##  58      58   59.2      13.4  
##  59      59  -53.1       2.44 
##  60      60  104.        7.41 
##  61      61  -20.7     -78.7  
##  62      62   55.9     -15.7  
##  63      63  114.      -29.1  
##  64      64  -57.7     -34.7  
##  65      65  -38.7      -9.14 
##  66      66 -106.      -58.0  
##  67      67   99.1     -37.6  
##  68      68  -56.9      21.0  
##  69      69  -50.4      -0.407
##  70      70   27.5      -2.69 
##  71      71  139.      -32.2  
##  72      72   44.9       8.53 
##  73      73  -14.8      71.7  
##  74      74   33.7     -52.6  
##  75      75    2.03     27.8  
##  76      76 -134.       37.0  
##  77      77   24.4      20.7  
##  78      78  -60.6     -36.7  
##  79      79   31.1      16.9  
##  80      80  -34.9       9.68 
##  81      81  206.       17.3  
##  82      82   -7.19    -25.4  
##  83      83  182.       46.0  
##  84      84   55.7      21.7  
##  85      85 -149.      -44.0  
##  86      86 -193.      -73.2  
##  87      87  167.       13.9  
##  88      88  160.        3.87 
##  89      89   84.1      82.1  
##  90      90   97.2      -6.55 
##  91      91 -205.     -125.   
##  92      92  -75.1       6.76 
##  93      93  -95.3     -46.5  
##  94      94  106.       38.6  
##  95      95  -42.4      11.3  
##  96      96   74.0     -21.1  
##  97      97 -245.      -25.3  
##  98      98 -113.       -1.88 
##  99      99   68.8      30.6  
## 100     100  136.       44.2
```


</div>



<div class='solution'><button>Hint 1</button>


recall that:

* *`tau_00`*: by-subject random intercept standard deviation
* *`tau_11`*: by-subject random slope standard deviation
* *`rho`* : correlation between intercept and slope


</div>



<div class='solution'><button>Hint 2</button>


`covariance = rho * tau_00 * tau_11`


</div>



<div class='solution'><button>Hint 3</button>



```r
matrix(    tau_00^2,            rho * tau_00 * tau_11,
        rho * tau_00 * tau_11,      tau_11^2, ...)
```


</div>



<div class='solution'><button>Hint 4</button>



```r
as_tibble(mx) %>%
  mutate(subj_id = ...)
```


</div>



<div class='solution'><button>Solution</button>



```r
cov <- rho * tau_00 * tau_11

mx <- matrix(c(tau_00^2, cov,
               cov,      tau_11^2),
             nrow = 2)

by_subj_rfx <- MASS::mvrnorm(nsubj, mu = c(S_0s = 0, S_1s = 0), Sigma = mx)

subjects <- as_tibble(by_subj_rfx) %>%
  mutate(subj_id = row_number()) %>%
  select(subj_id, everything())

subjects %>% print(n = +Inf)
```


```
## # A tibble: 100 x 3
##     subj_id      S_0s     S_1s
##       <int>     <dbl>    <dbl>
##   1       1  -80.0      -0.763
##   2       2   44.6      54.5  
##   3       3    8.74    -20.4  
##   4       4  -38.6     -23.8  
##   5       5  -83.3      29.2  
##   6       6  -70.9     -13.8  
##   7       7  -21.4      46.0  
##   8       8    2.33      8.39 
##   9       9   62.3     -58.2  
##  10      10  238.        7.72 
##  11      11  -92.5       2.14 
##  12      12   58.5     -65.8  
##  13      13 -204.      -38.8  
##  14      14  -91.6       5.46 
##  15      15   51.1     -38.8  
##  16      16  142.      -12.9  
##  17      17   46.0       6.60 
##  18      18  -56.7     -54.8  
##  19      19  -10.1      62.1  
##  20      20 -226.      -19.3  
##  21      21 -158.      -18.5  
##  22      22  102.        8.99 
##  23      23  -12.7     -70.6  
##  24      24  135.       -9.50 
##  25      25   62.0     -52.5  
##  26      26    0.0653   32.8  
##  27      27 -117.       70.8  
##  28      28 -232.        3.43 
##  29      29   70.9      50.8  
##  30      30 -123.       22.8  
##  31      31  268.       30.0  
##  32      32  -18.7     -25.0  
##  33      33   50.8     -31.0  
##  34      34  -43.1     -28.9  
##  35      35  -10.1      28.3  
##  36      36   65.6      18.2  
##  37      37 -123.       -4.63 
##  38      38  -94.8      10.3  
##  39      39   77.7     -22.5  
##  40      40  -59.1      52.4  
##  41      41  -91.2    -103.   
##  42      42  -66.6      -2.14 
##  43      43   -4.40      0.305
##  44      44   69.7      10.2  
##  45      45  -77.5     -10.4  
##  46      46  -17.8     -48.2  
##  47      47 -103.       47.0  
##  48      48   22.8     -39.3  
##  49      49  -31.1     -34.9  
##  50      50  -26.4      40.0  
##  51      51   47.8      26.0  
##  52      52  -93.2     -42.7  
##  53      53   28.9      51.4  
##  54      54  -19.3      11.5  
##  55      55   53.6      21.5  
##  56      56  -27.4     -21.4  
##  57      57  -67.7     -32.1  
##  58      58   59.2      13.4  
##  59      59  -53.1       2.44 
##  60      60  104.        7.41 
##  61      61  -20.7     -78.7  
##  62      62   55.9     -15.7  
##  63      63  114.      -29.1  
##  64      64  -57.7     -34.7  
##  65      65  -38.7      -9.14 
##  66      66 -106.      -58.0  
##  67      67   99.1     -37.6  
##  68      68  -56.9      21.0  
##  69      69  -50.4      -0.407
##  70      70   27.5      -2.69 
##  71      71  139.      -32.2  
##  72      72   44.9       8.53 
##  73      73  -14.8      71.7  
##  74      74   33.7     -52.6  
##  75      75    2.03     27.8  
##  76      76 -134.       37.0  
##  77      77   24.4      20.7  
##  78      78  -60.6     -36.7  
##  79      79   31.1      16.9  
##  80      80  -34.9       9.68 
##  81      81  206.       17.3  
##  82      82   -7.19    -25.4  
##  83      83  182.       46.0  
##  84      84   55.7      21.7  
##  85      85 -149.      -44.0  
##  86      86 -193.      -73.2  
##  87      87  167.       13.9  
##  88      88  160.        3.87 
##  89      89   84.1      82.1  
##  90      90   97.2      -6.55 
##  91      91 -205.     -125.   
##  92      92  -75.1       6.76 
##  93      93  -95.3     -46.5  
##  94      94  106.       38.6  
##  95      95  -42.4      11.3  
##  96      96   74.0     -21.1  
##  97      97 -245.      -25.3  
##  98      98 -113.       -1.88 
##  99      99   68.8      30.6  
## 100     100  136.       44.2
```


</div>


### Generate a sample of encounters (trials)

Each trial is an *encounter* between a particular subject and stimulus.  In this experiment, each subject will see each stimulus.  Generate a table `trials` that lists the encounters in the experiments. Note: each participant encounters each stimulus item once.  Use the `crossing()` function to create all possible encounters.

Now apply this example to generate the table below, where `err` is the residual term, drawn from \(N \sim \left(0, \sigma^2\right)\), where \(\sigma\) is `err_sd`.


```
## # A tibble: 5,000 x 3
##    subj_id item_id    err
##      <int>   <int>  <dbl>
##  1       1       1  382. 
##  2       1       2  283. 
##  3       1       3   30.4
##  4       1       4 -282. 
##  5       1       5 -239. 
##  6       1       6   73.4
##  7       1       7  -98.4
##  8       1       8 -189. 
##  9       1       9 -410. 
## 10       1      10  102. 
## # … with 4,990 more rows
```



<div class='solution'><button>Solution</button>



```r
trials <- crossing(subj_id = subjects %>% pull(subj_id),
                   item_id = items %>% pull(item_id)) %>%
  mutate(err = rnorm(nrow(subjects) * nrow(items), mean = 0, sd = sig))
```


```
## # A tibble: 5,000 x 3
##    subj_id item_id    err
##      <int>   <int>  <dbl>
##  1       1       1  382. 
##  2       1       2  283. 
##  3       1       3   30.4
##  4       1       4 -282. 
##  5       1       5 -239. 
##  6       1       6   73.4
##  7       1       7  -98.4
##  8       1       8 -189. 
##  9       1       9 -410. 
## 10       1      10  102. 
## # … with 4,990 more rows
```


</div>


### Join `subjects`, `items`, and `trials`

Merge the information in `subjects`, `items`, and `trials` to create the full dataset `dat_sim`, which looks like this:


```
## # A tibble: 5,000 x 7
##    subj_id item_id  S_0s  I_0i   S_1s  cond    err
##      <int>   <int> <dbl> <dbl>  <dbl> <dbl>  <dbl>
##  1       1       1 -80.0  14.9 -0.763  -0.5  382. 
##  2       1       2 -80.0 -86.3 -0.763   0.5  283. 
##  3       1       3 -80.0 -12.8 -0.763  -0.5   30.4
##  4       1       4 -80.0 -13.9 -0.763   0.5 -282. 
##  5       1       5 -80.0  55.6 -0.763  -0.5 -239. 
##  6       1       6 -80.0 -45.9 -0.763   0.5   73.4
##  7       1       7 -80.0 -42.0 -0.763  -0.5  -98.4
##  8       1       8 -80.0 -87.6 -0.763   0.5 -189. 
##  9       1       9 -80.0 -97.4 -0.763  -0.5 -410. 
## 10       1      10 -80.0 -85.2 -0.763   0.5  102. 
## # … with 4,990 more rows
```


<div class='solution'><button>Solution</button>



```r
dat_sim <- subjects %>%
  inner_join(trials, "subj_id") %>%
  inner_join(items, "item_id") %>%
  arrange(subj_id, item_id) %>%
  select(subj_id, item_id, S_0s, I_0i, S_1s, cond, err)

dat_sim
```


```
## # A tibble: 5,000 x 7
##    subj_id item_id  S_0s  I_0i   S_1s  cond    err
##      <int>   <int> <dbl> <dbl>  <dbl> <dbl>  <dbl>
##  1       1       1 -80.0  14.9 -0.763  -0.5  382. 
##  2       1       2 -80.0 -86.3 -0.763   0.5  283. 
##  3       1       3 -80.0 -12.8 -0.763  -0.5   30.4
##  4       1       4 -80.0 -13.9 -0.763   0.5 -282. 
##  5       1       5 -80.0  55.6 -0.763  -0.5 -239. 
##  6       1       6 -80.0 -45.9 -0.763   0.5   73.4
##  7       1       7 -80.0 -42.0 -0.763  -0.5  -98.4
##  8       1       8 -80.0 -87.6 -0.763   0.5 -189. 
##  9       1       9 -80.0 -97.4 -0.763  -0.5 -410. 
## 10       1      10 -80.0 -85.2 -0.763   0.5  102. 
## # … with 4,990 more rows
```


</div>


### Create the response variable

Add the response variable `Y` to dat according to the model formula:

$$Y_{si} = \beta_0 + S_{0s} + I_{0i} + (\beta_1 + S_{1s})X_{i} + e_{si}$$

so that the resulting table (`dat_sim2`) looks like this:


```
## # A tibble: 5,000 x 8
##    subj_id item_id     Y  S_0s  I_0i   S_1s  cond    err
##      <int>   <int> <dbl> <dbl> <dbl>  <dbl> <dbl>  <dbl>
##  1       1       1 1078. -80.0  14.9 -0.763  -0.5  382. 
##  2       1       2  957. -80.0 -86.3 -0.763   0.5  283. 
##  3       1       3  698. -80.0 -12.8 -0.763  -0.5   30.4
##  4       1       4  464. -80.0 -13.9 -0.763   0.5 -282. 
##  5       1       5  497. -80.0  55.6 -0.763  -0.5 -239. 
##  6       1       6  787. -80.0 -45.9 -0.763   0.5   73.4
##  7       1       7  540. -80.0 -42.0 -0.763  -0.5  -98.4
##  8       1       8  483. -80.0 -87.6 -0.763   0.5 -189. 
##  9       1       9  173. -80.0 -97.4 -0.763  -0.5 -410. 
## 10       1      10  776. -80.0 -85.2 -0.763   0.5  102. 
## # … with 4,990 more rows
```

Note: this is the full **decomposition table** for this model.


<div class='solution'><button>Solution</button>



```r
dat_sim2 <- dat_sim %>%
  mutate(Y = b0 + S_0s + I_0i + (S_1s + b1) * cond + err) %>%
  select(subj_id, item_id, Y, everything())

dat_sim2
```


```
## # A tibble: 5,000 x 8
##    subj_id item_id     Y  S_0s  I_0i   S_1s  cond    err
##      <int>   <int> <dbl> <dbl> <dbl>  <dbl> <dbl>  <dbl>
##  1       1       1 1078. -80.0  14.9 -0.763  -0.5  382. 
##  2       1       2  957. -80.0 -86.3 -0.763   0.5  283. 
##  3       1       3  698. -80.0 -12.8 -0.763  -0.5   30.4
##  4       1       4  464. -80.0 -13.9 -0.763   0.5 -282. 
##  5       1       5  497. -80.0  55.6 -0.763  -0.5 -239. 
##  6       1       6  787. -80.0 -45.9 -0.763   0.5   73.4
##  7       1       7  540. -80.0 -42.0 -0.763  -0.5  -98.4
##  8       1       8  483. -80.0 -87.6 -0.763   0.5 -189. 
##  9       1       9  173. -80.0 -97.4 -0.763  -0.5 -410. 
## 10       1      10  776. -80.0 -85.2 -0.763   0.5  102. 
## # … with 4,990 more rows
```


</div>


## Fitting the model

Now that you have created simulated data, estimate the model using `lme4::lmer()`, and run `summary()`.


<div class='solution'><button>Solution</button>



```r
mod_sim <- lmer(Y ~ cond + (1 + cond | subj_id) + (1 | item_id),
                dat_sim2, REML = FALSE)

summary(mod_sim, corr = FALSE)
```

```
## Linear mixed model fit by maximum likelihood  ['lmerMod']
## Formula: Y ~ cond + (1 + cond | subj_id) + (1 | item_id)
##    Data: dat_sim2
## 
##      AIC      BIC   logLik deviance df.resid 
##  67639.4  67685.0 -33812.7  67625.4     4993 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -3.6357 -0.6599 -0.0251  0.6767  3.7685 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev. Corr
##  subj_id  (Intercept)  9464.8   97.29       
##           cond          597.7   24.45   0.68
##  item_id  (Intercept)  8087.0   89.93       
##  Residual             40305.0  200.76       
## Number of obs: 5000, groups:  subj_id, 100; item_id, 50
## 
## Fixed effects:
##             Estimate Std. Error t value
## (Intercept)   793.29      16.26  48.782
## cond           77.65      26.18   2.967
```


</div>


Now see if you can identify the data generating parameters in the output of `summary()`.



First, try to find \(\beta_0\) and \(\beta_1\).


<div class='solution'><button>Solution: Fixed effects</button>


<table>
 <thead>
  <tr>
   <th style="text-align:left;"> parameter </th>
   <th style="text-align:left;"> variable </th>
   <th style="text-align:right;"> input </th>
   <th style="text-align:right;"> estimate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> \(\hat{\beta}_0\) </td>
   <td style="text-align:left;"> `b0` </td>
   <td style="text-align:right;"> 800 </td>
   <td style="text-align:right;"> 793.293 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> \(\hat{\beta}_1\) </td>
   <td style="text-align:left;"> `b1` </td>
   <td style="text-align:right;"> 80 </td>
   <td style="text-align:right;"> 77.652 </td>
  </tr>
</tbody>
</table>


</div>


Now try to find estimates of random effects parameters \(\tau_{00}\), \(\tau_{11}\), \(\rho\), \(\omega_{00}\), and \(\sigma\).


<div class='solution'><button>Solution: Random effects parameters</button>


<table>
 <thead>
  <tr>
   <th style="text-align:left;"> parameter </th>
   <th style="text-align:left;"> variable </th>
   <th style="text-align:right;"> input </th>
   <th style="text-align:right;"> estimate </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> \(\hat{\tau}_{00}\) </td>
   <td style="text-align:left;"> `tau_00` </td>
   <td style="text-align:right;"> 100.0 </td>
   <td style="text-align:right;"> 97.287 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> \(\hat{\tau}_{11}\) </td>
   <td style="text-align:left;"> `tau_11` </td>
   <td style="text-align:right;"> 40.0 </td>
   <td style="text-align:right;"> 24.448 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> \(\hat{\rho}\) </td>
   <td style="text-align:left;"> `rho` </td>
   <td style="text-align:right;"> 0.2 </td>
   <td style="text-align:right;"> 0.675 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> \(\hat{\omega}_{00}\) </td>
   <td style="text-align:left;"> `omega_00` </td>
   <td style="text-align:right;"> 80.0 </td>
   <td style="text-align:right;"> 89.928 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> \(\hat{\sigma}\) </td>
   <td style="text-align:left;"> `sig` </td>
   <td style="text-align:right;"> 200.0 </td>
   <td style="text-align:right;"> 200.761 </td>
  </tr>
</tbody>
</table>


</div>

