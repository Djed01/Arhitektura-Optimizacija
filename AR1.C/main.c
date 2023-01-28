#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    FILE *fp_input;
    FILE *fp_output;
    int numOfRanges;
    int numOfPrime = 0;

    fp_input = fopen(argv[1], "rb");

    if (fp_input == NULL)
    {
        printf("Greska sa ulaznim fajlom!");
        return -1;
    }

    size_t itemsRead = fread(&numOfRanges, sizeof(int), 1, fp_input);
    if ( itemsRead != 1)
    {
        printf("Greska sa ulaznim fajlom!");
        return -1;
    }

    int *rangesArray = (int *)calloc(2 * numOfRanges, sizeof(int));

    size_t itemsRead2 = fread(rangesArray, sizeof(int), numOfRanges * 2, fp_input);
    if ( itemsRead2 != numOfRanges*2)
    {
        printf("Greska sa ulaznim fajlom!");
        return -1;
    }
    fclose(fp_input);

    for (int i = 0; i < numOfRanges; i++)
    {
        int first = rangesArray[i * 2];
        int last = rangesArray[i * 2 + 1];
        // printf("%d first:%d last:%d\n",i,first,last);
        if (first > last)
        {
            printf("Greska sa ulaznim fajlom!");
            return -1;
        }
        for (int j = first; j <= last; j++)
        {
            if (j != 1)
            {
                int temp = 0;
                for (int k = 2; k <= j / 2; k++)
                {
                    if (j % k == 0)
                    {
                        temp++;
                    }
                }
                if (temp == 0)
                {
                    numOfPrime++;
                }
            }
        }
    }

    // printf("NUM OF PRIME: %d",numOfPrime);
    fp_output = fopen(argv[2], "wb");
    if (fp_output == NULL)
    {
       printf("Greska sa ulaznim fajlom!");
       return -1;
    }
    fwrite(&numOfPrime, sizeof(int), 1, fp_output);

    return 0;
}
