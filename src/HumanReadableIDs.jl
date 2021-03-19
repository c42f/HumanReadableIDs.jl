module HumanReadableIDs

# Write your package code here.

using Distributions
using Random

_normalize(x) = x./sum(x)

#-------------------------------------------------------------------------------
# Tools to generate transition probabilities
function letter_transition_frequencies(words)
    # Build (right) stochastic matrix
    # https://en.wikipedia.org/wiki/Stochastic_matrix<Paste>
    char_to_ind(c) = c - 'a' + 1

    nletters = 26
    nstates = nletters
    #end_ind = nletters+1
    start_letter_freqs = zeros(Int, nletters)
    transition_freqs = zeros(Int, nstates,nstates)
    for word in words
        isempty(word) && continue
        start_letter_freqs[char_to_ind(word[1])] += 1
        for i = 1:length(word)-1
            i1 = char_to_ind(word[i])
            i2 = char_to_ind(word[nextind(word,i)])
            transition_freqs[i1,i2] += 1
        end
        # End state
        # transition_freqs[char_to_ind(last(word)),end_ind] += 1
    end

    start_letter_freqs, transition_freqs
end

function letter_transition_probabilites(words)
    start_letter_freqs, transition_freqs = letter_transition_frequencies(words)
    (_normalize(start_letter_freqs),
     [_normalize(transition_freqs[i,:]) for i=1:size(transition_freqs, 1)])
end

function read_name_corpus()
    names=String[]
    # Name corups from
    # https://www.cs.cmu.edu/Groups/AI/areas/nlp/corpora/names/male.txt
    # https://www.cs.cmu.edu/Groups/AI/areas/nlp/corpora/names/female.txt
    #
    # Also interesting, much larger corpus:
    # https://www.cs.cmu.edu/Groups/AI/areas/nlp/corpora/names/other/names.txt
    for line in vcat(readlines(joinpath(@__DIR__, "../notebooks/male.txt")),
                     readlines(joinpath(@__DIR__, "../notebooks/female.txt")))
        if isempty(line) || first(line) == "#"
            continue
        end
        append!(names, lowercase.(split(line, r"[^a-z]"i)))
    end
    names
end


#-------------------------------------------------------------------------------
# Markov chain sampling for Human-readable-ids (HRIDs)

struct MarkovHridSampler
    start_letter_sampler::Distributions.AliasTable
    pairwise_samplers::Vector{Distributions.AliasTable}
end

function MarkovHridSampler(start_letter_probs::AbstractVector,
                           pairwise_probs::AbstractVector)
    MarkovHridSampler(sampler(Categorical(start_letter_probs)),
                      sampler.(Categorical.(pairwise_probs)))
end

"""
Create a word-like ID of total length `id_length`, by running a Markov chain
with the initial letter probability `start_letter_probs` and transition
probabilities `pairwise_probs`.
"""
function Random.randstring(m::MarkovHridSampler, id_length::Integer)
    nameinds = Int[]
    cind = rand(m.start_letter_sampler)
    push!(nameinds, cind)
    for i=2:id_length
        cind = rand(m.pairwise_samplers[cind])
        push!(nameinds, cind)
    end
    name = join('a' .+ nameinds .- 1)
    name = uppercase(name[1])*name[2:end]
    name
end


include("name_model.jl")

end
