#include "ruby.h"
#include <math.h>

VALUE KeplerDFT = Qnil;
void Init_kepler_dft();
VALUE method_dft(VALUE self, VALUE times, VALUE magnitudes, VALUE number_of_points, VALUE bandwidth, VALUE min_frequency, VALUE max_frequency);

void Init_kepler_dft() {
  VALUE KeplerDFT = rb_define_module("KeplerDFT");
  rb_define_method(KeplerDFT, "dft", method_dft, 6);
}

VALUE method_dft(VALUE self, VALUE times, VALUE magnitudes, VALUE number_of_points, VALUE bandwidth, VALUE min_frequency, VALUE max_frequency) {
  VALUE output = rb_hash_new();
  const int num_points = NUM2INT(number_of_points);
  const double dataset_length = NUM2DBL(bandwidth), step_size = 1 / (20 * dataset_length), two_PI = 6.283185307179586477, start_frequency = NUM2DBL(min_frequency), final_frequency = NUM2DBL(max_frequency);
  double C_i, S_i, omega_t, magnitude, time, amplitude;
  int i, j, k, num_frequencies = 0;

  for(k = 0; start_frequency + (k * step_size) <= final_frequency; ++k)
  {
    ++num_frequencies;
  }

  double frequency_array[num_frequencies], real_component[num_frequencies], imaginary_component[num_frequencies];

  for(k = 0; k < num_frequencies; ++k)
  {
    frequency_array[k] = start_frequency + (k * step_size);
    real_component[k] = 0;
    imaginary_component[k] = 0;
  }

  // main loop
  for (i = 0; i < num_points; ++i)
  {
    time = NUM2DBL(rb_ary_entry(times, i));
    magnitude = NUM2DBL(rb_ary_entry(magnitudes, i));

    // prepare SIN-Approximation
    double ThisSin, LastSin, sin_wt, ThisCos, LastCos, cos_wt;
    const double two_pi_t = two_PI * time;

    double omega_0_t = two_pi_t * start_frequency;
    double omega_step_t = two_pi_t * step_size;

    LastSin = magnitude * sin(omega_0_t);
    LastCos = magnitude * cos(omega_0_t);
    sin_wt = sin(omega_step_t);
    cos_wt = cos(omega_step_t);

    double *real = real_component, *imaginary = imaginary_component;
    for(j = 0; j < num_frequencies; ++j)
    {
      (*real++) += LastSin;
      (*imaginary++) += LastCos;

      ThisSin = LastSin * cos_wt + LastCos * sin_wt;
      ThisCos = LastCos * cos_wt - LastSin * sin_wt;
      LastSin = ThisSin;
      LastCos = ThisCos;
    }
  } // end main loop

  double *real = real_component, *imaginary = imaginary_component;
  for(j = 0; j < num_frequencies; ++j)
  {
    amplitude = 2 * sqrt((*real) * (*real) + (*imaginary) * (*imaginary)) / num_points;
    rb_hash_aset(output, DBL2NUM(frequency_array[j]), DBL2NUM(amplitude * 1000));
    real++; imaginary++;
  }

  // free(real_component);
  // free(imaginary_component);
  // free(frequency_array);

  return output;
}
