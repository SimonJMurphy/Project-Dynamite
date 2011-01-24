#include <iostream>
#include <cmath>
#include <string>
#include <fstream>
#include <vector>
using namespace std;

int main (int argc, char * const argv[]) {
	
	//need filename
	string filename = "/Users/simonmurphy/code/Project-Dynamite/data/output/converted_DSct_CorrectedFlux/kic1163943_CFlux_Q0_llc.txt"; // specifies the file to be opened
	
	ifstream file;
	file.open(filename.c_str());				// instruction to open file
	if (!file)
	{
		cerr << "failed to open input file with filename " << filename << endl;
	}
	
	file.precision(15);
	cout.precision(15);
	vector<long double> times;
	vector<long double> magnitudes;
	
	// no file.size method on ifstream apparently, so use a linenumber iterator 'number_of_points'
	int number_of_points = 0;
	while (!file.eof())
	{
		number_of_points++;
		
		long double time;
		long double magnitude;
		
		file >> time;
		file >> magnitude;
		
		times.push_back(time);		// reads time values and puts them into the vector "times"
		magnitudes.push_back(magnitude);		// reads magnitude values and puts them into the vector "magnitudes"
	}
	file.close();
    
	// integer declaration and initialisation for calculation
	
	int start_frequency = 0, final_frequency = 100;
	double dataset_length = times[number_of_points - 1] - times[0];
	double step_size = 1 / (10 * dataset_length);
	double C_i = 0, S_i = 0, k = 0, real_component = 0, imaginary_component = 0, omega_t = 0, amplitude = 0, phase = 0;
	const double PI = 3.1415926535;
	
	// prepare output file for writing data
	
	string outfilename = "/Users/simonmurphy/code/Project-Dynamite/data/output/converted_DSct_CorrectedFlux/kic1163943_fourier_spectrum";	// specifies output file
	
	ofstream outfile;
	outfile.open(outfilename.c_str());				// opens the output file
	if (!outfile)
	{
		cerr << "failed to open output file with filename " << outfilename << endl;
	}
	outfile.precision(15);
	
	outfile << "# frequency (c/d)\t amplitude\t phase" << endl;	// give columns a title
	
	// loop over all frequencies in the range at a given step_size, and write to output
	
	for (int j = start_frequency; j * step_size <= final_frequency; ++j)
	{
		k = j * step_size;
		for (int i = 0; i < number_of_points; ++i)
		{
			omega_t = 2 * PI * k * times[i];
			C_i = cos(omega_t);
			S_i = sin(omega_t);

			real_component += C_i * magnitudes[i];
			imaginary_component += S_i * magnitudes[i];
		}
		
		amplitude = 2 * sqrt(real_component * real_component + imaginary_component * imaginary_component) / number_of_points;
		phase = atan2( -imaginary_component , real_component);
		
		outfile << k << "\t" << amplitude << "\t" << phase << endl;
	}
	
    return 0;
}
