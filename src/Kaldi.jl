## Kaldi.jl Julia support for the Kaldi speech recognition toolkit
## (c) 2016 David A. van Leeuwen

module Kaldi

using DataStructures

export load_ark_matrix, save_ark_matrix, load_nnet_am

include("types.jl")
include("io.jl")

end
