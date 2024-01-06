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

// Enforce that the inputs fits in 4 bits, 
// which means 0 <= input < 16.
template Bits4() {
    signal input in;
    // The signal for the 4-bit decomposition of `in`
    signal bits[4];
    var bitsum = 0;

    for (var i = 0; i < 4; i++) {
        // The following assignment cannot be included
        // in a constraint since is not rank 1.
        //
        // This operation takes the i-th bit from the right
        bits[i] <-- (in >> i) & 1;
        // This is the constraint for the operation above
        bits[i] * (bits[i] - 1) === 0;
        bitsum = bitsum + 2 ** i * bits[i];
    }

    // The input is in the range if it equals the bit sum 
    // of its 4-bit decomposition
    bitsum === in;
}

// Enforce that the input satisfies 1 <= input <= 9
template OneToNine() {
  signal input in;

  component lowerBound = Bits4();
  component upperBound = Bits4();

  // if `in` is zero, then `in - 1` overflows and this constraint fails
  lowerBound.in <== in - 1;
  // if `in <= 9`, then `in + 6 <= 15`
  upperBound.in <== in + 6;
}

template Sudoku() {
  var n = 9;

  signal input solution[n][n];
  // In the puzzle we have as a convention that zero indicates a blank spot
  signal input puzzle[n][n];

  // Ensure that each solution is in-range
  component inRange[n][n];
  for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        inRange[i][j] = OneToNine();
        inRange[i][j].in <== solution[i][j];
      }
  }

  // Ensure that puzzle and solution agree.
  for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        // Given that we're in Z/p with a high p, this is zero
        // iff one of the factors is zero which is what we want.
        puzzle[i][j] * (puzzle[i][j] - solution[i][j]) === 0;
      }
  }

  // Ensure uniqueness in rows.
  component distinctRows[n];
  for (var i = 0; i < n; i++) {
      distinctRows[i] = Distinct(n);
      for (var j = 0; j < n; j++) {
        distinctRows[i].in[j] <== solution[i][j];
      } 
  }

  // Ensure uniqueness in columns.
  component distinctColumns[n];
  for (var i = 0; i < n; i++) {
      distinctColumns[i] = Distinct(n);
      for (var j = 0; j < n; j++) {
        distinctColumns[i].in[j] <== solution[i][j];
      } 
  }

  // Ensure uniqueness in each 3x3 grid.
  component distinctGrids[n];
  for (var i = 0; i < n; i += 3) {
      for (var j = 0; j < n; j += 3) {
          var idx = i + (j / 3);
          distinctGrids[idx] = Distinct(9);
          for (var k = i; k < i + 3; k++) {
            for (var l = j; l < j + 3; l++) {
              var innerIdx = (k % 3) * 3 + (l % 3);
              distinctGrids[idx].in[innerIdx] <== solution[k][l];
            }
          }
      }
  }
}

component main {public [puzzle]} = Sudoku();
