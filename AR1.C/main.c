#include <stdio.h>
#include <stdlib.h>

int ErrorEnd(){
    printf("Greska sa ulaznim fajlom!");
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
        ErrorEnd();
    }

    fread(&numOfRanges,sizeof(int),1,fp_input);

    int rangesArray[2*numOfRanges];

    fread(rangesArray,sizeof(int),numOfRanges*2,fp_input);
    fclose(fp_input);

    for(int i=0;i<numOfRanges;i++){
        int first = rangesArray[i*2];
        int last = rangesArray[i*2+1];
        printf("%d first:%d last:%d\n",i,first,last);
        if(first>last) ErrorEnd();
        for(int j=first;j<=last;j++){
            int temp=0;
            for(int k=2;k<=last;k++){
                if(j%k==0){
                    temp++;
                }
            }
            if(temp==1){
               // printf("%d \n",j);
                numOfPrime++;
            }
        }
    }

    printf("NUM OF PRIME: %d",numOfPrime);
    fp_output = fopen(argv[2],"wb");
    if(fp_output == NULL){
        ErrorEnd();
    }
    fwrite(&numOfPrime, sizeof(int), 1, fp_output);


    return 0;
}
