# Dispatch to TBLIS implementation.
#

oind2eins(oindA::NTuple{NAo}, cindA::NTuple{NAc},
          oindB::NTuple{NBo}, cindB::NTuple{NBc},
          tindC::NTuple{NCt}) where {NAo, NAc, NBo, NBc, NCt} = begin
    NAo + NBo == NCt || throw(ArgumentError("Number of outer index not consistent."))
    NAc == NBc || throw(ArgumentError("Number of contracted index not consistent."))

    cPadding = 'a' - 'A'
    einA = zeros(Int8, NAo+NAc)
    einB = zeros(Int8, NBo+NBc)

    # Outer indices.
    for i = 1:NAo
        einA[oindA[i]] = i
    end
    for i = 1:NBo
        einB[oindB[i]] = i + NAo
    end

    # Contracted indices.
    for i = 1:NAc
        einA[cindA[i]] = i + cPadding
        einB[cindB[i]] = i + cPadding
    end

    einA = string((einA .+'A')...)
    einB = string((einB .+'A')...)
    einC = string((tindC.+'A')...) # C has direct conversion relations.
    einA, einB, einC
end

contract!(α, 
          A::StridedArray{T}, conjA::Symbol,
          B::StridedArray{T}, conjB::Symbol,
          β, 
          C::StridedArray{T}, 
          oindA::IndexTuple, cindA::IndexTuple, 
          oindB::IndexTuple, cindB::IndexTuple,
          tindC::IndexTuple, syms::Union{Nothing, NTuple{3,Symbol}} = nothing) where{T<:Real} = begin

    einA, einB, einC = oind2eins(oindA, cindA, 
                                 oindB, cindB, 
                                 tindC)
    BliContractor.contract!(A, einA, B, einB, C, einC, α, β)
    C
end

