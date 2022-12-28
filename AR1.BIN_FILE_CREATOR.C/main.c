#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc,char* argv[]) {
    int numOfRanges = 500;
    int numOfElements = 2*numOfRanges;
    FILE *fp = fopen("input.bin","wb");
    int* rangesArray = calloc(numOfElements, sizeof(int));
    if(fp == NULL) {
        printf("error creating file");
        return -1;
    }
    fwrite(&numOfRanges,sizeof(int),1,fp);
    int i=0;
    while(i<numOfRanges){
        int first = 2;
        int last = 1000;
            rangesArray[i*2] = first;
            rangesArray[i*2+1] = last;
            printf("%d First: %d Last: %d\n",i,rangesArray[i*2],rangesArray[i*2+1]);
            i++;
    }
    fwrite(rangesArray, sizeof(int), numOfElements, fp);
    fclose(fp);
    return 0;
}
