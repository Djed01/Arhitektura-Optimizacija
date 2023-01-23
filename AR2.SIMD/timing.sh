echo "500 runs of main_SSE"
time for i in {1..500}; do ./mainSIMD input.bin output.bin; done
echo

