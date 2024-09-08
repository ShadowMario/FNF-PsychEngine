package grig.audio;

/*
 * fft.c
 * Copyright 2011 John Lindgren
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions, and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions, and the following disclaimer in the documentation
 *    provided with the distribution.
 *
 * This software is provided "as is" and without any warranty, express or
 * implied. In no event shall the authors be liable for any damages arising from
 * the use of this software.
 */

// Original c code copyright 2011 John Lindgren, ported to haxe by Thomas J. Webb 2024

class FFT
{
    private static final TWO_PI:Float = 6.2831853;

    private var hamming = new Array<Float>();   // hamming window, scaled to sum to 1
    private var reversed = new Array<Int>();    // bit-reversal table
    private var roots = new Array<Complex>();   // N-th roots of unity
    private var n:Int;
    private var logN:Int;

    public function new(n:Int = 512) {
        hamming.resize(n);
        reversed.resize(n);
        roots.resize(Std.int(n / 2));

        this.n = n;
        logN = Std.int(log(2.0, n));
        generateTables();
    }

    // This should be moved to a utility class somewhere
    public static function log(base:Float, x:Float):Float {
        return Math.log(x) / Math.log(base);
    }

    @:generic
    public static function clamp<T:Float>(value:T, lower:T, upper:T):T {
        return value < lower ? lower : (value > upper ? upper : value);
    }

    // Reverse the order of the lowest LOGN bits in an integer.
    private function bitReverse(x:Int):Int {
        var y:Int = 0;

        var i:Int = logN;
        while (i > 0) {
            y = (y << 1) | (x & 1);
            x >>= 1;
            i--;
        }

        return y;
    }

    // Generate lookup tables.
    private function generateTables() {
        for (i in 0...n)
            hamming[i] = 1 - 0.85 * Math.cos(i * (TWO_PI / n));
        for (i in 0...reversed.length)
            reversed[i] = bitReverse(i);
        for (i in 0...Std.int(n / 2))
            roots[i] = Complex.exp(new Complex(0, i * (TWO_PI / n)));
    }

    /* 
     * Perform the DFT using the Cooley-Tukey algorithm.  At each step s, where
     * s=1..log N (base 2), there are N/(2^s) groups of intertwined butterfly
     * operations.  Each group contains (2^s)/2 butterflies, and each butterfly has
     * a span of (2^s)/2.  The twiddle factors are nth roots of unity where n = 2^s.
     */
    private function doFFT(a:Array<Complex>) {
        var half:Int = 1;                   // (2^s)/2
        var inv = Std.int(a.length / 2);    // N/(2^s)

        // loop through steps
        while (inv > 0) {
            // loop through groups
            var g:Int = 0;
            while (g < a.length) {
                // loop through butterflies
                var b:Int = 0;
                var r:Int = 0;
                while (b < half) {
                    var even = a[g + b];
                    var odd = roots[r] * a[g + half + b];
                    a[g + b] = even + odd;
                    a[g + half + b] = even - odd;
                    b++;
                    r += inv;
                }
                g += half << 1;
            }

            half <<= 1;
            inv >>= 1;
        }
    }

    // Input is N=512 PCM samples.
    // Output is intensity of frequencies from 1 to N/2=256.
    public function calcFreq(data:Array<Float>):Array<Float> {
        // input is filtered by a Hamming window
        // input values are in bit-reversed order
        var a = new Array<Complex>();
        var freq = new Array<Float>();
        a.resize(n);
        freq.resize(Std.int(n / 2));
        for (i in 0...a.length)
            a[reversed[i]] = { real: data[i] * hamming[i], imag: 0.0 };

        doFFT(a);
        // trace('${a[30]} ${a[100]}');

        // output values are divided by N
        // frequencies from 1 to N/2-1 are doubled
        for (i in 0...Std.int(n/2))
            freq[i] = 2 * Complex.abs(a[1 + i]) / n;

        // frequency N/2 is not doubled
        freq[Std.int(n / 2) - 1] = Complex.abs(a[Std.int(n / 2)]) / n;

        return freq;
    }
}