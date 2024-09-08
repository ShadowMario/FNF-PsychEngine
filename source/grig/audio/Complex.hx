package grig.audio;

typedef ComplexType =
{
	var real:Float;
	var imag:Float;
}

abstract Complex(ComplexType) from ComplexType to ComplexType
{
	public var real(get, set):Float;
	public var imag(get, set):Float;

	inline function get_real():Float
	{
		return this.real;
	}

	inline function set_real(n:Float)
	{
		return this.real = n;
	}

	inline function get_imag():Float
	{
		return this.imag;
	}

	inline function set_imag(n:Float)
	{
		return this.imag = n;
	}

	/**
		Constructs a complex number
	**/
	inline public function new(real:Float, imag:Float)
	{
		this = {real: real, imag: imag};
	}

	inline function toString():String
	{
		return "(" + this.real + "," + this.imag + ")";
	}

	@:op(A + B)
	inline function sum(z:Complex):Complex
	{
		return new Complex(this.real + z.real, this.imag + z.imag);
	}

	@:op(A + B)
	inline function sumWithFloat(x:Float):Complex
	{
		return new Complex(this.real + x, this.imag);
	}

	@:op(A - B)
	inline function subWithFloat(x:Float):Complex
	{
		return sumWithFloat(-x);
	}

	@:op(A - B)
	inline function sub(z:Complex):Complex
	{
		return new Complex(this.real - z.real, this.imag - z.imag);
	}

	@:op(A * B)
	inline function mul(z:Complex):Complex
	{
		return new Complex((this.real * z.real) - (this.imag * z.imag), ((this.real * z.imag) + (this.imag * z.real)));
	}

	@:op(A * B)
	inline function mulWithFloat(x:Float):Complex
	{
		return new Complex(this.real * x, this.imag * x);
	}

	@:op(A / B)
	inline function div(z:Complex):Complex
	{
		var d = Complex.abs(z);
		return new Complex((this.real * z.real + this.imag * z.imag) / d, (this.imag * z.real - this.real * z.imag) / d);
	}

	@:op(A / B)
	inline function divWithFloat(x:Float):Complex
	{
		trace(x, this.real * x, this.imag * x);
		return mulWithFloat(1 / x);
	}

	// Assignment Operators

	@:op(A += B)
	inline function sumAsn(z:Complex):Complex
	{
		return this = sum(z);
	}

	@:op(A += B)
	inline function sumWithFloatAsm(x:Float):Complex
	{
		return this = sumWithFloat(x);
	}

	@:op(A -= B)
	inline function subAsn(z:Complex):Complex
	{
		return this = sub(z);
	}

	@:op(A -= B)
	inline function subWithFloatAsn(x:Float):Complex
	{
		return this = subWithFloat(x);
	}

	@:op(A *= B)
	inline function mulAsn(z:Complex):Complex
	{
		return this = mul(z);
	}

	@:op(A *= B)
	inline function mulWithFloatAsn(x:Float):Complex
	{
		return this = mulWithFloat(x);
	}

	@:op(A /= B)
	inline function divAsn(z:Complex):Complex
	{
		return this = div(z);
	}

	@:op(A /= B)
	inline function divWithFloatAsn(x:Float):Complex
	{
		return this = divWithFloat(x);
	}

    @:op(A == B)
    inline function equals(z:Complex):Bool
    {
        return this.real == z.real && this.imag == z.imag;
    }

	/**
		Constructs a complex number from magnitude and phase angle
	**/
	public static inline function fromPolar(norm:Float, phi:Float)
	{
		return new Complex(norm * Math.cos(phi), norm * Math.sin(phi));
	}

	/**
		Returns the magnitude of a complex number
	**/
	public static inline function abs(z:Complex):Float
	{
		return Math.sqrt(norm(z));
	}

	/**
		Returns the squared magnitude
	**/
	public static inline function norm(z:Complex):Float
	{
		return z.real * z.real + z.imag * z.imag;
	}

	public static inline function arg(z:Complex):Float
	{
		return Math.atan2(z.imag, z.real);
	}

	public static inline function sqrt(z:Complex):Complex
	{
		var m = Math.sqrt(Complex.norm(z));
		var a = Complex.arg(z) / 2.0;
		return Complex.fromPolar(m, a);
	}

	public static inline function exp(z:Complex):Complex
	{
		var m = Math.exp(z.real);
		return Complex.fromPolar(m, z.imag);
	}

	public static inline function conj(z:Complex):Complex
	{
		return new Complex(z.real, -z.imag);
	}

	public static inline function pow(base:Complex, exponent:Float):Complex
	{
		var m = Complex.abs(base);
		var a = Complex.arg(base);

		var nM = Math.pow(m, exponent);
		var nA = a * exponent;

		return Complex.fromPolar(nM, nA);
	}

	public static inline function log(z:Complex):Complex
	{
		var m = Complex.abs(z);
		var a = Complex.arg(z);
		if (m > 0)
			return new Complex(Math.log(m), a);
		else
			return new Complex(Math.NaN, Math.NaN);
	}
}
