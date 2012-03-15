#!/usr/bin/env ruby
require("rbgsl")

x = GSL::Vector[1, 2, 3, 4, 5]
y = GSL::Vector[5.5, 43.1, 128, 290.7, 498.4]
# The results are stored in a polynomial "coef"
coef, cov, chisq, status = GSL::Poly::fit(x, y, 3) 

x2 = GSL::Vector.linspace(1, 5, 20)
GSL::Vector.graph([x, y], [x2, coef.eval(x2)], "-C -g 3 -S 4")