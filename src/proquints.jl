using UUIDs

# Refs
#
# * https://arxiv.org/html/0901.4016
# * https://github.com/dsw/proquint/blob/master/proquint.c

_split_16(u::UInt8) = (u,) .% UInt16
_split_16(u::UInt16) = (u,) .% UInt16
_split_16(u::UInt32) = (u >> 16,
                        u & 0xffff) .% UInt16
_split_16(u::UInt64) = (u >> 48,
                        (u >> 32) & 0xffff,
                        (u >> 16) & 0xffff,
                        u & 0xffff) .% UInt16
_split_16(u::UInt128) = ((u >> 112),
                         (u >> 96) & 0xffff,
                         (u >> 80) & 0xffff,
                         (u >> 64) & 0xffff,
                         (u >> 48) & 0xffff,
                         (u >> 32) & 0xffff,
                         (u >> 16) & 0xffff,
                         u & 0xffff) .% UInt16

const consonants = ('b','d','f','g','h','j','k','l','m','n','p','r','s','t','v','z')
const vowels = ('a','i','o','u')

# Encode 16 bit segment as a "quint" of 5 characters
function encode_quint(segment)
    # From the spec
    #
    #    0 1 2 3 4 5 6 7 8 9 A B C D E F
    #   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    #   |con    |vo |con    |vo |con    |
    #   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

    @inbounds begin
        (consonants[(segment >> 12) & 0xf + 1],
             vowels[(segment >> 10) & 0x3 + 1],
         consonants[(segment >> 6)  & 0xf + 1],
             vowels[(segment >> 4)  & 0x3 + 1],
         consonants[segment         & 0xf + 1])
    end
end

# Decode a "quint" of 5 characters as a 16 bit number
function decode_quint(str, index)
    u = UInt16(0)
    for i=index:index+4
        c = str[i]
        if c == 'b'      u <<= 4 ; u |= 0x0;
        elseif c == 'd'  u <<= 4 ; u |= 0x1;
        elseif c == 'f'  u <<= 4 ; u |= 0x2;
        elseif c == 'g'  u <<= 4 ; u |= 0x3;
        elseif c == 'h'  u <<= 4 ; u |= 0x4;
        elseif c == 'j'  u <<= 4 ; u |= 0x5;
        elseif c == 'k'  u <<= 4 ; u |= 0x6;
        elseif c == 'l'  u <<= 4 ; u |= 0x7;
        elseif c == 'm'  u <<= 4 ; u |= 0x8;
        elseif c == 'n'  u <<= 4 ; u |= 0x9;
        elseif c == 'p'  u <<= 4 ; u |= 0xa;
        elseif c == 'r'  u <<= 4 ; u |= 0xb;
        elseif c == 's'  u <<= 4 ; u |= 0xc;
        elseif c == 't'  u <<= 4 ; u |= 0xd;
        elseif c == 'v'  u <<= 4 ; u |= 0xe;
        elseif c == 'z'  u <<= 4 ; u |= 0xf;
        elseif c == 'a'  u <<= 2 ; u |= 0x0;
        elseif c == 'i'  u <<= 2 ; u |= 0x1;
        elseif c == 'o'  u <<= 2 ; u |= 0x2;
        elseif c == 'u'  u <<= 2 ; u |= 0x3;
        else
            throw(ArgumentError("Unexpected character '$c' in proquint"))
        end
    end
    u
end

function encode_proquint(u::Unsigned, separator::Char='-')
    segments = encode_quint.(_split_16(u))
    buf = Vector{UInt8}(undef, 6*length(segments) - 1)
    j = 1
    @inbounds for i in 1:length(segments)
        for c in segments[i]
            buf[j] = c
            j += 1
        end
        if i != length(segments)
            buf[j] = separator
            j += 1
        end
    end
    String(buf)
end

encode_proquint(u::UUID, separator::Char='-') = encode_proquint(UInt128(u), separator)


function decode_proquint(T::Type{<:Unsigned}, str)
    val = zero(T)
    i = 1
    while i <= length(str)
        val <<= 16
        val |= decode_quint(str, i)
        if i+5 <= length(str)
            c = str[i+5]
            if c != '-'
                throw(ArgumentError("Unexpected proquint separator character '$c'"))
            end
        end
        i += 6
    end
    val
end

decode_proquint(T::Type{UInt8}, str) = UInt8(decode_proquint(UInt16, str))
decode_proquint(::Type{UUID}, str) = UUID(decode_proquint(UInt128, str))
