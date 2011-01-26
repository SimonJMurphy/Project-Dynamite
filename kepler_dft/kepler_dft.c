#include "ruby.h"
#include <math.h>

VALUE KeplerDFT = Qnil;
void Init_kepler_dft();
VALUE method_dft(VALUE self, VALUE times, VALUE magnitudes, VALUE number_of_points, VALUE bandwidth);

void Init_kepler_dft() {
	VALUE KeplerDFT = rb_define_module("KeplerDFT");
	rb_define_method(KeplerDFT, "dft", method_dft, 4);
}

VALUE method_dft(VALUE self, VALUE times, VALUE magnitudes, VALUE number_of_points, VALUE bandwidth) {
	VALUE output = rb_hash_new();
	int num_points = NUM2INT(number_of_points);
	int start_frequency = 0, final_frequency = 100;
	double dataset_length = NUM2DBL(bandwidth);
	double step_size = 1 / (20 * dataset_length);
	double C_i, S_i, k, real_component = 0, imaginary_component = 0, omega_t, amplitude;
	double PI = 3.1415926535;
	int i, j;
	for (j = 0; start_frequency + (j * step_size) <= final_frequency; ++j)
	{
		k = start_frequency + (j * step_size);
		real_component = 0, imaginary_component = 0;
		for (i = 0; i < num_points; ++i)
		{
			omega_t = 2 * PI * k * rb_ary_entry(times, i);
			C_i = cos(omega_t);
			S_i = sin(omega_t);
			
			real_component += C_i * rb_ary_entry(magnitudes, i);
			imaginary_component += S_i * rb_ary_entry(magnitudes, i);
		}
	
		amplitude = 2 * sqrt(real_component * real_component + imaginary_component * imaginary_component) / num_points;
		rb_hash_aset(output, DBL2NUM(k), DBL2NUM(amplitude));
	}
	return output;
}
