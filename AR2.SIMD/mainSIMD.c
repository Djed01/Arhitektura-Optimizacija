#include <stdio.h>
#include <stdlib.h>
#include <x86intrin.h>
#include <stdbool.h>

int ErrorEnd(){
    printf("Greska sa ulaznim fajlom!");
    return -1;
}

_Bool isItPrime(int num){
    __m128 number = _mm_setr_ps((float)num, (float)num, (float)num, (float)num);
    int numOfIterations = (num/2)-1; // idemo do n/2 i ne racunamo 1
    int initialIterations = numOfIterations/4; //Broj inicijalnih iteracija
    int processingIterations = numOfIterations%4; //Ostatak za obraditi

    if(num == 1) {
        return false; //Ako je 1 nije prost
    }

    __m128 maska = _mm_setr_ps(0.0f, 0.0f, 0.0f, 0.0f); // Postavljamo masku na 0,0,0,0
    float temp = 2; //Pomocni brojac od 2 do n
    int counter=0;
    if(initialIterations != 0){
    for(int i = 0; i<initialIterations;i++){
        __m128 iterationPair = _mm_setr_ps(temp++, temp++, temp++, temp++); //Iteration pair npr. (2,3,4,5)

        __m128 result = _mm_div_ps(number, iterationPair); //Dijelimo dobili smo rezultat sa zarezom

       __m128i integerResult = _mm_cvttps_epi32(result); //Pretvramo u integer (bez zareza)
       __m128 floatResult = _mm_cvtepi32_ps(integerResult); //Vracamo u float
        result = _mm_sub_ps(result, floatResult); //Oduzimamo sa zarezom i bez
        
        result = _mm_cmpeq_ps(result, maska); //Poredimo sa maskom (ako je 0 razliciti su inace su isti)
        float temp[4];
         _mm_store_ps(temp, result);
         for(int j=0;j<4;j++){
            if(temp[j]!=0.0f){ //Ako je prilikom oduzimanja rezultat bio 0 znaci da je djeljiv pa povecavamo borojac
                counter++;
            }
         }
    }
    }

    float processingTemp[4]; //Pomocni niz za obradu preostalih
    for(int i=0;i<processingIterations;i++){
        processingTemp[i] = temp++;
    }
    //Opet ista prica
    __m128 processingPair = _mm_load_ps(processingTemp); //Ucitavamo par
    __m128 processingResult = _mm_div_ps(number, processingPair); //Dijelimo
    __m128i integerResult = _mm_cvttps_epi32(processingResult); //Pretvaramo u int
    __m128 floatProcessingResult = _mm_cvtepi32_ps(integerResult); //Vracamo u float
    processingResult = _mm_sub_ps(processingResult, floatProcessingResult); //Oduzimamo 
    processingResult = _mm_cmpeq_ps(processingResult, maska); //Poredimo sa maskom
    float tempArray[4];
    _mm_store_ps(tempArray, processingResult);

    for(int j=0;j<processingIterations;j++){
        if(tempArray[j]!=0.0f){
            counter++;
        }
    }
    if(counter==0){ //Ako je brojac 0 znaci da je prost
       // printf("%d\n",num);
        return true;
    }else{
        return false;
    }
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
        if(first>last) ErrorEnd();
        for(int j=first;j<=last;j++){
            if(isItPrime(j)){
                numOfPrime++;
            }
        }
    }

   // printf("NUM OF PRIME: %d\n",numOfPrime);
    fp_output = fopen(argv[2],"wb");
    if(fp_output == NULL){
        ErrorEnd();
    }
    fwrite(&numOfPrime, sizeof(int), 1, fp_output);


    return 0;
}

