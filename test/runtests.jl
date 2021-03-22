using HumanReadableIDs
using Test
using Random
using UUIDs

# Monkey patch uuid4
_rand(T) = rand(T)
_rand(::Type{UUID}) = uuid4()

@testset "proquints" begin
    # Literal test cases
    for (x,str) in [ # all letters for first 6 bit positions
                    (0x0000, "babab"),
                    (0x0001, "babad"),
                    (0x0002, "babaf"),
                    (0x0003, "babag"),
                    (0x0004, "babah"),
                    (0x0005, "babaj"),
                    (0x0006, "babak"),
                    (0x0007, "babal"),
                    (0x0008, "babam"),
                    (0x0009, "baban"),
                    (0x000a, "babap"),
                    (0x000b, "babar"),
                    (0x000c, "babas"),
                    (0x000d, "babat"),
                    (0x000e, "babav"),
                    (0x000f, "babaz"),
                    (0x0010, "babib"),
                    (0x0020, "babob"),
                    (0x0030, "babub"),
                    # Other bits
                    (0x03c0, "bazab"),
                    (0x0c00, "bubab"),
                    (0xf000, "zabab"),
                    # Larger sizes
                    (0xf0000000, "zabab-babab"),
                    (0x000f0000, "babaz-babab"),
                   ]
        @test str == encode_proquint(x)
    end
    @testset "round-trip type tests" for T in [UInt8, UInt16, UInt32,
                                               UInt64, UInt128, UUID]
        for i=1:10
            x = _rand(T)
            y = decode_proquint(T, encode_proquint(x))
            @test y isa T
            @test x == y
        end
    end
    @testset "Exhaustive round-trip test for all 16 bit numbers" begin
        for i=0x0000:0xffff
            @test i == decode_proquint(UInt16, encode_proquint(i))
        end
    end
end
