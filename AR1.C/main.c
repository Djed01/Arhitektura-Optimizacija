#include <stdio.h>
#include <stdlib.h>

void ErrorEnd(){
    printf("Greska sa ulaznim fajlom!");
    return -1;
}

int main(int argc,char* argv[])
{
    FILE *fp_input;
    FILE *fp_output;
    int numOfRanges = atoi(argv[1])+1;
    int rangesArray[2*numOfRanges];
    int numOfPrime = 0;

    fp_input = fopen(argv[2],"rb");
    if(fp_input == NULL){
        ErrorEnd();
    }

    fread(rangesArray,sizeof(rangesArray),1,fp_input);
    fclose(fp_input);

    for(int i=0;i<2*numOfRanges;i++){
        int first = rangesArray[i*2];
        int last = rangesArray[i*2+1];
        if(first>last) ErrorEnd;
        for(int j=first;j<=last;j++){
            int temp=0;
            for(int k=2;k<=last;k++){
                if(j%k==0){

                    temp++;
                }
            }
            if(temp==1){
                numOfPrime++;
            }
        }
    }

    printf("NUM OF PRIME: %d",numOfPrime);
    fp_output = fopen(argv[3],"wb");
    if(fp_output == NULL){
        ErrorEnd();
    }
    fwrite(&numOfPrime, sizeof(numOfPrime), 1, fp_output);


    return 0;
}
