// ignore_for_file: constant_identifier_names

/// We cant compute constants functions or getters like: const math.pow(1,32); gives error
///
/// So we have to use precomputed values.
///
/// There is a library for handling binary data at https://pub.dev/packages/binary
///   but it doesn't seem performant, too many checks for somethig simple.
///   throws on checks, binary operation that throws? no thanks.
///   also, the builder seems complicated, masks are simplier.
///
/// Use 53bit values as max to be compatible with javascript platforms.
///   https://dart.dev/guides/language/numbers

class CompatibleBits
{
    /// The largest posible unsigned integer that is valid in JavaScript.
    static const MAXJSUINT = ALLBITSSET53;
    static const ALLBITSSET53 = 0x1fffffffffffff;

    // JavaScript shift operations works on 32 bit values only.
    static const int bit1 = MAXJSUINT & 1 << 0;
    static const int bit2 = MAXJSUINT & 1 << 1;
    static const int bit3 = MAXJSUINT & 1 << 2;
    static const int bit4 = MAXJSUINT & 1 << 3;
    static const int bit5 = MAXJSUINT & 1 << 4;
    static const int bit6 = MAXJSUINT & 1 << 5;
    static const int bit7 = MAXJSUINT & 1 << 6;
    static const int bit8 = MAXJSUINT & 1 << 7;
    static const int bit9 = MAXJSUINT & 1 << 8;
    static const int bit10 = MAXJSUINT & 1 << 9;
    static const int bit11 = MAXJSUINT & 1 << 10;
    static const int bit12 = MAXJSUINT & 1 << 11;
    static const int bit13 = MAXJSUINT & 1 << 12;
    static const int bit14 = MAXJSUINT & 1 << 13;
    static const int bit15 = MAXJSUINT & 1 << 14;
    static const int bit16 = MAXJSUINT & 1 << 15;
    static const int bit17 = MAXJSUINT & 1 << 16;
    static const int bit18 = MAXJSUINT & 1 << 17;
    static const int bit19 = MAXJSUINT & 1 << 18;
    static const int bit20 = MAXJSUINT & 1 << 19;
    static const int bit21 = MAXJSUINT & 1 << 20;
    static const int bit22 = MAXJSUINT & 1 << 21;
    static const int bit23 = MAXJSUINT & 1 << 22;
    static const int bit24 = MAXJSUINT & 1 << 23;
    static const int bit25 = MAXJSUINT & 1 << 24;
    static const int bit26 = MAXJSUINT & 1 << 25;
    static const int bit27 = MAXJSUINT & 1 << 26;
    static const int bit28 = MAXJSUINT & 1 << 27;
    static const int bit29 = MAXJSUINT & 1 << 28;
    static const int bit30 = MAXJSUINT & 1 << 29;
    static const int bit31 = MAXJSUINT & 1 << 30;
    static const int bit32 = MAXJSUINT & 1 << 31;

    // We can use aditional precision bits until 53 bits are used.
    // shift is not working on bits over 32 bits in javascript
    static const int bit33 = 0x100000000;
    static const int bit34 = 0x200000000;
    static const int bit35 = 0x400000000;
    static const int bit36 = 0x800000000;
    static const int bit37 = 0x1000000000;
    static const int bit38 = 0x2000000000;
    static const int bit39 = 0x4000000000;
    static const int bit40 = 0x8000000000;
    static const int bit41 = 0x10000000000;
    static const int bit42 = 0x20000000000;
    static const int bit43 = 0x40000000000;
    static const int bit44 = 0x80000000000;
    static const int bit45 = 0x100000000000;
    static const int bit46 = 0x200000000000;
    static const int bit47 = 0x400000000000;
    static const int bit48 = 0x800000000000;
    static const int bit49 = 0x1000000000000;
    static const int bit50 = 0x2000000000000;
    static const int bit51 = 0x4000000000000;
    static const int bit52 = 0x8000000000000;
    static const int bit53 = 0x10000000000000;

    static const bit = [
        0,
        bit1,
        bit2,
        bit3,
        bit4,
        bit5,
        bit6,
        bit7,
        bit8,
        bit9,
        bit10,
        bit11,
        bit12,
        bit13,
        bit14,
        bit15,
        bit16,
        bit17,
        bit18,
        bit19,
        bit20,
        bit21,
        bit22,
        bit23,
        bit24,
        bit25,
        bit26,
        bit27,
        bit28,
        bit29,
        bit30,
        bit31,
        bit32,
        bit33,
        bit34,
        bit35,
        bit36,
        bit37,
        bit38,
        bit39,
        bit40,
        bit41,
        bit42,
        bit43,
        bit44,
        bit45,
        bit46,
        bit47,
        bit48,
        bit49,
        bit50,
        bit51,
        bit52,
        bit53
    ];
}
