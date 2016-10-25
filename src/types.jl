type Transition{T<:AbstractFloat}
	index::Int32
	prob::T
end
Base.eltype{T}(t::Transition{T}) = T

type HmmState{TT<:Transition}
	pdf_class::Int32
	transitions::Vector{TT}
end
# HmmState{TT<:Transition}(p::Int32, t::Vector{TT}) = HmmState{eltype(TT), TT}(p, t)

type TopologyEntry
	entry::Vector{HmmState}
end

type Triple
	phone::Int32
	hmm_state::Int32
	df::Int32
end

type TransitionModel{T<:AbstractFloat}
	topo::Vector{TopologyEntry}
	triples::Vector{Triple}
	log_probs::Vector{T}
end

abstract NnetComponent{T}

type Nnet{T}
	components::Array{NnetComponent}
	priors::Vector{T}
end

type NnetAM{T<:AbstractFloat}
	trans_model::TransitionModel{T}
	nnet::Nnet
end

type Delay{T}
	context::Vector{Int32}
	buffer::AbstractMatrix{T}
	i::Int
	function Delay(context, dim::Integer)
		nbuf = maximum(context) - min(minimum(context), 0)
		new(context, zeros(T, dim, nbuf), 0)
	end
end
Delay(context, dim::Integer, ftype=Float32) = Delay{ftype}(context, dim)

type SpliceComponent{T} <: NnetComponent
	input_dim::Int32
	const_component_dim::Int32
	delay::Delay{T}
	# const_delay::Delay
	function SpliceComponent(input_dim, context, const_component_dim)
		var_dim = input_dim - const_component_dim
		new(input_dim, const_component_dim, Delay{T}(context, input_dim))
	end
end
SpliceComponent(input_dim, context, const_component_dim, T::Real) = SpliceComponent{T}(input_dim, context, const_component_dim)

abstract AbstractAffineComponent <: NnetComponent

type FixedAffineComponent{T} <: AbstractAffineComponent
	linear_params::Matrix{T}
	bias_params::Vector{T}
end

type AffineComponentPreconditionedOnline{T} <: AbstractAffineComponent
	learning_rate::T
	linear_params::Matrix{T}
	bias_params::Vector{T}
	rank_in::Int32
	rank_out::Int32
	update_period::Int32
	num_samples_history::T
	alpha::T
	max_change_per_sample::T
end

type PnormComponent{T} <: NnetComponent
	input_dim::Int32
	output_dim::Int32
	P::T
end

type NormalizeComponent{T} <: NnetComponent
	dim::Int32
	value_sum::Vector{T}
	deriv_sum::Vector{T}
	count::Int64
end

type FixedScaleComponent{T} <: NnetComponent
	scales::Vector{T}
end

type SoftmaxComponent{T} <: NnetComponent
	dim::Int32
	value_sum::Vector{T}
	deriv_sum::Vector{T}
	count::Int64
end
