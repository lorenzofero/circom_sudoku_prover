pragma circom 2.1.7;

// Checks whether two signals are not equal.
template NonEqual() {
  signal input in0;
  signal input in1;
  // in0 and in1 are equal if in0 - in1 != 0,
  // which means an inverse exists
  signal inverse <-- 1 / (in0 - in1);
  inverse * (in0 - in1) === 1;
}

// All elements are distinct in the array.
template Distinct(n) {
  signal input in[n];
  component nonEqual[n][n];
  
  for (var i = 0; i < n; i++) {
      for (var j = 0; j < i; j++) {
          nonEqual[i][j] = NonEqual();
          nonEqual[i][j].in0 <== in[i];
          nonEqual[i][j].in1 <== in[j];
        }
    }
}

component main = NonEqual();
