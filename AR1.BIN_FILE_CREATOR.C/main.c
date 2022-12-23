#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc,char* argv[]) {
    //srand(time(NULL));
    int numOfElements = 100;
    FILE *fp = fopen("input.bin","wb");
    int* rangesArray = calloc(2*numOfElements, sizeof(int));
    if(fp == NULL) {
        printf("error creating file");
        return -1;
    }
    int i=0;
    while(i<numOfElements){
        int first = 2;
        int last = 50;
        if(first<last){
            rangesArray[i*2] = first;
            rangesArray[i*2+1] = last;
            printf("%d First: %d Last: %d\n",i,rangesArray[i*2],rangesArray[i*2+1]);
            i++;
        }
    }

    fwrite(rangesArray, sizeof(int), numOfElements, fp);
    fclose(fp);
    return 0;
}
