#include <stdio.h>
#include <stdlib.h>

int main(int argc,char* argv[]) {
    srand(time(NULL));
    FILE *fp = fopen("test.bin","wb");
    int* rangesArray = calloc(2000000, sizeof(int));
    if(fp == NULL) {
        printf("error creating file");
        return -1;
    }

    int i=0;
    while(i<2000000/2){
        int first = rand();
        int last = rand();
        if(first<last){

            rangesArray[i*2] = first;
            rangesArray[i*2+1] = last;
          //  printf("First: %d Last: %d",rangesArray[i*2],rangesArray[i*2+1]);
            i++;
        }
    }

    fwrite(rangesArray, sizeof(int), 2000000, fp);
    fclose(fp);
    return 0;
}
