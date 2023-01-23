#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

int ErrorEnd(){
    printf("Error with input file!");
    return -1;
}

int main(int argc,char* argv[])
{
    FILE *fp_input;
    FILE *fp_output;
    int numOfRanges;
    int numOfPrime = 0;

    fp_input = fopen(argv[1],"rb");

    if(fp_input == NULL){
        return ErrorEnd();
    }

    fread(&numOfRanges,sizeof(int),1,fp_input);

    int rangesArray[2*numOfRanges];

    fread(rangesArray,sizeof(int),numOfRanges*2,fp_input);
    fclose(fp_input);

#pragma omp parallel for reduction(+:numOfPrime) //numOfPrime se azurira thread safe dodavanjem medjurezultata svake niti 
    for(int i=0;i<numOfRanges;i++){
        int first = rangesArray[i*2];
        int last = rangesArray[i*2+1];
        if(first>last) ErrorEnd();
        for(int j=first;j<=last;j++){
            int temp=0;
            for(int k=2;k<=j/2;k++){
                if(j%k==0){
                    temp++;
                }
            }
            if(temp==0){
                numOfPrime++;
            }
        }
    }

    fp_output = fopen(argv[2],"wb");
    if(fp_output == NULL){
        return ErrorEnd();
    }
    fwrite(&numOfPrime, sizeof(int), 1, fp_output);
    fclose(fp_output);

    return 0;
}
