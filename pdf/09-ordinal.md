# Modeling Ordinal Data

It is perhaps easiest to think about ordinal data by viewing it as a more general case of logistic regression. In logistic regression, the response variable $Y$ has two categories (e.g., 0, 1), with the model intercept representing the point in log odds space where 0 and 1 are equiprobable.

$$\eta = \beta_0 + \beta_1 X_i$$


```r
library(tidyverse)
```