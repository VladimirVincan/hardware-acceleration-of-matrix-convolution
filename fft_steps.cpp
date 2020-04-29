// CPP program to implement iterative
// fast Fourier transform.
#include <bits/stdc++.h>
#include <fstream>
#include <iostream>
using namespace std;

typedef complex<double> cd;
const double PI = 3.1415926536;
vector<vector<cd>> steps;

// Utility function for reversing the bits
// of given index x
unsigned int bitReverse(unsigned int x, int log2n) {
  int n = 0;
  for (int i = 0; i < log2n; i++) {
    n <<= 1;
    n |= (x & 1);
    x >>= 1;
  }
  return n;
}

// Iterative FFT function to compute the DFT
// of given coefficient vector
void fft(vector<cd> &a, vector<cd> &A, int log2n) {
  steps.push_back(a);
  int n = 1 << log2n;

  // bit reversal of the given array
  for (unsigned int i = 0; i < n; ++i) {
    int rev = bitReverse(i, log2n);
    A[i] = a[rev];
  }

  // j is iota
  const complex<double> J(0, 1);
  for (int s = 1; s <= log2n; ++s) {
    int m = 1 << s;  // 2 power s
    int m2 = m >> 1; // m2 = m/2 -1
    cd w(1, 0);

    // principle root of nth complex
    // root of unity.
    cd wm = exp(J * (PI / m2));
    for (int j = 0; j < m2; ++j) {
      for (int k = j; k < n; k += m) {

        // t = twiddle factor
        cd t = w * A[k + m2];
        cd u = A[k];

        // similar calculating y[k]
        A[k] = u + t;

        // similar calculating y[k+n/2]
        A[k + m2] = u - t;
        // cout << u << " " << t << " " << endl; // w << endl;
      }
      w *= wm;
    }
    steps.push_back(A);
    // cout << endl << "A" << endl;
    // for (int it = 0; it < n; ++it) {
    //   cout << A[it] << " ";
    // }
    // cout << endl;
  }
}

void print_steps() {
  cout << "STEPS:" << endl;
  // cout << steps.size() << endl;
  // cout << steps[0].size() << endl;
  for (int i = 0; i < steps.size(); ++i) {
    for (int j = 0; j < steps[i].size(); ++j) {
      cout << steps[i][j] << " ";
    }
    cout << endl;
  }
}

template <class T>
std::vector<std::vector<T>> transpose(const std::vector<std::vector<T>> data) {
  // this assumes that all inner vectors have the same size and
  // allocates space for the complete result in advance
  std::vector<std::vector<T>> result(data[0].size(),
                                     std::vector<T>(data.size()));
  for (typename std::vector<T>::size_type i = 0; i < data[0].size(); i++)
    for (typename std::vector<T>::size_type j = 0; j < data.size(); j++) {
      result[i][j] = data[j][i];
    }
  return result;
}

int main() {
  cout << "FFT STEPS ALGO" << endl;
  ifstream fin;
  fin.open("vector.in");
  int n;
  vector<cd> a;

  fin >> n;
  for (int i = 0; i < n; ++i) {
    int real;
    fin >> real;
    cd tmp(real, 0);
    a.push_back(tmp);
  }
  vector<cd> A(a.size());

  fft(a, A, n >> 1);

  cout << "start  = ";
  for (int i = 0; i < n; ++i)
    cout << a[i] << " ";
  cout << endl;

  cout << "finish = ";
  for (int i = 0; i < n; ++i)
    cout << A[i] << " ";
  cout << endl;

  // print_steps();
  steps = transpose<cd>(steps);
  print_steps();
  // for (int i = 0; i < a.size(); ++i)
  //   cout << A[i] << "\n";
  fin.close();
  return 0;
}
