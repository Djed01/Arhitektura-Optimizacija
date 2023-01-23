echo "500 runs of mainSIMD+OpenMP"
time for i in {1..500}; do ./mainSIMD+OpenMP input.bin output.bin; done
echo

