
# The General Linear Model

## Learning statistics is like learning to cook

One thing that students of statistics struggle with is deciding which statistical approach is appropriate for their data. This difficulty comes from the way statistics is taught. Open up many traditional textbooks for teaching statistics in Psychology, and you will often find a decision tree that looks something like this:

<!-- TODO: create flowchart -->

if often taught as if you were giving people instructions for warming up pre-packaged meals. 

Pre-packaged foods solve an immediate, short-term problem: *I am hungry, and I want something tasty and easy to prepare. I don't want to invest too much time, thought, or energy into it. I don't know anything about how the ingredients were chosen, nor about how it was prepared. In fact, the less I know about what I'm putting in my body, the better.* 

This is a great approach to meeting your basic caloric needs and providing some quick gratification after a long day of work, but as anyone will tell you, 

is this the set of values that we want to have when we are producing or consuming scientific research?

Microwave instructions for pre-packaged food.

## Recipe-driven approaches 

"If all you have is a hammer, everything looks like a nail"

The real problem is this: *the real data that you will encounter in your lifetime as a psychologist will be far more complex than the canned datasets you find in traditional statistics textbooks.* 

Let's have a look at an example.

- violation of assumptions, especially: independence
- discretizing predictors
- treating categorical data as continuous
- over-aggregation
- mindless statistics

## It's all just regression



## The fundamental unity of all common statistical tests

- t-test
- correlation & regression
- multiple regression
- analysis of variance
- mixed-effects modeling

## The GLM approach

1. Define a mathematical model describing the processes that give rise to the data
2. Use your data to estimate model parameters
3. Validate the model
4. Report what you did as transparently as possible

## Models are just... models

A statistical model is a **simplification** and **idealization** of reality that captures our key assumptions about the Data Generating Process (the DGP).

## Importance of data simulation

## Case study: Stroop Effect data

### t-test

### analysis of variance

### linear regression

### multilevel model

## Single-level versus multi-level data

## Issues with multilevel data

- GLMs assume independence of residuals
- Observations within a cluster (unit) are not independent
- Any sources of non-independence must be modelled or "aggregated away"
- Typical consequence of failure to do so: High false-positive rates

## Regression: Killer app

(see slide 18)

## Four functions to rule them all

1. How is the data structured?
2. What type of response variable?
3. How are the observations distributed?
