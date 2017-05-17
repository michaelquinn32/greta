context('syntax')

test_that('`distribution<-` works in models', {

  source('helpers.R')

  flush()

  # with a distribution parameter
  y <- as_data(randn(5))
  expect_equal(y$node$type, 'data')
  y_op <- y * 1
  expect_equal(y_op$node$type, 'operation')

  # data
  mu <- normal(0, 1)
  distribution(y) = normal(mu, 2)
  sample_distribution(mu)

  # operation
  mu <- normal(0, 1)
  distribution(y_op) = normal(mu, 1)
  sample_distribution(mu)

  # with a free parameter

  flush()

  y <- as_data(randn(5))
  expect_equal(y$node$type, 'data')
  y_op <- y * 1
  expect_equal(y_op$node$type, 'operation')

  # data
  mu <- free()
  distribution(y) = normal(mu, 2)
  sample_distribution(mu)

  # op
  mu <- free()
  distribution(y_op) = normal(mu, 1)
  sample_distribution(mu)

  # test truncation

})

test_that('distribution() works', {

  source('helpers.R')

  flush()

  a = normal(0, 1)
  b = free()
  c = as_data(randn(5))
  d = c * 1

  # when run on a distribution, should just return the same greta array
  expect_identical(distribution(a), a)

  # when run on something without a distribution, should return NULL
  expect_null(distribution(b))
  expect_null(distribution(c))
  expect_null(distribution(d))

  # once assigned, should return the original distribution
  a2 = normal(0, 1)
  distribution(b) = a2
  expect_equal(distribution(b), b)

  a2 = normal(0, 1)
  distribution(c) = a2
  expect_equal(distribution(c), c)

  a3 = normal(0, 1)
  distribution(d) = a3
  expect_equal(distribution(d), d)

})

test_that('`distribution<-` errors informatively', {

  source('helpers.R')

  flush()

  y <- randn(3, 3, 2)
  x <- randn(1)

  # not a greta array with a distribution on the right
  expect_error({distribution(y) = x},
               'right hand side must be a greta array')

  expect_error({distribution(y) = as_data(x)},
               'right hand side must have a distribution')

  # no density on the right
  expect_error({distribution(y) = free()},
               'right hand side must have a distribution')

  # non-scalar and wrong dimensions
  expect_error({distribution(y) = normal(0, 1, dim = c(3, 3, 1))},
               '^left and right hand sides have different dimensions.')

  # double assignment of distribution to node
  y_ <- as_data(y)
  distribution(y_) = normal(0, 1)
  expect_error({distribution(y_) = normal(0, 1)},
               'left hand side already has a distribution assigned')

  # assignment with a greta array that already has a fixed value
  y1 <- as_data(y)
  y2 <- as_data(y)
  d <- normal(0, 1)
  distribution(y1) = d
  expect_error({distribution(y2) = d},
               'right hand side has already been assigned fixed values')

  # unsupported truncation
  z = free(lower = 0)
  expect_error({distribution(z) = student(5, 0, 1)},
               'distribution cannot be truncated')

  # shouldn't error with -Inf, Inf
  z = free()
  distribution(z) = student(5, 0, 1)

})

test_that('distribution() errors informatively', {

  source('helpers.R')

  flush()

  y <- randn(3)

  expect_error(distribution(y),
               'not a greta array')


})
